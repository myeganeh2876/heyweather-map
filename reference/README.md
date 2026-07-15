# reference/

Developer/inspection material. **Not used by the app at runtime.**

- **`main_remote.js`** — a copy of nullschool's live remote bundle, kept for diffing against the local `js/bundle.js` when porting changes.
- **`fetch_layers.py`** — scrapes the live nullschool bundle to discover the current `.epak` URL patterns / layer suffixes. Requires the `requests` package (`pip install requests`).
