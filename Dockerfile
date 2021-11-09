ARG BASE_IMAGE


FROM golang:latest AS builder

ARG VERSION="head on container"
ARG COMMIT=UNKNOWN

ENV CGO_ENABLED 0

RUN mkdir /output

WORKDIR /usr/src/ayd
COPY ayd .
RUN go build --trimpath -ldflags="-s -w -X 'main.version=$VERSION' -X 'main.commit=$COMMIT'" -o /output/ayd

WORKDIR /usr/src/ayd-mailto-alert
COPY ayd-mailto-alert .
RUN go build --trimpath -ldflags="-s -w -X 'main.version=$VERSION' -X 'main.commit=$COMMIT'" -o /output/ayd-mailto-alert

WORKDIR /usr/src/ayd-slack-alert
COPY ayd-slack-alert .
RUN go build --trimpath -ldflags="-s -w -X 'main.version=$VERSION' -X 'main.commit=$COMMIT'" -o /output/ayd-slack-alert

WORKDIR /usr/src/ayd-ftp-probe
COPY ayd-ftp-probe .
RUN go build --trimpath -ldflags="-s -w -X 'main.version=$VERSION' -X 'main.commit=$COMMIT'" -o /output/ayd-ftp-probe

WORKDIR /usr/src/ayd-smb-probe
COPY ayd-smb-probe .
RUN go build --trimpath -ldflags="-s -w -X 'main.version=$VERSION' -X 'main.commit=$COMMIT'" -o /output/ayd-smb-probe

RUN apt update && apt install -y upx && upx --lzma /output/*


FROM $BASE_IMAGE

WORKDIR /var/log/ayd

COPY --from=builder /output /usr/bin
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENV AYD_PRIVILEGED yes

EXPOSE 9000
VOLUME /var/log/ayd

ENTRYPOINT ["ayd"]
