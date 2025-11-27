# Triton is a tool for AI/ML workloads.

- model serving
- makes a trained model available so other apps can use it.
- Depends on : Model repository and batching 
- Model repo - how does it work ?
   - needs explicit folder structure 
   - done automatically
   - no need of writing code 
   - config.pbxt : input, output and batch size 
- makes inference aka prediction faster 
- lowers cost so GPU gets utilized efficiently 
- reduces GPU idle time


### Dynamic batching : Dynamic batching gives you BOTH low latency AND high GPU throughput.
Not all requests arrive at the same time.
If Triton waits for a full batch, it increases latency.
If Triton runs each request individually, it reduces GPU efficiency.
Dynamic batching solves this by doing smart batching on the fly.

### Multiple models on a single GPU 
GPUs are powerful — most real workloads don't use 100% of the GPU.
- Running only ONE model wastes GPU capacity.
- parallel execution
- automatic distribution of traffic
- maximizing GPU usage

⭐ Key point:
You get more performance per GPU → lower cost per inference.

### Why version folders matter
better accuracy
retraining
bug fixes
new data
avoid breaking production.

solution : 
✔️ You can load multiple versions of the same model
✔️ Traffic can target a specific version
✔️ Or Triton can auto-pick the "latest" one
✔️ You can roll back instantly
 - ⭐ Key point:
Versions allow safe updates, A/B testing, and easy rollback.

### How Triton routes traffic to correct models
http request : POST /v2/models/resnet/versions/2/infer
Triton guarantees the right model handles the right request, even with multiple versions and multiple models loaded.

## Triton Model Serving: 
### 3.1 . Package ONNX Model (ResNet50 or MobileNet)
 - config.pbtxt - protobuff style config file - important 
 - define model metadata in the pbtxt file.
 - batching, GPU acceleration, and correct tensor formatting — all critical for production-grade inference.

### 3.2 - Create Dockerfile - commands are in Makefile (automation)
 - build image locally 
 - Create ECR Repository (One-Time)
 - Tag and Push to ECR
 - triton/Makefile.triton : 
 -usage :
 ```
 cd triton
make push-triton
```
- note : to push triton model to ECR repo you need aws credentials. do not hardcode anything in files.
- create a .env file in the /triton folder with credentials 
- " make check-env " to verify your environment before pushing.
- " make push-triton "  - this will not expose any credentials

✅ Result
You now have a custom Triton image in ECR that:
Serves your ONNX model
Runs on GPU nodes
Deploys cleanly via Helm or YAML
Can be versioned, reused, and torn down easily

### 3.3: Deploy Triton via Helm (GPU + Probes) 
 - deploy via helm for easy teardown - helm unistall
 - Scalable: Add replicas, autoscaling, and metrics later
 
 ### Manual method of deploying triton via helm
 - Add Helm Repo (if using NVIDIA’s chart) 

 ```
 helm repo add nvcr https://helm.ngc.nvidia.com/nvcr
helm repo update
```
- triton/helm/values.yaml 
-  deploy via helm: 
```
helm upgrade --install triton-infer nvcr/triton-inference-server \
  --namespace triton \
  --create-namespace \
  -f triton/helm/values.yaml
```

- verify deployment: 
```
kubectl get pods -n triton
kubectl describe pod <triton-pod-name> -n triton | grep nvidia.com/gpu
```

- teardown: 
```
helm uninstall triton-infer -n triton
```
Resuls: 
Deployed Triton on GPU nodes using your custom ECR image, with health probes, node targeting, and teardown hygiene — all via Helm.

#### Automated deployment via Make utility
 - make deploy-triton (Add and update the Helm repo) 
 - make destroy-triton

### step 3.4 Smoke test inference endpoint: 

 #### Helm + Port-Forward + Scripted Smoke Test
This smoke test confirms that your Triton server is:
 - Running on GPU nodes
 - Serving your ONNX model correctly
 - Accepting and responding to inference requests

#### Manual method step-by-step smoke test
1. Port-forward Triton service
```
kubectl port-forward svc/triton-infer 8000:8000 -n triton
```

2. Prepare input.json ( run script triton/generate-input.py)
3. Send Inference Request
```
curl -X POST http://localhost:8000/v2/models/resnet50/infer \
  -H "Content-Type: application/json" \
  -d @input.json
```

4. Confirm GPU Usage (Optional)
```
kubectl exec -it <triton-pod> -n triton -- nvidia-smi
```
#### Automated smoke test
make smoke-test



#==================metadata from inference server===================

ubuntu@ip-172-31-79-152:pwd
/home/ubuntu/triton-mlops-gpu-platform
ubuntu@ip-172-31-79-152:docker run --rm --gpus all \
  -p8000:8000 -p8001:8001 -p8002:8002 \
  -v /home/ubuntu/triton-mlops-gpu-platform/services/triton/models:/models \
  nvcr.io/nvidia/tritonserver:24.01-py3 \
  tritonserver --model-repository=/models --strict-model-config=false

=============================
== Triton Inference Server ==
=============================

NVIDIA Release 24.01 (build 80100513)
Triton Server Version 2.42.0

Copyright (c) 2018-2023, NVIDIA CORPORATION & AFFILIATES.  All rights reserved.

