# lambda/alert_sender.py
import json
import os
import boto3
from datetime import datetime

sns = boto3.client('sns')

def lambda_handler(event, context):
    """Handle SNS notifications and route alerts"""
    
    try:
        # This can be triggered directly or via SNS
        if 'Records' in event:
            # Triggered by SNS
            for record in event['Records']:
                if record['EventSource'] == 'aws:sns':
                    message = record['Sns']['Message']
                    subject = record['Sns']['Subject']
                    process_sns_alert(message, subject)
        else:
            # Direct invocation
            send_custom_alert(event)
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Alert processed successfully',
                'timestamp': datetime.utcnow().isoformat()
            })
        }
        
    except Exception as e:
        print(f"Error in alert sender: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

def process_sns_alert(message, subject):
    """Process incoming SNS alert"""
    print(f"Processing SNS Alert:")
    print(f"Subject: {subject}")
    print(f"Message: {message}")
    
    # Here you could add logic to:
    # - Send push notifications
    # - Send SMS to emergency contacts  
    # - Update dashboard
    # - Log to database
    # - Trigger other systems
    
    print("Alert processed and logged")

def send_custom_alert(event):
    """Send custom alert via SNS"""
    try:
        sns_topic_arn = os.environ.get('SNS_TOPIC_ARN')
        
        if not sns_topic_arn:
            print("No SNS topic ARN configured")
            return
        
        # Extract alert data from event
        alert_type = event.get('alert_type', 'GENERAL')
        message = event.get('message', 'Custom disaster alert')
        severity = event.get('severity', 'LOW')
        
        # Send custom alert
        response = sns.publish(
            TopicArn=sns_topic_arn,
            Message=f"🚨 CUSTOM ALERT 🚨\n\nType: {alert_type}\nSeverity: {severity}\n\n{message}\n\nTime: {datetime.utcnow().isoformat()}",
            Subject=f"🚨 {severity} CUSTOM ALERT - {alert_type}"
        )
        
        print(f"Custom alert sent. MessageId: {response['MessageId']}")
        
    except Exception as e:
        print(f"Error sending custom alert: {str(e)}")

# Example usage for testing:
# aws lambda invoke --function-name DisasterAlertSender --payload '{"alert_type":"TEST","message":"This is a test alert","severity":"HIGH"}' response.json