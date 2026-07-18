Lab1: Continuous Deployment Using GitHub Actions


Minikube is a tool that makes it easy to run a Kubernetes cluster on your local machine. This can be useful for testing and development purposes, as it allows you to experiment with Kubernetes without access to a remote cluster.

To use Minikube, you'll need to have Docker (or a similar container runtime) installed on your machine. Once you have that, you can download and install Minikube using the instructions provided on the official website: https://minikube.sigs.k8s.io/docs/start/

Once you have Minikube installed, you can start a cluster by running the minikube start command. This will create a new Kubernetes cluster with a single node running on your local machine.

You can interact with your Minikube cluster using the kubectl command-line tool, just as you would with a remote Kubernetes cluster. This means you can deploy and manage applications on your local cluster, and test them as if they were running in a production environment.

In the context of your lab, you will use Minikube with GitHub Actions. By setting up a workflow that starts a Minikube cluster and deploys its application for testing, you can ensure that its code is working correctly before pushing it to a remote cluster or production environment.

To get started with Minikube in GitHub Actions, you can use the medyagh/setup-minikube action, which provides a convenient way to install and start Minikube in your workflow. You can find more information about this action in the GitHub Actions Marketplace: https://github.com/marketplace/actions/setup-minikube

In this Practic-on lab, we will learn how to deploy a Node.js app to Minikube using GitHub Actions.
You should create a new GitHub repository on your personal account and push your code to it.

Minikube
We need to create Dockerfile for Node.js App using below code.
FROM node:14
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
RUN npm install express
COPY . .
EXPOSE 3000
CMD [ "node", "server.js" ]

After the first step we need to create package.json file using below code.
{
    "name": "docker_web_app",
    "version": "1.0.0",
    "description": "Node.js on Docker",
    "author": "First Last <first.last@example.com>",
    "main": "server.js",
    "scripts": {
      "start": "node server.js"
    },
    "dependencies": {
      "express": "^4.16.1"
    }
  }

Now let's create server.js file.
'use strict';

const express = require('express');

// Constants
const PORT = 3000;
const HOST = '0.0.0.0';

// App
const app = express();
app.get('/', (req, res) => {
  res.send('Hello World');
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);

Here let's create k8s-node-app.yaml file using below code.
--
kind: Deployment
apiVersion: apps/v1
metadata:
  name: nodejs-app
  namespace: default
  labels:
    app: nodejs-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nodejs-app
  template:
    metadata:
      labels:
        app: nodejs-app
    spec:
      containers:
      - name: nodejs-app
        image: "devopshint/node-app:latest"
        ports:
          - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: nodejs-app
  namespace: default
spec:
  selector:
    app: nodejs-app
  type: NodePort
  ports:
  - name: http
    targetPort: 3000
    port: 80

Now its time to create workflow so firstly create .github>>Workflows>>deploy-to-minikube-github-actions.yaml
name: Deploy to Minikube using GitHub Actions

on: [push]
  
jobs:
  job1:
    runs-on: ubuntu-latest
    name: build Node.js Docker Image and deploy to minikube
    steps:
    - uses: actions/checkout@v2
    - name: Start minikube
      uses: medyagh/setup-minikube@master
    - name: Try the cluster !
      run: kubectl get pods -A
    - name: Build image
      run: |
          export SHELL=/bin/bash
          eval $(minikube -p minikube docker-env)
          docker build -f ./Dockerfile -t devopshint/node-app:latest .
          echo -n "verifying images:"
          docker images         
    - name: Deploy to minikube
      run:
        kubectl apply -f k8s-node-app.yaml
    - name: Test service URLs
      run: |
          minikube service list
          minikube service nodejs-app --url

After that go to the actions in GitHub and check your job is success or not.



So you can see my job status is success.



We have covered How to Deploy to Minikube using GitHub Actions | Deploy Node.js app to Minikube using GitHub Actions.

Upload the .pdf file to the platform using the "Upload your assignment" button below and click “Submit”.
Please pay attention, that you have only one attempt to submit your file!


Unfortunately, checking this lab is not yet automated. Therefore, your solution may be left unchecked if you take this course without the support of a mentor.
Otherwise, provide your mentor with access to your private GitHub repository. This will allow them to review your work and provide feedback and guidance as needed.