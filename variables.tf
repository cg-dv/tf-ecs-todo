data "aws_secretsmanager_secret_version" "credentials" {
  secret_id = "arn:aws:secretsmanager:us-east-1:414402433373:secret:tf-3-tier-credentials-kG8z3u"
}

locals {
  db_credentials = jsondecode(
    data.aws_secretsmanager_secret_version.credentials.secret_string
  )
}
