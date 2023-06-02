---
title: "Setting up K8S cluster & Rancher - Part 2"
date: 2023-06-02T11:47:06+05:30
draft: false
tags: ["devops"]
categories: ["Engineering"]
image: "img/k8s-cluster-and-rancher-2.png"
author: "Mhathesh TSR"
authorDes: "DevOps Engineer at Nurdsoft"

authorImage: "img/mhathesh-tsr.jpeg"
---

## To import an AWS EKS (Elastic Kubernetes Service) cluster into Rancher server, you can follow these steps:

1. Install and Set up Rancher: Ensure that you have Rancher installed and set up by following the installation instructions provided by Rancher. You should have access to the Rancher web interface.

2. Log in to Rancher: Open a web browser and navigate to the URL of your Rancher server. Enter your admin credentials to log in.

3. Add a Cluster: Once logged in, click on the "Global" tab in the top-left corner and select "Clusters" from the drop-down menu. Click on the "Add Cluster" button.

4. Choose an Infrastructure Provider: In the "Add Cluster" screen, select the option for your AWS EKS cluster. Rancher supports different cloud providers, including Amazon Web Services (AWS).

5. Connect to AWS EKS: Rancher needs access to your AWS account to import and manage the EKS cluster. You will need to provide the necessary AWS credentials to establish the connection. Follow the instructions provided by Rancher to create an IAM role or user with the required permissions and enter the access key and secret key.

6. Configure Cluster Details: In the next step, provide the necessary details about your AWS EKS cluster:

   - Enter a name for your cluster in Rancher.
   - Specify the AWS region where your EKS cluster is located.
   - Choose the cluster from the list of available EKS clusters in your AWS account.

7. Review and Import the Cluster: Once you have configured the cluster details, review the configuration settings to ensure accuracy. Click on the "Import" button to initiate the import process.

8. Monitor and Manage the Cluster: Rancher will import the AWS EKS cluster and start managing it. You can monitor the progress through the Rancher UI. Once the cluster import is complete, you can access and manage the AWS EKS cluster using the Rancher interface.

Note: Importing an existing EKS cluster into Rancher allows you to manage it through Rancher, but it does not modify or change the underlying EKS cluster in AWS. Any changes or updates made to the cluster through Rancher will be reflected in Rancher's management layer, but the actual cluster resources remain in AWS.

## Resources

- [Rancher Documentation](https://www.rancher.com/quick-start)
