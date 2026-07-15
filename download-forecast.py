import os
import sys
import datetime
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed

import shutil

# Settings
HOURS_BACK = 12
HOURS_FWD = 72
INTERVAL_HOURS = 1
MAX_WORKERS = 8  # Number of parallel download workers

def download_task(task):
    source, date_str, time_str, filename, is_current, suffix = task
    base_dir = f"./data/{source}/{date_str}"
    os.makedirs(base_dir, exist_ok=True)
    
    url = f"https://gaia.nullschool.net/data/{source}/{date_str}/{filename}"
    local_path = f"{base_dir}/{filename}"
    
    # We always override as per previous requirement
    # but we can add a small log for start
    # print(f"Starting {filename}...")
    
    cmd = [
        "curl", "-s", "--cookie-jar", "cookies.txt",
        "--header", "Host: gaia.nullschool.net",
        "--header", "referer: https://earth.nullschool.net/",
        "--compressed", "-L",
        url, "--output", local_path
    ]
    
    result = subprocess.run(cmd, capture_output=True)
    if result.returncode == 0:
        msg = f"Successfully downloaded {filename}"
        if is_current:
            try:
                current_dir = f"./data/{source}/current"
                os.makedirs(current_dir, exist_ok=True)
                current_path = f"{current_dir}/current-{suffix}"
                shutil.copy2(local_path, current_path)
                msg += " (and updated current)"
            except Exception as e:
                msg += f" (failed to update current: {e})"
        return msg
    else:
        return f"Failed to download {filename}: {result.stderr.decode()}"

def cleanup_old_files(threshold_time):
    """Remove files older than threshold_time and prune empty directories."""
    print(f"\nCleaning up files older than 1 day ({threshold_time.strftime('%Y/%m/%d %H:%M')} UTC)...")
    count = 0
    for source in ["gfs", "cams"]:
        base_path = f"./data/{source}"
        if not os.path.exists(base_path): continue
        for root, dirs, files in os.walk(base_path, topdown=False):
            for name in files:
                if name.endswith(".epak"):
                    # Expected root: ./data/{source}/YYYY/MM/DD
                    # name: HH00-suffix
                    rel_path = os.path.relpath(root, base_path)
                    if rel_path == "current": continue
                    try:
                        # Reconstruct date from path and filename
                        file_dt_str = f"{rel_path}/{name[:4]}"
                        file_dt = datetime.datetime.strptime(file_dt_str, "%Y/%m/%d/%H%M")
                        if file_dt < threshold_time:
                            os.remove(os.path.join(root, name))
                            count += 1
                    except Exception:
                        continue
            # Prune empty directories
            if root != base_path and root != os.path.join(base_path, "current"):
                if not os.listdir(root):
                    try:
                        os.rmdir(root)
                    except OSError:
                        pass
    if count > 0:
        print(f"Removed {count} obsolete data files.")

def main():
    now = datetime.datetime.now(datetime.timezone.utc)
    # Round to nearest hour
    now_rounded = now.replace(minute=0, second=0, microsecond=0)
    start_time = now_rounded - datetime.timedelta(hours=HOURS_BACK)
    end_time = now_rounded + datetime.timedelta(hours=HOURS_FWD)
    
    layers = [
        ("gfs", "wind-surface-level-gfs-0.5.epak"),
        ("gfs", "temp-surface-level-gfs-0.5.epak"),
        ("gfs", "precip_3hr-gfs-0.5.epak"),
        ("gfs", "relative_humidity-surface-level-gfs-0.5.epak"),
        ("gfs", "total_cloud_water-gfs-0.5.epak"),
        ("cams", "pm2p5-cams.epak"),
    ]
    
    tasks = []
    current = start_time
    while current <= end_time:
        date_str = current.strftime("%Y/%m/%d")
        time_str = current.strftime("%H00")
        is_current = (current == now_rounded)
        
        for source, suffix in layers:
            filename = f"{time_str}-{suffix}"
            tasks.append((source, date_str, time_str, filename, is_current, suffix))
        
        current += datetime.timedelta(hours=INTERVAL_HOURS)

    total_tasks = len(tasks)
    print(f"Starting parallel download of {total_tasks} files using {MAX_WORKERS} workers...")
    print(f"Window: {start_time.strftime('%Y/%m/%d %H:%M')} to {end_time.strftime('%Y/%m/%d %H:%M')} UTC\n")

    completed = 0
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        future_to_task = {executor.submit(download_task, task): task for task in tasks}
        for future in as_completed(future_to_task):
            completed += 1
            res = future.result()
            # print(f"[{completed}/{total_tasks}] {res}")
            # For brevity in terminal, just print progress every 10 files
            if completed % 10 == 0 or completed == total_tasks:
                print(f"Progress: {completed}/{total_tasks} files processed")

    # Cleanup phase
    # Keeping 24 hours of history to provide a safe buffer for the 12H slider window
    cleanup_threshold = now_rounded - datetime.timedelta(hours=24)
    cleanup_old_files(cleanup_threshold)
    print(f"\nAll tasks complete.")

if __name__ == "__main__":
    # Ensure we are in project root
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    main()
