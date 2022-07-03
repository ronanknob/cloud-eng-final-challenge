# cloud-eng-final-challenge
Final Challenge of Cloud Data Engineer course by IGTI


# Testing this project:
The main purpose of this project was create the essential infrastructure to run the task. Is possible to reproduce my results, following the steps below to configure and run the services correctly.

## Creating the cluster
1. Create your keypair in Amazon EC2 console [see this link](https://docs.aws.amazon.com/servicecatalog/latest/adminguide/getstarted-keypair.html) and choose .pem key when asked. Save the key and move to kubernetes folder in this project folder. 
2. Change the keypair name on the cluster_config.yaml file.
3. Configure your AWS connection locally using the command `aws configure` [more information](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
4. Change the --profile parameter to your AWS profile (if you haven't set a name for the profile, you can remove the parameter and in this case will use the default one).
5. Execute the command `eksctl create cluster -f cluster_config.yaml --profile pos-igti --alb-ingress-access --color=fabulous`. It will create a cluster with 3 spot instances in a EKS cluser
6. Check with `kubectl get nodes`

## Creating the namespace processing
1. kubectl create namespace processing
2. Check with `kubectl kubectl get namespaces`

## Storing AWS credentials as a Kubernet secret
1. kubectl create secret generic aws-credentials --from-literal=aws_access_key_id=YOURACCESSKEY --from-literal=aws_secret_access_key=YOURSECRETAK -n processing
2. Check with `kubectl describe secret aws-credentials -n processing`

## Deploying SparkOperator
1. Create a repository in Dockerhub
2. Mount the image spark using `docker build -t yourrepo/imagename .`
3. Push the image to Dockerhub
4. kubectl create serviceaccount spark -n processing
5. kubectl create clusterrolebinding spark-role-binding --clusterrole=edit --serviceaccount=processing:spark -n processing
6. helm repo add spark-operator https://googlecloudplatform.github.io/spark-on-k8s-operator
7. helm repo update
8. helm install spark spark-operator/spark-operator -n processing
10. Create a bucket egc-challenge in S3
11. Create a folder spark-jobs inside the bucket
12. Upload the file spark-convert-enem-2020.py to spark-jobs folder
13. Deploy the manifest: `kubectl apply -f spark-convert-enem-manifest.yaml -n processing`
14. Check the execution with `kubectl get pods -n processing --watch`. If a exec or other container get stuck in status Pending for a long time, check if is a problem with container with `kubectl logs spark-convert-enem-data-driver -n processing`

## Deploying Airflow
1. helm repo add apache-airflow https://airflow.apache.org
2. helm upgrade --install airflow apache-airflow/airflow --namespace airflow --create-namespace
3. Not necessary command - In kubernetes folder execute `helm show values apache-airflow/airflow > airflow/myvalues.yaml`
4. Create folder airflow-logs in S3 and put the path in airflow values file
5. Persist values with `helm upgrade --install airflow apache-airflow/airflow -f airflow/myvalues.yaml -n airflow --debug`
6. Validate with `kubectl get pods -n airflow`
7. Get the Airrflow DNS with `kubectl get svc -n airflow`
8. Acess dns via browser.

Obs:
* If you want to get updated airflow values execute in kubernetes folder: `helm show values apache-airflow/airflow > airflow/myvalues.yaml` (custom customizations will be ovewritten)


## Run Airflow DAG