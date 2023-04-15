import boto3
import os
from datetime import datetime, timedelta

def handler(event, context):
    ec2 = boto3.resource('ec2')
    instance_id = os.environ.get('INSTANCE_ID')
    instance = ec2.Instance(instance_id)
    
    launch_time = instance.launch_time
    now = datetime.now(launch_time.tzinfo)
    elapsed_time = now - launch_time
    
    if elapsed_time >= timedelta(hours=3):
        instance.stop()
        return {
            'statusCode': 200,
            'body': 'Instance stopped'
        }
    else:
        return {
            'statusCode': 200,
            'body': 'Instance not yet eligible for stopping'
        }
