import boto3
import os

def handler(event, context):
    # Get the EC2 instance ID from the Lambda event
    instance_id = os.environ.get('INSTANCE_ID')
    
    # Create an EC2 client
    ec2 = boto3.client('ec2')
    
    # Start the EC2 instance
    ec2.start_instances(InstanceIds=[instance_id])
    
    # Return a success message
    return {
        'statusCode': 200,
        'body': 'Started EC2 instance: ' + instance_id
    }