Various files include modifications (c) NVIDIA CORPORATION & AFFILIATES.  All rights reserved.

This container image and its contents are governed by the NVIDIA Deep Learning Container License.
By pulling and using the container, you accept the terms and conditions of this license:
https://developer.nvidia.com/ngc/nvidia-deep-learning-container-license

Warning: '--strict-model-config' has been deprecated! Please use '--disable-auto-complete-config' instead.
I1127 05:39:31.423818 1 pinned_memory_manager.cc:275] Pinned memory pool is created at '0x7d874a000000' with size 268435456
I1127 05:39:31.425636 1 cuda_memory_manager.cc:107] CUDA memory pool is created on device 0 with size 67108864
I1127 05:39:31.428902 1 model_lifecycle.cc:461] loading: resnet50:1
I1127 05:39:31.431244 1 onnxruntime.cc:2610] TRITONBACKEND_Initialize: onnxruntime
I1127 05:39:31.431264 1 onnxruntime.cc:2620] Triton TRITONBACKEND API version: 1.17
I1127 05:39:31.431269 1 onnxruntime.cc:2626] 'onnxruntime' TRITONBACKEND API version: 1.17
I1127 05:39:31.431274 1 onnxruntime.cc:2656] backend configuration:
{"cmdline":{"auto-complete-config":"true","backend-directory":"/opt/tritonserver/backends","min-compute-capability":"6.000000","default-max-batch-size":"4"}}
I1127 05:39:31.450095 1 onnxruntime.cc:2721] TRITONBACKEND_ModelInitialize: resnet50 (version 1)
W1127 05:39:31.841427 1 onnxruntime.cc:815] autofilled max_batch_size to 4 for model 'resnet50' since batching is supporrted but no max_batch_size is specified in model configuration. Must specify max_batch_size to utilize autofill with a larger max batch size
I1127 05:39:31.849204 1 onnxruntime.cc:2786] TRITONBACKEND_ModelInstanceInitialize: resnet50_0 (GPU device 0)
I1127 05:39:32.137481 1 model_lifecycle.cc:827] successfully loaded 'resnet50'
I1127 05:39:32.137562 1 server.cc:606] 
+------------------+------+
| Repository Agent | Path |
+------------------+------+
+------------------+------+

I1127 05:39:32.137631 1 server.cc:633] 
+-------------+-----------------------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Backend     | Path                                                            | Config                                                                                                                                                        |
+-------------+-----------------------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------+
| onnxruntime | /opt/tritonserver/backends/onnxruntime/libtriton_onnxruntime.so | {"cmdline":{"auto-complete-config":"true","backend-directory":"/opt/tritonserver/backends","min-compute-capability":"6.000000","default-max-batch-size":"4"}} |
+-------------+-----------------------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------+

I1127 05:39:32.137666 1 server.cc:676] 
+----------+---------+--------+
| Model    | Version | Status |
+----------+---------+--------+
| resnet50 | 1       | READY  |
+----------+---------+--------+

I1127 05:39:32.166102 1 metrics.cc:877] Collecting metrics for GPU 0: Tesla T4
I1127 05:39:32.172044 1 metrics.cc:770] Collecting CPU metrics
I1127 05:39:32.172232 1 tritonserver.cc:2498] 
+----------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Option                           | Value                                                                                                                                                                                                           |
+----------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| server_id                        | triton                                                                                                                                                                                                          |
| server_version                   | 2.42.0                                                                                                                                                                                                          |
| server_extensions                | classification sequence model_repository model_repository(unload_dependents) schedule_policy model_configuration system_shared_memory cuda_shared_memory binary_tensor_data parameters statistics trace logging |
| model_repository_path[0]         | /models                                                                                                                                                                                                         |
| model_control_mode               | MODE_NONE                                                                                                                                                                                                       |
| strict_model_config              | 0                                                                                                                                                                                                               |
| rate_limit                       | OFF                                                                                                                                                                                                             |
| pinned_memory_pool_byte_size     | 268435456                                                                                                                                                                                                       |
| cuda_memory_pool_byte_size{0}    | 67108864                                                                                                                                                                                                        |
| min_supported_compute_capability | 6.0                                                                                                                                                                                                             |
| strict_readiness                 | 1                                                                                                                                                                                                               |
| exit_timeout                     | 30                                                                                                                                                                                                              |
| cache_enabled                    | 0                                                                                                                                                                                                               |
+----------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

I1127 05:39:32.173421 1 grpc_server.cc:2519] Started GRPCInferenceService at 0.0.0.0:8001
I1127 05:39:32.173675 1 http_server.cc:4623] Started HTTPService at 0.0.0.0:8000
I1127 05:39:32.214706 1 http_server.cc:315] Started Metrics Service at 0.0.0.0:8002

#===================curl test======================

00/v2/models/resnet50
{"name":"resnet50","versions":["1"],"platform":"onnxruntime_onnx","inputs":[{"name":"data","datatype":"FP32","shape":[-1,3,224,224]}],"outputs":[{"name":"resnetv24_dense0_fwd","datatype":"FP32","shape":[-1,1000]}]}gpu-ec2-->

