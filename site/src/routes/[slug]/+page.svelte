<script lang="ts">
  import { CodeBlock, type Diagram, DiagramCard, Tags } from '$lib'
  import { filters } from '$lib/state.svelte'
  import { homepage, repository } from '$root/package.json'
  import { FullscreenButton, Icon, PrevNext, Tabs, type IconData } from 'svelte-widgets'
  import {
    Code,
    Download,
    FilePDF,
    FilePNG,
    FileXML,
    HomeOutline,
    LaTeX,
    Typst,
  } from 'svelte-widgets/icons'

  let { data } = $props()
  let {
    title,
    description,
    code,
    images,
    tags,
    slug,
    creator,
    creator_url,
    url,
    downloads,
  } = $derived(data.diagram)
  const download_options: Record<string, { icon: IconData; label: string }> = {
    [`.png`]: { icon: FilePNG, label: `PNG` },
    [`-hd.png`]: { icon: FilePNG, label: `PNG (HD)` },
    [`.pdf`]: { icon: FilePDF, label: `PDF` },
    [`.svg`]: { icon: FileXML, label: `SVG` },
  }
  const code_tabs = [
    { label: `Typst`, value: `typst` },
    { label: `TikZ`, value: `tikz` },
  ] as const
  const code_tab_icons = { tikz: LaTeX, typst: Typst }

  // production serves downloads from GitHub so we don't re-upload assets with every build
  let base_uri = $derived(`${repository}/raw/refs/heads/main/assets/${slug}/${slug}`)
  let plain_description = $derived(description?.replaceAll(/<[^>]*>/g, ``))

  // prev/next walks the active home-page filter; fall back to all diagrams when the current
  // one isn't in the filtered set (direct navigation, or the filter excludes it)
  let nav_diagrams = $derived(
    filters.filtered.some((diagram) => diagram.slug === slug)
      ? filters.filtered
      : data.diagrams,
  )

  // Prefer Typst when both Typst (CeTZ) and TeX (TikZ) sources exist
  let code_tab = $state<`typst` | `tikz`>(`typst`)
  let diagram_wrapper = $state<HTMLDivElement>()
  let selected_source = $derived.by(() => {
    if (code.typst && (code_tab === `typst` || !code.tex)) {
      return { code: code.typst, ext: `typ` as const }
    }
    if (code.tex) return { code: code.tex, ext: `tex` as const }
  })
</script>

