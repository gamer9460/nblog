---
title: "Nomad Odyssey: Navigating the HashiCorp Universe with Confidence Part-II - The Practical Guide"
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
In Part-I of our Nomad Odyssey, we delved into the theoretical aspects, laying the groundwork for confidently navigating the HashiCorp Universe. Now, in Part-II, we're diving into the practical side of things. Get ready to roll up your sleeves as we guide you through the hands-on experience of downloading, installing, and running Nomad. This practical guide will solidify your understanding and set you on the path to mastering Nomad's real-world application.

Stay tuned for a step-by-step walkthrough that bridges theory and practice, making your Nomad journey both educational and exciting. Whether you're a seasoned explorer of infrastructure orchestration or a newcomer to the HashiCorp ecosystem, this practical guide will equip you with the skills to leverage Nomad effectively in your deployments. Get ready for a Nomad Odyssey filled with practical insights and actionable knowledge! 🚀✨

## Starting Simple
Now the fun begins — we are going to get started with downloading, installing and running Nomad! The theory above will help you to understand what we are doing, so if you’ve skipped straight to this section, go back and spend a couple of minutes reading it — it will help in the long run!

A quick caveat — your operating system might work differently from the one used in this guide (MacOS). If you find a command or job is not working as expected, you might need to modify it to work in your particular environment. Refer back to the Nomad [documentation](https://developer.hashicorp.com/nomad/docs/) for the most up to date information. At present Nomad only supports Windows containers when running on Windows. The examples given below are for Linux containers. If you want to use them as is and are running Windows, consider running a Linux VM to complete the examples.

## Prerequisites
To complete the hands-on components you will need:

- Internet connectivity to download binaries and containers
- An up to date installation of Windows, Linux or MacOS
- An installation of [Docker](https://docs.docker.com/get-docker/) for your operating system

## Nomad installation
- Go to this [page](https://developer.hashicorp.com/nomad/install) and Download the appropriate package for your system.
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

## Summary:
Congratulations on mastering the basics of Nomad! You now wield the knowledge to confidently navigate the HashiCorp Universe. From understanding its architecture to running your first job, you've embarked on a Nomad Odyssey.

As you continue exploring, remember the fundamentals – jobs, task groups, and resources. Nomad's simplicity makes workload management a breeze, ensuring your deployments are seamless.

So, here's to your Nomad journey! May your deployments be swift, your clusters resilient, and your tech adventures ever exciting. Happy deploying, and may your Nomad Odyssey be a success! 🚀✨
