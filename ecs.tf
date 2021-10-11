resource "aws_ecs_cluster" "todo-cluster" {
  name               = "todo-app"
  capacity_providers = ["FARGATE"]
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}


resource "aws_ecs_task_definition" "todo-app" {
  family                   = "todo-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = "arn:aws:iam::414402433373:role/ECSPermissions-task"
  depends_on               = [aws_cloudwatch_log_group.tf-ecs-todo-logs]
  container_definitions    = <<TASK_DEFINITION
[
		{
			"name": "todo-app",
			"cpu": 1,
			"essential": true,
			"image": "cgdv/getting-started",
			"memory": 128,
			"portMappings": [
				{
					"containerPort": 3000,
					"hostPort": 3000
				}
			],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                  "awslogs-group" : "tf-ecs-todo-logs",
                  "awslogs-region": "us-east-1",
                  "awslogs-stream-prefix": "demo"
                }
		    }
    }
]
TASK_DEFINITION
}


resource "aws_ecs_service" "todo-app" {
  name                   = "todo-app"
  cluster                = aws_ecs_cluster.todo-cluster.id
  task_definition        = aws_ecs_task_definition.todo-app.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  platform_version       = "1.4.0"
  enable_execute_command = true

  network_configuration {
    subnets          = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id, aws_subnet.public_subnet_3.id]
    security_groups  = [aws_security_group.http.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.example-tg.arn
    container_name   = "todo-app"
    container_port   = 3000
  }
}

