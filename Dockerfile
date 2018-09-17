FROM debian:stretch

# https://nlnetlabs.nl/downloads/unbound/unbound-1.8.0.tar.gz.sha256
ENV UNBOUND_SHA256=78f79d6d3b643fdcd74a14fc76542250da886c82f82bc55b51e189663d61b83f
ENV UNBOUND_URL=https://nlnetlabs.nl/downloads/unbound/unbound-1.8.0.tar.gz

RUN set -ex; \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		bsdmainutils \
		build-essential \
		ca-certificates \
		curl \
		ldnsutils \
		libevent-2.0 \
		libevent-dev \
		libexpat1 \
		libexpat1-dev \
		libssl1.1 \
		libssl-dev \
		openssl \
	&& \
	curl $UNBOUND_URL -o unbound.tar.gz && \
	echo "${UNBOUND_SHA256} unbound.tar.gz" | sha256sum -c - && \
	tar xzf unbound.tar.gz && \
	rm -f unbound.tar.gz && \
	cd unbound-* && \
	groupadd unbound && \
	useradd -g unbound unbound && \
	./configure \
        --disable-dependency-tracking \
        --prefix=/opt/unbound \
        --with-pthreads \
        --with-username=unbound \
        --with-libevent \
        --enable-event-api \
	&& \
	make install && \
	apt-get purge -y --auto-remove \
		build-essential \
		curl \
		libevent-dev \
		libexpat1-dev \
		libssl-dev \
	&& \
    rm -rf \
        /opt/unbound/share/man \
        /tmp/* \
        /var/tmp/* \
        /var/lib/apt/lists/*

COPY etc/unbound/unbound.conf.d /etc/unbound/unbound.conf.d

EXPOSE 53
EXPOSE 53/udp

CMD ["/opt/unbound/sbin/unbound", "-d", "-c", "/etc/unbound/unbound.conf.d/pi-hole.conf"]
