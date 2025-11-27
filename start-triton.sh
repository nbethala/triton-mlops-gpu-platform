#!/usr/bin/env bash
set -e

########################################
# Configuration
########################################
MODEL_REPO="/home/ubuntu/triton-mlops-gpu-platform/services/triton/models"
IMAGE="nvcr.io/nvidia/tritonserver:23.08-py3"
MIN_DISK_GB=5

########################################
# Helper Functions
########################################

function check_command() {
  if ! command -v "$1" &> /dev/null; then
    echo "❌ Error: '$1' is not installed. Please install it and retry."
    exit 1
  fi
}

function check_disk_space() {
  FREE_GB=$(df -BG / | awk 'NR==2 {gsub("G",""); print $4}')
  if (( FREE_GB < MIN_DISK_GB )); then
    echo "❌ Error: Not enough disk space. Need ${MIN_DISK_GB}GB free, found ${FREE_GB}GB."
    exit 1
  fi
}

########################################
# System Checks
########################################

echo "🔍 Checking environment..."

check_command docker
check_command nvidia-smi

echo "✔ Docker Installed"
echo "✔ NVIDIA drivers OK (nvidia-smi works)"

########################################
# Check model repository
########################################

if [[ ! -d "$MODEL_REPO" ]]; then
  echo "❌ Model repository not found at: $MODEL_REPO"
  exit 1
fi

echo "✔ Model repository found: $MODEL_REPO"

########################################
# Check disk space
########################################

check_disk_space
echo "✔ Sufficient disk space available"

########################################
# Pull image if not available
########################################

if [[ -z $(docker images -q "$IMAGE") ]]; then
  echo "📦 Triton image not found locally. Pulling..."
  docker pull "$IMAGE"
else
  echo "✔ Triton image already available locally"
fi

########################################
# Start Triton Server
########################################

echo ""
echo "🚀 Starting Triton Inference Server..."
echo "========================================="

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

