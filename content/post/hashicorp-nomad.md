---
title: "Nomad Odyssey: Navigating the HashiCorp Universe with Confidence Part-I"
date: 2023-11-17T11:54:00+05:30
draft: false
tags: ["Devops"]
categories: ["Devops"]
image: "img/"
author: "Chinmay Jain"
authorDes: "DevOps Engineer at Nurdsoft"

authorImage: "img/chinmay_jain.jpg"

---

## Introduction

It can be daunting when first looking at a new piece of software. There’s a balance to be struck between getting up and running as quickly as possible, while also trying to make sure you understand what it is you are doing. Getting started guides often try to jump to the advanced use cases before you are truly comfortable with the basics, let alone everything in between!

This guide will walk you through all the steps to getting Nomad running, explaining along the way what it is you are doing, and where to go for more information.

## What Is Nomad?
 According to its [website](https://www.nomadproject.io/) Nomad is:
 A simple and flexible workload orchestrator to deploy and manage containers and non-containerized applications across on-prem and clouds at scale.

 Nomad is a scheduler similar to something like ECS, Kubernetes, Swarm, etc. Your scheduler is going to take information like “I want N copies of image X running” and take care of running and maintaining the availability of these containers on a cluster of different hosts.

If a container crashes, Nomad will detect this and reschedule it. Or say one of your Azure instances crashes and it had 3 different microservices instances running on it. Nomad will reschedule these 3 microservice instances on different machines in your cluster (if capacity is available).

Say you have version A of your app running and you want to deploy version B. If you want to maintain up time you will need either some form of Blue/Green or rolling deployment. Your scheduler defines and executes these types of tasks.

Think of it as a lightweight version of Kubernetes and also much easier to learn.

## Nomad architecture:
I will try to simplify as much as I can but I strongly advise you to still read this nonetheless [website](https://developer.hashicorp.com/nomad/docs/concepts/architecture/)

Nomad is composed of two agents: Server and Client.

- Server — A Server manages all jobs and clients, runs         evaluations and creates task allocations. There is a cluster of servers per region and they manage all jobs and clients, run evaluations, and create task allocations. The servers replicate data between each other and perform leader election to ensure high availability. Servers federate across regions to make Nomad globally aware.
- Client — A Client of Nomad is a machine that tasks can be run on. All clients run the Nomad agent. The agent is responsible for registering with the servers, watching for any work to be assigned and executing tasks. The Nomad agent is a long-lived process which interfaces with the servers.

## IMPORTANT NOTE:
We will be running Nomad in development mode as you will see below, this means that our agent will run as both server and client, data will not be persisted which implicates that every time you close Nomad all the data will be gone.

## Single Region Architecture:

![Alt text](https://miro.medium.com/v2/resize:fit:1100/format:webp/0*muwgfRjcuDnix2QE.png "Nomad single region")

Within each region, we have both clients and servers. Servers are responsible for accepting jobs from users, managing clients, and [computing task placements](https://developer.hashicorp.com/nomad/docs/concepts/scheduling/scheduling/). Each region may have clients from multiple datacenters, allowing a small number of servers to handle very large clusters.

In some cases, for either availability or scalability, you may need to run multiple regions. Nomad supports federating multiple regions together into a single cluster. At a high level, this setup looks like this:

![Alt text](https://miro.medium.com/v2/resize:fit:1100/format:webp/0*koN8pBJWncaZU-RX.png "Hashicorp’s Nomad Multiple Region Server Setup")

## Key Definitions

The Nomad [job specification](https://developer.hashicorp.com/nomad/docs/job-specification/) defines the schema for Nomad jobs. Job files are written in the [HashiCorp Configuration Language](https://github.com/hashicorp/hcl/) (HCL),which strikes a nice balance between human readable and editable code, and is machine-friendly.

There are many pieces to the job specification although not all are required. Some of the key ones are below.

## Job
A specification provided by users that declares a workload for Nomad.

```bash
# This declares a job named "docs". There can
# be exactly one job declaration per job file
job "docs" {
  ...
}
```

## Task Group
A set of tasks that must be run together on the same client node. Multiple instances of a task group can run on different nodes.

```bash
job "docs" {
  group "web" {
    # All tasks in this group will run on 
    # the same node
    ...
  }
  group "logging" {
    # These tasks must also run together 
    # but may be a different node from web
    ...
  }
}
```

## Task
The smallest unit of work in Nomad.

```bash
job "docs" {
  group "example" {
    task "server" {
      # ...
    }
  }
}
```

## Task Driver
Represents the basic means of executing your Tasks e.g. Docker, Java, Qemu etc.

```bash
task "server" {
  driver = "docker"
  ...
}
```

## Resources
Describes the requirements a task needs to execute such as memory, network, CPU and more.

```bash
job "docs" {
  group "example" {
    task "server" {
      resources {
        cpu    = 100
        memory = 256

        network {
          mbits = 100
          port "http" {}
          port "ssh" {
            static = 22
          }
        }

        device "nvidia/gpu" {
          count = 2
        }
      }
    }
  }
}
```
Hopefully you found this useful and are enjoying using Nomad.
