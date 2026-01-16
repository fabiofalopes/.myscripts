import sys
import os
import django
import argparse

# Setup Django environment
sys.path.insert(0, "/opt/jumpserver/apps")
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "jumpserver.settings")
django.setup()

from assets.models import Asset, Node, Platform, Protocol
from accounts.models import Account
from orgs.models import Organization


def add_asset(
    ip,
    hostname,
    platform_name="Linux",
    node_name="Default",
    protocol_name="ssh",
    port=22,
    username=None,
    password=None,
):
    # 1. Get Organization
    org = Organization.objects.first()
    if not org:
        print("Error: Default Organization not found.")
        return

    # 2. Get or Create Node
    node = Node.objects.filter(org_id=org.id, value=node_name).first()
    if not node:
        print(f"Node '{node_name}' not found, creating...")
        try:
            # Using 'value' as the name/identifier for the node
            node = Node.objects.create(value=node_name, key="1", org_id=org.id)
        except Exception as e:
            print(f"Error creating node: {e}")
            return

    # 3. Get Platform
    platform = Platform.objects.filter(name__icontains=platform_name).first()
    if not platform:
        print(
            f"Error: Platform '{platform_name}' not found. Available: Linux, Windows, etc."
        )
        return

    # 4. Create Asset
    # Note: 'address' is the field for IP/Hostname in newer versions, but let's check the model if needed.
    # Based on previous error, 'ip' was wrong, 'address' was correct.
    try:
        asset, created = Asset.objects.get_or_create(
            address=ip,
            org_id=org.id,
            defaults={
                "name": hostname,
                "platform": platform,
                "is_active": True,
            },
        )

        if created:
            asset.nodes.add(node)
            # Add Protocol
            Protocol.objects.create(name=protocol_name, port=port, asset=asset)

            # Add Account (if provided)
            if username and password:
                Account.objects.create(
                    username=username,
                    secret=password,
                    secret_type="password",
                    asset=asset,
                    name=username,
                    is_active=True,
                    org_id=org.id,
                )
                print(
                    f"SUCCESS: Added Host: {hostname} ({ip}) with {protocol_name}/{port} and Account: {username}"
                )
            else:
                print(
                    f"SUCCESS: Added Host: {hostname} ({ip}) with {protocol_name}/{port}"
                )

            asset.save()
        else:
            print(f"INFO: Host {ip} already exists.")

    except Exception as e:
        print(f"Error adding asset: {e}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Add a host to JumpServer")
    parser.add_argument("ip", help="IP Address of the host")
    parser.add_argument("hostname", help="Hostname for display")
    parser.add_argument("--platform", default="Linux", help="Platform (Linux/Windows)")
    parser.add_argument("--user", help="Username for the asset")
    parser.add_argument("--password", help="Password for the asset")

    args = parser.parse_args()

    add_asset(
        args.ip,
        args.hostname,
        args.platform,
        username=args.user,
        password=args.password,
    )
