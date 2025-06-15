<script lang="ts">
  import Icon from '@iconify/svelte'
  import hljs from 'highlight.js/lib/core'
  import latex from 'highlight.js/lib/languages/latex'
  import 'highlight.js/styles/vs2015.css'
  import { CopyButton } from 'svelte-multiselect'

  hljs.registerLanguage(`latex`, latex)
  // TODO highlight.js does not support Typst
  // https://github.com/highlightjs/highlight.js/blob/main/SUPPORTED_LANGUAGES.md
  // and won't unless someone contributes a grammar
  // https://highlightjs.readthedocs.io/en/latest/language-requests.html

  interface Props {
    code: string
    github_link: string
    title: string
    tex_file_uri?: string
  }

  let { code, github_link, title, tex_file_uri = `` }: Props = $props()
</script>

<div>
  {#if title}
    <h3>
      {title} <small>({code.split(`\n`).length} lines)</small>
    </h3>
  {/if}
  <aside>
    {#if github_link}
      {@const [link_title, href] = (github_link ?? ``).split(`||`, 2)}
      <a {href}>
        <button>
          <Icon icon="octicon:mark-github" inline /> {link_title}
        </button>
      </a>
    {/if}
    <!-- https://github.com/typst/webapp-issues/issues/516 tracks Typst web app API for opening code files -->
    {#if tex_file_uri}
      {@const href = `https://overleaf.com/docs?snip_uri=${tex_file_uri}`}
      <a {href} target="_blank" rel="noreferrer">
        <button>
          <img src="overleaf.svg" alt="Overleaf Logo" height="16" />
          Open in Overleaf
        </button>
      </a>
    {/if}
    <CopyButton content={code} />
  </aside>
  <pre><code>{@html hljs.highlight(code, { language: `latex` }).value}</code></pre>
</div>

<style>
  div {
    max-width: 55em;
    margin: 3em auto;
    position: relative;
  }
  h3 {
    position: absolute;
    bottom: calc(100% - 1em);
    left: 1em;
    background: teal;
    padding: 2pt 8pt;
    border-radius: 3pt 3pt 0 0;
  }
  h3 small {
    color: #fff;
    font-weight: 200;
    padding-left: 6pt;
  }
  aside {
    position: absolute;
    top: 1em;
    right: 1em;
    display: flex;
    gap: 1em;
  }
  pre {
    padding: 1em;
    background: rgba(255, 255, 255, 0.2);
    overflow-x: scroll;
    font-size: 1.2em;
    border-radius: 3pt;
  }
  button {
    display: inline-flex;
    gap: 6pt;
    align-items: center;
  }
</style>
