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

Quick start
The following steps assume a simple Terraform directory is being used, we recommend you use a more relevant example if required.

1. If you haven't done so already, download Infracost and run infracost auth login to get a free API key.

2. Retrieve your Infracost API key by running infracost configure get api_key.

3. Create a repo secret called INFRACOST_API_KEY with your API key.

4. Create a new file in .github/workflows/infracost.yml in your repo with the following content.

```bash
name: "Infracost Analysis for PRs"

on:
  workflow_call:
    inputs:
      # working-directory is added to specify "terraform" directory in project source code as that's where the terraform files live.
      working-directory:
        required: false
        type: string
        default: 'terraform'
      # tfvars file path
      terraform-var-file:
        required: false
        type: string
        default: ''
      # infracost usage file path
      usage-file:
        required: false
        type: string
        default: './.env/dev/infracost-usage.yml'

jobs:
  infracost:
    name: Infracost Analysis

    runs-on: ubuntu-latest

    env:
      TF_ROOT: ${{ inputs.working-directory }}

    steps:
      # Harden Runner is a security action to protect our workflow from supply chain attacks
      - name: Harden Runner
        uses: step-security/harden-runner@2e205a28d0e1da00c5f53b161f4067b052c61f34
        with:
          egress-policy: audit # TODO: change to 'egress-policy: block' after couple of runs

      # this step calls infracost/actions/setup@v2, which installs the latest patch version of the Infracost CLI v0.10.x and
      # gets the backward-compatible bug fixes and new resources. Replacing the version number with git SHA is a security hardening measure.
      - name: Setup Infracost
        uses: infracost/actions/setup@6bdd3cb01a306596e8a614e62af7a9c0a133bc5c
        # See https://github.com/infracost/actions/tree/master/setup for other inputs
        with:
          api-key: ${{ secrets.INFRACOST_API_KEY }}

      # Checkout the base branch of the pull request (e.g. main).
      - name: Checkout base branch
        uses: actions/checkout@93ea575cb5d8a053eaa0ac8fa3b40d7e05a33cc8
        with:
          ref: '${{ github.event.pull_request.base.ref }}'

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
      # upload the report to artifact so subsequent workflow can download the report and email it as attachment
      - uses: actions/upload-artifact@83fd05a356d7e2593de66fc9913b3002723633cb
        with:
          name: report.html
          path: ${{ inputs.working-directory }}/report.html

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
                                   --policy-path=${TF_ROOT}/infracost-policy.rego
```

- Conclusion: Implementing the Infracost Terraform tool has been a game-changer for our organization in optimizing cloud infrastructure costs. By providing real-time cost estimation, centralized cost tracking across multiple cloud providers, and enabling cost allocation and forecasting, Infracost has empowered us to make data-driven decisions, optimize spending, and align our infrastructure changes with our budgetary constraints. 
