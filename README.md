# Smart Environmental Monitoring System

[![AWS](https://img.shields.io/badge/AWS-Cloud-orange)](https://aws.amazon.com/)
[![Python](https://img.shields.io/badge/Python-3.9-blue)](https://python.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

A comprehensive IoT-based environmental monitoring solution that demonstrates the integration of simulated IoT sensors, cloud computing, and AI/ML technologies using AWS services.

## Architecture Overview

This project simulates environmental sensors and processes their data through a serverless architecture on AWS, implementing real-time analytics and anomaly detection.

### System Components
- **Data Generation**: Simulated IoT sensors using EventBridge and Lambda
- **Data Processing**: Real-time stream processing with Lambda functions
- **Storage**: DynamoDB for real-time data, S3 for historical storage
- **Analytics**: Custom anomaly detection using statistical models
- **API**: RESTful endpoints via API Gateway
- **Visualization**: Real-time dashboard with interactive charts

## Quick Start

### Prerequisites
- AWS CLI configured with appropriate permissions
- Python 3.9+
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/shoaibalimir/iot-meets-cloud-and-ai.git
   cd iot-meets-cloud-and-ai
   ```

2. **Deploy the infrastructure**
   ```bash
   chmod +x scripts/setup-environment.sh
   ./scripts/setup-environment.sh
   ```

3. **Deploy CloudFormation stack**
   ```bash
   aws cloudformation create-stack \
     --stack-name iot-monitoring-system \
     --template-body file://infrastructure/cloudformation/main-stack.yaml \
     --capabilities CAPABILITY_NAMED_IAM \
     --parameters ParameterKey=Environment,ParameterValue=dev
   ```

4. **Access the dashboard**
   - Get the CloudFront URL from stack outputs
   - Open the dashboard to view real-time sensor data

## Features

### IoT Data Simulation
- **Temperature Sensor**: Simulates room temperature (18°C - 35°C)
- **Humidity Sensor**: Relative humidity percentage (30% - 80%)
- **Air Quality Sensor**: CO, NO2, PM2.5 levels
- **Light Sensor**: Ambient light levels (0-1023 lux)
- **Motion Sensor**: Binary occupancy detection

### Real-time Processing
- Data validation and enrichment
- Statistical anomaly detection
- Trend analysis and forecasting
- Automated alerting via SNS

### AI/ML Capabilities
- **Anomaly Detection**: Statistical model identifying unusual patterns
- **Predictive Analytics**: Forecasting environmental conditions
- **Pattern Recognition**: Identifying daily/weekly usage patterns
- **Alert Classification**: Smart categorization of anomalies

### API Endpoints
```
GET  /sensors              - List all sensors
GET  /sensors/{id}/data    - Get sensor readings
GET  /analytics/anomalies  - Get detected anomalies
GET  /dashboard/metrics    - Get dashboard data
POST /alerts/subscribe     - Subscribe to alerts
```

## Architecture Details

### High-Level Architecture
```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│ EventBridge │<---│    Lambda    │--->│ DynamoDB    │
│   Rules     │    │ Data Gen.    │    │ (Real-time) │
└─────────────┘    └──────────────┘    └─────────────┘
                            |
                            V
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   SNS       │<---│    Lambda    │--->│     S3      │
│ Alerts      │    │ Processor    │    │ (Archive)   │
└─────────────┘    └──────────────┘    └─────────────┘
                            |
                            V
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   Web       │<---│ API Gateway  │--->│ CloudWatch  │
│ Dashboard   │    │              │    │ Metrics     │
└─────────────┘    └──────────────┘    └─────────────┘
```

### Data Flow
1. **EventBridge** triggers data generation every minute
2. **Lambda Data Generator** creates realistic sensor readings
3. **Lambda Processor** validates, enriches, and stores data
4. **Anomaly Detection** runs statistical analysis
5. **API Gateway** exposes data via RESTful endpoints
6. **Dashboard** displays real-time visualizations

## Project Structure

```
├── src/lambda/              # Lambda function code
│   ├── data-generator/      # IoT data simulation
│   ├── data-processor/      # Data processing logic
│   ├── api-handler/         # API Gateway handlers
│   └── ml-predictor/        # ML inference functions
├── infrastructure/          # CloudFormation templates
├── docs/                    # Architecture documentation
├── tests/                   # Unit and integration tests
└── scripts/                 # Deployment and utility scripts
```

## Configuration

### Environment Variables
```bash
# AWS Configuration
AWS_REGION=us-east-1
ENVIRONMENT=dev

# Application Settings
SENSOR_COUNT=5
DATA_GENERATION_INTERVAL=60
ANOMALY_THRESHOLD=2.5
ALERT_EMAIL=your-email@example.com
```

### Sensor Configuration
Edit `config/dev.yaml` to customize sensor parameters:
```yaml
sensors:
  temperature:
    min: 18
    max: 35
    unit: "celsius"
  humidity:
    min: 30
    max: 80
    unit: "percentage"
```

## Testing

### Unit Tests
```bash
cd tests/unit
python -m pytest test_data_generator.py -v
python -m pytest test_data_processor.py -v
```

### Integration Tests
```bash
cd tests/integration
python -m pytest test_end_to_end.py -v
```

### Load Testing
```bash
python scripts/generate-test-data.py --sensors 100 --duration 3600
```

## Monitoring

### CloudWatch Metrics
- `SensorReadings/Count`: Number of readings per minute
- `Anomalies/Detected`: Anomalies detected per hour
- `API/ResponseTime`: API endpoint response times
- `Errors/Count`: Error count by function

### Dashboards
- Real-time sensor readings
- Anomaly detection results
- System performance metrics
- Cost optimization insights

## Alerts Configuration

### SNS Topics
- **Critical Alerts**: Temperature > 35°C, Air Quality dangerous
- **Warning Alerts**: Humidity > 75%, unusual patterns
- **Info Alerts**: Daily summaries, system status

### Alert Rules
```json
{
  "temperature_critical": {
    "threshold": 35,
    "severity": "critical",
    "notification": "immediate"
  },
  "humidity_warning": {
    "threshold": 75,
    "severity": "warning",
    "notification": "batched"
  }
}
```

## Cost Optimization

### Estimated Monthly Costs (1000 readings/day)
- **Lambda**: $2-5
- **DynamoDB**: $3-8
- **API Gateway**: $1-3
- **S3**: $0.50-2
- **CloudWatch**: $1-3
- **Total**: ~$7-21/month

### Cost Reduction Tips
1. Use DynamoDB on-demand pricing for variable workloads
2. Enable S3 Intelligent Tiering for historical data
3. Set CloudWatch log retention to 30 days
4. Use Reserved Capacity for predictable workloads

## Security

### IAM Policies
- Least privilege access for Lambda functions
- Separate roles for different components
- Cross-service permissions properly scoped

### Data Protection
- Encryption at rest for DynamoDB and S3
- API Gateway with API key authentication
- VPC endpoints for private communication

## Deployment

### Development Environment
```bash
./scripts/deploy.sh dev
```

### Production Environment
```bash
./scripts/deploy.sh prod
```

### Cleanup
```bash
./scripts/cleanup.sh
aws cloudformation delete-stack --stack-name iot-monitoring-system
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For questions or support:
- Create an issue in this repository
- Contact: [your-email@example.com](mailto:shoaibalimir@icloud.com)
- LinkedIn: [Your LinkedIn Profile](https://linkedin.com/in/shoaibalimir)

## Learning Objectives

This project demonstrates:
- **IoT Data Simulation**: Creating realistic sensor data patterns
- **Serverless Architecture**: Building scalable solutions with AWS Lambda
- **Real-time Processing**: Stream processing with AWS services
- **AI/ML Integration**: Implementing anomaly detection algorithms
- **API Design**: Creating RESTful APIs with proper documentation
- **Infrastructure as Code**: Using CloudFormation for reproducible deployments
- **Monitoring & Alerting**: Implementing comprehensive observability

---
