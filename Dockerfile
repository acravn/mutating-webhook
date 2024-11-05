FROM golang:1.23-alpine AS build 

RUN apk add git make openssl

WORKDIR /go/src/github.com/acravn/mutating-webhook
ADD . .
RUN go build -v -o demo cmd/main.go

FROM scratch
WORKDIR /app
COPY --from=build /go/src/github.com/acravn/mutating-webhook/demo .
COPY --from=build /go/src/github.com/acravn/mutating-webhook/ssl ssl
COPY --from=build /go/src/github.com/acravn/mutating-webhook/ssl/ca.crt /etc/ssl/certs/ca-certificates.crt
CMD ["/app/demo"]