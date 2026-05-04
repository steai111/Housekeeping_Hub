#!/bin/bash

cd ~/AI_SYSTEMS/San_Felicissimo/Housekeeping_Hub

echo "=== DAILY SNAPSHOT START ==="

python3 -m app.main

echo "=== GIT PUSH START ==="

git add .
git commit -m "auto daily snapshot $(date '+%Y-%m-%d %H:%M:%S')"
git push

echo "=== DONE ==="
