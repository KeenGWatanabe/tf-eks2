code source
https://spacelift.io/blog/terraform-eks

# terraform eks
terraform init
terraform apply

# connect with kubectl
aws eks --region us-east-1 update-kubeconfig --name example

# check log in to cluster
kubectl config current-context

# view running nodes
kubectl get nodes
# node details
kubectl get nodes -o custom-columns=Name:.metadata.name,nCPU:.status.capacity.cpu,Memory:.status.capacity.memory

# deploy nginx instance
kubectl run --port 80 --image nginx nginx

# view running pods
kubectl get pods

# setup a tunnel to this pod
kubectl port-forward nginx 3000:80