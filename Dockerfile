# No `# syntax=` directive on purpose: it would make every build pull an extra
# image from Docker Hub, and BuildKit already supports everything used here.
#
# One file, four stages. Which one you get depends on the target you ask for:
#
#   dev      hot-reloading dev server  -> docker compose up            (default)
#   runner   minimal production image  -> docker compose --profile prod up
#
# `deps` and `builder` are intermediate stages and are never run directly.

# Keep in sync with .nvmrc.
ARG NODE_VERSION=24

# Keep in sync with `packageManager` in package.json.
ARG PNPM_VERSION=12.10.1

# ---------------------------------------------------------------------------
# base: Node + pnpm, shared by every other stage
# ---------------------------------------------------------------------------
FROM node:${NODE_VERSION}-alpine AS base

ARG PNPM_VERSION

ENV PNPM_HOME="/pnpm" \
    PATH="/pnpm:$PATH" \
    NEXT_TELEMETRY_DISABLED=1 \
    # npm is used once, to install pnpm. On slow or proxied connections
    # (Docker Desktop, corporate VPN) the default timeouts give up too early,
    # so allow long fetches and a few retries.
    npm_config_fetch_timeout=600000 \
    npm_config_fetch_retries=5 \
    npm_config_fetch_retry_mintimeout=20000 \
    npm_config_fetch_retry_maxtimeout=120000

# pnpm is installed from npm rather than via `corepack enable`: Corepack
# downloads pnpm on first use with no timeout or retry control, which fails
# behind Docker Desktop's proxy. A plain npm install is one predictable
# download, cached between builds, and retried automatically.
# --allow-scripts is required because npm 11 blocks install scripts by default
# and pnpm's own postinstall sets up its platform binary.
RUN --mount=type=cache,id=npm-cache,target=/root/.npm \
    npm install -g pnpm@${PNPM_VERSION} --allow-scripts=pnpm --no-fund --no-audit

WORKDIR /app

# ---------------------------------------------------------------------------
# deps: install dependencies from the lock file only (cached until it changes)
# ---------------------------------------------------------------------------
FROM base AS deps

# libc6-compat is needed by some prebuilt native binaries (e.g. sharp) on Alpine.
RUN apk add --no-cache libc6-compat

# pnpm-workspace.yaml is required here: it holds the allowBuilds list, and
# without it pnpm refuses to run sharp's and unrs-resolver's install scripts
# and fails the install with ERR_PNPM_IGNORED_BUILDS.
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

RUN --mount=type=cache,id=pnpm-store,target=/pnpm/store \
    pnpm install --frozen-lockfile --store-dir=/pnpm/store

# ---------------------------------------------------------------------------
# dev: what `docker compose up` runs. Source is bind-mounted over /app, so this
# only needs to provide node_modules.
# ---------------------------------------------------------------------------
FROM base AS dev

ENV NODE_ENV=development \
    # Bind-mounted folders don't emit change events reliably on Windows/macOS,
    # so webpack-based features poll instead.
    WATCHPACK_POLLING=true

COPY --from=deps /app/node_modules ./node_modules
COPY . .

EXPOSE 3000

# Re-installs on every start so that editing package.json on the host is enough
# to pick up a new dependency: the store is cached in a volume, so this is a
# no-op whenever the lock file hasn't changed.
CMD ["sh", "-c", "pnpm install --frozen-lockfile --store-dir=/pnpm/store && exec pnpm dev --hostname 0.0.0.0"]

# ---------------------------------------------------------------------------
# builder: produce .next/standalone
# ---------------------------------------------------------------------------
FROM base AS builder

# NEXT_PUBLIC_* values are inlined into the client bundle at build time, so they
# must be present here and not at container start. Pass with:
#   docker compose --profile prod build
ARG NEXT_PUBLIC_API_URL

ENV NODE_ENV=production \
    NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN pnpm build

# ---------------------------------------------------------------------------
# runner: production image. Runs .next/standalone as a non-root user, with no
# package manager and no dev dependencies installed.
# ---------------------------------------------------------------------------
FROM node:${NODE_VERSION}-alpine AS runner

ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    PORT=3000 \
    HOSTNAME=0.0.0.0

RUN addgroup -g 1001 -S nodejs \
 && adduser -S nextjs -u 1001

WORKDIR /app

# standalone/ contains server.js plus the traced node_modules it needs.
# public/ and .next/static are not traced, so they are copied explicitly.
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

USER nextjs

EXPOSE 3000

CMD ["node", "server.js"]
