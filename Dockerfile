FROM alpine:latest
RUN apk add openssl
CMD openssl ocsp -port $OCSP_INT_PORT -text -index $INDEX_FILE -CA $CA_FILE -rsigner $OCSP_CERT_FILE -rkey $OCSP_KEY_FILE -out $OCSP_LOG_FILE
