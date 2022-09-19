<script lang="ts">
  import Icon from '@iconify/svelte'
  import { afterUpdate, onMount } from 'svelte'
  import CopyButton from './CopyButton.svelte'

  export let code: string
  export let link: string
  export let title: string

  let [linkTitle, url] = (link ?? ``).split(`||`, 2)

  const highlight = () => window.Prism?.highlightAll()
  onMount(highlight) // for page reloads
  afterUpdate(highlight)

  const cdn = `https://cdnjs.cloudflare.com/ajax/libs/prism/1.28.0`
</script>

<svelte:head>
  <link rel="stylesheet" href="{cdn}/themes/prism-okaidia.min.css" />
  <script async src="{cdn}/prism.min.js"></script>
  <script async src="{cdn}/components/prism-latex.min.js" onload={highlight}></script>
</svelte:head>

<div>
  {#if title}
    <h3>{title}</h3>
  {/if}
  <section>
    {#if link}<a href={url}>
        <button>
          <Icon icon="octicon:mark-github" inline />
          {linkTitle}
        </button>
      </a>{/if}
    <CopyButton content={code} />
  </section>
  <pre><code class="language-latex">{code}</code></pre>
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
    border-radius: 1ex 1ex 0 0;
  }
  section {
    position: absolute;
    top: 1em;
    right: 1em;
    display: flex;
    gap: 1em;
  }
  pre {
    text-align: left;
    background: rgba(255, 255, 255, 0.2) !important;
  }
</style>
