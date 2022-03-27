<script lang="ts">
  import CodeIcon from '@svicons/octicons/code.svelte'
  import DownloadIcon from '@svicons/octicons/download.svelte'
  import LinkExternal from '@svicons/octicons/link-external.svelte'
  import Prism from '../components/Prism.svelte'
  import { TexFile } from '../types'
  export let texFile: TexFile

  $: ({ title, desc, code, width, height, slug, downloads } = texFile)
  $: link = `GitHub||https://github.com/janosh/tikz/blob/main/assets/${slug}/${slug}.tex`
  const labels = [
    [`.png`, `PNG`],
    [`-hd.png`, `PNG (HD)`],
    [`.pdf`, `PDF`],
    [`.svg`, `SVG`],
    [`.tex`, `TeX`],
  ] as const

  $: snip_uri = `https://raw.githubusercontent.com/janosh/tikz/main/assets/${slug}/${slug}.tex`
  $: overleaf_href = `https://overleaf.com/docs?snip_uri=${snip_uri}`
</script>

<a href="/" sveltekit:prefetch>&laquo; back</a>
<h1>{title}</h1>

{#if desc}
  <p>{@html desc}</p>
{/if}

<img src="/assets/{slug}/{slug}-hd.png" alt={title} {width} {height} />

<h2><LinkExternal height="1em" style="vertical-align: middle;" />&nbsp; Edit</h2>
<a href={overleaf_href} target="_blank">
  <img src="overleaf.svg" alt="Overleaf Logo" height="30" />&nbsp;Open in Overleaf
</a>

<h2><DownloadIcon height="1em" style="vertical-align: middle;" />&nbsp; Download</h2>

{#each labels as [ext, label]}
  {#if downloads?.some((filename) => filename.includes(ext))}
    <a href="/assets/{slug}/{slug}{ext}" target="_blank">
      {label}
    </a>
  {/if}
{/each}

<h2><CodeIcon height="1em" style="vertical-align: middle;" />&nbsp; Code</h2>

<Prism {code} title="{slug}.tex" {link} />

<style>
  h1 {
    font-size: 3em;
  }
  :where(h1, h2) {
    border-bottom: 2px solid orange;
    max-width: 10em;
    margin: 2em auto 1em;
    padding-bottom: 8pt;
  }
  p {
    max-width: 45em;
    margin: 1em auto;
    padding: 1em;
    line-height: 3ex;
  }
  img[width] {
    width: 100%;
    background: #ffffff85;
    padding: 1em;
    box-sizing: border-box;
    max-width: min(850px, 90vw);
    margin: auto;
    border-radius: 1ex;
    height: auto;
    display: block;
  }
  a {
    background: rgba(255, 255, 255, 0.1);
    padding: 4pt 1ex;
    border-radius: 4pt;
    margin: 2pt;
    transition: color 0.3s, background-color 0.3s;
    font-size: 16pt;
  }
  a:hover {
    background: rgba(255, 255, 255, 0.2);
  }
  a[target='_blank'] {
    display: inline-flex;
    place-items: center;
  }
  a[href='/'] {
    position: absolute;
    top: 2em;
    left: 2em;
  }
</style>
