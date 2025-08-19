<script lang="ts">
  import { building } from '$app/environment'
  import { goto } from '$app/navigation'
  import { DiagramCard, diagrams, tags } from '$lib'
  import { filtered_diagrams, filters } from '$lib/state.svelte'
  import { homepage, repository } from '$root/package.json'
  import Icon from '@iconify/svelte'
  import MultiSelect, { type ObjectOption } from 'svelte-multiselect'
  import { highlight_matches } from 'svelte-multiselect/attachments'

  let innerWidth: number = $state(0)

  const clamp = (num: number, min: number, max: number) =>
    Math.min(Math.max(num, min), max)

  const meta_description =
    `${diagrams.length} Diagrams on Physics, Chemistry, Computer Science, and Machine Learning`

  let active_diagram = $state(-1)

  function handle_keyup(event: KeyboardEvent) {
    if (event.key === `Enter` && active_diagram >= 0) {
      const site = diagrams[active_diagram]
      goto(site.slug)
    }
    const to = {
      // wrap around
      ArrowLeft: (active_diagram - 1 + diagrams.length) % diagrams.length,
      ArrowRight: (active_diagram + 1) % diagrams.length,
      Escape: -1,
    }[event.key]
    // if not arrow or escape key, return early for browser default behavior
    if (to === undefined) return
    if (to >= 0) active_diagram = to
    // keep active_idx in viewport
    const active = document.querySelector(`ul > li.active`)
    if (active) active.scrollIntoView()
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

<h1>
  {diagrams.length} Scientific Diagrams
</h1>
<p>
  About
  {#each [`physics`, `chemistry`, `machine learning`] as tag, idx}
    {#if idx > 0},{/if}
    <button onclick={() => (filters.tags = [{ label: tag, count: 0 }])}>
      {tag}
    </button>{/each},<br />
  <button onclick={() => (filters.tags = [{ label: `cetz`, count: 0 }])}>
    {diagrams.filter((diagram) => diagram.code.typst).length}
  </button>
  of which in
  <a href="https://cetz-package.github.io/docs/">CeTZ</a>
  (Typst) and
  <button onclick={() => (filters.tags = [{ label: `tikz`, count: 0 }])}>
    {diagrams.filter((diagram) => diagram.code.tex).length}
  </button>
  in
  <a href="https://tikz.dev">TikZ</a> (LaTeX) diagrams.
</p>
<p>
  <Icon icon="octicon:law" inline />&nbsp;
  <a href="{repository}/blob/main/license">MIT licensed</a> (free to reuse)&ensp;
  <a href={repository}><Icon icon="octicon:mark-github" inline />&nbsp;Repo</a>
</p>
<p style="margin: auto; max-width: 40em">
  Have a TikZ image you'd like to share with attribution?
  <a href="{repository}/pulls">Submit a PR</a> with a <code>.tex</code> or
  <code>.typ</code>
  file and a corresponding metadata <code>.yml</code> file in the <code>assets/</code>
  directory to add it to this list. Also be sure to add yourself to the
  <a href="{repository}/blob/main/citation.cff"><code>citation.cff</code></a> file.
</p>

<div class="filters">
  <input name="Search" bind:value={filters.search} placeholder="Search..." />
  <MultiSelect
    options={tags.map(([label, count]) => ({ label, count }))}
    placeholder="Filter by tag..."
    bind:selected={filters.tags}
  >
    {#snippet option({ option, idx }: { option: ObjectOption; idx: number })}
      <span style="display: flex; gap: 5pt; align-items: center">
        {option.label} <span style="flex: 1"></span> {option.count}
      </span>
    {/snippet}
    {#snippet afterInput()}
      {#if filters.tags?.length > 1}
        <label style="margin-inline: 2pt">
          <input type="checkbox" bind:checked={filters.tag_mode} />
          has {filters.tag_mode ? 'all' : 'any'}
        </label>
      {/if}
    {/snippet}
  </MultiSelect>
</div>

{#if filters.search?.length || filters.tags?.length}
  <p>
    {filtered_diagrams().length} match{filtered_diagrams().length != 1 ? `es` : ``}
  </p>
{/if}

{#if cols || building}
  <ul
    style:column-count={cols}
    style="column-gap: 1em"
    {@attach highlight_matches({ query: filters.search, css_class: `highlight-match` })}
  >
    {#each filtered_diagrams() as item, idx (item.slug)}
      <li class:active={active_diagram == idx}>
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
