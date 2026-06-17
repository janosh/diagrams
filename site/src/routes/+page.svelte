<script lang="ts">
  import { building } from '$app/environment'
  import { goto } from '$app/navigation'
  import { page } from '$app/state'
  import { DiagramCard, diagrams, tags } from '$lib'
  import { filters } from '$lib/state.svelte'
  import { homepage, repository } from '$root/package.json'
  import Icon from '@iconify/svelte'
  import { tick } from 'svelte'
  import MultiSelect, { type ObjectOption } from 'svelte-multiselect'
  import { highlight_matches } from 'svelte-multiselect/attachments'

  let innerWidth: number = $state(0)

  const clamp = (num: number, min: number, max: number) =>
    Math.min(Math.max(num, min), max)

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

  async function handle_keyup(event: KeyboardEvent) {
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
    active_slug = to >= 0 ? shown[to].slug : undefined // Escape (-1) clears the selection
    // wait for the active class to apply before scrolling the selected card into view
    await tick()
    document.querySelector(`ul > li.active`)?.scrollIntoView({ block: `nearest` })
  }
  let cols = $derived(clamp(Math.floor(innerWidth / 300), 1, 6))
</script>

<svelte:head>
  <meta name="description" content={meta_description} />
  <meta property="og:title" content="Scientific Diagrams" />
  <meta property="og:description" content={meta_description} />
  <meta property="og:image" content="{homepage}/index-page-2021-08-04.png" />
  <meta property="og:image:alt" content="Scientific Diagrams index page" />
  <meta property="og:url" content={homepage} />
  <meta name="twitter:card" content="summary" />
</svelte:head>

<svelte:window bind:innerWidth onkeyup={handle_keyup} />

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
    <Icon icon="simple-icons:typst" inline />CeTZ
  </a>
  and
  <button onclick={() => filter_by_tag(`tikz`)}>
    {diagrams.filter((diagram) => diagram.code.tex).length}
  </button>
  made with
  <a href="https://tikz.dev"><Icon icon="simple-icons:latex" inline />TikZ</a>.
</p>
<p>
  <Icon icon="octicon:law" inline />&nbsp;
  <a href="{repository}/blob/main/license">MIT licensed</a> (free to reuse)&ensp;
  <a href={repository}><Icon icon="octicon:mark-github" inline />&nbsp;Repo</a>
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
    style="max-width: 34rem"
  >
    {#snippet option({ option }: { option: ObjectOption; idx: number })}
      <span style="display: flex; gap: 5pt; align-items: center">
        {option.label} <span style="flex: 1"></span>
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

{#if cols || building}
  <ul
    style:column-count={cols}
    style="column-gap: 1em"
    {@attach highlight_matches({ query: filters.search, css_class: `highlight-match` })}
  >
    {#each filters.filtered as item (item.slug)}
      <li class:active={item.slug === active_slug}>
        <DiagramCard {item} style="break-inside: avoid; font-size: 14pt" />
      </li>
    {/each}
  </ul>
{/if}

<style>
  h1 {
    font-size: clamp(2rem, 2rem + 2vw, 3.5rem);
  }
  p {
    font-size: 2.2ex;
    line-height: 1.5;
  }
  ul {
    list-style: none;
    padding: 0;
  }
  ul > li {
    margin-bottom: 1em;
    border-radius: 1ex;
    overflow: hidden;
    border: 1px solid var(--card-border);
  }
  ul > li.active {
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
    background-color: var(--nav-bg);
    font-size: inherit;
  }
</style>
