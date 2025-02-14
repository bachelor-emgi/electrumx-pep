FROM python:3.12

# Set working directory
WORKDIR /root/

# Install necessary packages
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    libleveldb-dev \
    curl \
    gpg \
    ca-certificates \
    tar \
    dirmngr \
    apache2 \
    php \
    libapache2-mod-php \
    php-curl

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Install Python package uvloop
RUN pip install uvloop

# Copy ElectrumX source code and install dependencies
COPY electrum /root/electrum
RUN cd /root/electrum && pip3 install .

# Copy entrypoint script and set executable permissions
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy dashboard directory into the working directory
COPY dashboard /data/dashboard

RUN apt-get install -y apache2 php php-cli libapache2-mod-php \
    && a2enmod rewrite

# Configure Apache to serve the dashboard directory
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /data/dashboard\n\
    <Directory /data/dashboard>\n\
    AllowOverride All\n\
    Require all granted\n\
    </Directory>\n\
    </VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Set environment variables
ENV HOME /data
ENV ALLOW_ROOT 1
ENV COIN=Pepecoin
ENV DAEMON_URL=http://pepe:epep@10.0.1.1:22555
ENV EVENT_LOOP_POLICY uvloop
ENV DB_DIRECTORY /data
ENV SERVICES=tcp://:50001,ssl://:50002,wss://:50004,rpc://0.0.0.0:8000
ENV SSL_CERTFILE ${DB_DIRECTORY}/electrumx-pepecoin.crt
ENV SSL_KEYFILE ${DB_DIRECTORY}/electrumx-pepecoin.key
ENV HOST ""
ENV REPORT_SERVICES=tcp://electrum.pepelum.site:50001,ssl://electrum.pepelum.site:50002,wss://electrum.pepelum.site:50004
ENV DONATION_ADDRESS=PeXUmAtzbJYfd3ZBJuRC4EzeYooXKWD9B5

# Set working directory for data
WORKDIR /data

# Expose necessary ports
EXPOSE 80 50001 50002 50004 8000

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
