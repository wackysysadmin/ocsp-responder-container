# Containerised OCSP Responder
This is a containerised version of the OCSP responder built into OpenSSL.

Had built this to add onto my certificates primarily remove the warning on Microsoft's Terminal Services Client about being unable to validate the certificate against a responder when RDP'ing onto a server.

<h1>Prerequisites</h1>
This container relies on already having the following:

* A working CA and/or intermediate server (Useful Guide: https://jamielinux.com/docs/openssl-certificate-authority/index.html, <a href=https://bounca.org/>BounCA</a>, <a href=https://lab-ca.net/>LabCA</a> etc)
* An index file containing a list of current valid/revoked/expired certificates. (Otherwise known as the 'database' file in OpenSSL terminology)
* The public certificate of your CA, or chain of the CA and intermediate.
* An OCSP signing keypair from your CA or intermediate. (Guide: https://bhashineen.medium.com/create-your-own-ocsp-server-ffb212df8e63)

<h1>Running the container</h1>
<h2>Environment Variables</h2>

* OCSP_INT_PORT: "2560" # OCSP mounting port internal to the container.
* INDEX_FILE: "/data/index.txt" # The database file of the CA.
* CA_FILE: "/data/ca-chain.cert.pem" # The CA or CA and intermediate public chain certificate.
* OCSP_CERT_FILE: "/data/ocsp.pem" # OCSP public certificate signed by the CA or intermediate.
* OCSP_KEY_FILE: "/data/ocsp.key" # OCSP private key.
* OCSP_LOG_FILE: "/data/ocsp.log" # OCSP process's output log file, HTTP access logs and responses.

<h2>Using Docker Compose</h2>
Create a docker-compose.yml file with the contents of https://github.com/wackysysadmin/ocsp-responder-container/blob/main/docker-compose.yml.

Bring up the OCSP responder server.
```
docker compose up -d
```

```
docker logs ocsp-responder
ACCEPT 0.0.0.0:2560 PID=1
ocsp: waiting for OCSP client connections...
```

<h2>Reverse Proxy/HTTPS Support</h2>
The OCSP responder server can be put behind a reverse proxy such as Caddy/NGINX/Traefik.

This can be done by using a method of your choice, if you append a reverse proxy onto the Docker Compose file or if the reverse proxy server is on the same container bridge network you can specify http://ocsp-responder:2560 as the proxy upstream address.

Serving an OCSP responder over HTTPS <a href=https://datatracker.ietf.org/doc/html/rfc5280#section-8>isn't a requirement</a> but is certainly possible, as mentioned in the wider community OCSP requirements on CA/Intermediate certificates can cause issues, using them on issued server/client certificates from them should be fine. 

<h3>Building the container from scratch</h3>
The container can be built manually, it is only an Alpine image with OpenSSL and CMD values set.

Enter a directory and create a Dockerfile with the contents from <a href=https://github.com/wackysysadmin/ocsp-responder-container/blob/main/Dockerfile>here</a>.

Create the container using build command:
```
docker build -t ocsp-responder:latest .
```
<h1>Known issues</h1>

* All files can be direct mounted into the container, however the index/database file must be in a mounted folder.
This is due to Docker mounting the file as it is at the time. If there are changes to the index it will not be reflected unless the container gets restarted. For my use case I created an ocsp folder then changed my openssl.cnf to save changes to an index.txt in the ocsp folder.
