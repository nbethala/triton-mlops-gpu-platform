# ✅ Start from the full Triton Inference Server image
FROM nvcr.io/nvidia/tritonserver:24.01-py3

# Set working directory inside container
WORKDIR /opt/tritonserver

# Copy your model repository into the container
# (adjust path if your models live elsewhere)
COPY ./services/triton/models /models

# Optional: copy custom configs, scripts, or entrypoints
# COPY ./services/triton/configs /configs

# Expose Triton’s default ports
EXPOSE 8000 8001 8002

# Default command: run Triton with your model repo
CMD ["tritonserver", "--model-repository=/models"]
