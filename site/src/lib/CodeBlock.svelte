<script module lang="ts">
  import grammar_typst from '@wooorm/starry-night/source.typst'
  import grammar_latex from '@wooorm/starry-night/text.tex.latex'
  import { create_highlighter } from 'svelte-widgets/live-examples/create-highlighter'

  // shared across all component instances, grammars load on first highlight.
  // import the subpath, not the barrel, which eagerly awaits 34 common grammars
  const highlighter = create_highlighter([grammar_latex, grammar_typst])
</script>

<script lang="ts">
  import Iconify from '@iconify/svelte'
  import { CopyButton, Icon } from 'svelte-widgets'
  import type { HTMLAttributes } from 'svelte/elements'

  let {
    code,
    repo_link,
    title,
    tex_file_uri = ``,
    ...rest
  }: {
    code: string
    repo_link: string
    title: string
    tex_file_uri?: string
  } & HTMLAttributes<HTMLDivElement> = $props()

  let ext = $derived(title?.split(`.`).pop() as `typ` | `tex`)
  const icon = $derived({ typ: `simple-icons:typst`, tex: `file-icons:latex` }[ext])

  let highlighted_code = $state(``)

  $effect(() => {
    highlighter.highlight(code, ext).then((html) => (highlighted_code = html))
  })
</script>

<div {...rest}>
  {#if title}
    <h3>
      <Iconify {icon} inline />&nbsp;
      {title} <small>({code.split(`\n`).length} lines)</small>
    </h3>
  {/if}
  <aside>
    {#if repo_link}
      <a href={repo_link} target="_blank" rel="noreferrer noopener">
        <button>
          <Icon icon="GitHub" />
        </button>
      </a>
    {/if}
    <!-- https://github.com/typst/webapp-issues/issues/516 tracks Typst web app API for opening code files -->
    {#if tex_file_uri}
      {@const href = `https://overleaf.com/docs?snip_uri=${tex_file_uri}`}
      <a {href} target="_blank" rel="noreferrer noopener">
        <button>
          <img src="/overleaf.svg" alt="Overleaf Logo" height="16" />
        </button>
      </a>
    {/if}
    <CopyButton content={code} />
  </aside>
  <pre><code>{@html highlighted_code}</code></pre>
</div>

<style>
  div {
    max-width: var(--content-max-width);
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
