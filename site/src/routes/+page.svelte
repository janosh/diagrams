<script lang="ts">
  import { goto } from '$app/navigation'
  import type { Snapshot } from '@sveltejs/kit'
  import { DiagramCard, diagrams, tags } from '$lib'
  import { gallery_batch_size, gallery_count_for } from '$lib/gallery'
  import { filters } from '$lib/state.svelte'
  import { homepage, repository } from '$root/package.json'
  import { tick } from 'svelte'
  import { Icon, Masonry, MultiSelect } from 'svelte-widgets'
  import { highlight_matches } from 'svelte-widgets/attachments'
  import { GitHub, LaTeX, License, Typst } from 'svelte-widgets/icons'

  const meta_description = `${diagrams.length} Diagrams on Physics, Chemistry, Computer Science, and Machine Learning`

  // Replace the tag filter with a single tag.
  const filter_by_tag = (label: string) => {
    filters.tags = [label]
  }

  const clear_filters = () => filters.read_url(new URLSearchParams())
  let search_input = $state<HTMLInputElement>()

  // track the active card by slug (not index) so the highlight follows the diagram
  // across filter changes instead of pointing at a stale position
  let active_slug = $state<string>()
  let visible_count = $derived(
    gallery_count_for(gallery_batch_size, filters.filtered.length),
  )
  let gallery = $state<HTMLDivElement>()
  const gallery_link = (slug: string) =>
    gallery?.querySelector<HTMLAnchorElement>(`[data-slug="${CSS.escape(slug)}"] > a`)
  type GallerySnapshot = {
    visible_count: number
    active_slug?: string
    scroll_x: number
    scroll_y: number
  }
  let restoring = $state<GallerySnapshot>()
  const cancel_restoration = () => {
    restoring = undefined
  }
  export const snapshot: Snapshot<GallerySnapshot> = {
    capture: () => ({ visible_count, active_slug, scroll_x: scrollX, scroll_y: scrollY }),
    restore: (saved) => {
      visible_count = saved.visible_count
      active_slug = saved.active_slug
      restoring = saved
    },
  }

  // Kit restores snapshots after scrolling. Keep the saved position through late image
  // measurements, until the user resumes interacting with the gallery.
  $effect(() => {
    if (!restoring || !gallery) return
    const { active_slug: saved_slug, scroll_x, scroll_y } = restoring
    if (saved_slug) gallery_link(saved_slug)?.focus({ preventScroll: true })
    const observer = new ResizeObserver(() => window.scrollTo(scroll_x, scroll_y))
    observer.observe(gallery)
    return () => observer.disconnect()
  })

  const observe_gallery_end = (element: HTMLElement) => {
    if (restoring) return
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

  async function handle_keydown(event: KeyboardEvent) {
    cancel_restoration()
    if (
      event.defaultPrevented ||
      event.altKey ||
      event.ctrlKey ||
      event.metaKey ||
      event.shiftKey
    )
      return
    const target = event.target
    const card_link =
      target instanceof Element && target.closest(`.gallery a[data-diagram-link]`)
    if (
      target instanceof Element &&
      !card_link &&
      target.closest(
        `a, button, input, select, textarea, [contenteditable]:not([contenteditable='false']), [role='dialog'], [role='combobox'], [role='menu']`,
      )
    )
      return
    // filters.filtered is the shared, title-sorted view shown in the grid, so keyboard
    // nav stays in sync with what's on screen
    const shown = filters.filtered
    const count = shown.length
    if (count === 0) return
    // current is -1 when nothing is selected or the selection was filtered out
    const current = shown.findIndex((diagram) => diagram.slug === active_slug)
    if (event.key === `Enter`) {
      // Focused links keep native Enter and modifier-click behavior.
      if (!card_link && current !== -1) {
        event.preventDefault()
        goto(filters.url_for(shown[current].slug))
      }
      return
    }
    const to = {
      // wrap around; from no selection ArrowRight starts at first, ArrowLeft at last
      ArrowLeft: current === -1 ? count - 1 : (current - 1 + count) % count,
      ArrowRight: (current + 1) % count,
      Escape: -1,
    }[event.key]
    // if not arrow or escape key, return early for browser default behavior
    if (to === undefined) return
    event.preventDefault()
    if (to >= visible_count) visible_count = gallery_count_for(to + 1, count)
    active_slug = to >= 0 ? shown[to].slug : undefined // Escape (-1) clears the selection
    // wait for the active class to apply before scrolling the selected card into view
    await tick()
    if (active_slug) {
      const link = gallery_link(active_slug)
      link?.focus({ preventScroll: true })
      link?.scrollIntoView({ block: `nearest` })
    }
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

<svelte:window
  onkeydown={handle_keydown}
  onpointerdown={cancel_restoration}
  onwheel={cancel_restoration}
  ontouchstart={cancel_restoration}
/>

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
    {diagrams.filter((diagram) => diagram.source_types.includes(`typ`)).length}
  </button>
  made with
  <a href="https://cetz-package.github.io/docs/">
    <Icon icon={Typst} />CeTZ
  </a>
  and
  <button onclick={() => filter_by_tag(`tikz`)}>
    {diagrams.filter((diagram) => diagram.source_types.includes(`tex`)).length}
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
  <span
    role="status"
    aria-live="polite"
    aria-atomic="true"
    style="color: var(--text-secondary)"
  >
    {filters.filtered.length} match{filters.filtered.length != 1 ? `es` : ``}
  </span>
  <input
    name="Search"
    aria-label="Search diagrams"
    bind:this={search_input}
    bind:value={filters.search}
    placeholder="Search..."
  />
  <MultiSelect
    input_props={{ 'aria-label': `Filter by tag` }}
    options={tags}
    placeholder="Filter by tag..."
    bind:value={filters.tags}
    style="max-width: 34rem; --sms-bg: var(--input-bg); --sms-options-bg: var(--page-bg)"
  >
    {#snippet option({ option })}
      <span style="display: flex; justify-content: space-between; gap: 5pt; width: 100%">
        {option}
        <span title="Matching diagrams after adding this tag"
          >{filters.tag_counts.get(option)}</span
        >
      </span>
    {/snippet}
    {#snippet after_input()}
      {#if filters.tags.length > 1}
        <span role="group" aria-label="Match selected tags" style="margin-inline: 2pt">
          {#each [`all`, `any`] as value (value)}
            <label
              ><input type="radio" bind:group={filters.tag_mode} {value} /> {value}</label
            >
          {/each}
        </span>
      {/if}
    {/snippet}
  </MultiSelect>
</div>

<div
  class="gallery"
  bind:this={gallery}
  {@attach highlight_matches({ query: filters.search, css_class: `highlight-match` })}
>
  {#if filters.filtered.length === 0}
    <div class="empty-results">
      <h2>No matching diagrams</h2>
      <p>Try a different search or reset the filters.</p>
      <div style="display: flex; justify-content: center; gap: 1em">
        {#if filters.search}
          <button
            onclick={() => {
              filters.search = ``
              search_input?.focus()
            }}>Clear search</button
          >
        {/if}
        <button
          onclick={() => {
            clear_filters()
            search_input?.focus()
          }}>Reset filters</button
        >
      </div>
    </div>
  {/if}
  <!-- Keep existing cards in their columns when measurements arrive or more cards load. -->
  <Masonry
    items={filters.filtered.slice(0, visible_count)}
    animate={false}
    id_key="slug"
    min_col_width={280}
    gap={16}
    order="row-first"
    role="list"
  >
    {#snippet children({ item })}
      <div class="diagram-item" class:active={item.slug === active_slug} role="listitem">
        <DiagramCard
          {item}
          onfocus={() => (active_slug = item.slug)}
          style="font-size: 14pt"
        />
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
  .empty-results {
    margin: 3em auto;
    text-align: center;
    h2 {
      margin-bottom: 0;
    }
    button {
      padding: 0.5em 1em;
    }
  }
  .diagram-item {
    border-radius: 1ex;
    overflow: hidden;
    border: 1px solid var(--card-border);
  }
  .diagram-item.active {
    outline: 2px dashed var(--link-color);
    outline-offset: -2px;
  }
  input {
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
