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
  -v electrum_data:/data \
  -v /home/user/certs:/etc/ssl/private \
  -e COIN=Pepecoin \
  -e DAEMON_URL=http://pepe:epep@10.0.1.1:22555 \
  -e EVENT_LOOP_POLICY=uvloop \
  -e DB_DIRECTORY=/data \
  -e SERVICES=tcp://:50001,ssl://:50002,wss://:50004,rpc://0.0.0.0:8000 \
  -e SSL_CERTFILE=/data/electrumx-pepecoin.crt \
  -e SSL_KEYFILE=/data/electrumx-pepecoin.key \
  -e HOST="" \
  -e REPORT_SERVICES=tcp://electrum.domain.com:50001,ssl://electrum.domain.com:50002,wss://electrum.domain.com:50004 \
  -e DONATION_ADDRESS=PeXUmAtzbJYfd3ZBJuRC4EzeYooXKWD9B5 \
  --cap-add=NET_ADMIN \
  --name pepecoin-electrum \
  --restart always \
  emgi2/pepecoin-electrum
```
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

# Web Gui
Default password to access web gui is `pi2023`,  this can be changed in the `dashboard/src/Config.php` file.

# Ports
50001 - TCP
50002 - SSL
50004 - WSS
8002 - Web GUI
22555 - Pepecoin daemon

# Building the image
### You can build the image with this command:
```bash
docker build -t electrumx-pepecoin .
```
### Multiarch build with push on dockehub:
```bash:
docker buildx create --use
docker buildx create --name mybuilder --use
docker buildx build --platform linux/amd64,linux/arm64 -t emgi2/pepecoin-electrum:latest --push .
```
You can view all ElectrumX environment variables here: https://github.com/spesmilo/electrumx/blob/master/docs/environment.rst