#!/bin/bash

# Define paths for the PEM files using the mounted directory
SSL_CERTFILE="/etc/ssl/private/electrum.pepelum.site.crt"
SSL_KEYFILE="/etc/ssl/private/electrum.pepelum.site.key"

# Create the directory if it doesn't exist (this is typically redundant with the volume mount)
mkdir -p /etc/ssl/private

# Check if the certificate and key files exist and if not, provide an error message
if [ ! -e "${SSL_CERTFILE}" ] || [ ! -e "${SSL_KEYFILE}" ]; then
  echo "Error: SSL certificate or key files do not exist."
  exit 1
fi

# Set appropriate permissions for the certificate and key files (typically managed by host)
chmod 600 "${SSL_CERTFILE}"
chmod 600 "${SSL_KEYFILE}"

# Start the Apache service
service apache2 start


# Start OpenVPN with the config and auth files
openvpn --config /etc/openvpn/DE-ovpn-tcp.conf --auth-user-pass /etc/openvpn/auth.txt --daemon

# Start the Pepecoin daemon
pepecoind -conf=/root/.pepecoin/pepecoin.conf -datadir=/data 

# Start the ElectrumX server
/root/electrum/electrumx_server