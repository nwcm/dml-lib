import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "DML Lib",
  description: "Apex DML Lib.",
  head: [
    ['link', { rel: 'icon', href: '/favicon.ico' }],
    [
      'script',
      { async: '', src: 'https://www.googletagmanager.com/gtag/js?id=G-8DMDH217B8' }
    ],
    [
      'script',
      {},
      `window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());
      gtag('config', 'G-8DMDH217B8');`
    ]
  ],
  sitemap: {
    hostname: 'https://dml.beyondthecloud.dev'
  },
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Documentation', link: '/introduction' }
    ],

    sidebar: [
      {
        text: 'Docs',
        items: [
          { text: 'Introduction', link: '/introduction' }
        ]
      },
      {
        text: 'DMLs',
        collapsed: false,
        items: [
          { text: 'Insert', link: '/dml/insert' },
          { text: 'Update', link: '/dml/update' },
          { text: 'Upsert', link: '/dml/upsert' },
          { text: 'Delete', link: '/dml/delete' },
          { text: 'Undelete', link: '/dml/undelete' },
          { text: 'Publish', link: '/dml/publish' },
          { text: 'Result', link: '/result' }
        ]
      },
      {
        text: 'Mocking',
        collapsed: true,
        items: [
          { text: 'Insert', link: '/mocking/insert' },
          { text: 'Update', link: '/mocking/update' },
          { text: 'Upsert', link: '/mocking/upsert' },
          { text: 'Delete', link: '/mocking/delete' },
          { text: 'Undelete', link: '/mocking/undelete' },
          { text: 'Publish', link: '/mocking/publish' }
        ]
      },
      {
        text: 'Configuration',
        collapsed: true,
        items: [
          { text: 'Field-Level Security', link: '/configuration/field-level-security' },
          { text: 'Sharing Mode', link: '/configuration/sharing-mode' },
          { text: 'DmlOptions', link: '/configuration/dml-options' }
        ]
      }
    ],
    footer: {
      message: 'Released under the MIT License.',
      copyright: 'Copyright © 2025-present Beyond The Cloud Sp. z o.o.'
    },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/beyond-the-cloud-dev/dml-lib' },
      {
        icon: 'linkedin',
        link: 'https://www.linkedin.com/company/beyondtheclouddev'
      }
    ]
  }
})
