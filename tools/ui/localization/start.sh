#!/usr/bin/env bash
set -e

pkill -9 -f llama-server || true
sleep 3

LD_LIBRARY_PATH=/home/it/translate/llama.cpp/build/bin \
/home/it/translate/llama.cpp/build/bin/llama-server \
  -m /home/it/models/medgemma-4b-it-Q4_K_M.gguf \
  --host 0.0.0.0 --port 8081 &
