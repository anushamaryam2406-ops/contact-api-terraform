resource "aws_dynamodb_table" "contact_messages" {
  name         = "${var.project_name}-${var.environment}"
  billing_mode = var.billing_mode

  hash_key  = "email"
  range_key = "timestamp"

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  attribute {
    name = "status"
    type = "S"
  }

  global_secondary_index {
    name = "status-timestamp-index"

    key_schema {
      attribute_name = "status"
      key_type       = "HASH"
    }

    key_schema {
      attribute_name = "timestamp"
      key_type       = "RANGE"
    }

    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = var.enable_pitr
  }

  ttl {
    attribute_name = "expiry_time"
    enabled        = var.enable_ttl
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}"
    Description = "Contact form messages with status tracking"
  }
}