# Contributing to ImenaNewsBox-Web

Welcome to the team! This guide walks you through everything you need to go from "I have a laptop" to "my first pull request is merged." Read it once top to bottom, then keep it open as a reference.

**What this repo is:** the frontend for ImenaNewsBox, built with Next.js (App Router), React and TypeScript. It talks to the backend in the [ImenaNewsBox-API](https://github.com/<your-org>/ImenaNewsBox-API) repo.

---

## Contents

1. [The 60-second version](#1-the-60-second-version)
2. [Before you start](#2-before-you-start)
3. [Get the code](#3-get-the-code)
4. [Set up your local environment](#4-set-up-your-local-environment)
5. [Your daily workflow](#5-your-daily-workflow)
6. [Branch names](#6-branch-names)
7. [Commit messages](#7-commit-messages)
8. [Before you push](#8-before-you-push)
9. [Opening a pull request](#9-opening-a-pull-request)
10. [Code review](#10-code-review)
11. [Keeping your branch up to date](#11-keeping-your-branch-up-to-date)
12. [Project conventions](#12-project-conventions)
13. [Working with the backend API](#13-working-with-the-backend-api)
14. [Adding dependencies](#14-adding-dependencies)
15. [Secrets and security](#15-secrets-and-security)
16. [Troubleshooting](#16-troubleshooting)
17. [Git mistakes and how to fix them](#17-git-mistakes-and-how-to-fix-them)
18. [For maintainers](#18-for-maintainers)

---

## 1. The 60-second version

```bash
git clone https://github.com/<your-org>/ImenaNewsBox-Web.git   # once
cd ImenaNewsBox-Web
pnpm install                                                    # install dependencies
cp .env.example .env.local                                      # then edit the values

git switch main && git pull                                     # start from fresh main
git switch -c feat/short-description                            # make your branch

pnpm dev                                                        # http://localhost:3000
# ...write code and tests...

pnpm lint && pnpm typecheck && pnpm test && pnpm build
git add <files> && git commit -m "feat(scope): what you did"
git push -u origin feat/short-description                       # then open a Pull Request on GitHub
```

The rules that matter most:

- **Never commit directly to `main`.** Every change goes through a pull request.
- **One branch = one task.** Keep it small and short-lived.
- **Lint, typecheck, tests and build must pass** before you ask for a review.
- **Show your work.** UI changes need a screenshot or short recording in the PR.
- **Never commit secrets.** Anything starting with `NEXT_PUBLIC_` is visible to every visitor.

---

## 2. Before you start

Install these once:

| Tool | Why | Check it works |
|---|---|---|
| **Git** | version control | `git --version` |
| **Node.js** (the version in `.nvmrc`) | runs the app and the tooling | `node -v` |
| **pnpm** | installs dependencies (we use pnpm, not npm or yarn) | `pnpm -v` |
| **A GitHub account** in our organization | to push branches and open PRs | ask the team lead for an invite |

Install pnpm:

```bash
npm install -g pnpm
```

A Node version manager such as [fnm](https://github.com/Schniz/fnm) or [nvm](https://github.com/nvm-sh/nvm) (nvm-windows on Windows) makes it easy to switch to the exact version in `.nvmrc`.

Tell Git who you are (once per machine), using the same email as your GitHub account:

```bash
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
```

In your editor, turn on **ESLint**, **TypeScript** and format-on-save so problems show up as you type.

> **Windows users:** keep the project in a plain folder such as `C:\dev\`, **not** inside OneDrive, Dropbox or any synced folder. A synced `node_modules` folder (tens of thousands of files) causes very slow syncs, file locks and sometimes a corrupted `.git`.

---

## 3. Get the code

Clone the repository (HTTPS shown; use the SSH URL instead if you have SSH keys set up):

```bash
git clone https://github.com/<your-org>/ImenaNewsBox-Web.git
cd ImenaNewsBox-Web
```

You don't need to fork the repo. You're a member of the organization, so you push branches straight to it.

---

## 4. Set up your local environment

**Step 1. Check your Node version** matches the one in `.nvmrc`:

```bash
node -v
cat .nvmrc        # Windows PowerShell: Get-Content .nvmrc
```

**Step 2. Install dependencies:**

```bash
pnpm install
```

**Step 3. Create your local config:**

```bash
cp .env.example .env.local              # macOS / Linux
Copy-Item .env.example .env.local       # Windows PowerShell
```

Open `.env.local` and check the values. The one you'll always need is the backend URL:

```
NEXT_PUBLIC_API_URL=http://localhost:8000
```

`.env.local` is git-ignored. Never commit it.

**Step 4. Start the backend** so the frontend has an API to talk to. Follow the "Set up your local environment" steps in the backend repo's `CONTRIBUTING.md`. In short:

```bash
# in the ImenaNewsBox-API folder
uv run fastapi dev app/main.py
```

Check that http://127.0.0.1:8000/docs loads.

**Step 5. Start the frontend:**

```bash
pnpm dev
```

Open http://localhost:3000. The page reloads automatically when you save a file.

**Step 6. Run the checks** to confirm everything works on your machine:

```bash
pnpm lint
pnpm typecheck
pnpm test
```

If any of these fail on a fresh clone, tell the team. That's a bug in our setup, not in you.

### Scripts you'll use

| Command | What it does |
|---|---|
| `pnpm dev` | starts the dev server with hot reload on port 3000 |
| `pnpm build` | creates the production build (catches errors dev mode misses) |
| `pnpm start` | serves the production build (run `pnpm build` first) |
| `pnpm lint` | runs ESLint (add `--fix` to auto-fix: `pnpm lint --fix`) |
| `pnpm typecheck` | runs the TypeScript compiler without producing files |
| `pnpm test` | runs the test suite |
| `pnpm format` | formats all code with Prettier |
| `pnpm api:types` | regenerates TypeScript types from the backend's API ([section 13](#13-working-with-the-backend-api)) |

---

## 5. Your daily workflow

```
 main  ●────────●────────────────────●─────────●   (always deployable, protected)
        \                           ↗
         ●───●───●───●  feat/article-card           (your branch, short-lived)
                      │
                      └─ push → open Pull Request → review → squash merge → delete branch
```

### Step by step

**1. Start from the latest `main`:**

```bash
git switch main
git pull
pnpm install          # in case someone added or updated a dependency
```

**2. Create your branch** (see [naming rules](#6-branch-names)):

```bash
git switch -c feat/article-card
```

**3. Do the work.** Commit early and often in small, logical pieces ([commit rules](#7-commit-messages)):

```bash
git add src/components/features/ArticleCard.tsx
git commit -m "feat(article-card): add card with image and headline"
```

Prefer `git add <specific files>` over `git add .`, so you don't commit things by accident. Check what you're about to commit with `git status` and `git diff --staged`.

**4. Run the checks** ([see list](#8-before-you-push)).

**5. Push your branch:**

```bash
git push -u origin feat/article-card
```

The `-u` flag is needed only the first time. After that, plain `git push` works.

**6. Open a pull request** on GitHub ([details](#9-opening-a-pull-request)).

**7. Address review comments** by pushing more commits to the same branch. The PR updates automatically.

**8. After it's merged,** clean up:

```bash
git switch main
git pull --prune
git branch -D feat/article-card
```

Use a capital **`-D`** here. Because we squash merge, Git doesn't see your branch's commits on `main` and refuses the lowercase `-d` with "not fully merged." That's expected. Once GitHub shows the PR as merged, your work is safe on `main`, so `-D` is fine.

---

## 6. Branch names

Format: **`type/short-description`**, all lowercase, words separated by hyphens.

| Type | Use it for | Example |
|---|---|---|
| `feat` | a new feature or page | `feat/video-player` |
| `fix` | a bug fix | `fix/mobile-menu-overlap` |
| `refactor` | restructuring code without changing behavior | `refactor/split-article-list` |
| `style` | visual or CSS-only changes | `style/header-spacing` |
| `test` | adding or fixing tests only | `test/upload-form` |
| `docs` | documentation only | `docs/update-readme` |
| `chore` | tooling, dependencies, config | `chore/bump-next` |
| `hotfix` | urgent production fix | `hotfix/broken-login-redirect` |

If you have a ticket or issue number, include it: `feat/123-video-player`.

Good names are short and say what the branch is for. Avoid `my-branch`, `test`, `stuff` or `john-work`.

---

## 7. Commit messages

We follow **Conventional Commits**:

```
type(scope): short summary in the imperative mood
```

```
feat(upload-form): show progress while a video uploads
fix(header): stop the menu overlapping the logo on mobile
refactor(api): move fetch helpers into lib/api
style(article-card): align headline and author line
test(login): cover the wrong-password error state
chore(deps): upgrade next to the latest patch
docs: explain how to regenerate API types
```

Rules:

- **Imperative mood:** "add", "fix", "remove", not "added" or "fixes".
- **Under about 70 characters** in the first line, and no full stop at the end.
- **`scope` is optional** and names the component, page or area you touched.
- **One logical change per commit.** Don't mix a bug fix, a refactor and a new feature.
- Use the body for the *why* when it isn't obvious. Add a blank line, then explain.

---

## 8. Before you push

Run these. They are the same checks a reviewer expects to be green:

```bash
pnpm lint --fix       # lint and auto-fix what it can
pnpm format           # format code
pnpm typecheck        # TypeScript errors
pnpm test             # tests
pnpm build            # production build (can take a minute, but catches real problems)
```

Quick checklist:

- [ ] Lint, typecheck, tests and build all pass locally
- [ ] I added or updated tests for what I changed
- [ ] I checked my change **in the browser** at mobile, tablet and desktop widths
- [ ] Loading, error and empty states all look right, not just the happy path
- [ ] I can use it with the keyboard only (Tab, Enter, Escape), and images have `alt` text
- [ ] No secrets, `.env.local` files, leftover `console.log` calls or commented-out code in my diff
- [ ] The browser console shows no errors or warnings from my change
- [ ] `git status` shows only the files I meant to change

---

## 9. Opening a pull request

On GitHub, click **Compare & pull request** after pushing your branch (or go to the *Pull requests* tab, then *New pull request*).

**Title:** use the same format as a commit message.
`feat(article-card): add card with image and headline`

**Description:** use this template:

```markdown
## What
One or two sentences on what this PR does.

## Why
The problem it solves, or a link to the issue/ticket (Closes #123).

## Screenshots / recording
Before and after for any visual change. Include mobile width too.

## How to test
1. Run the backend and `pnpm dev`
2. Go to /articles
3. Expect to see the new card with image, headline and author

## Notes for the reviewer
Anything tricky, any trade-offs you made, anything you want a second opinion on.
```

Good pull requests are:

- **Small.** Aim for a change a reviewer can understand in about 15 minutes. If it's growing huge, split it into several PRs.
- **Focused.** One purpose per PR. Don't sneak in unrelated cleanups or reformatting.
- **Visible.** Reviewers shouldn't have to check out your branch to see what you built. Screenshots or a short recording are required for UI changes.
- **Self-reviewed.** Read your own diff on GitHub before asking anyone else to.

Not finished yet but want early feedback? Open it as a **Draft pull request**, and mark it *Ready for review* when it's done.

---

## 10. Code review

**If you're the author:**

- Request at least one reviewer (the team lead can tell you who owns which area).
- Respond to every comment, either with a change or a short explanation. Resolve a thread only once it's addressed.
- Push fixes as new commits during review. Don't rewrite history on a PR someone is actively reviewing.
- Don't take comments personally. Review is about the code, and everyone's code gets comments.

**If you're the reviewer:**

- Review promptly, since a waiting PR blocks a teammate.
- Be specific and kind. Explain *why*, and suggest an alternative when you can.
- Separate must-fix problems from optional suggestions (prefix the latter with `nit:`).
- Check for: correctness, tests, accessibility, responsive behavior, error and loading states, performance (unnecessary re-renders, oversized images, heavy new dependencies) and whether the change fits our [conventions](#12-project-conventions).

**Merging:**

- A PR needs at least one approval and all checks passing.
- We use **Squash and merge**, so each PR becomes one clean commit on `main`.
- The author merges their own PR once it's approved. Delete the branch afterwards.

---

## 11. Keeping your branch up to date

If `main` moved while you were working, bring your branch up to date:

```bash
git fetch origin
git rebase origin/main
pnpm install          # in case dependencies changed
```

If Git reports a **conflict**:

1. Open the conflicting files and look for `<<<<<<<`, `=======` and `>>>>>>>` markers.
2. Edit each file to keep the correct result, and delete the markers.
3. Run `git add <file>` for each fixed file.
4. Run `git rebase --continue`.
5. Run the checks again.

**Conflict in `pnpm-lock.yaml`?** Don't edit it by hand. Take the version from `main`, then let pnpm re-apply your changes:

```bash
git checkout origin/main -- pnpm-lock.yaml
pnpm install
git add pnpm-lock.yaml
git rebase --continue
```

Changed your mind mid-way? `git rebase --abort` puts everything back as it was.

Since rebasing rewrites your branch's history, pushing afterwards needs a force. Use the safe version, and only on **your own** feature branch:

```bash
git push --force-with-lease
```

**Never force-push to `main`.**

---

## 12. Project conventions

### Folder structure

Follow the structure that already exists in the repo. This is the shape we aim for:

```
src/
├── app/                  # routes, layouts and pages (Next.js App Router)
├── components/
│   ├── ui/               # small reusable pieces (Button, Input, Modal)
│   └── features/         # components tied to one feature (ArticleCard, UploadForm)
├── hooks/                # custom React hooks (useDebounce, useArticles)
├── lib/
│   └── api/              # the API client (the only place that calls the backend)
└── types/                # shared types, including the generated API types
public/                   # static files (favicon, fonts, static images)
```

Folder names inside `src/app/` become URLs, so keep them lowercase with hyphens (`src/app/top-stories/`).

### Code rules

- **TypeScript strict mode, and no `any`.** If you don't know a type, use `unknown` and narrow it. Never silence an error with `// @ts-ignore` without a comment explaining why.
- **Server Components by default.** Add `"use client"` only for components that need state, effects, event handlers or browser APIs. Keep client components small and push them toward the leaves of the tree.
- **One component per file,** with typed props. If a component passes about 200 lines, split it.
- **Handle every state:** loading, error and empty, not only success. Users see these more than you'd think.
- **Keep logic out of JSX.** Compute values above the `return`, or move reusable logic into a hook or a function in `lib/`.
- **Use stable `key` values** in lists (an `id`, not the array index).
- **Use `next/link` for navigation and `next/image` for images.**
- **Don't fetch data in components with raw `fetch` calls.** Go through `src/lib/api/` ([section 13](#13-working-with-the-backend-api)).
- **Read environment variables in one place** (e.g. `src/lib/env.ts`), not scattered through the code.
- **No `console.log`, commented-out code or unused imports** in merged code. ESLint will catch most of these.

### Naming

| Thing | Style | Example |
|---|---|---|
| component files and components | `PascalCase` | `ArticleCard.tsx` |
| hooks | `camelCase`, starts with `use` | `useArticles.ts` |
| utility files and functions | `camelCase` | `formatDate.ts` |
| types and interfaces | `PascalCase` | `Article`, `UploadState` |
| constants | `UPPER_SNAKE_CASE` | `MAX_UPLOAD_SIZE_MB` |
| route folders | `kebab-case` | `top-stories/` |

### Styling

Use the styling approach already in the repo, and don't introduce a second one without discussing it first. Take colors, spacing and font sizes from the shared theme or design tokens instead of hard-coding values like `#1a73e8`. Build **mobile first**, then add rules for larger screens.

### Accessibility

Accessibility is part of "done", not an extra:

- Use real elements: `<button>` for actions, `<a>` / `Link` for navigation, headings in order, `<label>` for every input.
- Every image needs meaningful `alt` text (or `alt=""` if it's purely decorative).
- Everything clickable must work with the keyboard and show a visible focus state.
- Don't rely on color alone to convey meaning, and keep text contrast readable.

### Images and video

NewsBox is media-heavy, so performance matters:

- Use `next/image` with `width` and `height` (or `fill` with a sized parent), so the layout doesn't jump while images load.
- Lazy-load anything below the fold. For `<video>`, set a `poster` and avoid autoloading with `preload="none"` unless it's the main content.
- For uploads, validate file **type and size on the client** to give quick feedback, show **progress**, and handle failure and retry. The backend is still the source of truth, so never assume client checks are enough.
- Don't read big files fully into memory. For large videos, ask the backend team which upload flow to use (direct, chunked or presigned URL).

### Tests

- Test behavior the way a user experiences it: query by role or visible text, not by CSS class or internal state.
- Cover forms, conditional rendering, and the loading, error and empty states of data-driven components.
- Put tests next to the code (`ArticleCard.test.tsx`) or in the repo's established test folder.

---

## 13. Working with the backend API

All calls to the backend go through **`src/lib/api/`**. That one place owns the base URL (`NEXT_PUBLIC_API_URL`), the `Authorization` header and error handling, so components never build requests themselves.

### Keep types in sync with the backend

The backend (FastAPI) publishes its full API description at `/openapi.json`. We generate TypeScript types from it, so a backend change shows up as a compile error here instead of a bug in production.

With the backend running locally:

```bash
pnpm api:types
```

This writes the types to `src/types/api.d.ts`. Commit the generated file. Run it again whenever the backend API changes, and mention it in your PR.

### What to know about the API

- **Login takes form data, not JSON.** `POST /auth/login` expects a form-encoded body with fields `username` (the email) and `password`, and returns `{ "access_token": "...", "token_type": "bearer" }`.
- **Protected routes need a token:** send `Authorization: Bearer <access_token>`. A `401` means the token is missing, wrong or expired.
- **Validation errors are `422`** with a `detail` list describing each bad field. Other errors return `{ "detail": "message" }`. Show friendly messages, not raw backend text.
- **Interactive docs** are at http://127.0.0.1:8000/docs when the backend runs locally. They're the quickest way to try an endpoint.
- Follow the team's agreed approach for storing and refreshing tokens (ask the team lead if you're unsure), and never log or expose a token.

### If the API doesn't do what you need

Don't work around it in the frontend. Talk to the backend team, agree the change, and link the backend PR from yours.

---

## 14. Adding dependencies

Use `pnpm`, never `npm` or `yarn`. Mixing package managers creates conflicting lock files.

```bash
pnpm add date-fns            # runtime dependency
pnpm add -D vitest           # development-only dependency
pnpm remove date-fns         # remove one
```

Commit **both** `package.json` and `pnpm-lock.yaml`. The lock file makes everyone's install identical.

Before adding a package, ask yourself:

- Is it actively maintained, and does it work with our Next.js and React versions?
- Can the browser, Next.js or an existing dependency already do this?
- How much does it add to the bundle? Everything you add ships to every visitor's browser, so check the size (for example on bundlephobia.com).

Mention new dependencies and why you chose them in your PR description.

---

## 15. Secrets and security

- **Everything prefixed `NEXT_PUBLIC_` is embedded in the browser bundle** and visible to anyone. Never put API secrets, private keys or passwords in one. Only put in values you'd be happy to print on a billboard, like the API URL.
- **Never commit** `.env.local`, keys, tokens or passwords. Commit `.env.example` with **fake placeholder values** when you add a new variable.
- **If you commit a secret by accident,** tell the team lead *immediately*, even if you already deleted it in a later commit. It stays in git history, so the secret must be rotated (replaced). Don't just try to hide it.
- **Avoid `dangerouslySetInnerHTML`.** If you truly must render HTML (for example article content), it has to be sanitized first, so ask for a review of that code.
- **Treat everything from users or the API as untrusted,** including article text, file names and uploaded media.
- Spotted a security problem? Tell the team lead privately instead of opening a public issue.

---

## 16. Troubleshooting

| Problem | Likely cause and fix |
|---|---|
| "Port 3000 is already in use" | Another app or an old dev server is running. Stop it, or use another port: `pnpm dev -p 3001` (the backend must then allow that origin, or you'll get CORS errors). |
| **CORS error** in the browser console | The backend isn't running, `NEXT_PUBLIC_API_URL` is wrong, or the backend doesn't allow your origin (by default only `http://localhost:3000`). |
| I changed `.env.local` but nothing changed | Restart `pnpm dev`. Environment variables are read at startup. |
| "Module not found" or odd errors after switching branches | Run `pnpm install`, then delete the build cache and restart: `rm -rf .next` (PowerShell: `Remove-Item -Recurse -Force .next`). |
| `ERR_PNPM_OUTDATED_LOCKFILE` | `package.json` and `pnpm-lock.yaml` disagree. Run `pnpm install` and commit the updated lock file. |
| Strange syntax or engine errors | Your Node version probably doesn't match `.nvmrc`. Check `node -v`. |
| `pnpm typecheck` says types like `LayoutProps` are missing | Run it through the script (`pnpm typecheck`), which generates Next.js's route types first. Plain `tsc` won't. |
| "Hydration mismatch" warning | The server and browser rendered different HTML, usually from dates, `Math.random()` or checks like `typeof window`. Ask for help if you're stuck. |
| 401 responses from the API | The token is missing or expired. Log in again. |

If none of these help, ask in the team channel with the exact error message and what you ran.

---

## 17. Git mistakes and how to fix them

Everyone makes these. None are fatal.

**I committed to `main` by accident (and haven't pushed):**

```bash
git switch -c feat/my-work           # your commit is now safely on a new branch
git switch main
git reset --hard origin/main         # put local main back to match GitHub
git switch feat/my-work              # carry on
```

**I'm on the wrong branch and have uncommitted changes:**

```bash
git stash                            # set the changes aside
git switch correct-branch
git stash pop                        # bring them back
```

**Undo my last commit but keep the changes:**

```bash
git reset --soft HEAD~1
```

**I staged a file I didn't mean to:**

```bash
git restore --staged path/to/file
```

**Throw away my uncommitted changes in one file** (this can't be undone):

```bash
git restore path/to/file
```

**My commit message has a typo (not pushed yet):**

```bash
git commit --amend
```

**I'm lost and want to see what's going on:**

```bash
git status
git log --oneline --graph --decorate -15
```

Still stuck? Don't try random commands. Ask for help *before* running anything with `--force` or `reset --hard`.

---

## 18. For maintainers

**Branch protection.** Set these once in **GitHub, then Settings, then Branches (or Rulesets), then the `main` branch rule**:

- [ ] Require a pull request before merging
- [ ] Require at least 1 approval
- [ ] Dismiss stale approvals when new commits are pushed
- [ ] Require status checks to pass (add the CI checks once CI exists)
- [ ] Require branches to be up to date before merging
- [ ] Block force pushes and branch deletion on `main`
- [ ] Allow **squash merging** only
- [ ] Automatically delete head branches after merge

**Repo setup this guide assumes.** Make sure the repo defines these:

1. **Scripts in `package.json`.** A fresh `create-next-app` only ships `dev`, `build`, `start` and `lint`, so add the rest:

   ```json
   "scripts": {
     "dev": "next dev",
     "build": "next build",
     "start": "next start",
     "lint": "eslint",
     "typecheck": "next typegen && tsc --noEmit",
     "test": "vitest run",
     "format": "prettier --write .",
     "api:types": "openapi-typescript http://127.0.0.1:8000/openapi.json -o src/types/api.d.ts"
   }
   ```

   ```bash
   pnpm add -D vitest prettier openapi-typescript
   ```

   `next typegen` needs a recent Next.js. On older versions use `tsc --noEmit` alone. Swap `vitest` for your own test runner if you prefer another.

2. **`.nvmrc`** with the Node version everyone should use.
3. **`.env.example`** listing every variable with fake values. Note that `create-next-app`'s default `.gitignore` contains `.env*`, which **also ignores `.env.example`**. Add this line after it so the example file can be committed:

   ```gitignore
   !.env.example
   ```

4. **A CI workflow** that runs `pnpm install --frozen-lockfile`, `pnpm lint`, `pnpm typecheck`, `pnpm test` and `pnpm build` on every pull request, and is set as a required check.

**Nice to have:** a `.github/pull_request_template.md` containing the template from [section 9](#9-opening-a-pull-request), a `CODEOWNERS` file to auto-request reviewers, preview deployments per PR (link them in the PR), and Husky with lint-staged to run lint and format before each commit.

---

## Getting help

Stuck on setup, unsure how to structure a feature, or not sure what to work on? Ask in the team channel or tag the team lead on your PR. Asking early is always better than being stuck for hours.

Thanks for contributing! 🎉