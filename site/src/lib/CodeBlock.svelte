<script lang="ts">
  import Icon from '@iconify/svelte'
  import hljs from 'highlight.js/lib/core'
  import latex from 'highlight.js/lib/languages/latex'
  import 'highlight.js/styles/vs2015.css'
  import { CopyButton } from 'svelte-zoo'

  hljs.registerLanguage(`latex`, latex)

  export let code: string
  export let link: string
  export let title: string

  let [linkTitle, url] = (link ?? ``).split(`||`, 2)
</script>

<div>
  {#if title}
    <h3>
      {title}
      <small>({code.split(`\n`).length} lines)</small>
    </h3>
  {/if}
  <aside>
    {#if link}<a href={url}>
        <button>
          <Icon icon="octicon:mark-github" inline />
          {linkTitle}
        </button>
      </a>{/if}
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
</style>
