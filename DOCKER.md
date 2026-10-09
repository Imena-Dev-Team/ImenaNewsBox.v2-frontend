# Running the project with Docker

Docker lets every contributor — Windows, macOS or Linux — run the app the exact
same way, without installing Node or pnpm and without "works on my machine"
problems. Nothing about the normal (non-Docker) workflow changes; this is an
extra option. See [CONTRIBUTING.md](./CONTRIBUTING.md) for the regular setup.

## What you need

- **Docker Desktop** (Windows/macOS) or Docker Engine + the Compose plugin
  (Linux). Check it with:

  ```bash
  docker --version
  docker compose version
  ```

That's it — you do **not** need Node or pnpm on your machine to use Docker.

> On Windows, keep the repository in a plain folder such as `C:\dev\`. Being
> inside OneDrive or another synced folder makes the bind mount slow and
> unreliable. (This is good advice for the non-Docker workflow too.)

## Development server (the usual choice)

From the repository root:

```bash
docker compose up
```

Then open <http://localhost:3000>. The first run builds the image, which takes a
few minutes (it downloads pnpm and every dependency); later runs start in
seconds because the downloads are cached.

Your source folder is mounted into the container, so **editing a file on your
machine updates the app immediately** — hot reload works just like `pnpm dev`.
Stop the server with `Ctrl+C`.

Run it in the background instead:

```bash
docker compose up -d        # start detached
docker compose logs -f web  # follow the logs
docker compose down         # stop
```

## Production build (to check the real thing)

The production image is behind a Compose profile so it doesn't start by default:

```bash
docker compose --profile prod up --build
```

Open <http://localhost:3001>. This runs the same optimised, standalone build that
would be deployed, as a non-root user, with no dev dependencies.

## Environment variables

Copy the example file if you haven't already:

```bash
cp .env.example .env
```

| Variable | Used by | Default | Notes |
|---|---|---|---|
| `NEXT_PUBLIC_API_URL` | app | `http://localhost:8000` | Base URL of the backend API |
| `WEB_PORT` | Compose | `3000` | Host port for the dev server |
| `PROD_PORT` | Compose | `3001` | Host port for the production server |

`NEXT_PUBLIC_*` values are baked into the browser bundle **at build time**, so
changing `NEXT_PUBLIC_API_URL` for the production container needs a rebuild:

```bash
NEXT_PUBLIC_API_URL=https://api.example.com docker compose --profile prod up --build
```

A backend running on your own machine is reachable from inside a container at
`http://host.docker.internal:8000` (already configured), not `localhost`.

## Common commands

```bash
docker compose up                              # dev server on :3000
docker compose up --build                      # dev, after changing the Dockerfile
docker compose --profile prod up --build       # production build on :3001
docker compose down                            # stop everything
docker compose down -v                         # stop AND wipe caches (see below)
docker compose exec web sh                     # a shell inside the running dev container
docker compose exec web pnpm lint              # run any script in the container
```

Adding a dependency: run `pnpm add <package>` on your machine as usual (this
updates `package.json` and the lock file), then restart the dev server —
`docker compose up` reinstalls automatically.

## How it's put together

| File | Purpose |
|---|---|
| `Dockerfile` | One multi-stage build; `dev`, `builder` and `runner` targets |
| `docker-compose.yml` | The `web` (dev) and `prod` services |
| `.dockerignore` | Keeps `node_modules`, `.next`, `.git` and secrets out of the build context |
| `.env.example` | Template for the variables above |

The Node and pnpm versions are pinned in the `Dockerfile` (`NODE_VERSION`,
`PNPM_VERSION`) and must stay in sync with `.nvmrc` and the `packageManager`
field in `package.json`. Dependencies are installed from the lock file with
`--frozen-lockfile`, so a Docker build and a local install always agree.

Build caches (the npm cache, the pnpm store and `node_modules`) live in named
volumes and BuildKit cache mounts, not on your filesystem. `docker compose down
-v` removes them; the next start re-downloads everything.

## Troubleshooting

| Problem | Fix |
|---|---|
| **"Port 3000 is already in use"** | Something else is on the port — stop it, or use another: `WEB_PORT=3005 docker compose up`. |
| **The first build is very slow, or fails with TLS/timeout errors** | Dependency downloads go through your network/Docker Desktop proxy and can be slow or intermittent. Just run the same command again — completed downloads are cached, so each retry makes progress. If it keeps failing on a corporate network, check Docker Desktop's proxy settings under Settings → Resources → Proxies. |
| **"failed to fetch oauth token" / "TLS handshake timeout"** | Same cause. Retry; if it persists, `docker logout` then `docker login`, and restart Docker Desktop. |
| **I changed `package.json` and the build says the lock file is out of date** | Run `pnpm install` on your machine (commit the updated `pnpm-lock.yaml`), then build again. |
| **My changes aren't hot-reloading** | Make sure you started with `docker compose up` (not `--profile prod`). The dev service polls for file changes, which is slower but reliable inside containers. |
| **Something is stuck and the build cache looks wrong** | `docker compose down -v`, then `docker compose up --build`. |
| **I want a clean slate** | `docker compose down -v` removes the containers and the named volumes. |
