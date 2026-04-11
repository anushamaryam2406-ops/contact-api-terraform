"""
Lambda Function: GET /messages
Retrieves contact messages from DynamoDB
Supports filtering by email and status
"""

import json
import boto3
import os
import logging  # ← NEW
from boto3.dynamodb.conditions import Key
from decimal import Decimal

# ← NEW: Setup logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

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

    # ← NEW: Log every incoming request
    logger.info(f"GET /messages called | RequestId: {context.aws_request_id}")

    try:
        # Get query parameters
        params = event.get('queryStringParameters') or {}
        email = params.get('email')
        status = params.get('status')
        limit = int(params.get('limit', 50))

        # ← NEW: Log what filters were requested
        logger.info(f"Filters received | email: {email} | status: {status} | limit: {limit}")

        # Query by email (main table)
        if email:
            # ← NEW
            logger.info(f"Querying by email | email: {email}")
            response = table.query(
                KeyConditionExpression=Key('email').eq(email.lower()),
                Limit=limit,
                ScanIndexForward=False
            )

        # Query by status (GSI)
        elif status:
            # ← NEW
            logger.info(f"Querying by status via GSI | status: {status}")
            response = table.query(
                IndexName='status-timestamp-index',
                KeyConditionExpression=Key('status').eq(status),
                Limit=limit,
                ScanIndexForward=False
            )

        # Get all messages (scan - careful!)
        else:
            # ← NEW: Warning because scan is expensive!
            logger.warning(f"Running full table SCAN | limit: {limit} | this is expensive!")
            response = table.scan(Limit=limit)

        # Format response
        items = response.get('Items', [])

        # ← NEW: Log how many results were returned
        logger.info(f"SUCCESS | returned {len(items)} messages | RequestId: {context.aws_request_id}")

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
        # ← IMPROVED: was print(), now logger.error()
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