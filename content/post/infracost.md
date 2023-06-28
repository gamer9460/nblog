---
title: "Infracost + Terraform + GitHub Actions = Automate Cloud Cost Management"
date: 2023-06-28
draft: false
tags: ["devops"]
categories: ["Engineering"]
author: "Chinmay Jain"
---
Preamble
The use of public cloud resources has increased drastically in the last decade with the growth in cloud-native development and ease of developing/delivering applications and many more are pros of using public cloud services/resources. But, there are many challenges that so come while using services from the various providers (AWS/Azure/GCP…) the cloud service provider has full ownership of the public cloud with its own policy, value, and profit, costing, and charging model. Every company's success/growth gets affected by each resource provisioned and sometimes we ignore this cost in case of rapid development by using some automation(IaC) tools like terraform, ansible, ARM template where we just go on provisioning and during the billing cycle we need to brace yourself.

But now we can estimate the cost before provisioning the resource and many other features to understand the cloud cost using an opensource solution (INFRACOST)

Automating Cloud Cost Management -
1. A Devops/Developer makes changes to their Terraform configuration, and they submit a pull request.

2. This pull request auto triggers a CI workflow, which calculates the cloud cost difference before and after their changes. It nicely displays the cost difference in a table format as a pull request comment, with a detailed drill-down on where the cost change occurs.

3. If the monthly cloud cost change exceeds your predefined policy threshold, your workflow fails for further examination to ensure there is no human error in your Terraform configuration.

4. The workflow can also generate an HTML/Json report on the cloud cost for the infrastructure with the latest changes.

5. You and/or the developer get an email/slack notification with this report attached. See a sample report below:


- Problem 1: Lack of Cost Visibility during Infrastructure Planning Before adopting Infracost, estimating the financial impact of infrastructure changes was a time-consuming and error-prone process. It was challenging to get an accurate picture of the costs associated with deploying new resources or modifying existing infrastructure. As a result, we often faced unexpected cost overruns, impacting our budget and hindering our ability to plan effectively.

Solution: Real-time Cost Estimation with Infracost Infracost revolutionized our infrastructure planning process by providing real-time cost estimates. By integrating seamlessly with Terraform, Infracost allowed us to analyze and estimate the financial impact of our infrastructure changes before actually deploying them. With detailed cost breakdowns for each resource, we could make informed decisions about resource provisioning, choose cost-effective alternatives, and ensure that our infrastructure changes aligned with our budgetary constraints.

- Problem 2: Limited Cost Insights across Multiple Cloud Providers As a multi-cloud organization, we faced the challenge of managing costs across different cloud providers. Each provider had its own cost models, pricing structures, and complexities, making it difficult to get a consolidated view of our infrastructure costs. This lack of visibility prevented us from identifying cost-saving opportunities and optimizing our cloud spending effectively.

Solution: Centralized Cost Tracking with Infracost Infracost served as a centralized platform for tracking costs across multiple cloud providers. It supported popular cloud platforms like AWS, Azure, Google Cloud, and more, enabling us to analyze and compare costs across different providers in a unified manner. With Infracost's detailed cost breakdowns and support for multiple currencies, we gained granular insights into our infrastructure spending, identified cost-saving opportunities, and optimized our cloud deployments accordingly.

- Conclusion: Implementing the Infracost Terraform tool has been a game-changer for our organization in optimizing cloud infrastructure costs. By providing real-time cost estimation, centralized cost tracking across multiple cloud providers, and enabling cost allocation and forecasting, Infracost has empowered us to make data-driven decisions, optimize spending, and align our infrastructure changes with our budgetary constraints. 
