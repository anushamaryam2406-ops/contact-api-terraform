# Contact API - Serverless Backend

> **Serverless Contact/Feedback API with DynamoDB, Lambda & API Gateway**

## 🎯 Project Overview

A production-ready serverless backend for website contact forms. Users can submit messages via API, and admins can retrieve them with filtering capabilities.

**Live API Endpoint:**  
`https://sveskt3il4.execute-api.ap-south-1.amazonaws.com/dev`

---

## 🏗️ Architecture

```
User/Website
    ↓
API Gateway (POST /contact, GET /messages)
    ↓
Lambda Functions (Validation & Processing)
    ↓
DynamoDB (Persistent Storage)
    ↓
CloudWatch (Logging & Monitoring)
```

---

## 🛠️ Tech Stack

- **Infrastructure:** Terraform
- **Backend:** AWS Lambda (Python 3.11)
- **API:** API Gateway (HTTP API)
- **Database:** DynamoDB with GSI
- **State Management:** S3 + DynamoDB locks
- **Logging:** CloudWatch Logs
- **Region:** ap-south-1 (Mumbai)

---

## 📦 Resources Created

### DynamoDB
- **Table:** `contact-messages-dev`
- **Partition Key:** email (String)
- **Sort Key:** timestamp (String)
- **GSI:** status-timestamp-index (for filtering by status)

### Lambda Functions
- **POST Handler:** `contact-messages-post-dev`
- **GET Handler:** `contact-messages-get-dev`

### API Gateway
- **Endpoint:** `https://sveskt3il4.execute-api.ap-south-1.amazonaws.com/dev`
- **Routes:**
  - `POST /contact` - Submit contact form
  - `GET /messages` - Retrieve messages

### IAM & Logging
- Lambda execution role with DynamoDB permissions
- CloudWatch log groups for all functions

---

## 🚀 Deployment

```bash
# Clone repository
git clone <your-repo-url>
cd contact-api

# Initialize Terraform
terraform init

# Review changes
terraform plan

# Deploy infrastructure
terraform apply

# Get API endpoint
terraform output api_endpoint
```

---

## 📡 API Usage

### Submit Contact Form (POST)

```bash
curl -X POST https://sveskt3il4.execute-api.ap-south-1.amazonaws.com/dev/contact \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "subject": "Question",
    "message": "Hello, I have a question..."
  }'
```

**Response:**
```json
{
  "message": "Contact form submitted successfully",
  "id": "2026-03-30T10:30:00Z",
  "email": "john@example.com"
}
```

### Get All Messages (GET)

```bash
curl "https://sveskt3il4.execute-api.ap-south-1.amazonaws.com/dev/messages"
```

### Filter by Status (Uses GSI)

```bash
curl "https://sveskt3il4.execute-api.ap-south-1.amazonaws.com/dev/messages?status=new"
```

### Filter by Email (Uses Main Table)

```bash
curl "https://sveskt3il4.execute-api.ap-south-1.amazonaws.com/dev/messages?email=john@example.com"
```

---

## 🗂️ Project Structure

```
contact-api/
├── main.tf                    # Main infrastructure
├── variables.tf              # Input variables
├── outputs.tf                # Output values
├── terraform.tfvars          # Configuration values
├── lambda_post_contact.py    # POST handler
├── lambda_get_messages.py    # GET handler
├── contact-form.html         # Demo HTML form
└── README.md                 # This file
```

---

## 📊 Data Schema

```json
{
  "email": "user@example.com",        // Partition Key
  "timestamp": "2026-03-30T10:30:00Z", // Sort Key
  "name": "John Doe",
  "subject": "Question",              // Optional
  "message": "Hello...",
  "status": "new",                     // new|read|archived
  "created_at": "2026-03-30T10:30:00Z",
  "ip_address": "103.255.4.23"        // Optional
}
```

---

## 🎓 What I Learned

### Concepts Mastered:
- ✅ DynamoDB partition keys & sort keys
- ✅ Global Secondary Index (GSI) design
- ✅ Query vs Scan performance
- ✅ Access pattern analysis
- ✅ Terraform remote backend (S3 + state locking)
- ✅ Lambda function development
- ✅ API Gateway HTTP APIs
- ✅ Input validation & error handling
- ✅ IAM roles & permissions
- ✅ CloudWatch logging

---

## 💰 Cost Estimate

**Development (Current):**
- DynamoDB: ~$0 (free tier)
- Lambda: ~$0 (free tier covers 1M requests)
- API Gateway: ~$0 (free tier covers 1M requests)
- CloudWatch: ~$0.50/month
- **Total: < $1/month**

**Production (1000 requests/day):**
- DynamoDB: ~$1/month
- Lambda: ~$0.50/month
- API Gateway: ~$1/month
- CloudWatch: ~$2/month
- **Total: ~$5/month**

---

## 🧪 Testing

### Automated Testing (cURL)
See API Usage section above.

### Manual Testing (HTML Form)
1. Open `contact-form.html` in browser
2. Fill form and submit
3. Check DynamoDB Console for saved message

### Verification
- ✅ POST /contact saves to DynamoDB
- ✅ GET /messages retrieves all messages
- ✅ GET /messages?status=new uses GSI (fast!)
- ✅ GET /messages?email=X uses main table (fast!)
- ✅ Input validation works (try submitting incomplete form)

---

## 🔐 Security Features

- ✅ CORS enabled (can be restricted to specific domains)
- ✅ Input validation (email format, required fields)
- ✅ IAM least-privilege roles
- ✅ DynamoDB encryption at rest
- ✅ CloudWatch logging for audit trail

---

## 🚀 Future Enhancements

- [ ] Add authentication (API keys or Cognito)
- [ ] Rate limiting per IP
- [ ] Email notifications on new messages
- [ ] Admin dashboard UI
- [ ] Message status update endpoint (mark as read)
- [ ] CAPTCHA integration
- [ ] File attachment support

---

## 🗑️ Cleanup

```bash
# Destroy all resources
terraform destroy

# Type: yes

# This will delete:
# - DynamoDB table (and all data!)
# - Lambda functions
# - API Gateway
# - IAM roles
# - CloudWatch logs
```

---

## 📚 Related Projects

- **Phase 2:** [Cloud Resume - Visitor Counter](../visitor-counter)
- **Phase 4:** CI/CD Pipeline (Coming soon)

---

## 👩‍💻 Author

**Anusha**  
Learning AWS & Serverless Architecture  
Phase 3 of Cloud Learning Journey

---

## 📝 License

This is a learning project - feel free to use and modify!

---

## 🙏 Acknowledgments

Built as part of structured AWS learning path covering:
- Phase 1: AWS Fundamentals
- Phase 2: Serverless Architecture (Visitor Counter)
- Phase 3: Data Layer & State Management (This project)
- Phase 4: CI/CD & Automation (Next)
