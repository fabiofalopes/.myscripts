import sys
import os
import django

# Setup Django environment
sys.path.insert(0, "/opt/jumpserver/apps")
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "jumpserver.settings")
django.setup()

from assets.models import Asset, Protocol


def fix_protocols(ip, protocol_name="ssh", port=22):
    print(f"--- Fixing Protocols for {ip} ---")
    asset = Asset.objects.filter(address=ip).first()
    if not asset:
        print(f"Error: Asset {ip} not found.")
        return

    # Check if protocol exists
    exists = asset.protocols.filter(name=protocol_name).exists()
    if exists:
        print(f"Protocol {protocol_name}/{port} already exists.")
    else:
        try:
            Protocol.objects.create(name=protocol_name, port=port, asset=asset)
            print(f"SUCCESS: Added protocol {protocol_name}/{port} to {asset.name}")
        except Exception as e:
            print(f"Error creating protocol: {e}")


if __name__ == "__main__":
    fix_protocols("192.168.112.10")
