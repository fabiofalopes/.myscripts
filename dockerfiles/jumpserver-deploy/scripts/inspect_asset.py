import sys
import os
import django

# Setup Django environment
sys.path.insert(0, "/opt/jumpserver/apps")
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "jumpserver.settings")
django.setup()

from assets.models import Asset
from perms.models import AssetPermission
from django.contrib.auth import get_user_model


def inspect(ip):
    print(f"--- Inspecting Asset: {ip} ---")
    asset = Asset.objects.filter(address=ip).first()
    if not asset:
        print("Asset NOT FOUND in database.")
        return

    print(f"ID: {asset.id}")
    print(f"Hostname: {asset.name}")
    print(f"Active: {asset.is_active}")
    print(f"Org: {asset.org.name if asset.org else 'None'}")
    print(f"Protocols: {asset.protocols.all()}")

    print("Accounts:")
    for acc in asset.accounts.all():
        print(f" - {acc.username} (Secret type: {acc.secret_type})")

    print("Nodes:")
    for node in asset.nodes.all():
        print(f" - {node.value} (Key: {node.key})")

    print("\n--- Permissions ---")
    User = get_user_model()
    admin = User.objects.filter(username="admin").first()

    perms = AssetPermission.objects.filter(users=admin)
    print(f"Permissions for user 'admin': {perms.count()}")
    for p in perms:
        print(f" - Rule: {p.name}")
        print(f"   Assets: {p.assets.count()}")
        print(f"   Nodes: {p.nodes.count()}")

        # Check if our asset is covered
        if asset in p.get_all_assets():
            print(f"   [MATCH] Covers this asset!")
        else:
            print(f"   [NO MATCH] Does not cover this asset.")


if __name__ == "__main__":
    inspect("192.168.112.10")
