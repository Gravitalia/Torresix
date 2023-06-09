FROM rust:alpine3.18 AS builder

RUN USER=root cargo new --bin torresix
WORKDIR /torresix

ENV     RUSTFLAGS="-C target-feature=-crt-static"
RUN     apk add -q --update-cache --no-cache build-base openssl-dev musl pkgconfig protobuf-dev

COPY ./Cargo.toml ./Cargo.toml
COPY ./build.rs ./build.rs
COPY ./proto ./proto
COPY ./models ./models
COPY ./src ./src

RUN cargo build --release --bin server

FROM alpine:3.18 AS runtime

RUN apk update \
 && apk add --no-cache libssl1.1 musl-dev libgcc tini curl

WORKDIR bin

COPY --from=builder /torresix/target/release/server .
COPY --from=builder /torresix/models ./models

EXPOSE 50051
ENTRYPOINT ["tini", "--"]
CMD     /bin/server
