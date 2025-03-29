Step 1: Set Up Kubernetes Cluster
### 1.1 Install Prerequisites
Ensure you have the following installed:


Minikube (for local cluster) OR GKE / EKS / AKS (for cloud-based cluster)


Docker (to build and push container images)


kubectl (Kubernetes CLI)


### 1.2 Start Minikube (For Local Deployment)
minikube start

Verify cluster status:
kubectl cluster-info
kubectl get nodes

Expected Output: A running Kubernetes cluster with at least 1 master and 1+ worker nodes.

## Step 2: Containerize the Web Application
### 2.1 Write the Dockerfile
Create a Dockerfile to containerize your web app:
# Use an official Node.js or Python base image
FROM node:16

# Set working directory
WORKDIR /app

# Copy application files
COPY . .

# Install dependencies
RUN npm install

# Expose application port
EXPOSE 3000

# Start the application
CMD ["npm", "start"]

### 2.2 Build and Push the Docker Image
Run the following commands:
docker build -t &lt;dockerhub_username&gt;/web-app:v1 .
docker push &lt;dockerhub_username&gt;/web-app:v1

Verify image in Docker Hub:
docker images


## Step 3: Create Kubernetes Deployment and Service
### 3.1 Define Deployment (deployment.yaml)
Create a YAML file:
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web-app
        image: &lt;dockerhub_username&gt;/web-app:v1
        ports:
        - containerPort: 3000

### 3.2 Define Service (service.yaml)
Expose the app using a Service:
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
spec:
  type: NodePort
  selector:
    app: web-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000

### 3.3 Apply Kubernetes Manifests
Run:
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

Verify:
kubectl get pods
kubectl get services

Expected Output:


3 Pods running


Service with a NodePort



## Step 4: Implement Auto-Scaling
### 4.1 Create hpa.yaml
Define auto-scaling policy:
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app-deployment
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50

### 4.2 Apply the HPA
kubectl apply -f hpa.yaml
kubectl get hpa

### 4.3 Simulate Load (Scaling Test)
Run:
kubectl run stress-test --rm -it --image=busybox -- /bin/sh
while true; do wget -q -O- http://web-app-service; done

Check if new pods are created:
kubectl get pods -w


## Step 5: Implement Persistent Storage (Optional)
### 5.1 Create Persistent Volume (pv.yaml)
apiVersion: v1
kind: PersistentVolume
metadata:
  name: web-app-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/data"

### 5.2 Create Persistent Volume Claim (pvc.yaml)
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: web-app-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi

### 5.3 Apply PV and PVC
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml

### 5.4 Modify Deployment to Use Storage
Update deployment.yaml:
volumeMounts:
  - mountPath: "/app/data"
    name: storage
volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: web-app-pvc

Reapply deployment:
kubectl apply -f deployment.yaml


## Step 6: Perform Rolling Updates &amp; Rollbacks
### 6.1 Update Image
kubectl set image deployment/web-app-deployment web-app=&lt;dockerhub_username&gt;/web-app:v2

### 6.2 Check Rollout Status
kubectl rollout status deployment/web-app-deployment

### 6.3 Rollback If Needed
kubectl rollout undo deployment/web-app-deployment


## Step 7: Test Deployment
### 7.1 Access the Application
Find external IP:
kubectl get services

Access via:
curl http://&lt;EXTERNAL-IP&gt;:&lt;PORT&gt;

### 7.2 Test Pod Failure &amp; Self-Healing
Delete a pod:
kubectl delete pod &lt;POD_NAME&gt;
kubectl get pods -w

Expected Output: Kubernetes should automatically recreate the pod.
### 7.3 Test Persistent Storage
kubectl delete pod &lt;POD_NAME&gt;
kubectl get pods -w

Expected Output: Data should persist across restarts.
### 7.4 Check Logs
kubectl logs &lt;POD_NAME&gt;


## Step 8: Deliverables


GitHub Repository: Upload all YAML files and Dockerfile.


Demo Video: Record a 3-5 min walkthrough.


Screenshots: Running cluster, auto-scaling in action.


Documented Test Cases: Include results for all tests.



## Conclusion
This procedure successfully sets up, deploys, and manages a scalable Kubernetes web application with auto-scaling, rolling updates, persistent storage, and fault tolerance.
Happy Deploying! 🚀
