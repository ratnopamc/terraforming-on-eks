# How to deploy StableDiffusion on Inference2 and EKS

# TODO 

## Pre-requisites


## Step 1: Deploy RayServe Cluster

To deploy the RayServe cluster with `Stable Diffusion` LLM on `Inf2.24xlarge` instance, run the following command:

**IMPORTANT NOTE: RAY MODEL DEPLOYMENT CAN TAKE UPTO 8 TO 10 MINS**

```bash

```

This will deploy a RayServe cluster with two `inf2.48xlarge` instances. The  LLM will be loaded on both instances and will be available to serve inference requests.

Once the RayServe cluster is deployed, you can start sending inference requests to it. To do this, you can use the following steps:

## Build the docker image for Inference script

```
#login
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/r8y1i9f8

#build
docker buildx build --platform=linux/amd64 -t doeks:latest examples/ray-serve/stable-diffusion-inf2

#tag
docker tag doeks:latest public.ecr.aws/r8y1i9f8/doeks:latest

#push
docker push public.ecr.aws/r8y1i9f8/doeks:latest

```


Get the NLB DNS Name address of the RayServe cluster. You can do this by running the following command:

```bash
kubectl get ingress -A
```

Now, you can access the Ray Dashboard from the URL Below

    http://<NLB_DNS_NAME>/dashboard/#/serve

## Step 2: To Test the Llama2 Model

To test the Llama2 model, you can use the following command with a query added at the end of the URL.
This uses the GET method to get the response:

   


You will see an output like this in your browser:


