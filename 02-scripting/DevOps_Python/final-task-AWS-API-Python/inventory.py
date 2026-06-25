from __future__ import annotations
import sys
import json
import random
import time
import logging
import argparse
import functools
from dataclasses import dataclass, field, asdict
import boto3
from botocore.config import Config
from botocore.exceptions import ClientError

logger = logging.getLogger(__name__)

THROTTLE_CODES = {"Throttling", "ThrottlingException", "RequestLimitExceeded", "TooManyRequestsException"}

def is_throttling(exc: Exception) -> bool:
    """True solo para errores de throttling de AWS."""
    return (isinstance(exc, ClientError) 
            and exc.response.get("Error", {}).get("Code") in THROTTLE_CODES)

def retry_with_backoff(max_attempts: int = 5, base_delay: float = 0.5, max_delay: float = 20.0, retry_if=is_throttling):
    """Decorador personalizado que implementa Exponential Backoff y Full Jitter."""
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            attempt = 0
            while True:
                try:
                    return func(*args, **kwargs)
                except Exception as exc:
                    attempt += 1
                    if not retry_if(exc) or attempt >= max_attempts:
                        raise
                    
                    # Parte 4b: Implementación de la fórmula oficial de Full Jitter de AWS
                    backoff = min(max_delay, base_delay * (2 ** attempt))
                    sleep_time = random.uniform(0, backoff)
                    
                    logger.warning("Attempt %d failed (%s); retry in %.2fs", attempt, exc, sleep_time)
                    time.sleep(sleep_time)
        return wrapper
    return decorator

@dataclass
class InstanceRecord:
    instance_id: str
    region: str
    instance_type: str
    state: str
    name: str | None
    tags: dict[str, str] = field(default_factory=dict)
    missing_required_tags: list[str] = field(default_factory=list)

def to_record(instance: dict, region: str, required_tags: list[str]) -> InstanceRecord:
    """Transforma el dict crudo de la API en una estructura InstanceRecord tipada."""
    instance_id = instance.get("InstanceId", "unknown")
    instance_type = instance.get("InstanceType", "unknown")
    state = instance.get("State", {}).get("Name", "unknown")
    
    raw_tags = instance.get("Tags", [])
    tag_map = {t["Key"]: t["Value"] for t in raw_tags if "Key" in t and "Value" in t}
    name = tag_map.get("Name")
    
    missing_required_tags = [tag for tag in required_tags if tag not in tag_map]
    
    return InstanceRecord(
        instance_id=instance_id,
        region=region,
        instance_type=instance_type,
        state=state,
        name=name,
        tags=tag_map,
        missing_required_tags=missing_required_tags
    )

def get_region_names(ec2_client) -> list[str]:
    """Obtiene una lista ordenada de nombres de regiones habilitadas."""
    try:
        response = ec2_client.describe_regions()
        return sorted([r["RegionName"] for r in response.get("Regions", []) if "RegionName" in r])
    except ClientError as exc:
        logger.error("Error al listar regiones: %s", exc)
        return []

@retry_with_backoff(max_attempts=5)
def list_instances_in_region(session: boto3.Session, region: str, required_tags: list[str]) -> list[InstanceRecord]:
    """Retorna los registros de instancias de una región manejando paginación activa."""
    # Parte 4a: Configuración explícita del modo retry standard de boto3
    boto3_cfg = Config(retries={"mode": "standard", "total_max_attempts": 3})
    client = session.client("ec2", region_name=region, config=boto3_cfg)
    
    records = []
    try:
        paginator = client.get_paginator("describe_instances")
        for page in paginator.paginate(PaginationConfig={"PageSize": 50}):
            for reservation in page.get("Reservations", []):
                for instance in reservation.get("Instances", []):
                    records.append(to_record(instance, region, required_tags))
    except ClientError as exc:
        code = exc.response.get("Error", {}).get("Code")
        logger.warning("Skipping region %s: %s", region, code)
        
    return records

def parse_args():
    """Configuración de argumentos por línea de comandos usando argparse."""
    parser = argparse.ArgumentParser(description="Audit EC2 instances for required tags across regions.")
    parser.add_argument("--profile", default=None, help="AWS profile (Track A).")
    parser.add_argument("--region", action="append", help="Limit to specific region(s).")
    parser.add_argument("--required-tag", action="append", default=[], help="A tag that must be present.")
    parser.add_argument("--output", choices=["table", "json"], default="table")
    parser.add_argument("-v", "--verbose", action="store_true", help="Debug logging")
    return parser.parse_args()

def main():
    args = parse_args()
    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",
        stream=sys.stderr
    )
    
    try:
        session = boto3.Session(profile_name=args.profile) if args.profile else boto3.Session()
    except Exception as e:
        logger.critical("Fallo de inicialización de la sesión: %s", e)
        sys.exit(2)
        
    default_client = session.client("ec2", region_name="us-east-1")
    target_regions = args.region if args.region else get_region_names(default_client)
    
    all_records = []
    for region in target_regions:
        all_records.extend(list_instances_in_region(session, region, args.required_tag))
        
    non_compliant = [r for r in all_records if r.missing_required_tags]
    
    if args.output == "json":
        print(json.dumps([asdict(r) for r in non_compliant], indent=2, default=str))
    else:
        print("\n" + "="*85)
        print(f"{'REGIÓN':<15} | {'ID INSTANCIA':<20} | {'NAME':<20} | {'TAGS AUSENTES'}")
        print("="*85)
        if not non_compliant:
            print(" ¡Excelente! El 100% de la infraestructura cumple con la gobernanza de tags.")
        for r in non_compliant:
            print(f"{r.region:<15} | {r.instance_id:<20} | {r.name or 'N/A':<20} | {', '.join(r.missing_required_tags)}")
        print("="*85 + "\n")
        
    sys.exit(1 if non_compliant else 0)

if __name__ == "__main__":
    main()