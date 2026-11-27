#!/usr/bin/env bash
set -euo pipefail

SOURCE="${1:?Rust source is required}"

temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

cd "$temp_dir"
cargo new --lib sorobix_temp >/dev/null

cat > Cargo.toml <<'EOF'
[package]
name = "sorobix_temp"
version = "0.1.0"
edition = "2021"

[lib]
crate-type = ["cdylib"]

[dependencies]
soroban-sdk = { version = "0.7.0" }

[profile.release]
opt-level = "z"
overflow-checks = true
debug = 0
strip = "symbols"
debug-assertions = false
panic = "abort"
codegen-units = 1
lto = true

[profile.release-with-logs]
inherits = "release"
debug-assertions = true
EOF

printf '%s\n' "$SOURCE" > src/lib.rs
cargo build --target wasm32-unknown-unknown --release
