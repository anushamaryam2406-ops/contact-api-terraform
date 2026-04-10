"""
Lambda Function: GET /messages
Retrieves contact messages from DynamoDB
Supports filtering by email and status
"""

import json
import boto3
import os
from boto3.dynamodb.conditions import Key
from decimal import Decimal

# Initialize DynamoDB
dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('TABLE_NAME', 'contact-messages-dev')
table = dynamodb.Table(table_name)

class DecimalEncoder(json.JSONEncoder):
    """Helper to convert DynamoDB Decimal to JSON"""
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)

def lambda_handler(event, context):
    """
    GET /messages?email=xxx&status=new
    Query parameters:
    - email: Filter by specific email
    - status: Filter by status (new/read/archived)
    - limit: Max results (default: 50)
    """
    
    try:
        # Get query parameters
        params = event.get('queryStringParameters') or {}
        email = params.get('email')
        status = params.get('status')
        limit = int(params.get('limit', 50))
        
        # Query by email (main table)
        if email:
            response = table.query(
                KeyConditionExpression=Key('email').eq(email.lower()),
                Limit=limit,
                ScanIndexForward=False  # Newest first
            )
        
        # Query by status (GSI)
        elif status:
            response = table.query(
                IndexName='status-timestamp-index',
                KeyConditionExpression=Key('status').eq(status),
                Limit=limit,
                ScanIndexForward=False  # Newest first
            )
        
        # Get all messages (scan - careful!)
        else:
            response = table.scan(Limit=limit)
        
        # Format response
        items = response.get('Items', [])
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'count': len(items),
                'messages': items
            }, cls=DecimalEncoder)
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
