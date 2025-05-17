# -- 
This app is configured to run in a Docker based Kubernetes.

Run the below commands to build the docker image and deploy the application to Kubernetes cluster.

# -- Commands
`docker build -t aiqx-g05:local .`
`kubectl apply -f .`
`kubectl get deployment,svc -n aiqx`