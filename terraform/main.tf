provider "aws" {
  region = var.aws_region
}

# Busca a senha do usuário master a partir do Parameter Store (SSM)
data "aws_ssm_parameter" "opensearch_password" {
  name = var.ssm_password_parameter_name
  with_decryption = true
}

data "aws_caller_identity" "current" {}

resource "aws_opensearch_domain" "log_observability" {
  domain_name           = var.domain_name
  engine_version        = var.engine_version

  cluster_config {
    instance_type = "t3.small.search"
    instance_count = 1
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
    volume_type = "gp2"
  }

  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = { AWS = "*" }
        Action = "es:*"
        Resource = "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}/*"
      }
    ]
  })

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.master_user
      master_user_password = data.aws_ssm_parameter.opensearch_password.value
    }
  }

  node_to_node_encryption {
    enabled = true
  }

  encrypt_at_rest {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https = true
  }
}

resource "null_resource" "create_opensearch_role" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "🔐 Criando ou atualizando role lambda-writer-role..."
      curl -X PUT \
        -u ${var.master_user}:${data.aws_ssm_parameter.opensearch_password.value} \
        -H "Content-Type: application/json" \
        -d '{
          "description": "Lambda writer role",
          "cluster_permissions": [],
          "index_permissions": [
            {
              "index_patterns": ["${var.index_name}"],
              "allowed_actions": [
                "indices:data/write/index",
                "indices:data/write/bulk",
                "indices:data/write/doc",
                "indices:admin/create"
              ]
            }
          ],
          "tenant_permissions": []
        }' \
        https://${aws_opensearch_domain.log_observability.endpoint}/_plugins/_security/api/roles/lambda-writer-role
    EOT
  }

  depends_on = [aws_opensearch_domain.log_observability]
}

resource "null_resource" "map_iam_role_to_opensearch" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "🔁 Mapeando IAM role para lambda-writer-role..."
      curl -X PUT \
        -u ${var.master_user}:${data.aws_ssm_parameter.opensearch_password.value} \
        -H "Content-Type: application/json" \
        -d '{
          "backend_roles": ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/log-indexer-lambda-dev-us-east-1-lambdaRole"]
        }' \
        https://${aws_opensearch_domain.log_observability.endpoint}/_plugins/_security/api/rolesmapping/lambda-writer-role
    EOT
  }

  depends_on = [null_resource.create_opensearch_role]
}