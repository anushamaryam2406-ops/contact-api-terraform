"""
Lambda Function: POST /contact
Handles contact form submissions and saves to DynamoDB
"""

import json
import boto3
import os
from datetime import datetime
from decimal import Decimal

# Initialize DynamoDB
dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('TABLE_NAME', 'contact-messages-dev')
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    """
    POST /contact
    Body: { "name": "...", "email": "...", "subject": "...", "message": "..." }
    """
    
    try:
        # Parse request body Problem: API Gateway sends data in weird format
#Sometimes: body is string (needs parsing)
#Sometimes: body is already dictionary (no parsing needed)
#This code: Handles both cases
        if isinstance(event.get('body'), str):
            body = json.loads(event['body'])
        else:
            body = event.get('body', {})
        
        # Validate required fields
        required_fields = ['name', 'email', 'message']
        missing_fields = [field for field in required_fields if not body.get(field)]
        
        if missing_fields:
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
        
        # Add optional fields
        if body.get('subject'):
            item['subject'] = body['subject'].strip()
        
        if body.get('phone'):
            item['phone'] = body['phone'].strip()
        
        # Get source IP (optional)
        source_ip = event.get('requestContext', {}).get('identity', {}).get('sourceIp')
        if source_ip:
            item['ip_address'] = source_ip
        
        # Save to DynamoDB
        table.put_item(Item=item)
        
        # Success response
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
        print(f"Error: {str(e)}")
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
