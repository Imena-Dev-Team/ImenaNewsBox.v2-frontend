This is the frontend for **ImenaNewsBox**, a [Next.js](https://nextjs.org)
(App Router) app built with React and TypeScript. It was bootstrapped with
[`create-next-app`](https://nextjs.org/docs/app/api-reference/cli/create-next-app).

See [CONTRIBUTING.md](./CONTRIBUTING.md) for the full contributor workflow.

## Getting Started

This project uses **pnpm**. Do not use npm or yarn.

```bash
pnpm install
cp .env.example .env   # then edit the values
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the
result.

You can start editing the page by modifying `app/page.tsx`. The page
auto-updates as you edit the file.

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts)
to automatically optimize and load [Geist](https://vercel.com/font), a new font
family for Vercel.

## Running with Docker

No Node or pnpm required — the whole app runs in a container, identically on
Windows, macOS and Linux:

```bash
docker compose up                              # dev server with hot reload on :3000
docker compose --profile prod up --build       # production build on :3001
```

See [DOCKER.md](./DOCKER.md) for the full guide and troubleshooting.

## Scripts

```bash
pnpm dev        # start the development server
pnpm build      # production build
pnpm start      # run the production build
pnpm lint       # ESLint
```

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!
