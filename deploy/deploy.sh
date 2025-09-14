#!/bin/bash

# EV Charging Demo - One-Click Deployment Script
set -e

# Configuration
STACK_NAME="ev-charging-demo"
REGION="${AWS_DEFAULT_REGION:-us-east-1}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    EV Charging Demo - One-Click Deployment    ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed${NC}"
    echo "Please install AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials not configured${NC}"
    echo "Please run: aws configure"
    exit 1
fi

# Check required files
if [ ! -f "infrastructure.yaml" ]; then
    echo -e "${RED}❌ infrastructure.yaml not found${NC}"
    echo "Please ensure infrastructure.yaml is in the current directory"
    exit 1
fi

if [ ! -f "index.html" ]; then
    echo -e "${RED}❌ index.html not found${NC}"
    echo "Please ensure index.html is in the current directory"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"
echo ""

# Get AWS Account info
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
USER_ARN=$(aws sts get-caller-identity --query Arn --output text)

echo -e "${YELLOW}Deployment Configuration:${NC}"
echo "  Stack Name: ${STACK_NAME}"
echo "  Region: ${REGION}"
echo "  Account ID: ${ACCOUNT_ID}"
echo "  User: ${USER_ARN}"
echo ""

# Validate CloudFormation template
echo -e "${YELLOW}Validating CloudFormation template...${NC}"
aws cloudformation validate-template \
    --template-body file://infrastructure.yaml \
    --region $REGION > /dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Template validation passed${NC}"
else
    echo -e "${RED}❌ Template validation failed${NC}"
    exit 1
fi

# Deploy CloudFormation stack
echo ""
echo -e "${YELLOW}Deploying CloudFormation stack...${NC}"
echo "This will take approximately 3-5 minutes..."
echo ""

aws cloudformation deploy \
    --template-file infrastructure.yaml \
    --stack-name $STACK_NAME \
    --parameter-overrides Environment=demo \
    --capabilities CAPABILITY_IAM \
    --region $REGION \
    --no-fail-on-empty-changeset

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ CloudFormation stack deployed successfully${NC}"
else
    echo -e "${RED}❌ CloudFormation deployment failed${NC}"
    exit 1
fi

# Get API endpoint from stack outputs
echo ""
echo -e "${YELLOW}Retrieving API endpoint...${NC}"

API_ENDPOINT=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`ApiEndpoint`].OutputValue' \
    --output text)

if [ -z "$API_ENDPOINT" ]; then
    echo -e "${RED}❌ Could not retrieve API endpoint${NC}"
    exit 1
fi

echo -e "${GREEN}✅ API Endpoint: ${API_ENDPOINT}${NC}"

# Update dashboard HTML with API endpoint
echo ""
echo -e "${YELLOW}Configuring dashboard...${NC}"

# Create a backup of the original
cp index.html index.html.backup

# Replace the API endpoint placeholder
sed -i.bak "s|API_ENDPOINT_HERE|${API_ENDPOINT}|g" index.html

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Dashboard configured successfully${NC}"
    rm index.html.bak
else
    echo -e "${RED}❌ Failed to configure dashboard${NC}"
    exit 1
fi

# Wait a moment for Lambda functions to be ready
echo ""
echo -e "${YELLOW}Initializing demo data...${NC}"
sleep 10

# Trigger the simulator to create initial demo data
SIMULATOR_FUNCTION=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`SimulatorFunctionName`].OutputValue' \
    --output text)

if [ ! -z "$SIMULATOR_FUNCTION" ]; then
    echo "Triggering initial data creation..."
    aws lambda invoke \
        --function-name $SIMULATOR_FUNCTION \
        --payload '{"chargePointId": "CP-DEMO-001", "messageType": "BootNotification"}' \
        --region $REGION \
        /tmp/lambda-response.json > /dev/null 2>&1
    
    # Trigger a few more for demo
    aws lambda invoke \
        --function-name $SIMULATOR_FUNCTION \
        --payload '{"chargePointId": "CP-DEMO-002", "messageType": "StatusNotification"}' \
        --region $REGION \
        /tmp/lambda-response2.json > /dev/null 2>&1
    
    echo -e "${GREEN}✅ Demo data initialized${NC}"
else
    echo -e "${YELLOW}⚠️  Could not find simulator function, but deployment succeeded${NC}"
fi

# Clean up temporary files
rm -f /tmp/lambda-response*.json

# Success message
echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}           🎉 DEPLOYMENT SUCCESSFUL! 🎉        ${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "${YELLOW}Your EV Charging Demo is now ready!${NC}"
echo ""
echo -e "${BLUE} Dashboard:${NC}"
echo "   Open index.html in your web browser"
echo ""
echo -e "${BLUE} API Endpoint:${NC}"
echo "   ${API_ENDPOINT}"
echo ""
echo -e "${BLUE} AWS Resources Created:${NC}"
echo "   • DynamoDB Tables: demo-charge-points, demo-charging-sessions"
echo "   • Lambda Functions: Simulator, Handler, API"
echo "   • EventBridge: Custom bus for events"
echo "   • API Gateway: REST API for dashboard"
echo ""
echo -e "${BLUE}🔍 Monitoring:${NC}"
echo "   • CloudWatch Logs: /aws/lambda/demo-*"
echo "   • DynamoDB Console: Tables with 'demo' prefix"
echo "   • EventBridge Console: demo-ev-bus"
echo ""
echo -e "${BLUE}💰 Cost:${NC}"
echo "   • Estimated cost: ~$0.10 per day"
echo "   • All resources use pay-per-use pricing"
echo ""
echo -e "${BLUE}🧹 Cleanup (after demo):${NC}"
echo "   aws cloudformation delete-stack --stack-name ${STACK_NAME} --region ${REGION}"
echo ""
echo -e "${GREEN}Good luck with your presentation! 🚀${NC}"
echo ""