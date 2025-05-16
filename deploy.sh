#!/bin/bash

set -e

echo "🔄 Inicializando Terraform..."
cd terraform
terraform init -upgrade

echo "🚀 Aplicando Terraform..."
terraform apply -var-file=terraform.tfvars -auto-approve
cd ..

echo "📦 Buildando e realizando deploy Serverless..."
npm run build && npx serverless deploy
