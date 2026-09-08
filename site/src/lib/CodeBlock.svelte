<script module lang="ts">
  import grammar_typst from '@wooorm/starry-night/source.typst'
  import grammar_latex from '@wooorm/starry-night/text.tex.latex'
  import { create_highlighter } from 'svelte-widgets/highlight'

  // Shared across component instances; only these grammars load on first highlight.
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
  let highlighted_code = $derived(highlighter.highlight(code, ext))
</script>

<div {...rest}>
  <header>
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
  </header>
  <!-- svelte-ignore a11y_no_noninteractive_tabindex (WebKit needs explicit focus for keyboard scrolling) -->
  <pre role="region" aria-label={title} tabindex="0"><code
      >{#await highlighted_code}{code}{:then html}{@html html}{/await}</code
    ></pre>
</div>

<style>
  div {
    --controls-inset: 1rem;
    max-width: var(--content-max-width);
    margin: 3em auto;
  }
  header {
    position: relative;
    display: flex;
    padding: 0 1em;
    z-index: 1;
  }
  h3 {
    margin: 0;
    display: inline-flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 0.35em;
    overflow-wrap: anywhere;
    background: var(--button-bg);
    padding: 0 8pt;
    border-radius: 3pt;
    font-size: medium;
    transform: translateY(50%);
  }
  h3 small {
    font-weight: 200;
    padding-left: 6pt;
  }
  aside {
    position: absolute;
    top: calc(100% + var(--controls-inset));
    right: var(--controls-inset);
    display: flex;
    gap: 1ex;
  }
  pre {
    margin: 0;
    padding: 1.75em 1em 1em;
    background: var(--pre-bg);
    overflow-x: auto;
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
  @media (width < 600px) {
    div {
      display: grid;
      grid-template-rows: auto auto auto auto;
      isolation: isolate;
    }
    div::before {
      content: '';
      grid-area: 2 / 1 / 5 / 2;
      background: var(--pre-bg);
      border-radius: 3pt;
      z-index: -1;
    }
    header {
      display: contents;
    }
    h3 {
      grid-area: 1 / 1 / 3 / 2;
      margin: 0 1rem;
      transform: none;
      justify-self: start;
    }
    aside {
      grid-area: 3 / 1 / 4 / 2;
      position: static;
      justify-self: end;
      margin: 1rem 1rem 0;
    }
    pre {
      grid-area: 4 / 1 / 5 / 2;
      background: none;
      padding-top: 1em;
    }
  }
</style>
