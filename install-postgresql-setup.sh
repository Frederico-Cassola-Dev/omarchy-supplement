#!/usr/bin/env bash

# 🚀 Complete PostgreSQL Setup Script for Arch Linux (FIXED)
PACKAGE_NAME='postgresql'

set -e # Exit on any error

echo "🛡️ PostgreSQL Setup Script - SAFE MODE"

# 1. CHECK/INSTALL PACKAGE
if ! pacman -Qi "$PACKAGE_NAME" &>/dev/null; then
	echo "📥 ==> Installing '$PACKAGE_NAME' package..."
	if yay -S --noconfirm --needed "$PACKAGE_NAME"; then
		echo "✅ SUCCESS ==> '$PACKAGE_NAME' installed!"
	else
		echo "❌ ERROR ==> Failed to install package!"
		exit 1
	fi
else
	echo "⚠️  ==> '$PACKAGE_NAME' already installed"
fi

# 2. SAFETY CHECK - List existing databases
echo "📋 ==> Checking current databases..."
if sudo systemctl is-active --quiet postgresql &>/dev/null; then
	echo "   Current databases:"
	sudo -iu postgres psql -l -t | awk '{print $1}' | grep -v '^$' || true
	echo ""
fi

# 3. ASK FOR DATABASE NAME
read -p "📝 Enter database name (default: 'mydb'): " DB_NAME
DB_NAME=${DB_NAME:-mydb}
USERNAME=$(whoami)
echo "✅ Will use: DB='$DB_NAME', User='$USERNAME'"

# 4. ASK USER WHAT TO DO
echo "Choose action:"
echo "  1) Fresh install (⚠️ DELETES ALL DATABASES)"
echo "  2) Just start existing service"
echo "  3) Create new database '$DB_NAME' for Next.js project"
read -p "Enter choice (1-3): " choice

case $choice in
1)
	# FRESH INSTALL - DESTRUCTIVE
	read -p "⚠️  CONFIRM: Delete ALL databases? (y/N): " -n 1 -r
	echo
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		echo "❌ ABORTED - Keeping databases safe!"
		exit 0
	fi

	echo "🧹 ==> Fresh PostgreSQL setup (DESTRUCTIVE)..."

	# Stop service
	sudo systemctl stop postgresql &>/dev/null || true

	# Remove ALL data
	sudo rm -rf /var/lib/postgres/data_old /var/lib/postgres/data

	# Create fresh data dir
	sudo mkdir -p /var/lib/postgres/data
	sudo chown postgres:postgres /var/lib/postgres/data
	sudo chmod 700 /var/lib/postgres/data

	# Initialize
	sudo -iu postgres initdb --locale=$LANG -E UTF8 -D /var/lib/postgres/data
	echo "✅ Fresh database cluster created!"

	# Start service
	sudo systemctl start postgresql
	sudo systemctl enable postgresql

	# Create user WITHOUT interactive prompts (non-interactive)
	sudo -iu postgres psql -c "CREATE USER \"$USERNAME\" SUPERUSER CREATEDB CREATEROLE;"
	sudo -iu postgres createdb -O "$USERNAME" "$DB_NAME"
	echo "✅ User '$USERNAME' and database '$DB_NAME' created!"
	;;

2)
	# JUST START SERVICE
	echo "🔄 ==> Starting PostgreSQL service..."
	sudo systemctl start postgresql
	sudo systemctl enable postgresql
	;;

3)
	# CREATE NEW DATABASE (NON-DESTRUCTIVE)
	echo "🆕 ==> Creating database '$DB_NAME' for Next.js..."
	sudo systemctl start postgresql &>/dev/null || sudo systemctl start postgresql

	# Check and create user (non-interactive)
	if ! sudo -iu postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$USERNAME'" | grep -q 1; then
		sudo -iu postgres psql -c "CREATE USER \"$USERNAME\" SUPERUSER CREATEDB CREATEROLE;"
		echo "✅ User '$USERNAME' created!"
	else
		echo "⚠️  User '$USERNAME' already exists"
	fi

	# Check and create database
	if ! sudo -iu postgres psql -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
		sudo -iu postgres createdb -O "$USERNAME" "$DB_NAME"
		echo "✅ Database '$DB_NAME' created!"
	else
		echo "⚠️  Database '$DB_NAME' already exists"
	fi
	;;

*)
	echo "❌ Invalid choice!"
	exit 1
	;;
esac

# 5. FINAL VERIFICATION + CONNECTION STRING
echo "🔍 ==> Verifying setup..."
sleep 2
if sudo systemctl is-active --quiet postgresql && pg_isready &>/dev/null; then
	echo "✅ SUCCESS ==> PostgreSQL running ✓"

	# Test database connection
	if sudo -iu postgres psql -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
		echo "✅ Database '$DB_NAME' exists ✓"
		echo ""
		echo "🎉 READY FOR NEXT.JS/PRISMA!"
		echo "📝 Add to your .env file:"
		echo "   DATABASE_URL=\"postgresql://$USERNAME@localhost:5432/$DB_NAME\""
		echo ""
		echo "   → Test connection: sudo -iu postgres psql -d $DB_NAME"
		echo "   → Prisma: npx prisma db push"
	else
		echo "⚠️  Database '$DB_NAME' not found - create it manually:"
		echo "   sudo -iu postgres createdb -O $USERNAME $DB_NAME"
	fi
else
	echo "❌ ERROR ==> PostgreSQL not working!"
	sudo systemctl status postgresql --no-pager -l
	exit 1
fi

echo "✅ COMPLETE ==> PostgreSQL + '$DB_NAME' ready for your project!"
