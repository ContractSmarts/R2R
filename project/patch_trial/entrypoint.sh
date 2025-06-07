#!/bin/bash
echo "🔁 Live patching orchestration config and hatchet provider..."
cp /patches/orchestration.py /app/core/base/orchestration.py
cp /patches/hatchet.py /app/core/providers/orchestration/hatchet.py
exec "$@"