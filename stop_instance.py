import boto3

region = 'us-east-2'
instance_id = aws_instance.example.id

ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    ec2.stop_instances(InstanceIds=[instance_id])
    print(f"Instance {instance_id} stopped")
    
    