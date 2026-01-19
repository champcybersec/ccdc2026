#!/bin/bash

# Reports system users who have SSH key material under their home directory.
# Searches for authorized_keys, private keys (id_*), and public keys (*.pub).

set -uo pipefail

has_keys=false

while IFS=: read -r username _ _ _ _ homedir shell; do
  [[ -z "$homedir" || ! -d "$homedir" ]] && continue
  ssh_dir="$homedir/.ssh"
  [[ ! -d "$ssh_dir" ]] && continue

  mapfile -t key_files < <(find "$ssh_dir" -maxdepth 1 -type f \
    \( -name 'authorized_keys' -o -name 'authorized_keys2' -o -name '*.pub' -o -name 'id_*' \) 2>/dev/null)

  # Deduplicate entries by printing once per user
  if [[ ${#key_files[@]} -gt 0 ]]; then
    has_keys=true
    echo "User: $username"
    for key_file in "${key_files[@]}"; do
      echo "  $key_file"
    done
  fi
done < /etc/passwd

if [[ $has_keys == false ]]; then
  echo "No users with SSH key material found under home directories."
fi
