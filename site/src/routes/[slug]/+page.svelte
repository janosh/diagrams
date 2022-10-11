<script lang="ts">
  import { dev } from '$app/environment'
  import CodeBlock from '$lib/CodeBlock.svelte'
  import PrevNextFig from '$lib/PrevNextFig.svelte'
  import Tags from '$lib/Tags.svelte'
  import Icon from '@iconify/svelte'
  import { homepage, repo_url } from '../+layout'
  import type { PageData } from './$types'

  export let data: PageData

  $: ({ title, description, code, width, height } = data.tikz_figure)
  $: ({ creator, creator_url, url, downloads, tags, slug } = data.tikz_figure)
  $: link = `GitHub||${repo_url}/blob/main/assets/${slug}/${slug}.tex`
  const labels = [
    [`.png`, `PNG`],
    [`-hd.png`, `PNG (HD)`],
    [`.pdf`, `PDF`],
    [`.svg`, `SVG`],
    [`.tex`, `TeX`],
  ] as const

  // development server fetches files from local folder (specified by svelte.config.js kit.files.assets)
  // production server fetches files from GitHub (so we don't need to upload assets to netlify)
  const asset_uri = dev ? `` : `https://raw.githubusercontent.com/janosh/tikz/main/assets`
  $: base_uri = `${asset_uri}/${slug}/${slug}`
  $: hd_png = `${base_uri}-hd.png`
  $: tex_file_uri = `${base_uri}.tex`
  $: overleaf_href = `https://overleaf.com/docs?snip_uri=${tex_file_uri}`

  $: if (downloads.length < 2) throw `unexpectedly low number of assets for download`
  $: head_title = `${title} | TikZ Diagrams`
  $: plain_description = description?.replace(/<[^>]*>/g, ``)
</script>

<svelte:head>
  <title>{head_title}</title>
  <meta property="og:title" content={head_title} />
  {#if plain_description}
    <meta name="description" content={plain_description} />
    <meta property="og:description" content={plain_description} />
  {/if}
  <meta property="og:image" content={hd_png} />
  <meta property="og:image:alt" content={title} />
  <meta property="og:url" content="{homepage}/{slug}" />
  <meta name="twitter:card" content="summary" />
</svelte:head>

<a href="/" class="large-link">&laquo; back</a>
<h1>{title}</h1>

{#if creator || url}
  <p class="flex">
    {#if creator}
      Creator: {#if creator_url}
        <a href={creator_url}>{creator}</a>
      {:else}
        Creator: {creator}
      {/if}
    {/if}
    {#if url}
      (<a href={url}>original</a>)
    {/if}
  </p>
{/if}

<section>
  <h3>Tags</h3>
  <Tags {tags} fontSize="12pt" />

  {#if description}
    {@html description}
    <br />
  {/if}
</section>

<img src={hd_png} alt={title} {width} {height} />

<h2>
  <Icon icon="octicon:link-external" inline />&nbsp; Edit
</h2>
<a href={overleaf_href} target="_blank" class="large-link">
  <img src="overleaf.svg" alt="Overleaf Logo" height="30" />&nbsp;Open in Overleaf
</a>

<h2>
  <Icon icon="octicon:download-16" inline />&nbsp; Download
</h2>

{#each labels as [ext, label]}
  {#if downloads?.some((filename) => filename.includes(ext))}
    <a href="{base_uri}{ext}" target="_blank" class="large-link">
      {label}
    </a>
  {/if}
{/each}

<h2>
  <Icon icon="octicon:code" inline />&nbsp; Code
</h2>

<p>{code.split(`\n`).length} lines</p>

<CodeBlock {code} title="{slug}.tex" {link} />

<PrevNextFig prev={data.prev_fig} next={data.next_fig} />

<style>
  h1 {
    font-size: 3em;
  }
  :where(h1, h2) {
    border-bottom: 2px solid orange;
    max-width: 12em;
    margin: 2em auto 1em;
    padding-bottom: 8pt;
  }
  section {
    max-width: 45em;
    margin: 1em auto;
    line-height: 3ex;
  }
  img[width] {
    background: #ffffff85;
    padding: 1em;
    box-sizing: border-box;
    max-width: min(850px, 90vw);
    height: auto;
    max-height: 90vh;
    margin: auto;
    border-radius: 1ex;
    display: block;
  }
  a.large-link {
    background: rgba(255, 255, 255, 0.1);
    padding: 4pt 1ex;
    border-radius: 4pt;
    margin: 2pt;
    transition: color 0.3s, background-color 0.3s;
    font-size: 16pt;
  }
  a.large-link:hover {
    background: rgba(255, 255, 255, 0.2);
  }
  a.large-link[target='_blank'] {
    display: inline-flex;
    place-items: center;
  }
  a.large-link[href='/'] {
    position: absolute;
    top: 2em;
    left: 2em;
  }
</style>
