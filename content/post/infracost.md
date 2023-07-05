---
title: "Infracost + Terraform + GitHub Actions = Automate Cloud Cost Management"
date: 2023-06-28
draft: false
tags: ["devops"]
categories: ["Engineering"]
author: "Chinmay Jain"
---

## Preamble
The use of public cloud resources has drastically increased in the last decade due to the growth in cloud-native development and the ease of developing and delivering applications. There are numerous advantages of using public cloud services/resources. However, there are also challenges associated with using services from various cloud service providers such as AWS, Azure, and GCP.

Each cloud service provider has full ownership of the public cloud, with its own policies, values, profit models, and cost structures. Everycompany's success and growth are affected by the resources provisioned, and sometimes we overlook the costs during rapid development when using automation tools like Terraform, Ansible, and ARM templates. We may end up provisioning resources without considering the financial implications, only to realize the impact during the billing cycle.

Fortunately, now we have the ability to estimate costs before provisioning resources and gain a better understanding of cloud costs using anopen-source solution called Infracost. You can find additional information and resources related to cloud cost estimation and pricing on Infracost for AWS, Azure, and GCP. 

These links will provide you with detailed information on how to effectively use Infracost to estimate costs before provisioning resources. Additionally, the cloud provider pricing calculators will assist you in exploring pricing details and estimating costs for various services offered by each cloud platform.

## AWS:
Infracost GitHub Repository: https://github.com/infracost/infracost
Infracost AWS Provider Documentation: https://www.infracost.io/docs/providers/aws
AWS Pricing Calculator: https://calculator.aws
AWS Simple Monthly Calculator: https://calculator.s3.amazonaws.com/index.html

## Azure:
Infracost Azure Provider Documentation: https://www.infracost.io/docs/providers/azure
Azure Pricing Calculator: https://azure.microsoft.com/pricing/calculator
Azure Pricing Documentation: https://azure.microsoft.com/pricing

## Google Cloud Platform (GCP):
Infracost GCP Provider Documentation: https://www.infracost.io/docs/providers/gcp
GCP Pricing Calculator: https://cloud.google.com/products/calculator
GCP Pricing Documentation: https://cloud.google.com/pricing

## Automating Cloud Cost Management -
1. A DevOps/Developer makes changes to their Terraform configuration, and they submit a pull request.

2. This pull request auto triggers a CI workflow, which calculates the cloud cost difference before and after their changes. It nicely displays the cost difference in a table format as a pull request comment, with a detailed drill-down on where the cost change occurs.

![](../../../img/infracost.png)

3. If the monthly cloud cost change exceeds your predefined policy threshold, your workflow fails for further examination to ensure there is no human error in your Terraform configuration.

4. The workflow can also generate an HTML/Json report on the cloud cost for the infrastructure with the latest changes.

5. You and/or the developer get an email/slack notification with this report attached.

- Problem 1: Lack of Cost Visibility during Infrastructure Planning Before adopting Infracost, estimating the financial impact of infrastructure changes was a time-consuming and error-prone process. It was challenging to get an accurate picture of the costs associated with deploying new resources or modifying existing infrastructure. As a result, we often faced unexpected cost overruns, impacting our budget and hindering our ability to plan effectively.

Solution: Real-time Cost Estimation with Infracost Infracost revolutionized our infrastructure planning process by providing real-time cost estimates. By integrating seamlessly with Terraform, Infracost allowed us to analyze and estimate the financial impact of our infrastructure changes before actually deploying them. With detailed cost breakdowns for each resource, we could make informed decisions about resource provisioning, choose cost-effective alternatives, and ensure that our infrastructure changes aligned with our budgetary constraints.

- Problem 2: Limited Cost Insights across Multiple Cloud Providers As a multi-cloud organization, we faced the challenge of managing costs across different cloud providers. Each provider had its own cost models, pricing structures, and complexities, making it difficult to get a consolidated view of our infrastructure costs. This lack of visibility prevented us from identifying cost-saving opportunities and optimizing our cloud spending effectively.

Solution: Centralized Cost Tracking with Infracost Infracost served as a centralized platform for tracking costs across multiple cloud providers. It supported popular cloud platforms like AWS, Azure, Google Cloud, and more, enabling us to analyze and compare costs across different providers in a unified manner. With Infracost's detailed cost breakdowns and support for multiple currencies, we gained granular insights into our infrastructure spending, identified cost-saving opportunities, and optimized our cloud deployments accordingly.

