#!/bin/bash

# Define paths for the PEM files
SSL_CERTFILE="/etc/ssl/private/cloudflare_cert.pem"
SSL_KEYFILE="/etc/ssl/private/cloudflare_key.pem"

# Create the directory if it doesn't exist
mkdir -p /etc/ssl/private

# If certificate or key files do not exist, create them from provided content
if [ ! -e "${SSL_CERTFILE}" ] || [ ! -e "${SSL_KEYFILE}" ]; then
  echo "Creating SSL certificate and key files..."

  # Write the Cloudflare origin certificate to the PEM file
  cat <<EOF > "${SSL_CERTFILE}"
-----BEGIN CERTIFICATE-----
MIIE0TCCA7mgAwIBAgIUQWmdfC6IUIA6H1Nm9EDqUrqZBf4wDQYJKoZIhvcNAQEL
BQAwgYsxCzAJBgNVBAYTAlVTMRkwFwYDVQQKExBDbG91ZEZsYXJlLCBJbmMuMTQw
MgYDVQQLEytDbG91ZEZsYXJlIE9yaWdpbiBTU0wgQ2VydGlmaWNhdGUgQXV0aG9y
aXR5MRYwFAYDVQQHEw1TYW4gRnJhbmNpc2NvMRMwEQYDVQQIEwpDYWxpZm9ybmlh
MB4XDTI0MDcyNTE5NTgwMFoXDTM5MDcyMjE5NTgwMFowYjEZMBcGA1UEChMQQ2xv
dWRGbGFyZSwgSW5jLjEdMBsGA1UECxMUQ2xvdWRGbGFyZSBPcmlnaW4gQ0ExJjAk
BgNVBAMTHUNsb3VkRmxhcmUgT3JpZ2luIENlcnRpZmljYXRlMIIBIjANBgkqhkiG
9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqJ5CfipuuMWO1xOr5A+Qe84dgAGuCMuNgokl
2o4DWTv9J4B6rZo+gXAFPC1daealx1V5E31bax7AbHAtcR3O7Icj/2SO/RX9qqYa
vAkq2YWxXuA68oWaVqZ3IT51xpDswJqoHGSPcpbc1sPh/gJHAvhfU4bNqYWrHLsh
uPBKDYNVyuYDPLy5N23KYOaStruL7CzrLNpcjameWsKqXpfZuAbzZ8PNFdYqi6Aj
aofJUiEcbxRILy5KDcq5X0M8ifF/K7Tqqnc2Q7tR5umuFsc9YBbeIq/rzsotlQsz
SIcaTJ6TzXbeiFvmP+Llu/x020JzSmNZgXqL41k+wHo0Q5+X/QIDAQABo4IBUzCC
AU8wDgYDVR0PAQH/BAQDAgWgMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcD
ATAMBgNVHRMBAf8EAjAAMB0GA1UdDgQWBBStU/DkqEcIAEt/FhMyeWK+tSQTKDAf
BgNVHSMEGDAWgBQk6FNXXXw0QIep65TbuuEWePwppDBABggrBgEFBQcBAQQ0MDIw
MAYIKwYBBQUHMAGGJGh0dHA6Ly9vY3NwLmNsb3VkZmxhcmUuY29tL29yaWdpbl9j
YTBUBgNVHREETTBLgg4qLnBlcGVsdW0uc2l0ZYIVZWxlY3RydW0ucGVwZWx1bS5z
aXRlghRtYWlubWV0LnBlcGVsdW0uc2l0ZYIMcGVwZWx1bS5zaXRlMDgGA1UdHwQx
MC8wLaAroCmGJ2h0dHA6Ly9jcmwuY2xvdWRmbGFyZS5jb20vb3JpZ2luX2NhLmNy
bDANBgkqhkiG9w0BAQsFAAOCAQEAnGruhot6uCCTuoMkgyGpTDJtKT4HpXKsDuXC
Sc/1dvaT9sd4CPn26KbRu9DD7g46YR85kHhd/8EknRmiuS8RYbdGlAejU9DA/Dk2
TM7/NXbRlLi3Z1fm8wFooRyhOG/2zs6wBXjYGoMAMiO8UBCCh00tYpy7QwVQA7lx
T3m+64xAdkZbTzbTJnqeKx+Yj4cQ+6jXwKhPfVYNggldGeRllAmw6+HHqvRqoMKH
Yx/RWqL7MQ1tadp6pAzgr6utEAAcqiNjbgDVwy2Xx9bFKozST2Q7On9rkNHCCa2O
EkQRauNOY2HqgkkPzhCBtD4r7tqn8LL8YwxAjgmrMqIFtU7C2A==
-----END CERTIFICATE-----
EOF

  # Write the Cloudflare private key to the PEM file
  cat <<EOF > "${SSL_KEYFILE}"
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQConkJ+Km64xY7X
E6vkD5B7zh2AAa4Iy42CiSXajgNZO/0ngHqtmj6BcAU8LV1p5qXHVXkTfVtrHsBs
cC1xHc7shyP/ZI79Ff2qphq8CSrZhbFe4DryhZpWpnchPnXGkOzAmqgcZI9yltzW
w+H+AkcC+F9Ths2phascuyG48EoNg1XK5gM8vLk3bcpg5pK2u4vsLOss2lyNqZ5a
wqpel9m4BvNnw80V1iqLoCNqh8lSIRxvFEgvLkoNyrlfQzyJ8X8rtOqqdzZDu1Hm
6a4Wxz1gFt4ir+vOyi2VCzNIhxpMnpPNdt6IW+Y/4uW7/HTbQnNKY1mBeovjWT7A
ejRDn5f9AgMBAAECggEAAVzVIvSOsV4nhckcY1ahIk0tIhSqHyx7ksAvHhrqX7Ge
7yDbDmVSC8OZO/WCtc/mmjLwd/mlqNIQjG5VjSFxD0HFI/9Um02RtuvwH/YcjLH2
DFMeJ49ZKAQPgSsckmgb0sa6RNVhHXn4ZsP/EXgKMnXJ35rEe0xLZQs/o+ce2EMN
bTYKe4EOR/39+UOm9idnsh0+CbGB9jODoQk3Zb3Ls6Mpjk0DumlPw8JjJFY4gaR+
AtITfHxFpbYzZbDJUCWVd5KHBB1flAYD/BvLd0QKwFi8dkQCvyEYSdX1EjQflWsN
BQ3ByQbn84mTo3PwFinAr7mWowZ6hxut/WhPNqiPoQKBgQDUq3kPKEeGrIZ9TzhZ
xHFa4/NICfy+28Fw+rMMCBjtfGuiLhDPOkilyh+E9Ak6vuka6yV81C2Dd4yoUfvd
ntSgCUTXXbnFnsgcSIWahqU3Z3lA8jH1GjpcaPTR7eKGRsqFvpfE8wPhbFjEU6ZI
peyP2EkDY3bw3CCKXyEfdlu9nQKBgQDK+R+FPsoLglhqWpkIHuxejC61uN1SQQS5
J7aOe+K7xjaVdBZPdlruooPislhQhyg43Svpz6JglNgC+g2NHNcJC+A1LUlToEH7
5Qw1rWUgchRoOfbEgoWHwVoyNqiXikMQBJZBLnJzMbIOMLN3W1Mru0RFDm97SBGa
YQFsODtl4QKBgDDRe+Si1mhvyh+Rw9m3Yl3+3aW3xTD6uRj6M4ebhD1fxkVgVbN8
KZkFIN8gNc4qbNAlEmHpQtle5AbvauWgxCZIemkFttNKc50qeKDUL7DcK9Vgw18E
OklkPm7CMLGqJms1KRmov0dL28SVfyJGFFugxoHknzUDEuUwmSXjwYNxAoGAY76V
HNfEVm+Rn4IyHemEYtokwiy8poVJGuxHLDH5NCmt/Tf1Fsuk2AyJH0hhWgFxZLBb
uiTNOQUsOhpDuornqYxqe/drR2tDwdPHckFpps4o9Sc2+07g69u6xV5S71WEq0R1
ykZW/AD57TtFlmwMrTrzy7PSWRULgYAWQOZJWkECgYEAqds/BPjZuBNnpEDKofZV
KaI4vEBUa2OkZpQ08XYd22avAaH9497AVm+8Z+/Jy0oHe1cWYsCkoUUaHkvtIHP7
xuTDj7pcS8ggeKQzXNLroBqhF06NXxNxNJ9zR6fJga8ucuw0TFOguTROVsY3zvkH
9OOPlh0qJTGwm9dO7V73ePw=
-----END PRIVATE KEY-----
EOF

  # Set appropriate permissions for the certificate and key files
  chmod 600 "${SSL_CERTFILE}"
  chmod 600 "${SSL_KEYFILE}"

  # Set ownership to the user running the script (if necessary)
  chown root:root "${SSL_CERTFILE}"
  chown root:root "${SSL_KEYFILE}"
else
  echo "SSL certificate and key files already exist."
fi

# Start the Apache service
service apache2 start

# Start the pepecoin daemon
pepecoind -conf=/root/.pepecoin/pepecoin.conf -datadir=/data 

# Start the ElectrumX server
/root/electrum/electrumx_server
