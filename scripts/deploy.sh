#!/bin/bash
# scripts/deploy.sh

set -e

# Configuration
STACK_NAME="DisasterMonitoringSystem"
REGION="us-east-1"
BUCKET_NAME="disaster-monitoring-lambda-code-$(date +%s)"

echo "🚀 Deploying Disaster Monitoring System..."

# Create S3 bucket for Lambda code
echo "📦 Creating S3 bucket for Lambda code..."
aws s3 mb s3://$BUCKET_NAME --region $REGION

# Package Lambda functions
echo "📁 Packaging Lambda functions..."
cd lambda

# Create zip files
zip -r data_generator.zip data_generator.py
zip -r predictor.zip predictor.py  
zip -r alert_sender.zip alert_sender.py

# Upload to S3
echo "⬆️ Uploading Lambda code to S3..."
aws s3 cp data_generator.zip s3://$BUCKET_NAME/
aws s3 cp predictor.zip s3://$BUCKET_NAME/
aws s3 cp alert_sender.zip s3://$BUCKET_NAME/

cd ..

# Deploy CloudFormation stack
echo "☁️ Deploying CloudFormation stack..."
aws cloudformation deploy \
    --template-file iac/template.yaml \
    --stack-name $STACK_NAME \
    --parameter-overrides S3Bucket=$BUCKET_NAME \
    --capabilities CAPABILITY_IAM \
    --region $REGION

# Update Lambda function code
echo "🔄 Updating Lambda function code..."
aws lambda update-function-code \
    --function-name DisasterDataGenerator \
    --s3-bucket $BUCKET_NAME \
    --s3-key data_generator.zip \
    --region $REGION

aws lambda update-function-code \
    --function-name DisasterPredictor \
    --s3-bucket $BUCKET_NAME \
    --s3-key predictor.zip \
    --region $REGION

aws lambda update-function-code \
    --function-name DisasterAlertSender \
    --s3-bucket $BUCKET_NAME \
    --s3-key alert_sender.zip \
    --region $REGION

# Get outputs
echo "📋 Getting stack outputs..."
SNS_TOPIC_ARN=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --query 'Stacks[0].Outputs[?OutputKey==`SNSTopicArn`].OutputValue' \
    --output text \
    --region $REGION)

echo ""
echo "✅ Deployment completed successfully!"
echo "📧 SNS Topic ARN: $SNS_TOPIC_ARN"
echo ""
echo "🔔 To receive alerts, subscribe to the SNS topic:"
echo "aws sns subscribe --topic-arn $SNS_TOPIC_ARN --protocol email --notification-endpoint your-email@example.com"
echo ""
echo "🧪 To test the system manually:"
echo "aws lambda invoke --function-name DisasterDataGenerator response.json"
echo ""
echo "📊 The system will automatically generate mock data every 2 minutes"