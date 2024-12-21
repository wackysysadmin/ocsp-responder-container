FROM alpine:latest

RUN apk update && apk upgrade #Fully update the image
RUN apk add openssl #Install OpenSSL

CMD openssl ocsp -port $OCSP_INT_PORT -text -index $INDEX_FILE -CA $CA_FILE -rsigner $OCSP_CERT_FILE -rkey $OCSP_KEY_FILE -out $OCSP_LOG_FILE
