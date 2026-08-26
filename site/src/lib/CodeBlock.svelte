<script module lang="ts">
  import grammar_typst from '@wooorm/starry-night/source.typst'
  import grammar_latex from '@wooorm/starry-night/text.tex.latex'
  import { create_highlighter } from 'svelte-widgets/live-examples/create-highlighter'

  // shared across all component instances, grammars load on first highlight.
  // import the subpath, not the barrel, which eagerly awaits 34 common grammars
  const highlighter = create_highlighter([grammar_latex, grammar_typst])
</script>

<script lang="ts">
  import { CopyButton, Icon } from 'svelte-widgets'
  import { GitHub, LaTeXFile, Overleaf, Typst } from 'svelte-widgets/icons'
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
  let highlighted_code = $state(``)

  $effect(() => {
    highlighter.highlight(code, ext).then((html) => (highlighted_code = html))
  })
</script>

<div {...rest}>
  {#if title}
    <h3>
      <Icon icon={ext === `typ` ? Typst : LaTeXFile} />
      {title} <small>({code.split(`\n`).length} lines)</small>
    </h3>
  {/if}
  <aside>
    {#if repo_link}
      <a
        href={repo_link}
        target="_blank"
        rel="noreferrer noopener"
        title="View source on GitHub"
        aria-label="View source on GitHub"
      >
        <Icon icon={GitHub} />
      </a>
    {/if}
    <!-- https://github.com/typst/webapp-issues/issues/516 tracks Typst web app API for opening code files -->
    {#if tex_file_uri}
      {@const href = `https://overleaf.com/docs?snip_uri=${tex_file_uri}`}
      <a
        {href}
        target="_blank"
        rel="noreferrer noopener"
        title="Open in Overleaf"
        aria-label="Open in Overleaf"
      >
        <Icon icon={Overleaf} />
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
    display: inline-flex;
    align-items: center;
    gap: 0.35em;
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
  pre {
    padding: 1em;
    background: var(--pre-bg);
    overflow-x: scroll;
    border-radius: 3pt;
  }
  aside a,
  aside :global([data-sms-copy]) {
    place-items: center;
    background: var(--button-bg);
    border: none;
    border-radius: 3pt;
    padding: 3pt 1ex;
    color: var(--text-color);
    font: inherit;
    cursor: pointer;
  }
  aside a {
    display: inline-flex;
  }
</style>
