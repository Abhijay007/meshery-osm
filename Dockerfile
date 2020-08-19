FROM golang:1.13.7 as bd

WORKDIR /github.com/layer5io/meshery-osm
ADD . .
RUN go build -ldflags="-w -s" -a -o meshery-osm .

FROM alpine
RUN apk --update add ca-certificates curl
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 && \
	mkdir -p /home/scripts && \
	mkdir -p /root/.kube/

# Install kubectl
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl" && \
	chmod +x ./kubectl && \
	mv ./kubectl /usr/local/bin/kubectl

COPY --from=bd /github.com/layer5io/meshery-osm/meshery-osm /home/
COPY --from=bd /github.com/layer5io/meshery-osm/scripts/** /home/scripts/
WORKDIR /home
CMD ./meshery-osm
