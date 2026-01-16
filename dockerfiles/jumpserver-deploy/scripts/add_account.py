import sys
import os
import django
import argparse

# Setup Django environment
sys.path.insert(0, "/opt/jumpserver/apps")
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "jumpserver.settings")
django.setup()

from assets.models import Asset
from accounts.models import Account
from orgs.models import Organization


def add_account(ip, username, password):
    print(f"--- Adding Account to {ip} ---")

    org = Organization.objects.first()
    if not org:
        print("Error: Default Organization not found.")
        return

    asset = Asset.objects.filter(address=ip).first()
    if not asset:
        print(f"Error: Asset {ip} not found.")
        return

    # Check if account exists
    account = asset.accounts.filter(username=username).first()
    if account:
        print(f"Account '{username}' already exists on this asset.")
        # Update password just in case
        account.secret = password
        account.save()
        print("Updated password.")
    else:
        try:
            Account.objects.create(
                username=username,
                secret=password,
                secret_type="password",
                asset=asset,
                name=username,
                is_active=True,
                org_id=org.id,
            )
            print(f"SUCCESS: Added account '{username}' to {asset.name}")
        except Exception as e:
            print(f"Error creating account: {e}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Add an account to an asset")
    parser.add_argument("ip", help="IP Address of the host")
    parser.add_argument("username", help="Username (e.g. root)")
    parser.add_argument("password", help="Password")

    args = parser.parse_args()

    add_account(args.ip, args.username, args.password)
