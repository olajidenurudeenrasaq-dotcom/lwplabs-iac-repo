# lwplabs IaC Repo

This repository deploys a simple AWS infrastructure stack using reusable Terraform modules from the GitHub module repo.

## What this deploys

- VPC
- Public subnet
- Internet gateway
- Public route table
- Network ACL
- Security group
- 1 EC2 instance

## Prerequisites

For local Terraform runs, make sure you have:

- Terraform installed
- AWS CLI configured with credentials
- Access to an AWS account

For GitHub Actions, make sure:

- The repository has Actions enabled.
- The repository has the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` Actions secrets configured under **Settings > Secrets and variables > Actions**.
- `terraform.tfvars` is committed to the repository and contains the non-secret configuration used by the workflows. The workflows read the AWS region from this file and pass it to Terraform.
- The S3 bucket configured as the Terraform backend in `versions.tf` already exists, and the AWS credentials can access the bucket and manage the Terraform resources.

Do not put AWS credentials or other secrets in `terraform.tfvars`. Keep credentials in GitHub Actions secrets for CI/CD, or configure them locally using the AWS CLI:

```bash
aws configure
```

Alternatively, set environment variables locally:

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

## Local Terraform usage

### 1. Change to the repo folder

```bash
cd lwplabs-iac-repo
```

### 2. Create your tfvars file

Copy the example values into a real file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Then edit `terraform.tfvars` with your own values. Example configuration:

```hcl
aws_region                = "us-east-1"
project_name              = "lwplabs"
environment               = "dev"
vpc_cidr                  = "10.0.0.0/16"
public_subnets            = ["10.0.1.0/24"]
private_subnets           = ["10.0.10.0/24"]
availability_zones        = ["us-east-1a"]
private_availability_zones = ["us-east-1a"]

public_nacl_ingress_rules = [
  { rule_no = 100, action = "allow", protocol = "tcp", from_port = 22, to_port = 22, cidr_block = "0.0.0.0/0" },
  { rule_no = 110, action = "allow", protocol = "tcp", from_port = 80, to_port = 80, cidr_block = "0.0.0.0/0" },
  { rule_no = 120, action = "allow", protocol = "tcp", from_port = 443, to_port = 443, cidr_block = "0.0.0.0/0" }
]

public_nacl_egress_rules = [
  { rule_no = 100, action = "allow", protocol = "-1", from_port = 0, to_port = 0, cidr_block = "0.0.0.0/0" }
]

private_nacl_ingress_rules = [
  { rule_no = 100, action = "allow", protocol = "tcp", from_port = 443, to_port = 443, cidr_block = "10.0.1.0/24" }
]

private_nacl_egress_rules = [
  { rule_no = 100, action = "allow", protocol = "-1", from_port = 0, to_port = 0, cidr_block = "0.0.0.0/0" }
]

instance_type = "t3.micro"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review the plan

```bash
terraform plan -var-file="terraform.tfvars"
```

### 5. Apply the infrastructure

```bash
terraform apply -var-file="terraform.tfvars"
```

When prompted, type:

```bash
yes
```

### 6. Destroy resources when finished

```bash
terraform destroy -var-file="terraform.tfvars"
```

## GitHub Actions workflows

The repository includes three Terraform workflows:

| Workflow | Trigger | What it does |
| --- | --- | --- |
| **Terraform PR Validation** | Pull request targeting `main` | Initializes Terraform, validates the configuration, and creates a plan. It does not apply changes. |
| **Terraform Infrastructure** | Push to `main`, or manual run | Creates and applies a Terraform plan to deploy or update the infrastructure. |
| **Destroy Terraform Infrastructure** | Manual run only | Creates and applies a Terraform destroy plan to remove the infrastructure managed by this Terraform state. |

### Deploy or update with GitHub Actions

1. Configure the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` repository Actions secrets.
2. Ensure `terraform.tfvars` is present in the repository and contains the intended, non-secret configuration.
3. Merge or push a change to `main` to run **Terraform Infrastructure**, or open **Actions**, select **Terraform Infrastructure**, and choose **Run workflow** to start it manually.
4. Review the run and its logs in the Actions tab.

The deployment workflow applies changes automatically; it does not pause for an interactive approval. Pull requests targeting `main` run validation and a plan only.

### Destroy infrastructure with GitHub Actions

1. Open the repository's **Actions** tab.
2. Select **Destroy Terraform Infrastructure** and choose **Run workflow**.
3. Select the branch containing the workflow. When prompted for `confirm_destroy`, type the exact lowercase keyword `destroy`.
4. Choose **Run workflow** and follow the run in the Actions tab.

If the confirmation value is not exactly `destroy`, the workflow fails before checking out the code or accessing AWS. When confirmed, it creates and applies a destroy plan without an additional interactive approval. This removes resources managed in the configured Terraform state; it does not delete the S3 backend bucket or state file.

## Module source example

The root repo consumes the shared modules from GitHub:

```hcl
module "vpc" {
  source = "git::https://github.com/olajidenurudeenrasaq-dotcom/AWS-Modules.git//vpc?ref=main"

  name                       = var.project_name
  vpc_cidr                   = var.vpc_cidr
  public_subnets             = var.public_subnets
  private_subnets            = var.private_subnets
  availability_zones         = var.availability_zones
  private_availability_zones = var.private_availability_zones

  public_nacl_ingress_rules  = var.public_nacl_ingress_rules
  public_nacl_egress_rules   = var.public_nacl_egress_rules
  private_nacl_ingress_rules = var.private_nacl_ingress_rules
  private_nacl_egress_rules  = var.private_nacl_egress_rules
}
```

## Notes

- The Terraform modules are pulled from GitHub using the `main` branch.
- The source is defined in the root module files using `git::https://github.com/olajidenurudeenrasaq-dotcom/AWS-Modules.git//<module>?ref=main`.
- The VPC module supports both public and private subnets as well as separate public/private NACL rule sets.
- GitHub Actions requires `terraform.tfvars` to be available in the checked-out repository. Commit only non-secret configuration values; never commit credentials, keys, or other secrets.
- The Terraform state is stored in the S3 backend configured in `versions.tf`. Both deployment and destroy workflows use that same state.
