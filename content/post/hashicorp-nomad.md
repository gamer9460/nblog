---
title: "Nomad Odyssey: Navigating the HashiCorp Universe with Confidence"
date: 2023-11-17T11:54:00+05:30
draft: false
tags: ["devops"]
categories: ["Engineering"]
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

## Starting Simple
Now the fun begins — we are going to get started with downloading, installing and running Nomad! The theory above will help you to understand what we are doing, so if you’ve skipped straight to this section, go back and spend a couple of minutes reading it — it will help in the long run!

A quick caveat — your operating system might work differently from the one used in this guide (MacOS). If you find a command or job is not working as expected, you might need to modify it to work in your particular environment. Refer back to the Nomad [documentation](https://developer.hashicorp.com/nomad/docs/) for the most up to date information. At present Nomad only supports Windows containers when running on Windows. The examples given below are for Linux containers. If you want to use them as is and are running Windows, consider running a Linux VM to complete the examples.

## Prerequisites
To complete the hands-on components you will need:

- Internet connectivity to download binaries and containers
- An up to date installation of Windows, Linux or MacOS
- An installation of [Docker](https://docs.docker.com/get-docker/) for your operating system

## Nomad installation
- Go to this [page](https://developer.hashicorp.com/nomad /tutorials/get-started/gs-install/) and Download the appropriate package for your system.
- Check which version of Nomad is suitable for your machine CPU and hit download.
- Unzip the downloaded file into any directory.
- (Optional) Place the binary somewhere in your PATH to access it easily from the command line.

That’s all! One of the strengths of Nomad is its simplicity. Having a single binary also makes upgrading Nomad much easier too.

## Running Nomad
In this blog, we are going to use Nomad in [“dev mode”](https://developer.hashicorp.com/nomad/docs/commands/agent#dev). This runs Nomad on a single machine as both the server and client. The nice thing is we’ll be able to interact with Nomad in the same way we would if we were running hundreds or thousands of nodes.

One important note — in dev mode, Nomad will not persist any data. That’s fine for experimenting and prototyping, but not something you should do in production. Also in production, we’d recommend keeping workloads on client nodes and not scheduling work on the server nodes. Check out the Nomad documentation for more information on running it in production.

Starting Nomad in dev mode is very simple from the command line:

```bash
$ nomad agent -dev
```

At this point, you should see the Nomad agent has started and started to output some log data similar to this:

```bash
==> Starting Nomad agent...
==> Nomad agent configuration:
Client: true
             Log Level: DEBUG
                Region: global (DC: dc1)
                Server: true
==> Nomad agent started! Log data will stream in below:
...
```

From the log data, you will be able to see that the agent is running in both client and server mode, and has claimed leadership of the cluster. Additionally, the local client has been registered and marked as ready.

Leave this terminal window open, and open a new window if you wish to run any subsequent CLI commands. When you want to stop Nomad, return to the terminal window where it is running and press CTRL+C.

## Nomad Web UI
Once we have the Nomad agent running, we can access the web user interface by visiting http://localhost:4646 in a browser.

![Alt text](https://miro.medium.com/v2/resize:fit:1100/format:webp/1*1Arsy1L0PwEfgPkxBO2GSg.png "The Nomad UI — looking pretty bare — for now at least!")

The jobs section looks pretty bare when you first start it up — we are going to fix that shortly!

The UI also shows us the Clients and Servers in the cluster. In this case, we will see the same node appear in each section. By clicking on the node name, information about that node will be displayed including OS type, Nomad version, and which resources and task drivers are available.

For more information, take a look at the [Web UI tutorial](https://developer.hashicorp.com/nomad/tutorials/get-started).

## Running Our First Job
Now that Nomad is up and running, we can schedule our very first job. We will be running the [http-echo](https://github.com/hashicorp/http-echo/) Docker container. This is a simple application that renders an HTML page containing the arguments passed to the http-echo process such as “Hello World”. The process listens on a port such as 8080 provided by another argument.

## Job File
A simple job file that describes this looks like this:

```bash
job "http-echo" {
  datacenters = ["dc1"]
  group "echo" {
    count = 1
    task "server" {
      driver = "docker"
      config {
        image = "hashicorp/http-echo:latest"
        args  = [
          "-listen", ":8080",
          "-text", "Hello and welcome to 127.0.0.1 running on port 8080",
        ]
      }
      resources {
        network {
          mbits = 10
          port "http" {
            static = 8080
          }
        }
      }
    }
  }
}
```

Create a file with a name hello-world.nomad Extension must be .nomad.In this file, we will create a job called http-echo, set the driver to use docker and pass the necessary text and port arguments to the container. As we need network access to the container to display the resulting webpage, we define the resources section to require a network with port 8080 open from the host machine to the container.

## Running the Job in the Web UI
While we could use the CLI or API to run our job file, it is very easy to schedule the job from the Web UI.

From the Jobs section of the Web UI, click the Run Job button in the top right. This will take you to a screen where you can paste your job file contents into the Job Definition text box and click Plan.

![Alt text](https://miro.medium.com/v2/resize:fit:1100/format:webp/1*KEwUH1FKq6jK4wTsW2QjkQ.png "Running a Job from the Web UI is very easy")

When we plan a job in Nomad, it determines the impact it will have on our cluster. As this is a new job, Nomad will determine it needs to create the task group and task:

```bash
+ Job: "http-echo"
+ Task Group: "echo" ( 1 create )
  + Task: "server" ( forces create )
```

Click Run and Nomad will allocate the task group to a client (in our case there is only one client) and start running the task. Once the job is running, visit http://127.0.0.1:8080 in your browser and you will see the http-echo webpage with the text we passed as an argument in the job file:

![Alt text](https://miro.medium.com/v2/resize:fit:1100/format:webp/1*BFAfXPkFWg4SKKZLV9H5gw.png "Congratulations on running your first job in Nomad!")

Hopefully you found this useful and are enjoying using Nomad.
