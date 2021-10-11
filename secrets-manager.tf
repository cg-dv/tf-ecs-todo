resource "aws_secretsmanager_secret_version" "new_secret_version" {
  secret_id = "arn:aws:secretsmanager:us-east-1:414402433373:secret:tf-3-tier-credentials-kG8z3u"
  secret_string = jsonencode(
    {
      "host" : local.db_credentials.host,
      "username" : local.db_credentials.username,
      "password" : local.db_credentials.password,
      "database" : local.db_credentials.database
    }
  )

  depends_on = [
    data.aws_secretsmanager_secret_version.credentials
  ]
}
