# EV Charging Management System - Demo Version

[![AWS](https://img.shields.io/badge/AWS-Cloud-orange)](https://aws.amazon.com/)
[![Python](https://img.shields.io/badge/Python-3.9-blue)](https://python.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

## Overview
This is a simplified demonstration version of an AWS serverless EV charging management system. The demo uses **Lambda functions, EventBridge, and API Gateway** to simulate a complete EV charging ecosystem with a web-based dashboard for monitoring.

## Architecture

### Demo Architecture Components
- **Lambda Functions**: Three core functions for simulation, message handling, and API
- **EventBridge**: Custom event bus for OCPP message routing
- **DynamoDB**: Two tables for charge points and charging sessions
- **API Gateway**: REST API for dashboard data access
- **CloudWatch Events**: Automated simulation triggers
- **Web Dashboard**: Real-time monitoring interface

## Architecture Overview

<img width="1725" height="943" alt="image" src="https://github.com/user-attachments/assets/5a00e8b1-8cd9-4fa8-a499-eea7ac1bb48b" />

## Solution Architecture (Simplified)

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   CloudWatch    │    │   EventBridge   │    │    DynamoDB     │
│   (Schedule)    │--->│  (Custom Bus)   │--->│  (Charge Data)  │
│   Every 2min    │    │   ev-bus        │    │   2 Tables      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                        │                        ▲
        ▼                        ▼                        │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Simulator       │    │  Handler        │    │  API            │
│ Lambda          │    │  Lambda         │    │  Lambda         │
│ (demo-simulator)│    │ (demo-handler)  │    │ (demo-api)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
                                              ┌─────────────────┐
                                              │  API Gateway    │
                                              │  Dashboard API  │
                                              └─────────────────┘
                                                        │
                                                        ▼
                                              ┌─────────────────┐
                                              │  Web Dashboard  │
                                              │  (index.html)   │
                                              └─────────────────┘
```

## Quick Start

### Prerequisites
- AWS CLI installed and configured
- AWS account with appropriate permissions
- Modern web browser for dashboard

### Deployment

1. **Deploy the CloudFormation Stack**
```bash
# Create the stack
aws cloudformation create-stack \
  --stack-name ev-charging-demo \
  --template-body file://infrastructure.yaml \
  --capabilities CAPABILITY_IAM \
  --parameters ParameterKey=Environment,ParameterValue=demo
```

2. **Get the API Endpoint**
```bash
# Wait for stack completion and get outputs
aws cloudformation describe-stacks \
  --stack-name ev-charging-demo \
  --query 'Stacks[0].Outputs[?OutputKey==`ApiEndpoint`].OutputValue' \
  --output text
```

3. **Configure Dashboard**
```bash
# Update the API endpoint in index.html
# Replace 'API_ENDPOINT_HERE' with your actual API endpoint
sed -i 's/API_ENDPOINT_HERE/your-actual-endpoint/' index.html
```

4. **Open Dashboard**
```bash
# Open index.html in your web browser
open index.html
```

### Post-Deployment Verification
```bash
# Check if charge points were created
aws dynamodb scan --table-name demo-charge-points --max-items 5

# View Lambda function logs
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/demo"

# Test the API endpoints
curl https://your-api-endpoint.execute-api.region.amazonaws.com/prod/stats
```

## Demo Flow

1. **Automatic Simulation**: CloudWatch triggers simulator every 2 minutes
2. **OCPP Message Generation**: Simulator creates realistic charge point messages
3. **Event Processing**: EventBridge routes messages to handler Lambda
4. **State Updates**: Handler updates DynamoDB with charge point and session data
5. **Dashboard Display**: Web interface shows real-time data via API Gateway
6. **Demo Controls**: Manual simulation triggers available through dashboard

## Key Demo Features

### 1. Three Core Lambda Functions

#### Simulator Function (`demo-simulator`)
- Creates 3 demo charge points on first run
- Generates OCPP messages: BootNotification, Heartbeat, StatusNotification, MeterValues
- Publishes events to EventBridge
- Triggered automatically every 2 minutes

#### Handler Function (`demo-handler`)
- Processes OCPP messages from EventBridge
- Updates charge point status in DynamoDB
- Creates charging sessions automatically
- Handles all OCPP message types

#### API Function (`demo-api`)
- Provides REST endpoints for dashboard
- Supports CORS for web access
- Returns charge points, sessions, and statistics
- Real-time data access

### 2. DynamoDB Tables

#### Charge Points Table (`demo-charge-points`)
```json
{
  "chargePointId": "CP-DEMO-001",
  "status": "Available",
  "location": "Demo Location 1",
  "model": "FastCharge Pro",
  "vendor": "EV Solutions Inc",
  "connectors": 2,
  "maxPower": 50,
  "lastSeen": "2024-01-01T12:00:00Z"
}
```

#### Charging Sessions Table (`demo-charging-sessions`)
```json
{
  "sessionId": "uuid",
  "chargePointId": "CP-DEMO-001",
  "status": "Active",
  "startTime": "2024-01-01T12:00:00Z",
  "currentEnergy": 25.5,
  "cost": 5.75,
  "userId": "demo-user"
}
```

### 3. Interactive Web Dashboard
- Real-time statistics display
- Charge point status monitoring
- Charging session tracking
- Manual simulation controls
- Auto-refresh every 30 seconds
- Responsive design

## API Endpoints

The demo provides three main API endpoints:

```bash
# Get charge points status
GET /chargepoints

# Get charging sessions
GET /sessions

# Get system statistics
GET /stats
```

## Dashboard Features

### Statistics Cards
- Total Charge Points
- Available Charge Points
- Currently Charging
- Active Sessions
- Total Energy Consumed

### Charge Points Grid
- Real-time status display
- Hardware specifications
- Location information
- Last seen timestamps

### Sessions Table
- Active and completed sessions
- Energy consumption tracking
- Cost calculations
- Start times and duration

### Demo Controls
- Manual simulation trigger
- Data refresh button
- Auto-refresh toggle

## Testing the Demo

### Manual Function Testing
```bash
# Trigger simulator manually
aws lambda invoke \
  --function-name demo-simulator \
  --payload '{"chargePointId": "CP-DEMO-001", "messageType": "StatusNotification"}' \
  response.json

# Test API endpoints
curl https://your-endpoint/prod/chargepoints
curl https://your-endpoint/prod/sessions
curl https://your-endpoint/prod/stats
```

### Dashboard Testing
1. Open `index.html` in a browser
2. Verify API endpoint is configured correctly
3. Check that data loads automatically
4. Test manual refresh and simulation controls
5. Monitor auto-refresh functionality

## Configuration

### Environment Variables
The Lambda functions use these environment variables:
- `EVENT_BUS_NAME`: EventBridge bus name
- `CHARGE_POINTS_TABLE`: DynamoDB table name
- `SESSIONS_TABLE`: Sessions table name

### Simulation Frequency
Currently set to trigger every 2 minutes via CloudWatch Events. Modify the `ScheduleExpression` in the CloudFormation template to change frequency:

```yaml
ScheduleExpression: "rate(2 minutes)"  # Change as needed
```

## Monitoring

### CloudWatch Logs
- `/aws/lambda/demo-simulator`
- `/aws/lambda/demo-handler`
- `/aws/lambda/demo-api`

### CloudWatch Metrics
- Lambda invocation counts and durations
- EventBridge event processing
- DynamoDB read/write operations
- API Gateway requests

### Real-time Monitoring
The web dashboard provides real-time monitoring of:
- System statistics
- Charge point status changes
- Charging session progress
- Energy consumption

## Demo Scenarios

### Scenario 1: Initial Setup
1. Deploy the stack
2. Wait for first automatic simulation
3. Open dashboard to see 3 demo charge points
4. Observe automatic status changes

### Scenario 2: Charging Session
1. Wait for a charge point to change to "Charging" status
2. Observe automatic session creation
3. Monitor energy consumption in sessions table
4. Watch meter value updates

### Scenario 3: Manual Testing
1. Use dashboard controls to trigger simulation
2. Observe immediate data updates
3. Test different message types
4. Monitor EventBridge and Lambda logs

## Cost Estimation

**Demo Environment (24 hours)**:
- Lambda executions: ~$0.25 (720 executions)
- EventBridge custom events: ~$0.10 (720 events)
- DynamoDB on-demand: ~$0.05 (minimal data)
- API Gateway requests: ~$0.05 (dashboard calls)
- CloudWatch logs: ~$0.05

**Total: ~$0.50 per day**

## Troubleshooting

### Common Issues

1. **Dashboard shows "API endpoint not configured"**
   - Update the `API_ENDPOINT` variable in `index.html`

2. **No data in dashboard**
   - Check CloudFormation stack deployed successfully
   - Verify Lambda functions have proper permissions
   - Check CloudWatch logs for errors

3. **Simulation not running**
   - Verify CloudWatch Events rule is enabled
   - Check simulator Lambda function logs
   - Confirm EventBridge rule is active

### Debug Commands
```bash
# Check stack status
aws cloudformation describe-stacks --stack-name ev-charging-demo

# View recent Lambda executions
aws logs filter-log-events \
  --log-group-name "/aws/lambda/demo-simulator" \
  --start-time $(date -d "1 hour ago" +%s)000

# Check DynamoDB data
aws dynamodb scan --table-name demo-charge-points --max-items 5
```

## Cleanup

```bash
# Delete the CloudFormation stack
aws cloudformation delete-stack --stack-name ev-charging-demo

# Verify deletion (should show DELETE_COMPLETE)
aws cloudformation describe-stacks --stack-name ev-charging-demo
```

Note: DynamoDB tables with data may take a few minutes to delete.

## Extending the Demo

### Adding More Charge Points
Modify the `create_demo_charge_points` function in the simulator Lambda to add more demo charge points.

### Custom Message Types
Extend the `generate_ocpp_message` function to support additional OCPP message types.

### Enhanced Dashboard
Add more visualizations or real-time charts to the dashboard by modifying `index.html`.

## Additional Resources

- [Original AWS Guidance](https://github.com/aws-solutions-library-samples/guidance-for-modernizing-electric-vehicle-charging-on-aws)
- [OCPP Protocol Documentation](https://www.openchargealliance.org/)
- [AWS EventBridge User Guide](https://docs.aws.amazon.com/eventbridge/)
- [AWS Lambda Developer Guide](https://docs.aws.amazon.com/lambda/)
- [AWS API Gateway Developer Guide](https://docs.aws.amazon.com/apigateway/)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly with the demo environment
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For questions or support:
- Create an issue in this repository
- Check CloudWatch logs for detailed error information
- Review the AWS CloudFormation events for deployment issues

## Support

For questions or support:
- Create an issue in this repository
- Contact: [shoaibalimir1334@gmail.com](mailto:shoaibalimir1334@gmail.com)
- LinkedIn: [LinkedIn Profile](https://linkedin.com/in/shoaibalimir)
