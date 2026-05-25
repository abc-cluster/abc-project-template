# `abc-project-template` documentation site

Docusaurus 3 site for the [`abc-project-template`](https://github.com/abc-cluster/abc-project-template)
project. Three sections:

- **Get started** — install, scaffold, learn the Garden
- **Penguins tutorial** — end-to-end use case (Palmer Penguins classifier)
- **Reference** — feature-by-feature lookup (Garden, components, CLI,
  justfile, copier options, data stages, writeup, safety net)

## Develop

```bash
cd website/
npm install
npm start          # http://localhost:3000
```

## Build

```bash
npm run build
```

Static output lands in `website/build/`. Deploy to GitHub Pages, Netlify,
Cloudflare Pages, etc.

## Structure

```
website/
├── docusaurus.config.js     # site config
├── sidebars.js              # nav structure (3 sidebars)
├── package.json
├── docs/
│   ├── intro.md             # main landing → tutorialSidebar
│   ├── install.md
│   ├── first-project.md
│   ├── garden-overview.md
│   ├── penguins/            # 8-step tutorial → penguinsSidebar
│   │   ├── 00-overview.md
│   │   ├── 01-scaffold.md
│   │   ├── 02-data.md
│   │   ├── 03-explore.md
│   │   ├── 04-features.md
│   │   ├── 05-model.md
│   │   ├── 06-report.md
│   │   └── 07-publish.md
│   └── reference/           # feature reference → referenceSidebar
│       ├── garden.md
│       ├── components.md
│       ├── cli.md
│       ├── justfile.md
│       ├── copier-options.md
│       ├── data-stages.md
│       ├── writeup.md
│       └── safety-net.md
└── src/
    ├── pages/
    │   └── index.md         # site landing page
    └── css/
        └── custom.css
```

## Editing

Pages use standard Markdown / MDX with Docusaurus extensions:

- Front matter: `sidebar_position`, `title`
- Tabs: `import Tabs from '@theme/Tabs'`
- Admonitions: `:::tip`, `:::warning`, etc.
- Code blocks with language tags

## Deploy to GitHub Pages

```bash
GIT_USER=abhi18av npm run deploy
```

The `docusaurus.config.js` is set up for `https://abhi18av.github.io/abc-project-template/`.

## CI

Add `.github/workflows/website.yml` to auto-deploy on push to `main`:

```yaml
name: Deploy website

on:
  push:
    branches: [main]
    paths: ['website/**', '.github/workflows/website.yml']

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm', cache-dependency-path: website/package-lock.json }
      - run: cd website && npm ci && npm run build
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: website/build
          publish_branch: gh-pages
```
