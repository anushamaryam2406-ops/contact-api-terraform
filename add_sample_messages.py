
"""
Add Sample Contact Messages
This script adds realistic contact form data to test GSI queries
"""

import boto3
from datetime import datetime, timedelta
import random

# Initialize DynamoDB
dynamodb = boto3.resource('dynamodb', region_name='ap-south-1')
table = dynamodb.Table('message-inbox-dev')

# Sample data creating 
sample_messages = [
    # Anusha's messages (mix of new/read/archived)
    {
        'email': 'anusha@example.com',
        'name': 'Anusha',
        'subject': 'Question about pricing',
        'message': 'Hi, I want to know about your pricing plans. Can you provide details?',
        'status': 'new'
    },
    {
        'email': 'anusha@example.com',
        'name': 'Anusha',
        'subject': 'Follow up on pricing',
        'message': 'Still waiting for pricing information. Please respond.',
        'status': 'read'
    },
    {
        'email': 'anusha@example.com',
        'name': 'Anusha',
        'subject': 'Thank you!',
        'message': 'Got the information, thank you so much!',
        'status': 'archived'
    },
    
    # John's messages
    {
        'email': 'john@company.com',
        'name': 'John Smith',
        'subject': 'Technical support needed',
        'message': 'I am facing issues with the API integration. Please help.',
        'status': 'new'
    },
    {
        'email': 'john@company.com',
        'name': 'John Smith',
        'subject': 'Update on my ticket',
        'message': 'Any update on my technical issue?',
        'status': 'new'
    },
    
    # Sarah's messages
    {
        'email': 'sarah@startup.io',
        'name': 'Sarah Johnson',
        'subject': 'Partnership opportunity',
        'message': 'We would like to discuss a partnership. Are you interested?',
        'status': 'read'
    },
    {
        'email': 'sarah@startup.io',
        'name': 'Sarah Johnson',
        'subject': 'Meeting schedule',
        'message': 'Can we schedule a call next week?',
        'status': 'new'
    },
    
    # Ahmed's messages
    {
        'email': 'ahmed@tech.pk',
        'name': 'Ahmed Khan',
        'subject': 'Feature request',
        'message': 'Can you add support for multiple languages?',
        'status': 'new'
    },
    {
        'email': 'ahmed@tech.pk',
        'name': 'Ahmed Khan',
        'subject': 'Bug report',
        'message': 'Found a bug in the dashboard. Attaching details.',
        'status': 'read'
    },
    
    # Maria's messages
    {
        'email': 'maria@design.com',
        'name': 'Maria Garcia',
        'subject': 'Design consultation',
        'message': 'Looking for design services. What are your rates?',
        'status': 'archived'
    },
]

# Generate timestamps (spread over last 7 days)
base_time = datetime.utcnow()

def add_messages():
    """Add all sample messages to DynamoDB"""
    
    print("=" * 60)
    print("Adding Sample Contact Messages")
    print("=" * 60)
    
    for i, msg in enumerate(sample_messages):
        # Generate timestamp (spread over last 7 days)
        days_ago = random.randint(0, 7)
        hours_ago = random.randint(0, 23)
        timestamp = base_time - timedelta(days=days_ago, hours=hours_ago)
        
        # Create the item
        item = {
            'email': msg['email'],
            'timestamp': timestamp.strftime('%Y-%m-%dT%H:%M:%SZ'),
            'name': msg['name'],
            'subject': msg['subject'],
            'message': msg['message'],
            'status': msg['status'],
            'created_at': timestamp.strftime('%Y-%m-%dT%H:%M:%SZ')
        }
        
        # Add to DynamoDB
        try:
            table.put_item(Item=item)
            print(f"✅ Added: {msg['name']} - {msg['subject']} ({msg['status']})")
        except Exception as e:
            print(f"❌ Error adding {msg['name']}: {str(e)}")
    
    print("\n" + "=" * 60)
    print("✅ All messages added successfully!")
    print("=" * 60)
    
    # Print summary
    print("\n📊 Summary:")
    print(f"Total messages: {len(sample_messages)}")
    
    status_count = {}
    for msg in sample_messages:
        status = msg['status']
        status_count[status] = status_count.get(status, 0) + 1
    
    for status, count in status_count.items():
        print(f"  - {status}: {count} messages")
    
    print("\n🎯 Now ready to test queries!")

if __name__ == "__main__":
    add_messages()
