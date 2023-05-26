---
title: "Setting up K8S cluster and Rancher for managing the cluster"
date: 2023-05-26T17:08:11+05:30
draft: false
tags: ["devops"]
categories: ["Security"]
image: "img/k8s-cluster-and-rancher.png"
author: "Mhathesh TSR"
authorDes: "DevOps Engineer at Nurdsoft"

authorImage: "img/mhathesh-tsr.jpeg"
---

## What is rancher?

    Rancher is a Kubernetes management tool to deploy and run clusters anywhere and on any provider. Rancher can provision Kubernetes from a hosted provider, provision compute nodes and then install Kubernetes onto them, or import existing Kubernetes clusters running anywhere.

## Installing Rancher server:

    The Rancher server manages and provisions Kubernetes clusters. You can interact with downstream Kubernetes clusters through the Rancher server's user interface. The Rancher management server can be installed on any Kubernetes cluster, including hosted clusters, such as Amazon EKS clusters.

    To install Rancher using Docker, you can follow these general steps:

1. Install Docker: Ensure that Docker is installed on your server. You can refer to the official Docker documentation for instructions specific to your operating system.

2. Launch the Rancher Docker Container: Open a terminal or command prompt and run the following command to start the Rancher Docker container:

```bash
$ sudo docker run -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher
```

This command downloads the latest Rancher server image from Docker Hub and starts a container with the necessary configurations. The `-d` flag runs the container in the background, `--restart=unless-stopped` ensures that the container restarts automatically if the server reboots, and `-p` maps the container ports 80 and 443 to the corresponding ports on the host machine.

3. Access Rancher Web UI: Once the container is running, you can access the Rancher web interface by opening a web browser and navigating to `http://<server-ip>` or `https://<server-ip>`. Replace `<server-ip>` with the IP address or hostname of your server where Rancher is installed.

4. Set up Rancher: On the first visit to the Rancher web UI, you will be prompted to set up an admin password and configure other settings. Follow the on-screen instructions to complete the setup process.
   765po780.
5. Register Cluster Nodes: After setting up Rancher, you can register and manage cluster nodes through the Rancher UI. This allows you to create and manage containerized environments using the supported orchestration platforms (e.g., Kubernetes, Docker Swarm).

Note: The above steps provide a general overview of the installation process using Docker. However, for production deployments or specific configurations, it's recommended to consult the official Rancher documentation for detailed instructions and best practices.

## Create on-prem Kubernetes cluster from rancher:

To create a Kubernetes cluster using the "Kubernetes (Custom)" template in Rancher, you can follow these steps:

1. Install and Set up Rancher: Ensure that you have Rancher installed and set up by following the installation instructions provided by Rancher. You should have access to the Rancher web interface.

2. Log in to Rancher: Open a web browser and navigate to the URL of your Rancher server. Enter your admin credentials to log in.

3. Add a Cluster: Once logged in, +click on the "Global" tab in the top-left corner and select "Clusters" from the drop-down menu. Click on the "Add Cluster" button.

4. Choose "Kubernetes (Custom)" Template: In the "Add Cluster" screen, select the "From Existing Nodes" option and choose the "Kubernetes (Custom)" template.

5. Configure Cluster Settings:

   - Enter a name for your cluster.
   - Choose the desired Kubernetes version or select "Latest" to use the latest available version.
   - Specify the Network Provider. Rancher supports various network providers, such as Canal, Calico, Flannel, etc. Choose the one that suits your needs.
   - Configure additional settings, such as Pod CIDR, Service CIDR, Cluster DNS IP, etc., as per your requirements.

6. Add Cluster Nodes: In the next step, you need to add and register the cluster nodes that will be part of your Kubernetes cluster. Rancher provides multiple options to add nodes:

   - Choose "Custom" if you want to manually add nodes. You need to provide the node IP address, hostname, and SSH credentials to access the node.
   - Choose an Infrastructure Provider option if you want to utilize an existing provider like Amazon EC2, Google Compute Engine, etc. Follow the instructions provided by Rancher to integrate with your chosen provider and add the nodes.

7. Configure Node Options: Specify the Docker installation options, such as the Docker version, storage driver, and other custom options. You can also configure any additional cloud provider integrations or other advanced settings as needed.

8. Review and Create the Cluster: Once you have configured all the necessary settings, review the cluster configuration and ensure everything is correct. Click on the "Create" button to create the Kubernetes cluster.

9. Monitor and Manage the Cluster: Rancher will provision and deploy the Kubernetes cluster based on your configuration. You can monitor the progress through the Rancher UI. Once the cluster is created, you can access and manage it using the Rancher interface, including deploying applications, scaling resources, and monitoring cluster health.
