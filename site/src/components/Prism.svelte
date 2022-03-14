<script>
  import MarkGithub from '@svicons/octicons/mark-github.svelte'

  import CopyButton from './CopyButton.svelte'
  import { onMount, afterUpdate } from 'svelte'

  export let code, link, title

  let [linkTitle, url] = (link ?? ``).split(`||`, 2)

  const onLoad = () => window.Prism?.highlightAll()
  onMount(onLoad) // for page reloads
  afterUpdate(onLoad)

  const cdn = `https://cdnjs.cloudflare.com/ajax/libs/prism/1.22.0`
</script>

<svelte:head>
  <link rel="stylesheet" href="{cdn}/themes/prism-okaidia.min.css" />
  <script src="{cdn}/prism.min.js"></script>
  <script src="{cdn}/components/prism-latex.min.js" on:load={onLoad}></script>
</svelte:head>

<div>
  {#if title}
    <h3>{title}</h3>
  {/if}
  <section>
    {#if link}<a href={url}>
        <button>
          <MarkGithub height="14pt" style="vertical-align: -4px;" />
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
    background: rgba(255, 255, 255, 0.2) !important;
  }
</style>
