# CONTAINER FOR BUILDING BINARY
FROM golang:1.21 AS build

# TODO: REMOVE SSH BEFORE MERGING, ONCE AGGLAYER IS PUBLIC

# SSH KEY
ARG SSH_PRIVATE_KEY
RUN mkdir /root/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa
RUN chmod 700 /root/.ssh/id_rsa
RUN echo "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config
RUN git config --global --add url."git@github.com:".insteadOf "https://github.com/"
ENV GOPRIVATE=github.com/0xPolygon/agglayer

# INSTALL DEPENDENCIES
RUN go install github.com/gobuffalo/packr/v2/packr2@v2.8.3
COPY go.mod go.sum /src/
RUN cd /src && go mod download

# BUILD BINARY
COPY . /src
RUN cd /src/db && packr2
RUN cd /src && make build

# REMOVE SSH PRIVATE KEY
RUN rm /root/.ssh/id_rsa

# CONTAINER FOR RUNNING BINARY
FROM alpine:3.18.0
COPY --from=build /src/dist/zkevm-node /app/zkevm-node
COPY --from=build /src/config/environments/testnet/node.config.toml /app/example.config.toml
RUN apk update && apk add postgresql15-client
EXPOSE 8123
CMD ["/bin/sh", "-c", "/app/zkevm-node run"]
