import sys
import os
import django
import argparse

# Setup Django environment
sys.path.insert(0, "/opt/jumpserver/apps")
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "jumpserver.settings")
django.setup()

from assets.models import Asset


def remove_asset(ip):
    print(f"--- Removing Asset: {ip} ---")
    asset = Asset.objects.filter(address=ip).first()
    if not asset:
        print(f"Asset {ip} not found.")
        return

    try:
        asset.delete()
        print(f"SUCCESS: Deleted asset {asset.name} ({ip})")
    except Exception as e:
        print(f"Error deleting asset: {e}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Remove an asset from JumpServer")
    parser.add_argument("ip", help="IP Address of the host to remove")

    args = parser.parse_args()

    remove_asset(args.ip)
