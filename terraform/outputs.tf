output "opensearch_endpoint" {
  value = aws_opensearch_domain.log_observability.endpoint
}

output "opensearch_dashboard_url" {
  value = aws_opensearch_domain.log_observability.endpoint
  description = "OpenSearch dashboard URL"
} 