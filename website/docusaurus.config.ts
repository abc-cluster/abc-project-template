import { themes as prismThemes } from 'prism-react-renderer';
import type { Config } from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'abc-project-template',
  tagline: 'Grow-as-you-need template for data science / bioinformatics projects',
  favicon: 'img/favicon.svg',

  future: {
    v4: true,
  },

  url: 'https://abhi18av.github.io',
  baseUrl: '/abc-project-template/',

  organizationName: 'abhi18av',
  projectName: 'abc-project-template',
  deploymentBranch: 'gh-pages',
  trailingSlash: false,

  onBrokenLinks: 'warn',

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  markdown: {
    format: 'md',
    mermaid: true,
    hooks: {
      onBrokenMarkdownLinks: 'warn',
      onBrokenMarkdownImages: 'warn',  // tutorial references images in scaffolded projects, not in docs site
    },
  },

  themes: ['@docusaurus/theme-mermaid'],

  // Browser-theme-aware favicon: dark variant when the user's OS is in dark mode.
  // Mirrors the abc-cluster-cli site convention.
  headTags: [
    {
      tagName: 'link',
      attributes: {
        rel: 'icon',
        type: 'image/svg+xml',
        href: '/abc-project-template/img/favicon.svg',
        media: '(prefers-color-scheme: light)',
      },
    },
    {
      tagName: 'link',
      attributes: {
        rel: 'icon',
        type: 'image/svg+xml',
        href: '/abc-project-template/img/favicon-dark.svg',
        media: '(prefers-color-scheme: dark)',
      },
    },
  ],

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          editUrl: 'https://github.com/abhi18av/abc-project-template/tree/main/website/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    image: 'img/social-card.png',
    colorMode: {
      defaultMode: 'light',
      disableSwitch: false,
      // Deterministic light default across all abc-cluster sites; users can
      // still toggle to dark (persisted). OS preference intentionally not
      // honoured so first paint is consistent everywhere.
      respectPrefersColorScheme: false,
    },
    navbar: {
      title: 'abc',
      logo: {
        alt: 'abc-project-template ABC mark',
        src: 'img/logo.svg',
        srcDark: 'img/logo-dark.svg',
        // Trio rings need ~28px to read; smaller crushes the A/B/C glyphs.
        style: { width: '28px', height: '28px' },
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'mainSidebar',
          position: 'left',
          label: 'Docs',
        },
        {
          to: '/docs/penguins/overview',
          label: 'Penguins tutorial',
          position: 'left',
        },
        {
          to: '/docs/manuscript/overview',
          label: 'Manuscript workflow',
          position: 'left',
        },
        {
          href: 'https://github.com/abhi18av/abc-project-template',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            { label: 'Overview',      to: '/docs/intro' },
            { label: 'Install',       to: '/docs/install' },
            { label: 'First project', to: '/docs/first-project' },
            { label: 'Garden model',  to: '/docs/garden-overview' },
          ],
        },
        {
          title: 'Tutorial',
          items: [
            { label: 'Penguins study',    to: '/docs/penguins/overview' },
            { label: 'Scaffold',          to: '/docs/penguins/scaffold' },
            { label: 'Build a classifier',to: '/docs/penguins/model' },
            { label: 'Render manuscript', to: '/docs/penguins/report' },
          ],
        },
        {
          title: 'Reference',
          items: [
            { label: 'Garden CLI',     to: '/docs/reference/garden' },
            { label: 'Components',     to: '/docs/reference/components' },
            { label: 'CLI commands',   to: '/docs/reference/cli' },
            { label: 'Data stages',    to: '/docs/reference/data-stages' },
          ],
        },
        {
          title: 'Source',
          items: [
            { label: 'GitHub',     href: 'https://github.com/abhi18av/abc-project-template' },
            { label: 'Issues',     href: 'https://github.com/abhi18av/abc-project-template/issues' },
            { label: 'Releases',   href: 'https://github.com/abhi18av/abc-project-template/releases' },
            { label: 'abc-cluster',href: 'https://abc-cluster.io' },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} abc-project-template · Built with Docusaurus`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['bash', 'yaml', 'toml', 'python', 'r', 'json'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
