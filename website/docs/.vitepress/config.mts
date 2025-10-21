import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "DML Lib",
  description: "Apex DML Lib.",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Documentation', link: '/api' }
    ],

    sidebar: [
      {
        text: 'Docs',
        items: [
          { text: 'API', link: '/api' },
          { text: 'Examples', link: '/examples' }
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/beyond-the-cloud-dev/dml-lib' }
    ]
  }
})
