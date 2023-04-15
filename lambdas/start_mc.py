import boto3
import os

def handler(event, context):
    # Get the EC2 instance ID from the Lambda event
    instance_id = os.environ.get('INSTANCE_ID')
    
    # Create an EC2 client
    ec2_client = boto3.client('ec2')
    
    # Start the EC2 instance
    ec2_client.start_instances(InstanceIds=[instance_id])

    # Public IP of ec2 instance
    ec2_resources = boto3.resource('ec2')
    instance = ec2_resources.Instance(instance_id)
    public_ip_address = instance.public_ip_address
    
    # Return a success message
    return {
        'statusCode': 200,
        'body': (
            f'Started EC2 instance: {instance_id} | '
            f'Connect to the server at IP: {public_ip_address}'
        )
    }
