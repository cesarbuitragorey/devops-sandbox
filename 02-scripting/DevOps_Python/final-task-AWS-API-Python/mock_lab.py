import os
# Credenciales ficticias obligatorias para aislar las llamadas de red reales de boto3
for key in ("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_SECURITY_TOKEN", "AWS_SESSION_TOKEN"):
    os.environ.setdefault(key, "testing")
os.environ.setdefault("AWS_DEFAULT_REGION", "us-east-1")

import boto3
from moto import mock_aws
# Importación del script principal que acabas de escribir
from inventory import list_instances_in_region

def seed(session, region):
    """Puebla de forma virtual el entorno simulado en memoria RAM."""
    ec2 = session.client("ec2", region_name=region)
    
    # 8 Instancias correctas (tienen 'owner' y 'env')
    ec2.run_instances(
        ImageId="ami-12345678", MinCount=8, MaxCount=8,
        TagSpecifications=[{"ResourceType": "instance", "Tags": [
            {"Key": "Name", "Value": "web"},
            {"Key": "owner", "Value": "platform"},
            {"Key": "env", "Value": "prod"},
        ]}],
    )
    
    # 5 Instancias infractoras (no tienen 'owner')
    ec2.run_instances(
        ImageId="ami-12345678", MinCount=5, MaxCount=5,
        TagSpecifications=[{"ResourceType": "instance", "Tags": [
            {"Key": "Name", "Value": "orphan"},
            {"Key": "env", "Value": "dev"},
        ]}],
    )

@mock_aws
def main():
    session = boto3.Session() 
    seed(session, "us-east-1") 
    
    print("Lanzando auditoría local en memoria con Moto...")
    records = list_instances_in_region(session, "us-east-1", ["owner", "env"])
    non_compliant = [r for r in records if r.missing_required_tags]
    
    print(f"Found {len(records)} instances; {len(non_compliant)} missing a required tag.")
    for r in non_compliant:
        print(f" {r.instance_id} {r.name} missing={r.missing_required_tags}")

if __name__ == "__main__":
    main()