# devops-sandbox
Before starting the task:

Download the deploy_deployments binary file for Linux, MacOS AMD or MacOS ARM(some additional steps may be needed)
Run the following command:
$ ./deploy_deployments
To check tasks and get secret phrases run:

$ ./checker -course 'kubernetes' -course-version 'deployments' -test-suite 'deployment'
NOTE: before running check after each task make sure that deployment is up and all replicas are also running.

Task 1:

Create a new deployment called nginx-deploy:

Requirements:
 Name: nginx-deploy
 Image: nginx:1.19-alpine
 Namespace: default
 Replicas: 1
 Labels: app=nginx-deploy
Do not forget to copy secret phrase, test will fail after task 3.

Task 2:

Inspect the details listed below, add necessary options to kubectl create deploy command to produce following deployment configuration:

Name: easy-peasy
Image: busybox:1.34
Replicas: 5
Command: sleep infinity
Task 3:

Scale nginx-deploy deployment to 6 replicas.

Task 4:

Inspect the details listed below and create deployment:

Deployment Name: <youname>-app
Replicas: 1
Deployment Labels:
  task: deploy
  app: <youname>-app
  student: <youname>
Pod(s) Labels:
   deploy: <youname>-app
   kind: redis
   role: master
   tier: db
Container:
   Image: redis:5-alpine
   Port: 6379
   Name: redis-master
Init Container:
   Image: busybox:1.34
   Command: sleep 10
Task 5:

Current deployment nginx-deploy release has nginx:1.19-alpine image.New release should use nginx:1.21-alpine.Use rolling update process

Task 6:

A lemon deployment has been deployed in namespace trouble, but there are no pods associated with it. Figure out the root cause and fix the issue.

Task 7:

A orange deployment has been deployed in namespace trouble, but it doesn’t work properly. Figure out the root cause and fix the issue.