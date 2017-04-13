# k8s-tutorial
Repo to hold contents for kubernetes tutorial for NIRD Testing Cluster.

## Tl;dr
* Setup Kubectl
* Setup Kubed
* Get Authentication Token from Dataporten
* Deploy notebook on NIRD testing kubernetes cluster
* Make application available to public interenet with DNS name
* Get SSL cert from Lets Encrypt
* Fault tolerance of our notebook application

## Step 1 - Prerequiste 
* Git
* Kubectl
* Kubed

For Git, I assume it will be installed using usual package installation tools or their corresponding webpages.

### Kubernetes client
Get the `kubectl` client to deploy application on kubernetes cluster.

For MAC OSX (amd64)
```
wget -qO - https://storage.googleapis.com/kubernetes-release/release/v1.5.6/kubernetes-client-darwin-amd64.tar.gz | tar zxf - && sudo mv kubernetes/client/bin/kubectl /usr/local/bin && sudo chmod +x /usr/local/bin/kubectl
```
For Linux (amd64)
```
wget -qO - https://storage.googleapis.com/kubernetes-release/release/v1.5.6/kubernetes-client-linux-amd64.tar.gz| tar zxf - && sudo mv kubernetes/client/bin/kubectl /usr/local/bin && sudo chmod +x /usr/local/bin/kubectl
```

make sure you are able to run `kubectl help`

### Kubed Setup
Kubed is use to manage the authentication with Dataporten and configuration of Kubernetes cluster.

For MAC OSX (amd64)
```
wget -qO - https://github.com/UNINETT/kubed/releases/download/0.1.4/kubed-darwin-amd64| sudo mv kubed-darwin-amd64 /usr/local/bin/kubed && sudo chmod +x /usr/local/bin/kubed
```
For Linux (amd64)
```
wget -qO - https://github.com/UNINETT/kubed/releases/download/0.1.4/kubed-linux-amd64| sudo mv kubed-linux-amd64 /usr/local/bin/kubed && sudo chmod +x /usr/local/bin/kubed
```
For Windows (amd64)
Download [Kubed (0.1.4)](https://github.com/UNINETT/kubed/releases/download/0.1.4/kubed-windows-amd64.exe) and open `cmd`. On the command prompt run

```
copy %HOMEPATH%\Downloads\kubed-windows-amd64.exe C:\Windows\System32\kubed.exe
```

now you must be able to run `kubed -h or kubed.exe -h`.

## Step 2 - Deployment

### Get Credentials and Config
We need to get credentials from Dataporten to be used against our kubernetes cluster. To do that run the following command

```
kubed -name nirdtest -api-server <api-server-address> -client-id <client-id> -issuer <issuer-url>
```

This will open the browser and ask you to authenticate using your institution credentials. Once successful, it will store the credentials in `$HOME/.kube/config` file. These credentials are valid for **24 hours**, you can renew them by running this command
```
kubed -renew nirdtest
```

Now run the command
```
kubectl get po -n scratch
```
you should not see the error, it will either say `No resources found.` or will print the list of running pods.

As the NIRD Opsteam have access to scratch namespace, we can set this as our default namespace in `$HOME/.kube/config`
```
kubectl config set-context nirdtest --namespace scratch
```
### Deploy notebook to kubernetes

Since we have working kubernetes client, lets deploy our notebook app to kubernetes cluster. Before deploying the app, you should choose a name which is unique for your instance of app e.g. <APPNAME> and run the following command
```
APPNAME=ola ./name-fix.sh
```
Now, let's deploy our app
```
kubectl apply -f nb-dep.yaml
```
Now you should be able to see the pod with your app name is being scheduled and running
```
kubectl get pods -l app=APPNAME
```
To see the more details about pod, run the command
```
kubectl describe pod -l app=APPNAME
```

As our application is running, it has also created a [Service](https://kubernetes.io/docs/concepts/services-networking/service/) and [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) to expose it out to public internet. The deployment also asks [Kube-Lego](https://github.com/jetstack/kube-lego/) to get SSL certificate from Lets Encrypt. 

You can access your notebook instance with this DNS address `https://APPNAME.scratch.nirdtest.uninett.no`. You will see the warning, as currently we are using staging Let's entcrypt certificate authority to avoid rate limit.

### Fault tolerance

Kubernetes keeps track of the running application using liveness check and deployment replica count. If for some reason application is down, it will automatically start a new instance of our app. To simulate the failure, delete the running pod
```
kubectl delete pod -l app=APPNAME
```
Now if you try to access, your notebook instance it will be down. Let´s look at the deployment object and see what it shows as number of replicas.

```
kubectl get deployment -l app=APPNAME
```
You will see that Kubernetes has detected the number of `Available` pods are not what is `Desired`. So lets do a watch on the pod status, you will see that kubernetes has scheduled a new instance automatically.
```
kubectl get pod -w -l app=APPNAME
```
Once pod status changed to running with in a minute you will be able to access the notebook app again.

### Cleaning up
Now we can clean up our deployment.
```
kubectl delete -f nb-dep.yaml
```
