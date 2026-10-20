#!/usr/bin/env bash
# Rebuild the vendored third-party skills in plugins/indie-ios/skills from skills-lock.json.
#
# Usage: scripts/sync-skills.sh            restore exactly the pinned versions
#        scripts/sync-skills.sh --update   pin every skill to its upstream HEAD, restore that, rewrite the lock
#
# Each lock entry pins an upstream commit in `ref`, which `skills experimental_install` clones. Without a ref
# the CLI clones the default branch and never checks `computedHash`, so a "restore" silently pulls upstream
# changes; that is why an entry without a full commit SHA stops the restore.
#
# The plugin system loads skills only from files inside the plugin, so the pinned skills are
# copied in rather than installed per repo. ship-app, new-app, store-assets, first-impression and user-journey are this
# kit's own and are never touched here.
set -euo pipefail

KIT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$KIT/plugins/indie-ios/skills"
case "${1:-}" in
  "") UPDATE=0 ;;
  --update) UPDATE=1 ;;
  *) echo "usage: sync-skills.sh [--update]" >&2; exit 2 ;;
esac

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
cp "$KIT/skills-lock.json" "$WORK/"

cd "$WORK"
if (( UPDATE )); then
  # Pin to the commit fetched here rather than letting `skills update` take whatever HEAD is when it clones,
  # so the ref written to the lock is the commit the copies came from.
  python3 - skills-lock.json <<'EOF'
import json, subprocess, sys
path = sys.argv[1]
lock = json.load(open(path))
heads = {}
for name, entry in lock["skills"].items():
    if entry["sourceType"] != "github":
        sys.exit(f"{name}: --update only knows how to pin github sources, not {entry['sourceType']}")
    source = entry["source"]
    if source not in heads:
        out = subprocess.run(["git", "ls-remote", f"https://github.com/{source}.git", "HEAD"],
                             check=True, capture_output=True, text=True).stdout
        if not out.strip():
            sys.exit(f"{name}: git ls-remote found no HEAD for {source}")
        heads[source] = out.split()[0]
    entry["ref"] = heads[source]
open(path, "w").write(json.dumps(lock, indent=2) + "\n")
EOF
fi

require_pins() {
  python3 - skills-lock.json <<'EOF'
import json, re, sys
unpinned = [name for name, entry in json.load(open(sys.argv[1]))["skills"].items()
            if not re.fullmatch(r"[0-9a-f]{40}", entry.get("ref", ""))]
if unpinned:
    sys.exit("no commit SHA in 'ref' for: " + ", ".join(unpinned) + " (run with --update to pin upstream HEAD)")
EOF
}

require_pins
npx --yes skills experimental_install
if (( UPDATE )); then
  # Recomputes computedHash at the new refs; with the refs already pinned it fetches nothing newer.
  npx --yes skills update -p -y
  require_pins
  # `skills update` drops entries whose skill vanished upstream; the copy loop below would then leave the old
  # folder in the plugin with no lock entry behind it.
  python3 - "$KIT/skills-lock.json" skills-lock.json <<'EOF'
import json, sys
before, after = (set(json.load(open(p))["skills"]) for p in sys.argv[1:3])
if before - after:
    sys.exit("gone upstream, remove by hand from the plugin and lock: " + ", ".join(sorted(before - after)))
EOF
fi

names=$(python3 -c 'import json,sys; print("\n".join(json.load(open(sys.argv[1]))["skills"]))' skills-lock.json)
for name in $names; do
  case "$name" in ship-app|new-app|store-assets|first-impression|user-journey) echo "lock entry '$name' clashes with a kit skill" >&2; exit 1 ;; esac
  # experimental_install writes to .agents/skills whatever agent is asked for (skills CLI 1.7.2).
  [[ -d ".agents/skills/$name" ]] || { echo "not restored: $name" >&2; exit 1; }
done

for name in $names; do
  rm -rf "$DEST/$name"
  cp -R ".agents/skills/$name" "$DEST/$name"
done
(( UPDATE )) && cp skills-lock.json "$KIT/skills-lock.json"

echo "Synced $(echo "$names" | wc -l | tr -d ' ') skills into $DEST"
echo "Next: bump the version in plugins/indie-ios/.claude-plugin/plugin.json, commit, then"
echo "      claude plugin marketplace update indie-ios-kit"
