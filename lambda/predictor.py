# lambda/predictor.py
import json
import os
import boto3
from datetime import datetime

sns = boto3.client('sns')

def lambda_handler(event, context):
    """Simulate ML disaster prediction using simple rules"""
    
    try:
        # Extract sensor data
        sensors = event.get('sensors', {})
        timestamp = event.get('timestamp', datetime.utcnow().isoformat())
        
        alerts = []
        risk_level = 'LOW'
        
        # Water level analysis (Flood prediction)
        water_data = sensors.get('water_level', {})
        water_level = water_data.get('value', 0)
        if water_level > 12:
            alerts.append("🚨 CRITICAL FLOOD RISK - Immediate evacuation recommended")
            risk_level = 'CRITICAL'
        elif water_level > 8:
            alerts.append("⚠️ HIGH FLOOD RISK - Monitor situation closely")
            if risk_level == 'LOW':
                risk_level = 'HIGH'
        elif water_level > 6:
            alerts.append("⚡ MODERATE FLOOD RISK - Stay alert")
            if risk_level == 'LOW':
                risk_level = 'MODERATE'
        
        # Vibration analysis (Earthquake prediction)  
        vibration_data = sensors.get('vibration', {})
        vibration = vibration_data.get('value', 0)
        if vibration > 7:
            alerts.append("🚨 MAJOR EARTHQUAKE ACTIVITY - Take cover immediately")
            risk_level = 'CRITICAL'
        elif vibration > 5:
            alerts.append("⚠️ SIGNIFICANT SEISMIC ACTIVITY - Prepare for earthquake")
            if risk_level in ['LOW', 'MODERATE']:
                risk_level = 'HIGH'
        elif vibration > 3:
            alerts.append("⚡ MINOR SEISMIC ACTIVITY - Monitor situation")
            if risk_level == 'LOW':
                risk_level = 'MODERATE'
        
        # Weather analysis (Storm/Flash flood prediction)
        weather_data = sensors.get('weather', {})
        rainfall = weather_data.get('rainfall', 0)
        wind_speed = weather_data.get('wind_speed', 0)
        
        if rainfall > 75 and wind_speed > 60:
            alerts.append("🌪️ SEVERE STORM WARNING - Seek shelter immediately")
            risk_level = 'CRITICAL'
        elif rainfall > 50:
            alerts.append("🌧️ HEAVY RAINFALL WARNING - Flash flood risk")
            if risk_level in ['LOW', 'MODERATE']:
                risk_level = 'HIGH'
        elif wind_speed > 70:
            alerts.append("💨 HIGH WIND WARNING - Secure loose objects")
            if risk_level == 'LOW':
                risk_level = 'MODERATE'
        
        # Send alerts if any detected
        if alerts:
            send_alert(alerts, risk_level, event, timestamp)
            
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'alerts_generated': True,
                    'risk_level': risk_level,
                    'alerts': alerts,
                    'sensor_data': sensors,
                    'timestamp': timestamp
                })
            }
        else:
            print(f"No alerts - All sensors within normal range at {timestamp}")
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'alerts_generated': False,
                    'risk_level': 'LOW',
                    'message': 'All systems normal',
                    'sensor_data': sensors,
                    'timestamp': timestamp
                })
            }
            
    except Exception as e:
        print(f"Error in disaster predictor: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

def send_alert(alerts, risk_level, sensor_data, timestamp):
    """Send alert via SNS"""
    try:
        sns_topic_arn = os.environ.get('SNS_TOPIC_ARN')
        
        if not sns_topic_arn:
            print("No SNS topic ARN configured")
            return
        
        # Create alert message
        message_parts = [
            f"🚨 DISASTER EARLY WARNING SYSTEM 🚨",
            f"Risk Level: {risk_level}",
            f"Time: {timestamp}",
            "",
            "ALERTS:",
        ]
        
        for i, alert in enumerate(alerts, 1):
            message_parts.append(f"{i}. {alert}")
        
        message_parts.extend([
            "",
            "SENSOR DATA:",
            f"💧 Water Level: {sensor_data.get('sensors', {}).get('water_level', {}).get('value', 'N/A')} meters",
            f"📳 Vibration: {sensor_data.get('sensors', {}).get('vibration', {}).get('value', 'N/A')} magnitude", 
            f"🌧️ Rainfall: {sensor_data.get('sensors', {}).get('weather', {}).get('rainfall', 'N/A')} mm",
            f"💨 Wind: {sensor_data.get('sensors', {}).get('weather', {}).get('wind_speed', 'N/A')} km/h",
            "",
            "Take appropriate action immediately!"
        ])
        
        message = "\n".join(message_parts)
        subject = f"🚨 {risk_level} DISASTER ALERT - {len(alerts)} Warning(s)"
        
        # Send to SNS
        response = sns.publish(
            TopicArn=sns_topic_arn,
            Message=message,
            Subject=subject
        )
        
        print(f"Alert sent to SNS. MessageId: {response['MessageId']}")
        
    except Exception as e:
        print(f"Error sending SNS alert: {str(e)}")