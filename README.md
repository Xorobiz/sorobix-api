# Sorobix API

Rust/Axum HTTP API for Sorobix. It generates and funds Futurenet accounts, compiles Soroban contracts to WASM, deploys them, and invokes contract functions on Stellar Futurenet.

## Architecture

```text
HTTP client
  └── /api router (Axum)
        └── handlers
              └── ApplicationService
                    ├── AccountService  → Futurenet FriendBot
                    ├── ContractService → soroban CLI + compile scripts
                    └── ContractDeploymentService → Futurenet JSON-RPC
```

All routes are mounted under `/api`. Responses use a status envelope with a variant-specific payload.

## Endpoints

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/api/` | Health and service banner |
| `POST` | `/api/account` | Generate and fund an account with FriendBot |
| `POST` | `/api/compile` | Compile Rust source into WASM |
| `POST` | `/api/deploy` | Install and create a contract on Futurenet |
| `POST` | `/api/invoke` | Invoke a deployed contract function |

Example health check:

```bash
curl http://localhost:3000/api/
```

Example account generation:

```bash
curl -X POST http://localhost:3000/api/account \
  -H 'content-type: application/json' \
  -d '{"username":"sorobix"}'
```

See `docs/Sorobix-API.postman_collection.json` for full request examples. Replace every placeholder key before use and never commit real secret keys.

## Prerequisites

- Rust with the `wasm32-unknown-unknown` target
- Soroban CLI 0.7.1 on `PATH`
- `sh`, `cargo`, and outbound access to Futurenet FriendBot and RPC
- Docker for containerized runs

## Run locally

```bash
rustup target add wasm32-unknown-unknown
cargo build --release
RUST_LOG=sorobix_api_rs=debug,tower_http=debug cargo run
```

The server binds to `0.0.0.0:3000`.

### Docker

```bash
docker build -t sorobix-api-rs:latest .
docker run --rm -p 3000:3000 sorobix-api-rs:latest
```

## Configuration

Current network constants live in `src/utils/constants.rs`, the bind address in `src/main.rs`, and the FriendBot URL in `src/services/account_service.rs`. To point the service at another network, change those constants and rebuild.

Logging is controlled by `RUST_LOG`. The default filter is `sorobix_api_rs=debug,tower_http=debug,server=debug`.

## Quality checks

```bash
cargo fmt --all -- --check
cargo check --locked
cargo test --locked
cargo clippy --all-targets --locked -- -D warnings
bash -n utils/*.sh
```

CI runs these checks on pushes to `master`, the Rust deployer branch, and pull requests.

## Deploy semantics

On the `feat/contract-rust-deployer` branch, `POST /api/deploy` accepts a server-readable WASM path in `lib_file` plus `secret_key`. It installs the contract code and creates a contract through Futurenet JSON-RPC. Earlier versions accepted Rust source; check the branch before importing Postman examples.

## Security

This API has no authentication, authorization, or rate limiting. It accepts secret keys in request bodies, returns generated private keys, compiles arbitrary Rust, and uses permissive CORS. Run it only in a trusted development environment or behind an authenticated gateway.

Compile and deploy scripts use per-request temporary directories to avoid concurrent request races. The deployer still derives account sequence numbers from RPC responses, so concurrent deploys from the same account may conflict.

## License

MIT.
