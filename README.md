```
docker run -d \
  -p 50001:50001/tcp \
  -p 50002:50002/tcp \
  -p 50004:50004/tcp \
  -p 8002:80/tcp \
  -v pepelum_data:/data \
  -v /home/pi/certs:/etc/ssl/private \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  --name electrum-pepelum \
  --restart always \
  emgi2/pepelum-electrum
```
Certbot
```
docker run -d \
  --name certbot \
  --restart always \
  -e CLOUDFLARE_API_TOKEN=token \
  -e EMAIL=email \
  -e DOMAIN=electrum.pepelum.site \
  -v /etc/letsencrypt:/etc/letsencrypt \
  -v /var/lib/letsencrypt:/var/lib/letsencrypt \
  -v /var/log/letsencrypt:/var/log/letsencrypt \
  -v /home/pi/certs:/certs \
  emgi2/certbot
```

# docker-electrumx-pepecoin

> Run an All-In-One Pepecoin Electrum server with docker

## Usage

```
docker build -t electrumx-pepecoin:electrumx-pepecoin .
```

```
docker run -v C:\electrumx-pepecoin:/data -p 50002:50002 electrumx-pepecoin:electrumx-pepecoin
```

If there's an SSL certificate/key (`electrumx-pepecoin.crt`/`electrumx-pepecoin.key`) in the `/data` volume it'll be used. If not, one will be generated for you.

You can view all ElectrumX environment variables here: https://github.com/spesmilo/electrumx/blob/master/docs/environment.rst

### TCP Port

By default only the SSL port is exposed. You can expose the unencrypted TCP port with `-p 50001:50001`, although this is strongly discouraged.

### WebSocket Port

You can expose the WebSocket port with `-p 50004:50004`.

### RPC Port

To access RPC from your host machine, you'll also need to expose port 8000. You probably only want this available to localhost: `-p 127.0.0.1:8000:8000`.

If you're only accessing RPC from within the container, there's no need to expose the RPC port.
