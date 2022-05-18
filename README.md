## How to Run Application

$ go run main.go

Env variable:- Specify Golang and Postgres Database related variables in .env file 

Setup the env variable in the specified format to start the application.

    DATABASE_URL: "host=<db_host> port=<port> user=<db_user> password=<password> dbname=<database_name> pool_min_conns=<min_pool_connections> pool_max_conns=<max_pool_connections>"

    Example:
    DATABASE_URL="host=localhost port=5432 user=admin password=password dbname=my_db sslmode=disable pool_min_conns=5 pool_max_conns=10"

$ docker-compose -f docker-compose.yaml  up --build -d


## Make sure that following Pre Requisite tools is running on your local or remote machine.

IF you are running building and running this application on cloud you need to change your storage class in values.yaml to GCP or AWS related.

`docker` (docker version 20.10.11)

`docker-compose` ( docker-compose version 1.29.2 )

`helm 3` (helm version v3.8.1)

`rancher desktop / k3s` (latest)

`kubctl` (v1.22.7+k3s1)

`golang` (1.16.14)


## Run Following commands to make your application up and running with helm

Note: While running shell script pass your docker image repository currently in my shell script I am using `rkstar007` as repository name which is hosted in docker hub.

1. Automatic Deployment 

$ ./deployment.sh rkstar007

it's prompt for password then provide your docker hub registry password to login.


2. Manually Deployment 

###  K8s Deployment ( Manual Process )

Use following steps to build app:

$ docker-compose -f docker-compose.yaml  up --build -d

$ docker tag simple-go-service_app <Your-DockerRepositry-Name>/simple-go-service_app

$ docker push <Your-DockerRepositry-Name>/simple-go-service_app

Use following steps to deploy app in k3s cluster:

$ helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace

$ kubectl apply -f k8s/deployment

###  HELM  ( Manual Process )

Use following steps to build app:

$ docker-compose -f docker-compose.yaml  up --build -d

$ docker tag simple-go-service_app <Your-DockerRepositry-Name>/simple-go-service_app

$ docker push <Your-DockerRepositry-Name>/simple-go-service_app

Use following steps to deploy app in k3s cluster:

$ helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace

$ helm upgrade --install golang-app  helm/golang-app/ --set image.repository="<Your-DockerRepositry-Name>"/simple-go-service_app,image.tag=latest

$ helm upgrade --install postgres-app  helm/postgres-app/ --set image.repository="<Your-DockerRepositry-Name>"/simple-go-service_app,image.tag=14.2-alpine

## How to Access Application

Note: Replace Ingress IP address (192.168.0.200) with your Address

$ kubectl get ing

You can see output something like this:

NAME             CLASS    HOSTS   ADDRESS         PORTS   AGE
go-web-app-ing   <none>   *       192.168.0.200   80      3m35s

$ curl  -Iv  http://192.168.0.200/healthz
```
*   Trying 192.168.0.200...
* TCP_NODELAY set
* Connected to 192.168.0.200 (192.168.0.200) port 80 (#0)
> HEAD /healthz HTTP/1.1
> Host: 192.168.0.200
> User-Agent: curl/7.64.1
> Accept: */*
>
< HTTP/1.1 200 OK
HTTP/1.1 200 OK
< Date: Tue, 17 May 2022 18:08:26 GMT
Date: Tue, 17 May 2022 18:08:26 GMT
< Content-Type: text/plain; charset=utf-8
Content-Type: text/plain; charset=utf-8
< Content-Length: 27
Content-Length: 27
< Connection: keep-alive
Connection: keep-alive

<
* Connection #0 to host 192.168.0.200 left intact
* Closing connection 0 
```

