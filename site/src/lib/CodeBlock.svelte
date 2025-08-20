<script lang="ts">
  import Iconify from '@iconify/svelte'
  import hljs from 'highlight.js/lib/core'
  import latex from 'highlight.js/lib/languages/latex'
  import 'highlight.js/styles/vs2015.css'
  import { CopyButton, Icon } from 'svelte-multiselect'

  hljs.registerLanguage(`latex`, latex)
  // TODO highlight.js does not support Typst
  // https://github.com/highlightjs/highlight.js/blob/main/SUPPORTED_LANGUAGES.md
  // and won't unless someone contributes a grammar
  // https://highlightjs.readthedocs.io/en/latest/language-requests.html

  interface Props {
    code: string
    repo_link: string
    title: string
    tex_file_uri?: string
  }
  let { code, repo_link, title, tex_file_uri = `` }: Props = $props()
  let ext = $derived(title?.split(`.`).pop() as 'typ' | 'ext')
  const lang_icon = $derived(
    { typ: `simple-icons:typst`, tex: `file-icons:latex` }[ext],
  )
</script>

<div>
  {#if title}
    <h3>
      <Iconify icon={lang_icon} inline />&nbsp;
      {title} <small>({code.split(`\n`).length} lines)</small>
    </h3>
  {/if}
  <aside>
    {#if repo_link}
      <a href={repo_link} target="_blank" rel="noreferrer noopener">
        <button>
          <Icon icon="GitHub" inline />
        </button>
      </a>
    {/if}
    <!-- https://github.com/typst/webapp-issues/issues/516 tracks Typst web app API for opening code files -->
    {#if tex_file_uri}
      {@const href = `https://overleaf.com/docs?snip_uri=${tex_file_uri}`}
      <a {href} target="_blank" rel="noreferrer noopener">
        <button>
          <img src="overleaf.svg" alt="Overleaf Logo" height="16" />Overleaf
        </button>
      </a>
    {/if}
    <CopyButton content={code} />
  </aside>
  <pre><code>{@html hljs.highlight(code, { language: `latex` }).value}</code></pre>
</div>

<style>
  div {
    max-width: 50em;
    margin: 3em auto;
    position: relative;
  }
  h3 {
    position: absolute;
    bottom: calc(100% - 1em);
    left: 1em;
    background: var(--button-bg);
    padding: 0 8pt;
    border-radius: 3pt 3pt 0 0;
    font-size: medium;
  }
  h3 small {
    font-weight: 200;
    padding-left: 6pt;
  }
  aside {
    position: absolute;
    top: 1em;
    right: 1em;
    display: flex;
    gap: 1ex;
  }
  aside a button {
    height: 100%;
  }
  pre {
    padding: 1em;
    background: var(--pre-bg);
    overflow-x: scroll;
    border-radius: 3pt;
  }
  button {
    display: inline-flex;
    gap: 3pt;
    place-items: center;
  }
</style>
