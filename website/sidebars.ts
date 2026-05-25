import type { SidebarsConfig } from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  mainSidebar: [
    { type: 'doc', id: 'intro',           label: 'Overview' },
    { type: 'doc', id: 'install',         label: 'Install' },
    { type: 'doc', id: 'first-project',   label: 'First project' },
    { type: 'doc', id: 'garden-overview', label: 'Garden model' },

    {
      type: 'category',
      label: 'Penguins tutorial',
      collapsed: true,
      items: [
        { type: 'doc', id: 'penguins/overview', label: 'Overview' },
        { type: 'doc', id: 'penguins/scaffold', label: '1. Scaffold' },
        { type: 'doc', id: 'penguins/data',     label: '2. Get data' },
        { type: 'doc', id: 'penguins/explore',  label: '3. Explore' },
        { type: 'doc', id: 'penguins/features', label: '4. Features' },
        { type: 'doc', id: 'penguins/model',    label: '5. Model' },
        { type: 'doc', id: 'penguins/report',   label: '6. Report' },
        { type: 'doc', id: 'penguins/publish',  label: '7. Publish' },
      ],
    },

    {
      type: 'category',
      label: 'Manuscript workflow',
      collapsed: true,
      items: [
        { type: 'doc', id: 'manuscript/overview',          label: 'Overview' },
        { type: 'doc', id: 'manuscript/versioned-reports', label: '1. Versioned reports' },
        { type: 'doc', id: 'manuscript/writing',           label: '2. Writing' },
        { type: 'doc', id: 'manuscript/review',            label: '3. Review' },
        { type: 'doc', id: 'manuscript/versioning',        label: '4. Versioning' },
        { type: 'doc', id: 'manuscript/preprint',          label: '5. Preprint' },
        { type: 'doc', id: 'manuscript/journal',           label: '6. Journal submission' },
      ],
    },

    {
      type: 'category',
      label: 'Reference',
      collapsed: false,
      items: [
        { type: 'doc', id: 'reference/garden',         label: 'Garden CLI' },
        { type: 'doc', id: 'reference/components',     label: 'Components' },
        { type: 'doc', id: 'reference/cli',            label: 'CLI commands' },
        { type: 'doc', id: 'reference/justfile',       label: 'justfile structure' },
        { type: 'doc', id: 'reference/copier-options', label: 'Copier options' },
        { type: 'doc', id: 'reference/data-stages',    label: 'Data stages' },
        { type: 'doc', id: 'reference/writeup',        label: 'Writeup formats' },
        { type: 'doc', id: 'reference/safety-net',     label: 'Safety net (CTT)' },
      ],
    },
  ],
};

export default sidebars;
