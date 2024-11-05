#!/bin/bash

openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -sha512 -days 3650 -out ca.crt -subj "/C=US/ST=CO/L=Denver/O=DemoLLC/OU=DemoTeam/CN=demo"

openssl genrsa -out demo.key 2048
openssl req -new -key demo.key -subj "/CN=demo.default.svc" -out demo.csr -config csr.conf

openssl x509 -req -extfile san.ext -in demo.csr -days 365 -CA ca.crt -CAkey ca.key -CAcreateserial -out demo.crt
