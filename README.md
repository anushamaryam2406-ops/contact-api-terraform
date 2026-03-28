# Contact API - Infrastructure

Production-ready DynamoDB backend for website contact forms.

## 📁 Project Structure

```
contact-api/
├── main.tf              # Main infrastructure (DynamoDB, IAM, CloudWatch)
├── variables.tf         # Input variables
├── outputs.tf          # Output values
├── terraform.tfvars    # Your configuration
└── README.md           # This file
```

## 🚀 Quick Start

### Prerequisites
- Terraform >= 1.0
- AWS CLI configured
- S3 bucket: `anusha-tf-state-2024` (already exists)
- DynamoDB table: `terraform-state-locks` (already exists)

### Deployment

```bash
# 1. Navigate to project folder
cd contact-api/

# 2. Initialize Terraform
terraform init

# 3. Review what will be created
terraform plan

# You should see:
# - DynamoDB table: contact-messages-dev
# - IAM role for Lambda
# - CloudWatch log group
# - GSI: status-timestamp-index

# 4. Deploy infrastructure
terraform apply

# Type: yes

# 5. Save outputs
terraform output > deployment-info.txt
```

## 📊 What Gets Created

### DynamoDB Table
- **Name**: `contact-messages-dev`
- **Partition Key**: email (String)
- **Sort Key**: timestamp (String)
- **GSI**: status-timestamp-index
- **Billing**: On-Demand (pay per request)
- **Encryption**: Enabled (server-side)

### IAM Role
- **Name**: `contact-messages-lambda-role-dev`
- **Permissions**: DynamoDB read/write, CloudWatch logs
- **Ready for**: Lambda functions (Phase 3 Week 12)

### CloudWatch
- **Log Group**: `/aws/lambda/contact-messages-dev`
- **Retention**: 7 days

## 🔍 Testing Queries

### Query 1: Get messages by email
```bash
aws dynamodb query \
  --table-name contact-messages-dev \
  --key-condition-expression "email = :email" \
  --expression-attribute-values '{":email":{"S":"anusha@example.com"}}'
```

### Query 2: Get NEW messages (using GSI)
```bash
aws dynamodb query \
  --table-name contact-messages-dev \
  --index-name status-timestamp-index \
  --key-condition-expression "#status = :status" \
  --expression-attribute-names '{"#status":"status"}' \
  --expression-attribute-values '{":status":{"S":"new"}}'
```

## 📝 Data Schema

```json
{
  "email": "user@example.com",        // Partition Key
  "timestamp": "2024-03-25T10:30:00Z", // Sort Key
  "name": "John Doe",                  // Required
  "subject": "Question",               // Optional
  "message": "Hello...",               // Required
  "status": "new",                     // new|read|archived
  "created_at": "2024-03-25T10:30:00Z",
  "ip_address": "103.255.4.23",        // Optional
  "phone": "+92-300-1234567"           // Optional
}
```

## 🎯 Access Patterns (Query Support)

| Query | Method | Performance |
|-------|--------|-------------|
| Get messages by email | Main table | FAST ✅ |
| Get all NEW messages | GSI | FAST ✅ |
| Get messages by date range | Main table + sort key | FAST ✅ |
| Get NEW messages last 7 days | GSI + date range | FAST ✅ |
| Search by keyword | Scan | SLOW ⚠️ |

## 🔧 Configuration

### Development (Current)
```hcl
environment  = "dev"
billing_mode = "PAY_PER_REQUEST"
enable_pitr  = false
log_retention_days = 7
```

### Production (Future)
```hcl
environment  = "prod"
billing_mode = "PAY_PER_REQUEST"  # or PROVISIONED
enable_pitr  = true
log_retention_days = 30
```

## 💰 Cost Estimate

### Development
- DynamoDB: ~$0 (free tier covers development)
- CloudWatch Logs: ~$0.50/month
- **Total: < $1/month**

### Production (1000 requests/day)
- DynamoDB: ~$1/month
- CloudWatch: ~$2/month
- PITR: ~$5/month (depends on table size)
- **Total: ~$8/month**

## 🧹 Cleanup

```bash
# Destroy all resources
terraform destroy

# Type: yes

# This will delete:
# - DynamoDB table (and all data!)
# - IAM role
# - CloudWatch log group
```

## 📚 Next Steps

**Week 12 (Coming Soon):**
1. Create Lambda functions (POST /contact, GET /messages)
2. Add API Gateway
3. Add input validation
4. Add error handling
5. Deploy complete API

## 🔗 Related Files

- State backend: `s3://anusha-tf-state-2024/contact-api/terraform.tfstate`
- State locks: DynamoDB table `terraform-state-locks`

## 📞 Support

Questions? Review:
- Phase 3 learning guide
- DynamoDB documentation
- Terraform AWS provider docs
