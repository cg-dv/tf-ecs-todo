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
  depends_on               = [aws_cloudwatch_log_group.docker-logs]
  container_definitions    = <<TASK_DEFINITION
[
		{
			"name": "todo-app",
			"cpu": 1,
			"environment": [
				{"name": "MYSQLHOST", "value": "${local.db_credentials.host}"}, {"name": "MYSQL_USER", "value": "${local.db_credentials.username}"}, {"name": "MYSQL_PASSWORD", "value": "${local.db_credentials.password}"}, {"name": "MYSQL_DB", "value": "${local.db_credentials.database}"}
			],
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
                  "awslogs-group" : "docker-logs",
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

resource "aws_ecs_task_definition" "mysql-task-def" {
  family                   = "mysql-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  #cpu                      = 1024
  cpu = 2048
  #memory                   = 2048
  memory                = 16384
  execution_role_arn    = data.aws_iam_role.ecs_task_execution_role.arn
  task_role_arn         = "arn:aws:iam::414402433373:role/ECSPermissions-task"
  depends_on            = [aws_efs_file_system.todo-efs]
  container_definitions = <<TASK_DEFINITION
[
		{
			"name": "mysql-task",
			"cpu": 2,
			"environment": [
				{"name": "MYSQL_ROOT_PASSWORD", "value": "${local.db_credentials.password}"}, {"name": "MYSQL_DATABASE", "value": "${local.db_credentials.database}"}],
			"essential": true,
			"image": "mysql:latest",
			"memory": 16384,
            "ulimits": [
              {
                "name": "nofile",
                "softlimit": 2048,
                "hardlimit": 8192
              }
            ],
			"portMappings": [
				{
					"containerPort": 3306,
					"hostPort": 3306
				} ], 
            "mountPoints": [{"containerPath" : "/var/lib/mysql",
            "sourceVolume" : "mysql-storage",
            "readOnly" : false }],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                  "awslogs-group" : "docker-logs",
                  "awslogs-region": "us-east-1",
                  "awslogs-stream-prefix": "demo-mysql"
                }
		    }
    }
]
TASK_DEFINITION
  #"mountPoints": [{"containerPath" : "/var/lib/mysql",
  #"sourceVolume" : "mysql-storage",
  #"readOnly" : false }],
  volume {
    name = "mysql-storage"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.todo-efs.id
      root_directory     = "/var/lib/mysql"
      transit_encryption = "ENABLED"
    }
  }
}

resource "aws_ecs_service" "mysql-app" {
  name                   = "mysql-app"
  cluster                = aws_ecs_cluster.todo-cluster.id
  task_definition        = aws_ecs_task_definition.mysql-task-def.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  platform_version       = "1.4.0"
  enable_execute_command = true

  network_configuration {
    #subnets          = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_3.id]
    subnets          = [aws_subnet.private_subnet_1.id]
    security_groups  = [aws_security_group.mysql.id]
    assign_public_ip = false
  }
}
