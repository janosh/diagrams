<script lang="ts">
  import { goto } from '$app/navigation'
  import { page } from '$app/state'
  import { DiagramCard, diagrams, tags } from '$lib'
  import { gallery_batch_size, gallery_count_for } from '$lib/gallery'
  import { filters } from '$lib/state.svelte'
  import { homepage, repository } from '$root/package.json'
  import { tick } from 'svelte'
  import { Icon, Masonry, MultiSelect, type ObjectOption } from 'svelte-widgets'
  import { highlight_matches } from 'svelte-widgets/attachments'
  import { GitHub, LaTeX, License, Typst } from 'svelte-widgets/icons'

  const meta_description = `${diagrams.length} Diagrams on Physics, Chemistry, Computer Science, and Machine Learning`
  const update_tag_query = (label?: string) => {
    const url = new URL(page.url)
    if (label) {
      url.searchParams.set(`tag`, label)
    } else {
      url.searchParams.delete(`tag`)
    }
    goto(url, { keepFocus: true, noScroll: true, replaceState: true })
  }

  let tag_query = $state<string | null>(null)
  $effect(() => {
    const label = page.url.searchParams.get(`tag`)
    if (label === tag_query) return
    tag_query = label
    filters.tags = label ? [{ label, count: 0 }] : []
  })

  // replace the tag filter with a single tag (count is display-only, unused by filtering)
  const filter_by_tag = (label: string) => {
    filters.tags = [{ label, count: 0 }]
    update_tag_query(label)
  }

  const clear_filters = () => {
    filters.search = ``
    filters.tag_mode = `all`
    filters.tags = []
    update_tag_query()
  }

  // track the active card by slug (not index) so the highlight follows the diagram
  // across filter changes instead of pointing at a stale position
  let active_slug = $state<string>()
  let visible_count = $derived(
    gallery_count_for(gallery_batch_size, filters.filtered.length),
  )

  const observe_gallery_end = (element: HTMLElement) => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry?.isIntersecting) {
          visible_count = gallery_count_for(visible_count + 1, filters.filtered.length)
        }
      },
      { rootMargin: `800px` },
    )
    observer.observe(element)
    return () => observer.disconnect()
  }

  async function handle_keyup(event: KeyboardEvent) {
    if (event.target instanceof HTMLInputElement) return
    // filters.filtered is the shared, title-sorted view shown in the grid, so keyboard
    // nav stays in sync with what's on screen
    const shown = filters.filtered
    const count = shown.length
    if (count === 0) return
    // current is -1 when nothing is selected or the selection was filtered out
    const current = shown.findIndex((diagram) => diagram.slug === active_slug)
    if (event.key === `Enter`) {
      if (current !== -1) goto(shown[current].slug) // ignore Enter on an off-screen selection
      return
    }
    const to = {
      // wrap around; from no selection ArrowRight starts at first, ArrowLeft at last
      ArrowLeft: current === -1 ? count - 1 : (current - 1 + count) % count,
      ArrowRight: current === -1 ? 0 : (current + 1) % count,
      Escape: -1,
    }[event.key]
    // if not arrow or escape key, return early for browser default behavior
    if (to === undefined) return
    if (to >= visible_count) visible_count = gallery_count_for(to + 1, count)
    active_slug = to >= 0 ? shown[to].slug : undefined // Escape (-1) clears the selection
    // wait for the active class to apply before scrolling the selected card into view
    await tick()
    document.querySelector(`.diagram-item.active`)?.scrollIntoView({ block: `nearest` })
  }
</script>

<svelte:head>
  <meta name="description" content={meta_description} />
  <meta property="og:title" content="Scientific Diagrams" />
  <meta property="og:description" content={meta_description} />
  <meta property="og:image" content="{homepage}/index-page-2026-07-26.png" />
  <meta property="og:image:alt" content="Scientific Diagrams index page" />
  <meta property="og:url" content={homepage} />
  <meta name="twitter:card" content="summary_large_image" />
</svelte:head>

<svelte:window onkeyup={handle_keyup} />

