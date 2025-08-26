FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-venv \
    python3.10-dev \
    python3-pip \
    git \
    gcc \
    build-essential \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/log_dev
RUN chmod -R 755 /tmp/log_dev

RUN git clone https://github.com/espinr/eudi-srv-web-issuing-eudiw-py.git /root/eudi-srv-web-issuing-eudiw-py

RUN apt-get update && apt-get install -y ca-certificates
COPY ./config_secrets/ca.pem  /usr/local/share/ca-certificates/eudiw-issuer-ca.crt
COPY ./config_secrets/cert.pem  /usr/local/share/ca-certificates/eudiw-issuer.crt
RUN update-ca-certificates

ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

WORKDIR /root/eudi-srv-web-issuing-eudiw-py

RUN pip install --upgrade pip certifi
RUN pip install --no-cache-dir -r app/requirements.txt

EXPOSE 5000

ENV FLASK_APP=app\
    FLASK_RUN_PORT=5000\
    FLASK_RUN_HOST=0.0.0.0\
    SERVICE_URL="https://127.0.0.1:5000/" \
    EIDAS_NODE_URL="https://preprod.issuer.eudiw.dev/EidasNode/"\
    DYNAMIC_PRESENTATION_URL="https://dev.verifier-backend.eudiw.dev/ui/presentations/"

CMD ["sh", "-c", "cp /root/secrets/config_secrets.py /root/eudi-srv-web-issuing-eudiw-py/app/app_config/ && flask run --cert=/root/secrets/cert.pem --key=/root/secrets/key.pem"]
