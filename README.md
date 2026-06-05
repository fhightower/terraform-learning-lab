# terraform-learning-lab

A tiny, cheap, spin-up/tear-down lab for learning **Terraform on AWS with ECS Fargate**.

Deploys a minimal `whoami` HTTP service (returns the container's hostname, IP, and
request headers) onto ECS Fargate — no load balancer, no NAT gateway, no surprises
on your bill. Apply it, poke it, then `terraform destroy`.

## What it teaches

The Terraform in [`terraform/`](terraform/) provisions, from scratch:

- **Networking** — VPC, public subnet, internet gateway, route table, security group
- **Compute** — ECS cluster, Fargate task definition, ECS service
- **Registry** — ECR repository for the container image
- **Identity** — IAM task execution role
- **Observability** — CloudWatch log group (1-day retention)

## Cost

Designed to cost **cents**, not dollars, as long as you tear it down.

| Resource | Cost while running | Notes |
|---|---|---|
| ECS control plane | $0 | Free |
| Fargate task (0.25 vCPU / 0.5 GB) | ~$0.0145/hr | Fargate **Spot** by default → ~70% less |
| ECR / CloudWatch / data transfer | negligible | Tiny image, 1-day log retention |

**No ALB. No NAT gateway.** Those are the hourly money pits. This lab avoids both:
the task runs in a public subnet with a public IP and is reached directly on its
container port.

> ⚠️ Always run `terraform destroy` when you're done. Nothing here costs much per
> hour, but leaving cloud resources running is how test labs become bills.

## Prerequisites

- An AWS account + credentials (`aws configure` or env vars)
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- [Docker](https://docs.docker.com/get-docker/) (to build/push the image)
- AWS CLI v2

## Usage

### 1. Provision the registry + infra

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # edit if you like
terraform init
terraform apply
```

On first apply the ECS service has nothing to run yet (no image pushed). That's
expected — push the image next, then the service pulls it.

### 2. Build and push the image

Terraform outputs the ECR repo URL and a ready-to-run login command:

```bash
terraform output -raw ecr_push_commands
```

Run those (they log in to ECR, build, tag, and push). Or do it by hand from `app/`.

### 3. Force the service to pick up the image

```bash
aws ecs update-service \
  --cluster "$(terraform output -raw cluster_name)" \
  --service "$(terraform output -raw service_name)" \
  --force-new-deployment \
  --region "$(terraform output -raw region)"
```

### 4. Find the task's public IP and hit it

```bash
terraform output -raw how_to_get_url
```

Run the printed command to resolve the running task's public IP, then:

```bash
curl http://<public-ip>:8080/
```

### 5. Tear it all down

```bash
terraform destroy
```

## Layout

```
.
├── app/                 # the whoami service
│   ├── main.go
│   └── Dockerfile       # multi-stage → tiny static image
└── terraform/           # the infrastructure
    ├── versions.tf
    ├── variables.tf
    ├── main.tf
    ├── outputs.tf
    └── terraform.tfvars.example
```

## License

MIT
