FROM rust:1.72 AS builder
RUN rustup target add wasm32-unknown-unknown
RUN curl -fsSL -o /usr/local/bin/soroban https://github.com/stellar/soroban-tools/releases/download/v0.7.1/soroban-cli-0.7.1-x86_64-unknown-linux-gnu \
  && chmod +x /usr/local/bin/soroban
WORKDIR /sorobix-api-rs
COPY . .
RUN cargo build --release

FROM debian:bookworm-slim
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates curl \
  && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL -o /usr/local/bin/soroban https://github.com/stellar/soroban-tools/releases/download/v0.7.1/soroban-cli-0.7.1-x86_64-unknown-linux-gnu \
  && chmod +x /usr/local/bin/soroban
WORKDIR /app
COPY --from=builder /sorobix-api-rs/target/release/sorobix-api-rs ./server
COPY --from=builder /sorobix-api-rs/utils ./utils
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl --fail http://localhost:3000/api/ || exit 1
CMD ["./server"]