<h1>Scientific Diagrams</h1>
<p>
  About
  {#each [`physics`, `chemistry`, `machine learning`] as tag, idx (tag)}
    {#if idx > 0},{/if}
    <button onclick={() => filter_by_tag(tag)}>
      {tag}
    </button>{/each},<br />
  <button onclick={clear_filters}>{diagrams.length} total</button>,
  <button onclick={() => filter_by_tag(`cetz`)}>
    {diagrams.filter((diagram) => diagram.code.typst).length}
  </button>
  made with
  <a href="https://cetz-package.github.io/docs/">
    <Icon icon={Typst} />CeTZ
  </a>
  and
  <button onclick={() => filter_by_tag(`tikz`)}>
    {diagrams.filter((diagram) => diagram.code.tex).length}
  </button>
  made with
  <a href="https://tikz.dev"><Icon icon={LaTeX} />TikZ</a>.
</p>
<p>
  <a href="{repository}/blob/main/license"><Icon icon={License} /> MIT licensed</a>
  (free to reuse)&ensp;
  <a href={repository}><Icon icon={GitHub} /> Repo</a>
</p>
<p style="margin: auto; max-width: 40em">
  Have a diagram you'd like to share with attribution?
  <a href="{repository}/pulls">Submit a PR</a> with a <code>.tex</code> or
  <code>.typ</code>
  file and a corresponding metadata <code>.yml</code> file in the <code>assets/</code>
  directory to add it to this list.
</p>

<div class="filters">
  {#if filters.search?.length || filters.tags?.length}
    <span style="color: var(--text-secondary)">
      {filters.filtered.length} match{filters.filtered.length != 1 ? `es` : ``}
    </span>
  {/if}
  <input name="Search" bind:value={filters.search} placeholder="Search..." />
  <MultiSelect
    options={tags.map(([label, count]) => ({ label, count }))}
    placeholder="Filter by tag..."
    bind:selected={filters.tags}
    style="max-width: 34rem; --sms-bg: var(--input-bg); --sms-options-bg: var(--page-bg)"
  >
    {#snippet option({ option }: { option: ObjectOption })}
      <span style="display: flex; justify-content: space-between; gap: 5pt; width: 100%">
        {option.label}
        {option.count}
      </span>
    {/snippet}
    {#snippet afterInput()}
      {#if filters.tags?.length > 1}
        <label style="margin-inline: 2pt">
          {#each [`all`, `any`] as value (value)}
            <input type="radio" bind:group={filters.tag_mode} {value} /> {value}
          {/each}
        </label>
      {/if}
    {/snippet}
  </MultiSelect>
</div>

<div
  class="gallery"
  {@attach highlight_matches({ query: filters.search, css_class: `highlight-match` })}
>
  <Masonry
    items={filters.filtered.slice(0, visible_count)}
    animate={false}
    idKey="slug"
    minColWidth={280}
    gap={16}
    order="column-balanced"
    role="list"
  >
    {#snippet children({ item })}
      <div class="diagram-item" class:active={item.slug === active_slug} role="listitem">
        <DiagramCard {item} style="font-size: 14pt" />
      </div>
    {/snippet}
  </Masonry>
  {#if visible_count < filters.filtered.length}
    {#key visible_count}
      <div style="height: 1px" aria-hidden="true" {@attach observe_gallery_end}></div>
    {/key}
  {/if}
</div>

<style>
  h1 {
    font-size: clamp(2rem, 2rem + 2vw, 3.5rem);
    text-align: center;
  }
  p {
    font-size: 2.2ex;
    line-height: 1.5;
    text-align: center;
  }
  .gallery {
    margin-top: 2em;
  }
  .diagram-item {
    border-radius: 1ex;
    overflow: hidden;
    border: 1px solid var(--card-border);
  }
  .diagram-item.active {
    border: 2px dashed;
  }
  input {
    outline: none;
    padding: 4px 1ex;
    border-radius: 3pt;
    color: var(--text-color);
    background: var(--input-bg);
    border: 0.5px solid var(--border);
    font-size: 16px;
  }
  input::placeholder {
    color: var(--text-color);
  }
  div.filters {
    display: flex;
    flex-wrap: wrap;
    place-content: center;
    place-items: center;
    gap: 1ex 1em;
    margin: 2em;
  }
  button {
    padding: 1pt 3pt;
    background: var(--nav-bg);
    border: none;
    border-radius: 3pt;
    color: inherit;
    font-size: inherit;
    cursor: pointer;
  }
</style>