## Quick start
The following steps assume a simple Terraform directory is being used, we recommend you use a more relevant example if required.

1. If you haven't done so already, download Infracost and run infracost auth login to get a free API key.

2. Retrieve your Infracost API key by running infracost configure get api_key.

3. Create a repo secret called INFRACOST_API_KEY with your API key.

4. Create a new file in .github/workflows/infracost.yml in your repo with the following content.

# Check out more about the plugin : https://github.com/infracost/actions

```bash
name: "Infracost Analysis"

on:
  workflow_call:
    inputs:
      # working-directory is added to specify "terraform" directory in project source code as that's where the terraform files live.
      working-directory:
        required: false
        type: string
        default: 'terraform'

jobs:
  infracost:
    name: Infracost Analysis

    runs-on: ubuntu-latest

    env:
      TF_ROOT: ${{ inputs.working-directory }}

      - name: Setup Infracost
        uses: infracost/actions/setup@6bdd3cb01a306596e8a614e62af7a9c0a133bc5c
        # See https://github.com/infracost/actions/tree/master/setup for other inputs
        with:
          api-key: ${{ secrets.INFRACOST_API_KEY }}

      - name: Print debug info
        run: |
          echo github base branch is ${{github.event.pull_request.base.ref}}
          echo github.event.pull_request.number is ${{github.event.pull_request.number}}

      # Generate Infracost JSON file as the baseline.
      - name: Generate Infracost cost estimate baseline
        run: |
          export INFRACOST_API_KEY=${{ secrets.INFRACOST_API_KEY }}
          cd ${TF_ROOT}
          infracost breakdown --path=. \
                              --terraform-var-file=${{ inputs.terraform-var-file }} \
                              --usage-file ${{ inputs.usage-file }} \
                              --format=json \
                              --out-file=/tmp/infracost-base.json

      # Checkout the current PR branch so we can create a diff.
      - name: Checkout PR branch
        uses: actions/checkout@93ea575cb5d8a053eaa0ac8fa3b40d7e05a33cc8

      # Generate an Infracost diff and save it to a JSON file.
      - name: Generate Infracost diff
        run: |
          export INFRACOST_API_KEY=${{ secrets.INFRACOST_API_KEY }}
          cd ${TF_ROOT}
          infracost diff --path=. \
                          --format=json \
                          --show-skipped \
                          --terraform-var-file=${{ inputs.terraform-var-file }} \
                          --usage-file ${{ inputs.usage-file }} \
                          --compare-to=/tmp/infracost-base.json \
                          --out-file=/tmp/infracost.json

      # generate the html report based on the JSON output from last step
      - name: Generate Infracost Report
        run: |
          export INFRACOST_API_KEY=${{ secrets.INFRACOST_API_KEY }}
          cd ${TF_ROOT}
          infracost output --path /tmp/infracost.json --show-skipped --format html --out-file report.html

      # Posts a comment to the PR using the 'update' behavior.
      # This creates a single comment and updates it. The "quietest" option.
      # The other valid behaviors are:
      #   delete-and-new - Delete previous comments and create a new one.
      #   hide-and-new - Minimize previous comments and create a new one.
      #   new - Create a new cost estimate comment on every push.
      #   update - Update a cost estimate comment when there is a change in the cost estimate.
      # See https://www.infracost.io/docs/features/cli_commands/#comment-on-pull-requests for other options.
      - name: Post Infracost comment
        run: |
          export INFRACOST_API_KEY=${{ secrets.INFRACOST_API_KEY }}
          infracost comment github --path=/tmp/infracost.json \
                                   --repo=$GITHUB_REPOSITORY \
                                   --github-token=${{github.token}} \
                                   --pull-request=${{github.event.pull_request.number}} \
                                   --behavior=update \
```
## Conclusion: Implementing the Infracost Terraform tool has been a game-changer for your organization in optimizing cloud infrastructure costs. By providing real-time cost estimation, centralized cost tracking across multiple cloud providers, and enabling cost allocation and forecasting, Infracost has empowered us to make data-driven decisions, optimize spending, and align our infrastructure changes with our budgetary constraints. 
