# Base NVIDIA Triton image (GPU enabled)
FROM nvcr.io/nvidia/tritonserver:24.01-py3-min

# Where model repositories go inside container
COPY models/ /models/

# Expose Triton ports
EXPOSE 8000 8001 8002

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8000/v2/health/ready || exit 1

# Run Triton
CMD ["tritonserver", "--model-repository=/models", "--strict-model-config=false"]

