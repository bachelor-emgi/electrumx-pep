FROM python:3.13-slim AS builder

# Set working directory
WORKDIR /root/

# Install necessary packages and clean up
RUN apt-get update && apt-get upgrade -y --no-install-recommends && apt-get install -y \
    libleveldb-dev \
    curl \
    ca-certificates \
    tar \
    dirmngr \
    apache2 \
    php \
    libapache2-mod-php \
    php-curl \
    dos2unix \
    g++ \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && a2enmod rewrite \
    && pip install --no-cache-dir uvloop

# Copy ElectrumX source code and install dependencies
COPY electrum /root/electrum
RUN cd /root/electrum && pip3 install --no-cache-dir .

# Copy entrypoint script and set executable permissions
COPY entrypoint.sh /entrypoint.sh
RUN dos2unix /entrypoint.sh && chmod +x /entrypoint.sh && find /root/electrum -type f -exec dos2unix {} \; && find /root/electrum -type f -exec sed -i 's/\r//' {} \; && mkdir -p /data/db

# Copy dashboard directory into the working directory
COPY dashboard /data/dashboard

# Configure Apache to serve the dashboard directory
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /data/dashboard\n\
    <Directory /data/dashboard>\n\
    AllowOverride All\n\
    Require all granted\n\
    </Directory>\n\
    </VirtualHost>' > /etc/apache2/sites-available/000-default.conf

RUN apt-get purge -y dos2unix g++ \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Manually remove some file to fix multiple vulnerabilities
RUN rm -rf /usr/share/doc/libxml2 \
    /var/lib/dpkg/info/libxml2:amd64.md5sums \
    /var/lib/dpkg/status \
    /usr/share/doc/libtasn1-6 \
    /var/lib/dpkg/info/libtasn1-6:amd64.md5sums \
    /usr/share/doc/libgnutls30 \
    /var/lib/dpkg/info/libgnutls30:amd64.md5sums \
    /var/lib/dpkg/status \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Final stage
FROM python:3.13-slim

# Set environment variables
ENV HOME /data
ENV ALLOW_ROOT 1
ENV COIN=Pepecoin
ENV DAEMON_URL=http://pepe:epep@10.0.1.1:22555
ENV EVENT_LOOP_POLICY uvloop
ENV DB_DIRECTORY /data/db
ENV SERVICES=tcp://:50001,ssl://:50002,wss://:50004,rpc://0.0.0.0:8000
ENV SSL_CERTFILE ${DB_DIRECTORY}/electrumx-pepecoin.crt
ENV SSL_KEYFILE ${DB_DIRECTORY}/electrumx-pepecoin.key
ENV HOST ""
ENV REPORT_SERVICES=tcp://electrum.pepelum.site:50001,ssl://electrum.pepelum.site:50002,wss://electrum.pepelum.site:50004
ENV DONATION_ADDRESS=PeXUmAtzbJYfd3ZBJuRC4EzeYooXKWD9B5

# Copy necessary files from builder stage
COPY --from=builder / /

# Set working directory for data
WORKDIR /data

# Expose necessary ports
EXPOSE 80 50001 50002 50004 8000

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]