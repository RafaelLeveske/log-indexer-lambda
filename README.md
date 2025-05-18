# 🔁 Log Indexer Lambda

Lambda function responsible for consuming logs from **CloudWatch Logs** and indexing them into **OpenSearch** using IAM authentication (SigV4).

---

## 🚀 Technologies and Tools

- **AWS Lambda** (Node.js 22)
- **AWS CloudWatch Logs**
- **AWS IAM** with SigV4 signature
- **Amazon OpenSearch** (with FGAC enabled)
- **Serverless Framework** v4
- **Terraform**
- **TypeScript**

---

## 📌 What does this project do?

This project listens to logs coming from the `log-generator-lambda` function via **CloudWatch Logs**, and indexes them into **OpenSearch** using IAM-based authentication. The function uses **SigV4 signing** with specific roles and secure communication with the OpenSearch domain provisioned via **Terraform**.

---

## 🧱 Project Structure

```
├── src/
│   ├── handler.ts             # Lambda handler that processes logs
│   └── utils/sigv4-signer.ts  # Utility for SigV4 request signing
├── terraform/                 # OpenSearch infrastructure + roles
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
├── serverless.yml             # Serverless Framework configuration
├── package.json
└── tsconfig.build.json
```

---

## ⚙️ Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed
- Serverless Framework v4 installed
- Store the parameters below in AWS SSM Parameter Store:

```bash
aws ssm put-parameter \
  --name /log-indexer-lambda/OPENSEARCH_ENDPOINT \
  --value "https://<endpoint>" \
  --type String

aws ssm put-parameter \
  --name /log-indexer-lambda/OPENSEARCH_INDEX \
  --value "application-logs" \
  --type String

aws ssm put-parameter \
  --name /opensearch/master_password \
  --value "StrongPassword@123" \
  --type SecureString
```

---

## 📦 Deployment

**1. Deploy infrastructure (Terraform):**

```bash
cd terraform
terraform init
terraform apply -auto-approve
```

**2. Deploy Lambda function:**

```bash
npm install
npm run build
npm run deploy
```

---

## 🔁 Testing the flow

Trigger log generation using the `log-generator-lambda` function:

```bash
aws lambda invoke \
  --function-name log-generator-lambda-dev-generateLogs \
  --payload '{}' \
  response.json
```

Monitor logs in real time:

```bash
aws logs tail /aws/lambda/log-indexer-lambda-dev-indexLogs --follow
```

---

## 🔐 Security

- **FGAC** enabled on OpenSearch
- Lambda IAM Role mapped to an internal role in OpenSearch
- Authentication using **SigV4**
- Sensitive credentials stored in **AWS SSM Parameter Store**

---

## 📊 Observability

All logs are stored in the `application-logs` index and can be visualized via **OpenSearch Dashboards**:

```
https://<your-endpoint>/_dashboards
```

---

## 🧠 Learnings

- Secure integration between **Lambda**, **CloudWatch Logs**, and **OpenSearch**
- Use of **SigV4 signing** with mapped roles
- Real-world troubleshooting with **403 errors** and **FGAC**
- Fully automated infrastructure using **Terraform**

---
