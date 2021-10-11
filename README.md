# ECS Todo App

This Terraform project deploys a simple 'todo' list app from the
[Docker documentation]() to an ECS Fargate task.  The ECS deployment is load-balanced
by an Application Load Balancer to split traffic amongst multiple Fargate tasks
running the app.  This Terraform configuration defines three public subnets
in which the app can be deployed for the purpose of high availability.


## Usage:

Initalize Terraform and S3 remote backend:
    init terraform

Build infrastructure:
    terraform apply

## Outputs:
Application Load Balancer URL

(May have to remove 'S" from 'HTTPS' in URL - as SSL/TLS not configured for
this configuration - additionally, ALB may return 503 error for a minute or two
prior to actual launch of task - refresh page after a minute or two and task
should be active).
