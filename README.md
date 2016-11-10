# k8s-tutorial
Repo to hold contents for kubernetes hands on tutorial.

## Step 1
Get the `kubectl` client to deploy application on kubernetes cluster.

For MAC OSX (amd64)
```
wget https://storage.googleapis.com/kubernetes-release/release/v1.4.5/kubernetes-client-darwin-amd64.tar.gz
```

For Linux (amd64)
```
wget https://storage.googleapis.com/kubernetes-release/release/v1.4.5/kubernetes-client-linux-amd64.tar.gz
```

For Windows (amd64)
```
wget https://storage.googleapis.com/kubernetes-release/release/v1.4.5/kubernetes-client-windows-amd64.tar.gz
```

Untar this make sure you are able to run `kubectl`

## Kubernetes server configuration
We need to authenticate ourselves to get the credentials and also download the kubeconfig with details to connect to our kubernetes server. Go to this webpage in your browser `https://login.ioudaas.no`

Download the config file and place it under your home directory as `~/.kube/config`. After this you should be able to run the command and get output as
```
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"4", GitVersion:"v1.4.3", GitCommit:"4957b090e9a4f6a68b4a40375408fdc74a212260", GitTreeState:"clean", BuildDate:"2016-10-16T06:36:33Z", GoVersion:"go1.7.1", Compiler:"gc", Platform:"darwin/amd64"}

Server Version: version.Info{Major:"1", Minor:"4", GitVersion:"v1.4.3+coreos.0", GitCommit:"7819c84f25e8c661321ee80d6b9fa5f4ff06676f", GitTreeState:"clean", BuildDate:"2016-10-17T21:19:17Z", GoVersion:"go1.6.3", Compiler:"gc", Platform:"linux/amd64"}
```

## Deploy a demo app to kubernetes

Since we have working kubernetes client, lets deploy our app to kubernetes cluster. Before deploying the app, you should choose a name which is unique for your instance of app e.g. <ola-app> and run the following command
```
APPNAME=ola-app ./name-fix.sh
```
Once done, lets deploy our app
```
kubectl apply -f dp1.yaml
```
Now you should be able to see the pod with your app name is being scheduled and running
```
kubectl -n tutorial get pods
```
To see the more details about pod, run the command
```
kubectl -n tutorial describe pod -l app=<appname>
```
Lets access it using port-forward, as currently we have not yet exposed it to internet
```
kubectl port-forward 8080:80 <pod_name>
```
## Expose the app to internet
As our application is running, we can expose it out to public internet with a DNS name created for us already for our app. 
```
kubectl apply -f ingress.yaml
```

Now you should be able to access the app by going to url `http://<appname>.tutorial.ioudaas.no`

## Fault recovery and resilient
Kubernetes

## SSL certificate for app

## Dataporten integeration for app