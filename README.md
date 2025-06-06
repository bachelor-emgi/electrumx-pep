# What is Pepecoin ElectrumX?
Pepecoin ElectrumX is a high-performance server implementation of the Electrum protocol, originally developed by **[Spesmilo](https://github.com/spesmilo)** for Bitcoin and adapted for Ᵽepecoin by **[Pepe Enthusiast - Master Kush](https://github.com/PepeEnthusiast)** and later modified by **[Mr Bachelor emgi](https://github.com/bachelor-emgi)**. It allows lightweight wallets to interact with the Ᵽepecoin blockchain without downloading the full blockchain.

# What is this used for?
- Mobile Wallets – Provides fast and efficient blockchain access for lightweight Ᵽepecoin mobile wallets.
- Web Wallets – Enables web-based Ᵽepecoin wallets to send, receive, and verify transactions without running a full node.
- Fast Blockchain Queries – Supports instant balance checks, transaction history lookups, and UTXO retrieval.
- Full Node Indexing – Connects to a Ᵽepecoin full node, indexing the blockchain for wallet queries.

# How it works
- ElectrumX connects to a full Ᵽepecoin node (Pepecoin Core).
- It indexes blockchain data, allowing lightweight wallets to request address balances and transaction history.
- Wallets connect to ElectrumX, retrieving data without downloading the full blockchain.

ElectrumX is essential for keeping Ᵽepecoin wallets lightweight, secure and fast while maintaining decentralized access to the blockchain.

# Supported Hardware

| Architecture   | Description           |
|---------------|-----------------------|
| x86_64 / amd64 | 64-bit Intel/AMD CPUs |
| arm64 / aarch64 | 64-bit ARM CPUs       |
| arm (32-bit)  | 32-bit ARM CPUs       |
| ppc64le       | PowerPC 64-bit (Little Endian) |
| s390x         | IBM Z Systems         |

# Versions
Pepecoin ElectrumX has slightly different versioning:
| 1.16           | 0 |
|---------------|-----------------------|
| Original version by **[Spesmilo](https://github.com/spesmilo)** | Our Pepecoin changes, releases. These changes dont affect any methods or functionality. These changes are for improvements of our servers and helping us keep track who of all ElectrumX operators updated and are using latest version of server. |

# You will need:
1. Pepecoin core with pepecoin.conf from this repository - https://github.com/pepecoinppc/pepecoin/releases
2. Docker - https://docs.docker.com/engine/install/
3. Valid SSL certificate for your domain (You can use Certbot from this repository if you are using Cloudflare)

### To run Pepecoin ElectrumX server you need to use this command (edit the variables to your needs):
```bash
docker run -d \
  -p 50001:50001/tcp \
  -p 50002:50002/tcp \
  -p 50004:50004/tcp \
  -p 8002:80/tcp \
  -v /home/user/certs:/etc/ssl/private \
  -v electrum_data:/data/db \
  -e COIN=Pepecoin \
  -e DAEMON_URL=http://pepe:epep@10.0.1.1:22555 \
  -e EVENT_LOOP_POLICY=uvloop \
  -e SSL_DIRECTORY=/etc/ssl/private \
  -e SERVICES=tcp://:50001,ssl://:50002,wss://:50004,rpc://0.0.0.0:8000 \
  -e SSL_CERTFILE=/etc/ssl/private/electrum.domain.com.crt \
  -e SSL_KEYFILE=/etc/ssl/private/electrum.domain.com.key \
  -e HOST="" \
  -e REPORT_SERVICES=tcp://electrum.domain.com:50001,ssl://electrum.domain.com:50002,wss://electrum.domain.com:50004 \
  -e DONATION_ADDRESS=PZ6chc2WsAvLb6tmTczZfZutZQeSCnKeJR \
  -e MAX_SESSIONS=1000 \
  --cap-add=NET_ADMIN \
  --name pepecoin-electrum \
  --restart always \
  emgi2/pepecoin-electrum:latest
```
[![emgi2/pepecoin-electrum][docker-pulls-image]][docker-hub-url]
[![emgi2/pepecoin-electrum][docker-stars-image]][docker-hub-url]
[![emgi2/pepecoin-electrum][docker-size-image]][docker-hub-url]

### ElectrumX server will need valid ssl certificate, you can use this Certbot if you are using cloudflare:
```bash
docker run -d \
  --name certbot \
  --restart always \
  -e CLOUDFLARE_API_TOKEN=token \
  -e EMAIL=email \
  -e DOMAIN=electrum.domain.com \
  -v /etc/letsencrypt:/etc/letsencrypt \
  -v /var/lib/letsencrypt:/var/lib/letsencrypt \
  -v /var/log/letsencrypt:/var/log/letsencrypt \
  -v /home/user/certs:/certs \
  emgi2/certbot
```
[![emgi2/certbot][docker-pulls-image-certbot]][docker-hub-url-certbot]
[![emgi2/certbot][docker-stars-image-certbot]][docker-hub-url-certbot]
[![emgi2/certbot][docker-size-image-certbot]][docker-hub-url-certbot]

# Web Gui
Default password to access web gui is `pi2023`,  this can be changed in the `dashboard/src/Config.php` file.

# Ports
- 50001 - TCP
- 50002 - SSL
- 50004 - WSS
- 8002 - Web GUI
- 22555 - Pepecoin daemon

# Building the image
### After cloning the codebase, be sure to run this command to update the sub-modules:
```bash
git submodule update --init --recursive
```
### You can build the image with this command:
```bash
docker build -t electrumx-pepecoin .
```
### Multiarch build with push on dockehub:
```bash:
docker buildx create --use
docker buildx create --name mybuilder --use
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7,linux/ppc64le,linux/s390x -t emgi2/pepecoin-electrum:latest --push .
```
You can view all ElectrumX environment variables here: https://github.com/spesmilo/electrumx/blob/master/docs/environment.rst

[docker-hub-url]: https://hub.docker.com/r/emgi2/pepecoin-electrum
[docker-pulls-image]: https://img.shields.io/docker/pulls/emgi2/pepecoin-electrum.svg?style=flat-square
[docker-size-image]: https://img.shields.io/docker/image-size/emgi2/pepecoin-electrum?style=flat-square
[docker-stars-image]: https://img.shields.io/docker/stars/emgi2/pepecoin-electrum.svg?style=flat-square

[docker-hub-url-certbot]: https://hub.docker.com/r/emgi2/certbot
[docker-pulls-image-certbot]: https://img.shields.io/docker/pulls/emgi2/certbot.svg?style=flat-square
[docker-size-image-certbot]: https://img.shields.io/docker/image-size/emgi2/certbot?style=flat-square
[docker-stars-image-certbot]: https://img.shields.io/docker/stars/emgi2/certbot.svg?style=flat-square