#!/bin/bash
# start-server.sh
# Starts a simple HTTP server using Python 3 on port 8000

cd "$(dirname "$0")"

PORT=8080

echo "Starting Earth AE Local Server on http://localhost:$PORT"
echo "Press Ctrl+C to stop the server"

python3 -m http.server $PORT
