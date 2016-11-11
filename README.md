# k8s-tutorial
Repo to hold contents for kubernetes hands on tutorial.

##Tl;dr
* Setup kubernetes client with Dataporten authentication
* Deploy a demo app
* Make application availanle to public interenet with DNS name
* Make application fault tolerant
* Get SSL cert from Lets Encrypt
* Enable Dataporten integeration for the application

## Kubernetes client
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

Untar this and make sure you are able to run `kubectl`

## Kubernetes server configuration
We need to authenticate ourselves to get the credentials and also download the kubeconfig with details to connect to our kubernetes server. Make sure you are member of `uhsky-tutorial` group in dataporten. You can check that here `https://grupper.dataporten.no` . After that go to this webpage in your browser `https://login.ioudaas.no` to get the kuberentes configuration.

Download the config file and place it under your home directory as `~/.kube/config`. After this you should be able to run the command and get output as
```
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"4", GitVersion:"v1.4.5", GitCommit:"4957b090e9a4f6a68b4a40375408fdc74a212260", GitTreeState:"clean", BuildDate:"2016-10-16T06:36:33Z", GoVersion:"go1.7.1", Compiler:"gc", Platform:"darwin/amd64"}

Server Version: version.Info{Major:"1", Minor:"4", GitVersion:"v1.4.5+coreos.0", GitCommit:"7819c84f25e8c661321ee80d6b9fa5f4ff06676f", GitTreeState:"clean", BuildDate:"2016-10-17T21:19:17Z", GoVersion:"go1.6.3", Compiler:"gc", Platform:"linux/amd64"}
```

## Deploy a demo app to kubernetes

Since we have working kubernetes client, lets deploy our app to kubernetes cluster. Before deploying the app, you should choose a name which is unique for your instance of app e.g. <ola-app> and run the following command
```
APPNAME=ola-app ./name-fix.sh
```
Once done, lets deploy our app
```
kubectl apply -f dep.yaml
```
Now you should be able to see the pod with your app name is being scheduled and running
```
kubectl -n tutorial get pods -l app=<APPNAME>
```
To see the more details about pod, run the command
```
kubectl -n tutorial describe pod -l app=<APPNAME>
```
Lets access it using port-forward, as currently we have not yet exposed it to internet
```
kubectl -n tutorial port-forward <POD_NAME> 8080:80
```
## Expose the app to internet
As our application is running, we can expose it out to public internet with a DNS name created for us already for our app. 
```
kubectl apply -f ingress.yaml
```

Now you should be able to access the app by going to url `http://<APPNAME>.tutorial.ioudaas.no`

## Fault recovery and resilient
Kubernetes supports fault tolerance for the applications running in the cluster. To test this, lets kill our app
```
kubectl -n tutorial delete pod -l app=<APPNAME> --now
```

Now if you try to access the web url, it will not take us to our app. But if you try to list pod again, you should see that kubernetes has detected the missing pod and started a new one
```
kubectl -n tutorial get pods -l app=<APPNAME>
```
After some time the pod with start running and you should be able to access your app again by accessing url `http://<APPNAME>.tutorial.ioudaas.no`.

As we are using deployment, we can easily scale up and down the numbers of application instances. Lets scale our app to 2 by editing the replica counts in `dep.yaml` file
```
...
spec:
  replicas: 2
...
```
and apply the changes using
```
kubectl apply -f dep.yaml
```
now if you list the pod again, you should see that there are 2 pods for your app now.
```
kubectl -n tutorial get pods -l app=<APPNAME>
```
Once pod started running then you should see the hostname is changing as the request is being routed to different application instances. Now if you kill one of the instance, you still should be able to access your application and will not face any downtime.

```
kubectl -n tutorial delete pod <podname> --now
```

## SSL certificate for app
With support of Lets Encrypt, we can get SSL certificate (from staging LE, to avoid rate limit) automatic for our application. To do that apply the updated ingress file as
```
kubectl -n tutorial apply -f ingress-ssl.yaml
```

It might take a minute or so before we get our SSL certificate. Once successful, when you access your webpage you should see automatic redirection to `https`

## Dataporten integeration for app
Now we have app running with SSL in a fault tolerance way, so we are getting ready for production. We would like to get authentication support from `Dataporten`. For that, first we need to register the application in (Dataporten dashboard)[https://dashboard.dataporten.no].

Set the Redirect URL as `https://<APPNAME>.tutorial.ioudaas.no/cb.php` Once app is registered, we need add extra scopes `E-Post, Groups, Feide-navn`. After that we need to copy the `Oauth2` details from the dashboard's `Oauth2 details` section into `dep-dp.yaml` file. Copy `CLIENT_ID, CLIENT_SECRET` under `DATAPORTEN_CLIENTID, DATAPORTEN_CLIENTSECRET` correspondingly. Once done copying, apply the updated deployment as
```
kubectl apply -f dep-dp.yaml
```

Kubernetes will automatically restart your app and once done, you will see the `login` button which allows you to use Dataporten