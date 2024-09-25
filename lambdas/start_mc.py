import time

import boto3
import os

RETRY_AMOUNT = 5
RETRY_TIME_INTERVAL_SEC = 5

def handler(event, context):
    # Get the EC2 instance ID from the Lambda event
    instance_id = os.environ.get('INSTANCE_ID')
    
    # Create an EC2 client
    ec2_client = boto3.client('ec2')
    
    # Start the EC2 instance
    ec2_client.start_instances(InstanceIds=[instance_id])

    # Public IP of ec2 instance
    ec2_resources = boto3.resource('ec2')
    public_ip_address = None

    # Retry loop to check for the public IP
    for _ in range(RETRY_AMOUNT):
        time.sleep(RETRY_TIME_INTERVAL_SEC)  # Wait for instance to spin up
        instance = ec2_resources.Instance(instance_id)
        public_ip_address = instance.public_ip_address
        if public_ip_address:
            break

    if public_ip_address:
        print(f"Public IP: {public_ip_address}")
    else:
        public_ip_address = "IP not found, visit AWS console to find the public ipv4 ip."
        print("No public IP address found.")
    
    # Return a success message
    return {
        'statusCode': 200,
        'body': (
            f'Started EC2 instance: {instance_id} | '
            f'Connect to the server at IP: {public_ip_address}'
        )
    }