<svelte:head>
  <title>{title} | Scientific Diagrams</title>
  <meta property="og:title" content="{title} | Scientific Diagrams" />
  {#if plain_description}
    <meta name="description" content={plain_description} />
    <meta property="og:description" content={plain_description} />
  {/if}
  <meta property="og:image" content="{base_uri}-hd.png" />
  <meta property="og:image:alt" content={title} />
  <meta property="og:url" content="{homepage}/{slug}" />
  <meta name="twitter:card" content="summary" />
</svelte:head>

<a href="." class="large-link" data-sveltekit-preload-code="eager">
  <Icon icon={HomeOutline} /> home
</a>
<h1>{title}</h1>

{#if creator || url}
  <p>
    {#if creator}
      Creator: {#if creator_url}
        <a href={creator_url}>{creator}</a>
      {:else}
        {creator}
      {/if}
    {/if}
    {#if url}
      (<a href={url}>original</a>)
    {/if}
  </p>
{/if}

<section class="description">
  <Tags {tags} style="--tags-cursor: default" />

  {#if description}
    {@html description}
    <br />
  {/if}
</section>

<div class="diagram-wrapper" bind:this={diagram_wrapper}>
  <enhanced:img src={images.hd} alt={title} class="diagram" />
  <FullscreenButton
    wrapper={diagram_wrapper}
    placement="corner"
    bg_css_var="--page-bg"
    style="border: 0; font-size: 18pt; transition: color 0.2s"
  />
</div>

<h2>
  <Icon icon={Download} /> Download
</h2>
<section>
  {#each downloads as ext (ext)}
    {@const { icon, label } = download_options[ext]}
    <a href="{base_uri}{ext}" target="_blank" rel="noreferrer" class="large-link">
      <Icon {icon} />
      {label}
    </a>
  {/each}
</section>

<h2>
  <Icon icon={Code} /> Code
</h2>
{#if code.typst && code.tex}
  <Tabs items={code_tabs} bind:value={code_tab} label="Code language" class="code-tabs">
    {#snippet tab({ item })}
      <Icon icon={code_tab_icons[item.value]} />{item.label}
    {/snippet}
    {#snippet panel({ selected })}
      {#if selected && selected_source}
        <CodeBlock
          code={selected_source.code}
          title="{slug}.{selected_source.ext}"
          repo_link={`${repository}/blob/main/assets/${slug}/${slug}.${selected_source.ext}`}
          tex_file_uri={selected_source.ext === `tex` ? `${base_uri}.tex` : ``}
        />
      {/if}
    {/snippet}
  </Tabs>
{:else if selected_source}
  <CodeBlock
    code={selected_source.code}
    title="{slug}.{selected_source.ext}"
    repo_link={`${repository}/blob/main/assets/${slug}/${slug}.${selected_source.ext}`}
    tex_file_uri={selected_source.ext === `tex` ? `${base_uri}.tex` : ``}
  />
{/if}

<PrevNext
  items={nav_diagrams.map((diagram) => [diagram.slug, diagram])}
  current={data.slug}
  style="max-width: var(--content-max-width); margin: auto"
>
  {#snippet children({ item, kind })}
    {@const [slug, diagram] = item as [string, Diagram]}
    <div style="text-align: center">
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
    text-align: center;
  }
  h2 {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 0.35em;
  }
  p {
    text-align: center;
  }
  section {
    max-width: var(--content-max-width);
    margin: 1em auto;
    line-height: 3ex;
    text-align: center;
  }
  section.description :global(ul) {
    text-align: left;
  }
  .diagram-wrapper {
    position: relative;
    width: fit-content;
    max-width: min(850px, 90vw);
    margin: 2em auto;
    --fullscreen-btn-bg: transparent;
    --fullscreen-btn-hover-bg: transparent;
    --fullscreen-btn-color: var(--text-secondary);
    --fullscreen-btn-padding: 4pt;
  }
  :global(.diagram-wrapper .fullscreen-btn:hover) {
    color: var(--link-hover);
  }
  .diagram {
    background-color: var(--diagram-bg);
    padding: 1em;
    box-sizing: border-box;
    max-width: 100%;
    height: auto;
    max-height: 90vh;
    object-fit: scale-down;
    border-radius: 1ex;
    display: block;
  }
  .diagram-wrapper:fullscreen {
    display: grid;
    width: 100%;
    max-width: none;
    height: 100%;
    margin: 0;
    place-items: center;
  }
  .diagram-wrapper:fullscreen .diagram {
    max-height: 100%;
  }
  a.large-link {
    display: inline-flex;
    align-items: center;
    gap: 0.25em;
    background: var(--nav-bg);
    padding: 0 7pt;
    border-radius: 4pt;
    margin: 2pt;
    transition:
      color 0.3s,
      background-color 0.3s;
    font-size: 16pt;
  }
  a.large-link:hover {
    background: var(--card-bg);
  }
  a.large-link[href='.'] {
    position: absolute;
    top: 2em;
    left: 2em;
  }
  :global(.code-tabs .tabs-list) {
    display: flex;
    max-width: fit-content;
    margin: -0.5em auto 0;
    padding: 2pt;
    border-radius: 5pt;
    background: var(--nav-bg);
    border: 1px solid var(--border);
  }
  :global(.code-tabs .tabs-tab) {
    display: inline-flex;
    place-items: center;
    gap: 2pt;
    padding: 2pt 9pt;
    border: none;
    border-radius: 3pt;
    background: transparent;
    color: var(--text-secondary);
    font-size: 10pt;
    line-height: 1.2;
    cursor: pointer;
    transition:
      color 0.2s,
      background-color 0.2s;
  }
  :global(.code-tabs .tabs-tab:hover) {
    color: var(--text-color);
  }
  :global(.code-tabs .tabs-tab:focus-visible) {
    outline: 2px solid var(--link-color);
    outline-offset: 2px;
  }
  :global(.code-tabs .tabs-tab[data-state='active']) {
    color: var(--text-color);
    background: var(--button-bg);
  }
</style>
