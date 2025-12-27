#!/usr/bin/env bash

# Intructions
# run this command to put it globally with the command
# manage      -> Give the status
# manage up   -> Up all the containers
# manage down -> Down all the containers
set -e

WORKSPACE="$HOME/workspace"
folders=("jam-service-mesh" "moteur" "logistique" "logistique-front")
action="${1:-status}"

case "$action" in
up)
	echo "🚀 Démarrage depuis $WORKSPACE..."
	for folder in "${folders[@]}"; do
		dir="$WORKSPACE/$folder"
		if [ -d "$dir" ]; then
			(cd "$dir" && make up -d && echo "✓ $folder 🟢 UP")
		else
			echo "❌ $dir introuvable"
		fi
	done
	;;
down)
	echo "🛑 Arrêt depuis $WORKSPACE..."
	for folder in "${folders[@]}"; do
		dir="$WORKSPACE/$folder"
		if [ -d "$dir" ]; then
			(cd "$dir" && make down && echo "✓ $folder 🔴 DOWN")
		fi
	done
	;;
status)
	echo "📊 Statut des services :"
	for folder in "${folders[@]}"; do
		dir="$WORKSPACE/$folder"
		if [ -d "$dir" ]; then
			echo -e "\n📁 $folder:"
			cd "$dir"
			docker compose ps --format "table {{.Service}}\t{{.Status}}" 2>/dev/null | awk '
BEGIN {
    print "┌─────────────────────────────┐"
    print "│ SERVICE        │ STATUS     │"
    print "├─────────────────────────────┤"
}
NR==1 && NF==2 {next}
NR>1 {
    status = ($2 ~ /Up/ ? "🟢 UP" : ($2 ~ /Restarting/ ? "🔒 Restarting" : "🔴 DOWN"))
    printf "│ %-14s │ %-9s │\n", $1, status
}
END {
    if(NR==1) printf "│ %-14s │ %-9s │\n", "Aucun service", "❌ trouvé"
    print "└─────────────────────────────┘"
}'
			cd "$WORKSPACE"
		fi
	done
	;;
*)
	echo "Usage: manage {up|down|status}"
	exit 1
	;;
esac

echo "✅ Terminé !"
