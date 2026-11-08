#!/usr/bin/env bash
set -euo pipefail

for script in tasks/*.sh; do
  bash -n "$script"
done

mkdir -p tmp
work=$(mktemp -d "$PWD/tmp/task-tests.XXXXXX")
trap 'rm -rf -- "$work"' EXIT
export TASK_TEST_LOG="$work/calls"
: > "$TASK_TEST_LOG"

cat > "$work/nix" <<'STUB'
#!/usr/bin/env bash
printf 'nix:%s\n' "$*" >> "$TASK_TEST_LOG"
exit "${TASK_TEST_NIX_EXIT:-0}"
STUB
cat > "$work/sudo" <<'STUB'
#!/usr/bin/env bash
printf 'sudo:%s\n' "$*" >> "$TASK_TEST_LOG"
STUB
cat > "$work/uname" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "${TASK_TEST_SYSTEM:-Darwin}"
STUB
chmod +x "$work/nix" "$work/sudo" "$work/uname"
export PATH="$work:$PATH"

for host in macos macos-work nixos nixos-server; do
  output=$(bash tasks/rebuild.sh "$host" --dry-run)
  [[ $output == *"nix run .#check"* && $output == *"--flake ./$host#"* ]]
done
bash tasks/update.sh --dry-run > "$work/update-preview"
[[ ! -s $TASK_TEST_LOG ]]

for invalid in unknown --help ';sudo'; do
  if bash tasks/rebuild.sh "$invalid" > /dev/null 2>&1; then
    echo "Invalid host was accepted: $invalid" >&2
    exit 1
  fi
done
if bash tasks/rebuild.sh macos --unexpected > /dev/null 2>&1 || bash tasks/update.sh --unexpected > /dev/null 2>&1; then
  echo 'An invalid task option was accepted.' >&2
  exit 1
fi
[[ ! -s $TASK_TEST_LOG ]]

# Failed preflight and wrong-platform checks must never reach sudo.
if TASK_TEST_NIX_EXIT=31 bash tasks/rebuild.sh macos > /dev/null 2>&1; then
  echo 'A failed preflight was ignored.' >&2
  exit 1
fi
[[ $(cat "$TASK_TEST_LOG") == 'nix:run .#check' ]]
: > "$TASK_TEST_LOG"
if TASK_TEST_SYSTEM=Linux bash tasks/rebuild.sh macos > /dev/null 2>&1; then
  echo 'A platform mismatch was ignored.' >&2
  exit 1
fi
[[ ! -s $TASK_TEST_LOG ]]

bash tasks/rebuild.sh macos > /dev/null
[[ $(cat "$TASK_TEST_LOG") == $'nix:run .#check\nsudo:nix run --inputs-from ./macos nix-darwin -- switch --flake ./macos#totto2727-macos' ]]
: > "$TASK_TEST_LOG"
TASK_TEST_SYSTEM=Linux bash tasks/rebuild.sh nixos-server > /dev/null
[[ $(cat "$TASK_TEST_LOG") == $'nix:run .#check\nsudo:nixos-rebuild switch --flake ./nixos-server#nixos' ]]
: > "$TASK_TEST_LOG"

bash tasks/update.sh > /dev/null
[[ $(wc -l < "$TASK_TEST_LOG") -eq 8 ]]
[[ $(head -n 1 "$TASK_TEST_LOG") == 'nix:flake update --flake ./share/packages' ]]
[[ $(tail -n 1 "$TASK_TEST_LOG") == 'nix:flake update --flake ./.' ]]
: > "$TASK_TEST_LOG"
if TASK_TEST_NIX_EXIT=31 bash tasks/update.sh > /dev/null 2>&1; then
  echo 'A failed input update was ignored.' >&2
  exit 1
fi
[[ $(cat "$TASK_TEST_LOG") == 'nix:flake update --flake ./share/packages' ]]
printf 'Task safety tests passed. No real update or system switch was executed.\n'
