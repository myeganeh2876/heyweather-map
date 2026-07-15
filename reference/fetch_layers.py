import re
import requests
from urllib.parse import urljoin

BASE = "https://earth.nullschool.net/"

print(f"Fetching {BASE}...")
html = requests.get(BASE, timeout=30).text

# Find the module bundle path like ./src/main~CDOTJXYJ.js
m = re.search(r'<script[^>]+id="bundle"[^>]+src="([^"]+)"', html)
if not m:
    # Fallback
    m = re.search(r'<script[^>]+src="(\./src/main[^"]+)"', html)

if not m:
    print("Could not find bundle script tag.")
    raise SystemExit(1)

bundle_path = m.group(1)
bundle_url = urljoin(BASE, bundle_path)

print(f"Fetching bundle from: {bundle_url}")
js = requests.get(bundle_url, timeout=30).text

# Strategy 1: Full URLs (unlikely now)
urls = set(re.findall(r'https://gaia\.nullschool\.net/[^"\']+?\.epak', js))

# Strategy 2: File patterns ending in .epak (inside backticks or quotes)
# This captures things like "-wave-30m.epak" or "current-wind...epak"
patterns = set(re.findall(r'[`\'"]([^`\'"]+?\.epak)[`\'"]', js))

print(f"\nBundle: {bundle_url}")
print(f"Found {len(urls)} explicit URLs")
print(f"Found {len(patterns)} .epak patterns/suffixes\n")

all_hits = sorted(urls | patterns)

for u in all_hits:
    print(u)
