# Nurudeen Website — Terraform PR Workflow

This project deploys a two-tier AWS website using reusable local Terraform modules:

- **Client tier:** public EC2 instance running Apache HTTP Server (`httpd`) and an `index.html` page welcoming visitors to Nurudeen's website.
- **Middle tier:** private EC2 instance running Apache on port 8080. The client proxies `/middle` requests to it; it has no public IP and accepts traffic only from the client security group.
- **VPC module:** creates the VPC, public and private subnets, internet gateway, routes, and NAT gateway.
- **EC2 module:** creates configurable EC2 instances; the root configuration calls it once per tier.
- **Stable website address:** an Elastic IP is attached to the public client instance.

## Deployment flow

1. Push a change to a feature branch (any branch other than `main`).
2. GitHub Actions checks Terraform formatting and validates the configuration. After successful validation, a separate workflow opens a pull request to `main` if one is not already open for that branch.
3. Review and merge the pull request. Protect `main` so changes must use a pull request.
4. The merge push to `main` starts the deployment workflow, which plans and applies the infrastructure.

The workflow uses AWS OIDC federation rather than long-lived AWS access keys. It does not expose AWS credentials to pull-request validation runs.

## Prerequisites

1. An AWS account and an IAM role that can manage the VPC, EC2, security group, Elastic IP, NAT gateway, and Terraform state resources.
2. Create an AWS IAM OIDC identity provider for `token.actions.githubusercontent.com` if your AWS account does not already have one.
3. Create an IAM role trusted by GitHub OIDC. Restrict its trust policy to the exact GitHub repository and the `main` branch (subject `repo:OWNER/REPOSITORY:ref:refs/heads/main`) for deployment.
4. Add a repository Actions secret named `AWS_ROLE_ARN` containing the IAM role ARN. Do not add long-lived AWS access keys.
5. Create the S3 state bucket `terraform-lwplabs-olajide` in `us-east-1` before the first deployment. Enable bucket versioning and block public access. This project uses the distinct state key `pr-workflow/nurudeen-website/terraform.tfstate`.
6. In the GitHub repository's **Settings > Actions > General > Workflow permissions**, enable **Allow GitHub Actions to create and approve pull requests** so the pull-request creation workflow can open PRs using `GITHUB_TOKEN`.
7. Protect `main` in **Settings > Branches** or **Rules > Rulesets**: require pull requests and require the **Validate Terraform / validate** status check before merging. This prevents a direct push to `main` from bypassing review. Enable the setting that requires branches to be up to date if desired.

Grant the deployment role least privilege: include only required resource-management permissions and access to this project's S3 state object. The first run may also require permissions for provider-managed VPC and EC2 operations. Review AWS IAM policy requirements for your account before deployment.

## Put this project in its own GitHub repository

GitHub only discovers Actions workflows under `.github/workflows/` at the repository root. This project is in the `PR-Workflow` subfolder of a larger workspace, so create a dedicated repository and put the files from this folder at its root.

To keep the first infrastructure deployment behind a reviewed PR, bootstrap the new repository with only the workflows on `main`. The deploy workflow watches Terraform files, so this bootstrap commit does not create AWS resources. From this folder, after creating an empty GitHub repository:

```shell
git init -b main
git add .github/workflows
git commit -m "Add Terraform validation and deployment workflows"
git remote add origin https://github.com/OWNER/REPOSITORY.git
git push -u origin main
```

Then configure workflow permissions, protect `main`, and configure the AWS role secret and S3 backend bucket. Add the infrastructure on a feature branch and push it; after validation, the PR workflow opens a PR. Merging that PR triggers the first deployment. Do not put an AWS role secret in a repository with untrusted contributors or unreviewed deployment code.

## Run locally

From this project directory, with Terraform and AWS CLI credentials configured:

```shell
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
terraform output -raw website_url
```

To destroy the resources:

```shell
terraform destroy -var-file="terraform.tfvars"
```

## Configuration and costs

Edit `terraform.tfvars` to choose an AWS region, an availability zone in that region, and an EC2 instance type. If you change regions, also update the backend region in `versions.tf` and `AWS_REGION` in `.github/workflows/deploy.yml`.

The deployment includes two EC2 instances, a NAT gateway, and Elastic IPs. NAT gateways incur hourly and data-processing charges. Run `terraform destroy` when the environment is no longer needed. The pre-created S3 state bucket is not managed or deleted by this configuration.
