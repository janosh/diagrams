<script lang="ts">
  import { CodeBlock, type Diagram, DiagramCard, Tags } from '$lib'
  import { homepage, repository } from '$root/package.json'
  import Icon from '@iconify/svelte'
  import { PrevNext } from 'svelte-multiselect'

  let { data } = $props()
  let { title, description, code, images } = $derived(data.diagram)
  let { creator, creator_url, url, downloads, tags, slug } = $derived(
    data.diagram,
  )
  const labels = [
    [`.png`, `PNG`],
    [`-hd.png`, `PNG (HD)`],
    [`.pdf`, `PDF`],
    [`.svg`, `SVG`],
    [`.tex`, `TeX`],
  ] as const

  // development server fetches files from local folder (specified by svelte.config.js kit.files.assets)
  // production server fetches files from GitHub (so we don't need to re-upload with every build)
  const raw_repo_url =
    `https://github.com/janosh/diagrams/raw/refs/heads/main/assets/`
  let base_uri = $derived(`${raw_repo_url}/${slug}/${slug}`)

  $effect(() => {
    if (downloads?.length < 2) {
      throw `unexpectedly low number of assets for download`
    }
  })
  let plain_description = $derived(description?.replace(/<[^>]*>/g, ``))
</script>

<svelte:head>
  <title>{title} | TikZ Diagrams</title>
  <meta property="og:title" content="{title} | TikZ Diagrams" />
  {#if plain_description}
    <meta name="description" content={plain_description} />
    <meta property="og:description" content={plain_description} />
  {/if}
  <meta property="og:image" content="{base_uri}-hd.png" />
  <meta property="og:image:alt" content={title} />
  <meta property="og:url" content="{homepage}/{slug}" />
  <meta name="twitter:card" content="summary" />
</svelte:head>

<a href="." class="large-link">&laquo; home</a>
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

<section class="description">
  <Tags {tags} btn_props={{ style: `cursor: default` }} />

  {#if description}
    {@html description}
    <br />
  {/if}
</section>

<enhanced:img src={images.hd} alt={title} class="diagram" />

<h2>
  <Icon icon="octicon:download-16" inline />&nbsp; Download
</h2>
<section>
  {#each labels as [ext, label]}
    {#if downloads?.some((filename) => filename.includes(ext))}
      <a
        href="{base_uri}{ext}"
        target="_blank"
        rel="noreferrer"
        class="large-link"
      >
        {label}
      </a>
    {/if}
  {/each}
</section>

<h2>
  <Icon icon="octicon:code" inline />&nbsp; Code
</h2>
{#if code.tex}
  <CodeBlock
    code={code.tex}
    title="{slug}.tex"
    repo_link="{repository}/blob/main/assets/{slug}/{slug}.tex"
    tex_file_uri="{base_uri}.tex"
  />
{/if}
{#if code.typst}
  <CodeBlock
    code={code.typst}
    title="{slug}.typ"
    repo_link="{repository}/blob/main/assets/{slug}/{slug}.typ"
  />
{/if}

<PrevNext
  items={data.diagrams.map((diagram) => [diagram.slug, diagram])}
  current={data.slug}
  style="max-width: 50em; margin: auto"
>
  {#snippet children({ item, kind })}
    {@const [slug, diagram] = item as [string, Diagram]}
    <div>
      <h3>
        <a href={slug}>
          {@html kind == `next` ? `Next &rarr;` : `&larr; Previous`}
        </a>
      </h3>
      <DiagramCard
        item={diagram}
        style="max-width: 280px; font-size: 10pt"
        format="short"
      />
    </div>
  {/snippet}
</PrevNext>

<style>
  h1 {
    font-size: 2em;
  }
  :where(h1, h2) {
    border-bottom: 2px solid var(--link-hover);
    max-width: 12em;
    margin: 1em auto;
    padding-bottom: 8pt;
  }
  section {
    max-width: 45em;
    margin: 1em auto;
    line-height: 3ex;
    text-align: center;
  }
  section.description :global(ul) {
    text-align: left;
  }
  .diagram {
    background-color: light-dark(transparent, rgba(255, 255, 255, 0.3));
    padding: 1em;
    box-sizing: border-box;
    max-width: min(850px, 90vw);
    height: auto;
    max-height: 90vh;
    object-fit: scale-down;
    margin: 2em auto;
    border-radius: 1ex;
    display: block;
  }
  a.large-link {
    background: var(--nav-bg);
    padding: 0 7pt;
    border-radius: 4pt;
    margin: 2pt;
    transition: color 0.3s, background-color 0.3s;
    font-size: 16pt;
  }
  a.large-link:hover {
    background: var(--card-bg);
  }
  a.large-link[target='_blank'] {
    display: inline-flex;
    place-items: center;
  }
  a.large-link[href='.'] {
    position: absolute;
    top: 2em;
    left: 2em;
  }
</style>
