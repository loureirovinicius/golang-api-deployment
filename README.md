# Description

This project aims to have an API to mess around with DevOps tools and concepts, like cloud providers, IaC, containers, CI/CD pipelines, automation, etc. You can do everything you want with this project; just clone it and use your creativity.
I highly recommend you review the docs to see the project limitations and what you can take as your next step.
Since I'm doing things according to my free time, some features might not be available yet, but I'm looking forward to delivering them so the project can become complete (I'll leave a To Do list so you can know the next steps). Also, you're free (and I appreciate it) to contribute with new features, bug corrections and optimizations; just leave your PR, and I'll read it ASAP.

**TODO:**
- Go tests;
- CD pipeline;
- Infrastructure pipeline (maybe?);
- Basic observability;

## This project contains:

- A Golang API that connects to Postgres;
- A Dockerfile so you can create your own personalized image;
- Docker Compose file to run everything with a single command;
- Files to deploy it to a local Minikube cluster (you may also use "kind");
- Terraform files to deploy a GKE cluster;
- Files to deploy the API to your GKE cluster;
- Automated scripts to generate files and configurations;
- A CI pipeline (unit tests, build, integration test and pushing image to registry);

## Program Requirements:

- [Go](https://go.dev/dl/) (for running locally);
- [Docker](https://docs.docker.com/engine/install/ubuntu/) (for running with Docker Compose, building the Dockerfile or running a local cluster);
- [Kubectl](https://kubernetes.io/docs/tasks/tools/) (for running a Kubernetes cluster);
- [Minikube](https://kubernetes.io/docs/tasks/tools/) (for running in a local cluster);
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) (for running in a GCP cluster);
- [gcloud CLI](https://cloud.google.com/sdk/docs/install?hl=pt-br) (for running in a GCP cluster);


## Configuration Requirements:

1. Rename the *.env.example* file to *configs.env*;
2. According to your configuration, set values for each key present in the file;
3. Run the *configs.sh* script inside *scripts/* so you can generate all the necessary files for running the application in different environments;

**OBS.:** If you're planning to run it locally (not using Docker), you must set the "HOST" value as "localhost".

## Environments:

### Using Go to run it:

1. Make sure you have set the *configs.env* file;

2. Run a Postgres container mapping your sql scripts folder to the container entry point so it can run all the necessary queries:

        docker run -d -p 5432:5432 -e POSTGRES_PASSWORD=admin --mount type=bind,source=$(pwd)/sql,target=docker-entrypoint-initdb.d postgres:13-alpine

3. Run the application:

        go run main.go
  
4. Check if it worked (should return "null"):

        curl http://localhost:9000/
  
### Using Docker Compose to run it:

1. Make sure you have set the *configs.env* file;

2. Install Docker;

3. Run the application using Docker Compose (you must be at the same level as the *compose.yaml* file):

       docker compose up

4. Test it:

       curl http://localhost:9000/

### Using Minikube:

1. Make sure you have set the *configs.env* file;

2. Install Docker, Minikube and kubectl;

3. Start your cluster:

        minikube start

4. Apply the YAMLs responsible for running the application:

        kubectl apply -f kubernetes/local-cluster/

5. Get your node IP:

        NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')

6. Check if it's working:

        curl http://${NODE_IP}:30001/

### Using GKE cluster:

1. Make sure you have set the *configs.env* file;

2. Install Terraform, kubectl, gcloud CLI;

3. Authenticate to your GCP account:

        gcloud init

4. Set default credentials for resources creation:

        gcloud auth application-default login

5. Use one of the following approaches to define your GCP project, region, zone and service account (you are free to change the zone and region specified in the env variable):

    - On *terraform/terraform.tfvars*:

            gcp_configs = {
              project = ""
              region = ""
              zone = ""
              service_account_email = ""
            }

    - On CLI (recommended):
    
            export PROJECT=$(gcloud config get-value project); \
            export SERVICE_ACCOUNT_EMAIL=$(gcloud iam service-accounts list --project=${PROJECT} --format "value(email)"); \
            export REGION="us-central1"; \
            export ZONE="us-central1-a"; \
            export TF_VAR_gcp_configs="{project=\"$PROJECT\",region=\"$REGION\",zone=\"$ZONE\",service_account_email=\"$SERVICE_ACCOUNT_EMAIL\"}"
        
8. Download all necessary Terraform providers:

        terraform init

7. Check your infrastructure:

        terraform plan

8. If everything is ok, apply it and wait for its creation:

        terraform apply

9. Download the following gcloud CLI plugin so you can connect to your cluster:

        sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin

10. Configure your kubeconfig to communicate with your GKE environment:

        CLUSTER_NAME=$(gcloud container clusters list --format "value(name)"); gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION --project $PROJECT

11. Run the application in your cluster:

        kubectl apply -f kubernetes/cloud-provider/

- By default, the method to reach this API from the internet is through an ingress rule. If you're not using it, create a NodePort or LoadBalancer service to expose it to the internet. The following parts are dedicated to applying the Ingress object.

12. (Optional) Run *scripts/ingress.sh* to generate the Ingress YAML:

        sh scripts/ingress.sh

13. (Optional) Apply the YAML and wait until it gets ready:

        kubectl apply -f kubernetes/cloud-provider/ingress.yaml