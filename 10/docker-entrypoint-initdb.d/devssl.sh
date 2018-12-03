#!/bin/sh
# generate self signed ssl cert only if all cert files are empty or nonexistent

if [ -s "${PGDATA}"/server.crt ] || [ -s "${PGDATA}"/server.key ] || [ -n "${SKIP_SSL_GENERATE}" ]; then
    echo "Skipping SSL certificate generation for Postgres"
else
    echo "Generating self-signed certificate for Postgres"

    cd $PGDATA

    # Generating signing SSL private key
    openssl genrsa -des3 -passout pass:x -out key.pem 2048

    # Removing passphrase from private key
    cp key.pem key.pem.orig
    openssl rsa -passin pass:x -in key.pem.orig -out key.pem

    # Generating certificate signing request
    openssl req -new -key key.pem -out cert.csr -subj "/C=US/ST=California/L=Los Angeles/O=Company/OU=Digital/CN=default"

    # Generating self-signed certificate
    openssl x509 -req -days 3650 -in cert.csr -signkey key.pem -out cert.pem

    mv cert.pem server.crt
    mv key.pem server.key

    chmod og-rwx server.key
    chown postgres:postgres server.crt
    chown postgres:postgres server.key
fi

# turn on ssl
sed -ri "s/^#?(ssl\s*=\s*)\S+/\1'on'/" "$PGDATA/postgresql.conf"
