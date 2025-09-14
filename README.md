# EV Charging Management System - Demo Version

[![AWS](https://img.shields.io/badge/AWS-Cloud-orange)](https://aws.amazon.com/)
[![Python](https://img.shields.io/badge/Python-3.9-blue)](https://python.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

## Overview
This is a refactored version of the AWS guidance for modernizing electric vehicle charging, specifically designed for demonstration purposes. Instead of using IoT devices and physical charge points, this demo uses **Lambda functions and EventBridge** to simulate the entire EV charging ecosystem.

## Architecture Changes

### Original Architecture
- **ECS Containers** with OCPP Gateway
- **AWS IoT Core** for MQTT messaging
- **Physical charge points** with OCPP protocol
- **CDK** for deployment

### Demo Architecture
- **Lambda functions** for all processing
- **EventBridge** for event-driven communication
- **Simulated charge points** via Lambda
- **CloudFormation YAML** for deployment

## Solution Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   CloudWatch    │    │   EventBridge   │    │    DynamoDB     │
│   (Schedule)    │--->│  (Custom Bus)   │--->│  (Charge Data)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                        │                        ▲
        ▼                        ▼                        │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Charge Point    │    │  OCPP Handler   │    │  Session Mgmt   │
│  Simulator      │    │   (Lambda)      │    │   (Lambda)      │
│   (Lambda)      │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Quick Start

### Prerequisites
- AWS CLI installed and configured
- AWS account with appropriate permissions
- Bash shell (Linux/macOS/WSL)

### Deployment
```bash
# Clone the repository (or create the structure)
mkdir ev-charging-demo && cd ev-charging-demo

# Create the directory structure
mkdir -p deploy src/lambda config docs tests

# Copy the CloudFormation template to deploy/infrastructure.yaml
# Copy the deployment script to deploy/deploy.sh

# Make deployment script executable
chmod +x deploy/deploy.sh

# Deploy the stack
cd deploy
./deploy.sh
```

### Post-Deployment Verification
```bash
# Check charge points table
aws dynamodb scan --table-name demo-charge-points

# View recent Lambda logs
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/demo"

# Manually trigger simulation
aws lambda invoke \
  --function-name demo-charge-point-simulator \
  --payload '{"chargePointId": "CP-DEMO-002", "messageType": "StatusNotification"}' \
  response.json
```

## Demo Flow

1. **Automated Simulation**: CloudWatch triggers the simulator every 30 seconds
2. **Event Generation**: Simulator creates OCPP messages (BootNotification, Heartbeat, StatusNotification, MeterValues)
3. **Event Processing**: EventBridge routes messages to appropriate handlers
4. **State Management**: DynamoDB stores charge point states and session data
5. **Response Handling**: System responds with appropriate OCPP responses

## Key Demo Features

### 1. Charge Point Simulation
- **Multiple Message Types**: BootNotification, Heartbeat, StatusNotification, MeterValues
- **Realistic Data**: Hardware attributes, energy readings, status changes
- **Configurable**: Easy to modify charge point count and behavior

### 2. Event-Driven Architecture
- **EventBridge Integration**: Custom event bus for all communications
- **Lambda Processing**: Serverless handling of all OCPP messages
- **Scalable Design**: Can handle thousands of simulated charge points

### 3. Data Management
- **DynamoDB Storage**: Charge point registry and session management
- **Real-time Updates**: Immediate state synchronization
- **Query Capabilities**: Easy data access for monitoring

## Configuration

### Charge Point Configuration
```json
{
  "chargePoints": [
    {
      "id": "CP-DEMO-001",
      "location": "Demo Location 1",
      "connectorCount": 2,
      "maxPower": 50,
      "vendor": "Demo Charging Co"
    }
  ]
}
```

### Message Templates
```json
{
  "bootNotification": {
    "chargingStation": {
      "model": "Demo-Model-X",
      "vendorName": "Demo Charging Co",
      "firmwareVersion": "1.0.0"
    }
  }
}
```

## Monitoring and Observability

### CloudWatch Metrics
- Lambda function invocations and duration
- EventBridge event processing
- DynamoDB read/write capacity

### DynamoDB Tables
1. **demo-charge-points**: Charge point registry and status
2. **demo-charging-sessions**: Active and historical charging sessions

### EventBridge Events
- **ev.charging.simulator**: Events from charge point simulator
- **ev.charging.ocpp**: OCPP message processing events
- **ev.charging.session**: Charging session lifecycle events

## Presentation Points

### 1. **Serverless Architecture Benefits**
- **Cost Effective**: Pay only for execution time
- **Auto Scaling**: Handles any number of charge points
- **No Infrastructure Management**: Focus on business logic

### 2. **Event-Driven Design**
- **Loose Coupling**: Services communicate via events
- **Extensibility**: Easy to add new features
- **Reliability**: Built-in retry and error handling

### 3. **OCPP Compliance**
- **Standard Protocol**: Industry-standard messaging
- **Interoperability**: Works with any OCPP-compliant system
- **Future Proof**: Easy to integrate real charge points

### 4. **Demo Capabilities**
- **Real-time Simulation**: Live charge point behavior
- **Multiple Scenarios**: Various charging states and events
- **Monitoring**: Full observability of system operation

## Testing Scenarios

### Basic Connectivity Test
```bash
# Test charge point registration
aws lambda invoke \
  --function-name demo-charge-point-simulator \
  --payload '{"chargePointId": "CP-TEST-001", "messageType": "BootNotification"}' \
  test-response.json
```

### Status Change Simulation
```bash
# Simulate charging session start
aws lambda invoke \
  --function-name demo-charge-point-simulator \
  --payload '{"chargePointId": "CP-TEST-001", "messageType": "StatusNotification"}' \
  test-response.json
```

### Meter Reading Simulation
```bash
# Simulate energy meter reading
aws lambda invoke \
  --function-name demo-charge-point-simulator \
  --payload '{"chargePointId": "CP-TEST-001", "messageType": "MeterValues"}' \
  test-response.json
```

## Cleanup

```bash
# Delete the CloudFormation stack
aws cloudformation delete-stack --stack-name ev-charging-demo

# Verify deletion
aws cloudformation describe-stacks --stack-name ev-charging-demo
```

## Cost Estimation

**Demo Environment (1 hour operation)**:
- Lambda: ~$0.01 (minimal execution time)
- EventBridge: ~$0.01 (custom events)
- DynamoDB: ~$0.01 (on-demand pricing)
- CloudWatch: ~$0.01 (logs and metrics)

**Total: ~$0.04 per hour**

## Additional Resources

- [Original AWS Guidance](https://github.com/aws-solutions-library-samples/guidance-for-modernizing-electric-vehicle-charging-on-aws)
- [OCPP Protocol Documentation](https://www.openchargealliance.org/)
- [AWS EventBridge Documentation](https://docs.aws.amazon.com/eventbridge/)
- [AWS Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-sensor-type`)
3. Commit your changes (`git commit -m 'Add earthquake swarm detection'`)
4. Push to the branch (`git push origin feature/new-sensor-type`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For questions or support:
- Create an issue in this repository
- Contact: [shoaibalimir1334@gmail.com](mailto:shoaibalimir1334@gmail.com)
- LinkedIn: [LinkedIn Profile](https://linkedin.com/in/shoaibalimir)

---

**Note**: This is a simulation system for educational/presentation purposes. For production disaster monitoring, integrate with real IoT sensors and professional ML models.
