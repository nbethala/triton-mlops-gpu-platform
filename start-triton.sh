#!/bin/bash
set -e

MODEL_REPO="/home/ubuntu/triton-mlops-gpu-platform/services/triton/models"
IMAGE="nvcr.io/nvidia/tritonserver:23.08-py3"

echo "Starting Triton Inference Server..."
docker run -it --rm \
  --gpus=all \
  --shm-size=1g \
  --ulimit memlock=-1 \
  --ulimit stack=67108864 \
  -p 8000:8000 \
  -p 8001:8001 \
  -p 8002:8002 \
  -v ${MODEL_REPO}:/models \
  ${IMAGE} tritonserver \
    --model-repository=/models \
    --model-control-mode=none \
    --strict-readiness=true \
    --log-verbose=0 \
    --log-info=1 \
    --log-warning=1 \
    --log-error=1
