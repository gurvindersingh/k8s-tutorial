# k8s-tutorial
Repo to hold contents for kubernetes tutorial for NeIC AHM 2017 meeting.

##Tl;dr
* Setup Minikube
* Deploy notebook on local kubernetes cluster
* Access it using NodePort
* Setup kubernetes client with Dataporten authentication to access Main kubernetes cluster
* Deploy same notebook app on the cluster
* Make application available to public interenet with DNS name
* Get SSL cert from Lets Encrypt
* Fault tolerance of our notebook application

## Step 1 - Prerequiste 
* Git
* Virtualbox
* Kubectl
* Minikube

For Git and [Virtualbox](https://www.virtualbox.org/wiki/Downloads), I assume it will be installed using usual package installation tools or their corresponding webpages.

### Kubernetes client
Get the `kubectl` client to deploy application on kubernetes cluster.

For MAC OSX (amd64)
```
wget -qO - https://storage.googleapis.com/kubernetes-release/release/v1.5.1/kubernetes-client-darwin-amd64.tar.gz | tar zxf - && sudo mv kubernetes/client/bin/kubectl /usr/local/bin
```
For Linux (amd64)
```
wget -qO - https://storage.googleapis.com/kubernetes-release/release/v1.5.1/kubernetes-client-linux-amd64.tar.gz| tar zxf - && sudo mv kubernetes/client/bin/kubectl /usr/local/bin
```

make sure you are able to run `kubectl help`

### Minikube Setup
Make sure your **Virtualbox** setup is working before starting with `minikube`. Install the `minikube` to have a local kubernetes cluster.

For MAC OSX (amd64)
```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.14.0/minikube-darwin-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
```
For Linux (amd64)
```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.14.0/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
```

now you must be able to run `minikube help`. To avoid network congestion during tutorial, run these commands to download iso images and other dependencies.
```
minikube start (it will take some time to finish)
minikube stop
```

## Step 2 - Local deployment

### Deploy notebook to local kubernetes

Since we have working kubernetes client, lets deploy our notebook app to kubernetes cluster. Before deploying the app, you should choose a name which is unique for your instance of app e.g. <ola> and run the following command
```
APPNAME=ola ./name-fix.sh
```
Once done, lets see if we are connected to our local kubernetes cluster
```
kubectl get nodes
```
Now, let's deploy our app
```
kubectl apply -f nb-dep.yaml
```
Now you should be able to see the pod with your app name is being scheduled and running
```
kubectl -n tutorial get pods -l app=<APPNAME>
```
To see the more details about pod, run the command
```
kubectl -n tutorial describe pod -l app=<APPNAME>
```
### Access our notebook from local kubernetes

To access our running notebook, we need to create a service.
```
kubectl apply -f nb-local.yaml
```
This will expose our notebook on port 32000. To get the IP of the local kubernetes cluster, run
```
minikube ip
```
Now we can access our running notebook by opening url `http://<minikubeip>:32000`

## Step 3- Cluster Deployment

### Kubernetes server configuration
We need to get `kubectl` config file with authentication token for our main kubernetes cluster. To authenticate ourselves and get the credentials, go to this webpage in your browser `https://login.ioudaas.no`  and authenticate using either your own insitution sign or social e.g. twitter,linkedin.

Download the config file and place it under your home directory as `~/.kube/config`. After this you should be able to run the command and get output as
```
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"5", GitVersion:"v1.5.1", GitCommit:"82450d03cb057bab0950214ef122b67c83fb11df", GitTreeState:"clean", BuildDate:"2016-12-22T13:56:59Z", GoVersion:"go1.7.4", Compiler:"gc", Platform:"darwin/amd64"}
Server Version: version.Info{Major:"1", Minor:"5", GitVersion:"v1.5.1+coreos.0", GitCommit:"cc65f5321f9230bf9a3fa171155c1213d6e3480e", GitTreeState:"clean", BuildDate:"2016-12-14T04:08:28Z", GoVersion:"go1.7.4", Compiler:"gc", Platform:"linux/amd64"}
```

### Deploy a demo app to kubernetes

Since we have working kubernetes client, lets deploy our notebook app to kubernetes cluster, following same way as in Step 2. 
```
kubectl apply -f nb-dep.yaml
```
Now you should be able to see the pod with your app name is being scheduled and running
```
kubectl -n tutorial get pods -o wide -l app=<APPNAME>
```
To see the more details about pod, run the command
```
kubectl -n tutorial describe pod -l app=<APPNAME>
```

### Expose the app to internet
As our application is running, we can expose it out to public internet with a DNS name created for us automatically for our app. 
```
kubectl apply -f nb-ing.yaml
```
Now you should be able to access the app by going to url `http://<APPNAME>.tutorial.ioudaas.no`. The webpage from app can take a minute or so, due to ingress controller updating its configuration.

### SSL certificate for app
With support from Let's Encrypt, we can get SSL certificate (using staging LE, to avoid rate limit) automatically for our application. To do that apply the updated ingress file as
```
kubectl apply -f nb-ing-ssl.yaml
```
It might take a minute or so before we get our SSL certificate. Once successful, when you access your webpage or reload it, you should see automatic redirection to `https`. You will see the warning, as we currently we are using staging Let's entcrypt certificate authority to avoid rate limit.

### Fault tolerance

Kubernetes keeps track of the running application using liveness check and deployment replica count. If for some reason application is down, it will automatically start a new instance of our app. To simulate the failure, delete the running pod
```
kubectl -n tutorial delete pod -l app=<APPNAME>
```
Now if you try to access, your notebook instance it will be down. Let´s look at the deployment object and see what it shows as number of replicas.

```
kubectl -n tutorial get deployment -l app=<APPNAME>
```
You will see that Kubernetes has detected the number of `Available` pods are not what is `Desired`. So lets do a watch on the pod status, you will see that kubernetes has scheduled a new instance automatically.
```
kubectl -n tutorial get pod -w -l app=<APPNAME>
```
Once pod status changed to running with in a minute you will be able to access the notebook app again.