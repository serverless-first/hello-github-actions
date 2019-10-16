# ------------------------------------------------------------------------------
# Cargo Build Stage
# ------------------------------------------------------------------------------

FROM rust:latest as cargo-build

RUN apt-get update

RUN apt-get install musl-tools -y

RUN rustup target add x86_64-unknown-linux-musl

WORKDIR /usr/src/hello-github-actions

RUN rm -f target/x86_64-unknown-linux-musl/release/deps/hello-github-actions*

COPY . .

RUN RUSTFLAGS=-Clinker=musl-gcc cargo build --release --target=x86_64-unknown-linux-musl

RUN cargo build --release

RUN cargo install --path .
# ------------------------------------------------------------------------------
# Final Stage
# ------------------------------------------------------------------------------

FROM alpine:latest

RUN addgroup -g 1000 hello-github-actions

RUN adduser -D -s /bin/sh -u 1000 -G hello-github-actions hello-github-actions

WORKDIR /home/hello-github-actions/bin/

COPY --from=cargo-build /usr/src/hello-github-actions/target/x86_64-unknown-linux-musl/release/hello-github-actions .

RUN chown hello-github-actions:hello-github-actions hello-github-actions

USER hello-github-actions

CMD ["./hello-github-actions"]
