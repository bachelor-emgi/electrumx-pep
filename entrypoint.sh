#!/bin/bash

# Exit immediately on any error
set -e

# Make sure required environment variables are set
if [ -z "$SSL_CERTFILE" ] || [ -z "$SSL_KEYFILE" ]; then
  echo "Error: SSL_CERTFILE and/or SSL_KEYFILE environment variables are not set."
  exit 1
fi

# Create the directory if it doesn't exist (optional/safe)
mkdir -p "$(dirname "$SSL_CERTFILE")"

# Check if cert and key files exist
if [ ! -f "$SSL_CERTFILE" ] || [ ! -f "$SSL_KEYFILE" ]; then
  echo "Error: SSL certificate or key files do not exist."
  echo "CERT: $SSL_CERTFILE"
  echo "KEY:  $SSL_KEYFILE"
  exit 1
fi

# Set strict permissions
chmod 600 "$SSL_CERTFILE" "$SSL_KEYFILE"

# Start Apache
service apache2 start

# Start ElectrumX
/usr/local/bin/electrumx_compact_history
/usr/local/bin/electrumx_server
