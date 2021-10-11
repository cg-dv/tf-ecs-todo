resource "aws_cloudwatch_log_group" "docker-logs" {
  name = "docker-logs"
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id             = aws_vpc.example.id
  service_name       = "com.amazonaws.us-east-1.logs"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.http.id]
}
