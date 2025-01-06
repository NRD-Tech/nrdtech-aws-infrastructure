# Shared AWS Infrastructure
This project defines AWS elements that are shared across multiple AWS projects.

# Technology Stack
* Bash
* Terraform

# Using this Template

## Clone and Clean the template (if using GitHub)
* Navigate to: https://github.com/NRD-Tech/nrdtech-aws-infrastructure
* Log into your GitHub account (otherwise the "Use this template" option will not show up)
* Click "Use this template" in the top right corner
  * Create a new repository
* Fill in your repository name, description, and public/private setting
* Clone your newly created repository
* If you want to change the license to be proprietary follow these instructions: [Go to Proprietary Licensing Section](#how-to-use-this-template-for-a-proprietary-project)

## Clone and Clean the template (if NOT using GitHub)
```
git clone https://github.com/NRD-Tech/nrdtech-aws-infrastructure.git my-project
cd my-project
rm -fR .git venv .idea
git init
git add .
git commit -m 'init'
```
* If you want to change the license to be proprietary follow these instructions: [Go to Proprietary Licensing Section](#how-to-use-this-template-for-a-proprietary-project)

## OIDC Pre-Requisite
* You must have previously set up the AWS Role for OIDC and S3 bucket for the Terraform state files
* The easiest way to do this is to use the NRD-Tech Terraform Bootstrap template
  * https://github.com/NRD-Tech/nrdtech-terraform-aws-account-bootstrap
  * After following the README.md instructions in the bootstrap template project you should have:
    * An AWS Role ARN
    * An AWS S3 bucket for the Terraform state files

## AWS Pre-Requisite
* Configure VPC Subnets with names that have "private" or "public" in them
  * Examples:
    * public-subnet-west-2a
    * private-subnet-west-2a
  * Terraform uses this to determine in which subnets to deploy the tasks

## Configure
* Edit the .env.* files
  * Each config is a little different per application but at a minimum you will need to change:
    * APP_IDENT
    * TERRAFORM_STATE_BUCKET
    * AWS_DEFAULT_REGION
* Edit the terraform/*.tf files and un-comment the infrastructure parts that you want.
  * By default everything is commented out so you don't create things you don't need
* Commit your changes to git
```
git commit -a -m 'updated config'
```

## (If using Bitbucket) Enable Bitbucket Pipeline (NOTE: GitHub does not require any setup like this for the Actions to work)
* Push your git project up into a new Bitbucket project
* Navigate to your project on Bitbucket
  * Click Repository Settings
  * Click Pipelines->Settings
    * Click Enable Pipelines

## (If using GitHub) Configure the AWS Role
* Edit .github/workflows/main.yml
  * Set the pipeline role for role-to-assume
  * Set the correct aws-region

## Deploy to Staging
```
git checkout -b staging
git push --set-upstream origin staging
```

## Deploy to Production
```
git checkout -b production
git push --set-upstream origin production
```

## Un-Deploying in Bitbucket
1. Navigate to the Bitbucket project website
2. Click Pipelines in the left nav menu
3. Click Run pipeline button
4. Choose the branch you want to un-deploy
5. Choose the appropriate un-deploy Pipeline
   * un-deploy-staging
   * un-deploy-production
6. Click Run

# Misc How-To's

## How to use this template for a proprietary project
This project's license (MIT License) allows for you to create proprietary code based on this template.

Here are the steps to correctly do this:
1. Replace the LICENSE file with your proprietary license terms if you wish to use your own license.
2. Optionally, include a NOTICE file stating that the original work is licensed under the MIT License and specify the parts of the project that are governed by your proprietary license.
