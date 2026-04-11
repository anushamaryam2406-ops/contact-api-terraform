"""
Lambda Function: POST /contact
Handles contact form submissions and saves to DynamoDB
"""

import json
import boto3
import os
import logging  # ← NEW: proper logging library added
from datetime import datetime
from decimal import Decimal

# ← NEW: Setup logger (replaces plain print statements)
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize DynamoDB
dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('TABLE_NAME', 'contact-messages-dev')
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    """
    POST /contact
    Body: { "name": "...", "email": "...", "subject": "...", "message": "..." }
    """

    # ← NEW: Log every incoming request
    logger.info(f"POST /contact called | RequestId: {context.aws_request_id}")

    try:
        if isinstance(event.get('body'), str):
            body = json.loads(event['body'])
        else:
            body = event.get('body', {})

        # ← NEW: Log what data arrived
        logger.info(f"Request body received | email: {body.get('email')} | name: {body.get('name')}")

        # Validate required fields
        required_fields = ['name', 'email', 'message']
        missing_fields = [field for field in required_fields if not body.get(field)]

        if missing_fields:
            # ← NEW: Log validation failure
            logger.warning(f"Validation failed | missing fields: {missing_fields}")
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'Missing required fields',
                    'missing': missing_fields
                })
            }

        # Validate email format
        email = body['email'].strip().lower()
        if '@' not in email or '.' not in email:
            # ← NEW: Log invalid email
            logger.warning(f"Invalid email format received | email: {email}")
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'Invalid email format'
                })
            }

        # Create timestamp
        timestamp = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')

        # Prepare item for DynamoDB
        item = {
            'email': email,
            'timestamp': timestamp,
            'name': body['name'].strip(),
            'message': body['message'].strip(),
            'status': 'new',
            'created_at': timestamp
        }

        if body.get('subject'):
            item['subject'] = body['subject'].strip()

        if body.get('phone'):
            item['phone'] = body['phone'].strip()

        source_ip = event.get('requestContext', {}).get('identity', {}).get('sourceIp')
        if source_ip:
            item['ip_address'] = source_ip

        # ← NEW: Log before saving to DynamoDB
        logger.info(f"Saving to DynamoDB | table: {table_name} | email: {email}")

        # Save to DynamoDB
        table.put_item(Item=item)

        # ← NEW: Log success
        logger.info(f"SUCCESS | message saved | email: {email} | timestamp: {timestamp}")

        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': 'Contact form submitted successfully',
                'id': timestamp,
                'email': email
            })
        }

    except Exception as e:
        # ← IMPROVED: was print(), now proper logger.error()
        logger.error(f"UNHANDLED ERROR | {str(e)} | RequestId: {context.aws_request_id}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'message': str(e)
            })
        }