output "region" {
  description = "Deployment region."
  value       = var.region
}

output "cluster_name" {
  description = "ECS cluster name."
  value       = aws_ecs_cluster.main.name
}

output "service_name" {
  description = "ECS service name."
  value       = aws_ecs_service.app.name
}

output "ecr_repository_url" {
  description = "Push the image here, tagged :latest."
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_push_commands" {
  description = "Copy/paste to log in, build, tag, and push the image."
  value       = <<-EOT
    aws ecr get-login-password --region ${var.region} \
      | docker login --username AWS --password-stdin ${split("/", aws_ecr_repository.app.repository_url)[0]}
    docker build -t ${var.name} ../app
    docker tag ${var.name}:latest ${aws_ecr_repository.app.repository_url}:latest
    docker push ${aws_ecr_repository.app.repository_url}:latest
  EOT
}

output "how_to_get_url" {
  description = "Resolve the running task's public IP, then curl it on the container port."
  value       = <<-EOT
    TASK_ARN=$(aws ecs list-tasks --cluster ${aws_ecs_cluster.main.name} --service-name ${aws_ecs_service.app.name} --region ${var.region} --query 'taskArns[0]' --output text)
    ENI=$(aws ecs describe-tasks --cluster ${aws_ecs_cluster.main.name} --tasks "$TASK_ARN" --region ${var.region} --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text)
    aws ec2 describe-network-interfaces --network-interface-ids "$ENI" --region ${var.region} --query 'NetworkInterfaces[0].Association.PublicIp' --output text
    # then: curl http://<public-ip>:${var.container_port}/
  EOT
}
