import sys
import os
import django

# Setup Django environment
sys.path.insert(0, "/opt/jumpserver/apps")
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "jumpserver.settings")
django.setup()

from django.contrib.auth import get_user_model
from assets.models import Node
from accounts.models import AccountTemplate
from perms.models import AssetPermission
from orgs.models import Organization


def grant_admin_access():
    print("--- Granting Admin Access ---")

    # 1. Get Admin User
    User = get_user_model()
    admin = User.objects.filter(username="admin").first()
    if not admin:
        print("Error: User 'admin' not found.")
        return

    # 2. Get Default Org
    org = Organization.objects.first()

    # 3. Get/Create Account Template (System User)
    # We'll create a generic 'root' user.
    sys_user, created = AccountTemplate.objects.get_or_create(
        name="Root",
        username="root",
        org_id=org.id,
        defaults={
            "secret": "password",  # You should change this!
            "secret_type": "password",
        },
    )
    if created:
        print("Created Account Template: Root (username: root)")
    else:
        print("Using existing Account Template: Root")

    # 4. Get Default Node
    node = Node.objects.filter(value="Default", org_id=org.id).first()
    if not node:
        print("Error: Node 'Default' not found.")
        return

    # 5. Create Permission Rule
    perm, created = AssetPermission.objects.get_or_create(
        name="Admin Full Access",
        org_id=org.id,
        defaults={
            "is_active": True,
        },
    )

    # Add relations
    perm.users.add(admin)
    perm.nodes.add(node)

    # Add 'root' to the allowed accounts list
    current_accounts = perm.accounts
    if "root" not in current_accounts:
        current_accounts.append("root")
        perm.accounts = current_accounts
        perm.save()
        print("Added 'root' to allowed accounts.")

    # Also add '@ALL' to allow all accounts (optional, but good for admin)
    if "@ALL" not in current_accounts:
        current_accounts.append("@ALL")
        perm.accounts = current_accounts
        perm.save()
        print("Added '@ALL' to allowed accounts.")

    if created:
        print("SUCCESS: Created permission rule 'Admin Full Access'")
    else:
        print("SUCCESS: Updated permission rule 'Admin Full Access'")

    print("Admin should now see assets in the 'Default' node.")


if __name__ == "__main__":
    grant_admin_access()
