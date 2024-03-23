#!/usr/bin/env bash

set -euox pipefail

# Read activation bytes from configuration file.
ACTIVATION_BYTES=$(jq -r -c '.activation_bytes' /unlock_aax/config/config.json)
if [ -z "$ACTIVATION_BYTES" ]; then
  echo "ERROR: Unable to find activation_bytes in configuration file (config.json)."
  exit 1
fi

# Read contents of ledger.json into a variable.
LEDGER=$(cat /unlock_aax/config/ledger.json)

# Iterate over files in the staging directory
for AUDIOBOOK in /unlock_aax/staging/*.aax; do
  # Unlock audiobook if it isn't in the ledger.
  if [ -z "$(echo "$LEDGER" | jq -r --arg AUDIOBOOK "${AUDIOBOOK}" '.audiobooks[] | select (. == $AUDIOBOOK)')" ]; then
    FILE=$(basename "$AUDIOBOOK")
    if ffmpeg -activation_bytes "$ACTIVATION_BYTES" -i "$INPUT" -c copy "/unlock_aax/production/${FILE%.*}.m4b"; then
      LEDGER=$(echo "$LEDGER" | jq --arg AUDIOBOOK "${AUDIOBOOK}" '.audiobooks[.audiobooks | length] |= . + "$AUDIOBOOK"')
    fi
  fi
done

# Update contents of ledger.json.
echo "$LEDGER" > /unlock_aax/config/ledger.json