# Disaster Monitoring & Early Warning System

[![AWS](https://img.shields.io/badge/AWS-Cloud-orange)](https://aws.amazon.com/)
[![Python](https://img.shields.io/badge/Python-3.9-blue)](https://python.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

## Overview
A **simulated IoT-based Disaster Monitoring System** built on AWS for presentation/demo purposes. Since real IoT devices and ML models (SageMaker) are costly, this system uses:

- **EventBridge + Lambda** → Generate mock IoT sensor data
- **Lambda (Rule-based ML simulation)** → Predict disasters using simple thresholds  
- **SNS** → Send early warning alerts to subscribers

## Architecture
```
EventBridge (Schedule) → DataGenerator Lambda → DisasterPredictor Lambda → SNS Alerts
                             ↓
                        Mock IoT Data:
                        • Water levels (flood detection)
                        • Vibration (earthquake detection) 
                        • Weather data (storm detection)
```

## Quick Deploy

### Prerequisites
- AWS CLI configured
- Appropriate AWS permissions

### Deploy
```bash
git clone <your-repo>
cd disaster-monitoring-aws
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

### Subscribe to Alerts
```bash
# Replace with your email
aws sns subscribe \
    --topic-arn <SNS_TOPIC_ARN_FROM_DEPLOY_OUTPUT> \
    --protocol email \
    --notification-endpoint your-email@example.com
```

## Testing

### Automatic Testing
The system automatically generates mock sensor data every **2 minutes** via EventBridge.

### Manual Testing
```bash
# Trigger data generation manually
aws lambda invoke --function-name DisasterDataGenerator response.json

# Send custom alert
aws lambda invoke --function-name DisasterAlertSender \
    --payload '{"alert_type":"TEST","message":"Manual test alert","severity":"HIGH"}' \
    response.json
```

## Alert Thresholds

| Sensor Type | Warning Level | Critical Level |
|-------------|---------------|----------------|
| Water Level | > 6 meters    | > 12 meters    |
| Vibration   | > 3 magnitude | > 7 magnitude  |
| Rainfall    | > 50 mm       | > 75 mm        |
| Wind Speed  | > 70 km/h     | > 60 km/h (with rain) |

## AWS Services Used
- **AWS Lambda** - Mock data generation & disaster prediction
- **Amazon EventBridge** - Scheduled triggers  
- **Amazon SNS** - Alert notifications
- **CloudFormation** - Infrastructure as Code

## Project Structure

```
disaster-monitoring-aws/
├── iac/
│   └── template.yaml        # CloudFormation infrastructure template
├── lambda/
│   ├── data_generator.py    # IoT sensor data simulation
│   ├── predictor.py         # ML-based disaster prediction
│   └── alert_sender.py      # SNS notification handler
├── scripts/
│   └── deploy.sh           # Automated deployment script
├── README.md               # Project documentation
└── LICENSE                 # MIT License
```

## Configuration

### Alert Thresholds
| Sensor Type | Warning Level | Critical Level |
|-------------|---------------|----------------|
| Water Level | > 6 meters    | > 12 meters    |
| Vibration   | > 3 magnitude | > 7 magnitude  |
| Rainfall    | > 50 mm       | > 75 mm        |
| Wind Speed  | > 70 km/h     | > 60 km/h (with rain) |

### System Settings
```yaml
# EventBridge Schedule
data_generation_frequency: 2 minutes

# Sensor Configuration  
sensors:
  water_level_range: 0-15 meters
  vibration_range: 0-10 magnitude
  weather_monitoring: rainfall, wind, temperature
```

## Testing

### Automated Testing
The system runs continuous testing with scheduled data generation every 2 minutes.

### Manual Testing
```bash
# Test data generation
aws lambda invoke --function-name DisasterDataGenerator response.json

# Test custom alert
aws lambda invoke --function-name DisasterAlertSender \
  --payload '{"alert_type":"TEST","message":"System test","severity":"HIGH"}' \
  response.json

# Test emergency scenario
aws lambda invoke --function-name DisasterDataGenerator \
  --payload '{"scenario":"flood_emergency"}' response.json
```

### Test Scenarios
- **Normal Operations**: Sensors within safe thresholds
- **Flood Emergency**: Critical water levels triggering evacuations  
- **Earthquake Alert**: High magnitude seismic activity
- **Severe Weather**: Storm conditions with multiple risks

## Monitoring

### CloudWatch Integration
- **Lambda Metrics**: Execution time, error rates, invocation count
- **SNS Metrics**: Message delivery success/failure rates
- **System Health**: Overall system performance monitoring
- **Cost Tracking**: AWS service usage and billing alerts

### Available Metrics
```
DisasterMonitoring/DataGeneration/Count
DisasterMonitoring/AlertsSent/Count  
DisasterMonitoring/Errors/Count
DisasterMonitoring/PredictionAccuracy
```

## Cost Optimization

### Estimated Monthly Costs (1440 executions/day)
- **Lambda Executions**: $1-3
- **EventBridge Rules**: $0.50-1  
- **SNS Messages**: $0.50-2
- **CloudWatch Logs**: $1-2
- **Total**: ~$3-8/month

### Cost Reduction Tips
1. Adjust EventBridge frequency based on monitoring needs
2. Set CloudWatch log retention to 7-14 days  
3. Use SNS message filtering to reduce unnecessary alerts
4. Monitor and optimize Lambda memory allocation

## Security

### IAM Policies
- Least privilege access for all Lambda functions
- Separate execution roles for different components
- SNS topic access restricted to authorized services

### Data Protection
- No sensitive data stored (simulation only)
- CloudWatch logs with configurable retention
- SNS message encryption in transit

## Deployment

### Development Environment
```bash
./scripts/deploy.sh
```

### Cleanup
```bash
# Delete CloudFormation stack
aws cloudformation delete-stack --stack-name DisasterMonitoringSystem

# Remove S3 bucket (replace with actual bucket name)
aws s3 rb s3://disaster-monitoring-lambda-code-XXXXX --force
```

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
- Contact: [:shoaibalimir1334@gmail.com](mailto:shoaibalimir1334@gmail.com)
- LinkedIn: [LinkedIn Profile](https://linkedin.com/in/shoaibalimir)

## Learning Objectives

This project demonstrates:
- **IoT Simulation**: Creating realistic sensor data patterns for disaster scenarios
- **Serverless Architecture**: Building scalable monitoring systems with AWS Lambda  
- **Event-Driven Design**: Using EventBridge for automated data generation
- **Rule-Based ML**: Implementing disaster prediction without expensive ML services
- **Alert Systems**: Designing effective notification and escalation workflows
- **Infrastructure as Code**: CloudFormation for reproducible deployments
- **AWS Integration**: Combining multiple AWS services for complete solutions

---

**Note**: This is a simulation system for educational/presentation purposes. For production disaster monitoring, integrate with real IoT sensors and professional ML models.
