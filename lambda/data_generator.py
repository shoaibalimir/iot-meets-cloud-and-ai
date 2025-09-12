# lambda/data_generator.py
import json
import random
import boto3
import os
from datetime import datetime

lambda_client = boto3.client('lambda')

def lambda_handler(event, context):
    """Generate mock IoT sensor data and send to predictor"""
    
    # Generate mock sensor data
    sensor_data = {
        'timestamp': datetime.utcnow().isoformat(),
        'sensors': {
            'water_level': {
                'sensor_id': 'WL001',
                'value': round(random.uniform(0, 15), 2),
                'unit': 'meters',
                'location': 'River Basin A'
            },
            'vibration': {
                'sensor_id': 'VB001', 
                'value': round(random.uniform(0, 10), 2),
                'unit': 'magnitude',
                'location': 'Seismic Station 1'
            },
            'weather': {
                'sensor_id': 'WS001',
                'rainfall': round(random.uniform(0, 100), 2),
                'wind_speed': round(random.uniform(0, 80), 2),
                'temperature': round(random.uniform(15, 35), 1),
                'location': 'Weather Station A'
            }
        }
    }
    
    print(f"Generated sensor data: {json.dumps(sensor_data)}")
    
    # Send data to predictor lambda
    try:
        predictor_function = os.environ.get('PREDICTOR_FUNCTION', 'DisasterPredictor')
        
        lambda_client.invoke(
            FunctionName=predictor_function,
            InvocationType='Event',
            Payload=json.dumps(sensor_data)
        )
        
        print(f"Data sent to predictor: {predictor_function}")
        
    except Exception as e:
        print(f"Error invoking predictor: {str(e)}")
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Mock sensor data generated and sent to predictor',
            'data': sensor_data
        })
    }