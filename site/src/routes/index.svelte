<script lang="ts">
  import { prerendering } from '$app/env'
  import Law from '@svicons/octicons/law.svelte'
  import MarkGithub from '@svicons/octicons/mark-github.svelte'
  import Card from '../components/Card.svelte'
  import RadioButtons from '../components/RadioButtons.svelte'
  import tikz_figs from '../tikz-figures'
  import { filter_tags, tag_filter_mode, search } from '../stores'
  import MultiSelect from 'svelte-multiselect'

  let innerWidth: number

  const tags = Object.entries(
    tikz_figs
      .flatMap((file) => file.tags)
      .reduce((acc, el) => {
        acc[el] = (acc[el] ?? 0) + 1
        return acc
      }, {} as Record<string, number>)
  ).filter(([, count]) => count > 2)
  tags.sort(([a], [b]) => a.localeCompare(b))

  const clamp = (num: number, min: number, max: number) =>
    Math.min(Math.max(num, min), max)

  $: cols = clamp(Math.floor(innerWidth / 300), 1, 6)

  $: filtered_figs = tikz_figs.filter((file) => {
    const searchTerms = $search?.toLowerCase().split(` `)
    const matches_search = searchTerms?.every((term) =>
      JSON.stringify(file).toLowerCase().includes(term)
    )

    let matches_tags = true
    if ($filter_tags.length > 0) {
      if ($tag_filter_mode === `or`) {
        matches_tags = $filter_tags.some((tag) => file.tags.includes(tag.label))
      } else if ($tag_filter_mode === `and`) {
        matches_tags = $filter_tags.every((tag) => file.tags.includes(tag.label))
      }
    }
    return matches_search && matches_tags
  })
</script>

<svelte:window bind:innerWidth />

<h1>Random Tikz Collection</h1>
<p>
  {tikz_figs.length} standalone TikZ images, mostly about physics and machine learning.
</p>
<p>
  Built by <a href="https://janosh.dev">Janosh Riebesell</a>.
</p>
<p>
  <MarkGithub height="16pt" style="vertical-align: -2pt;" />&nbsp; TikZ code on
  <a href="https://github.com/janosh/tikz">GitHub</a>. &ensp;

  <Law height="16pt" style="vertical-align: -4pt;" />&nbsp;
  <a href="https://github.com/janosh/tikz/blob/main/license">MIT licensed</a>. Free to
  reuse.
</p>
<p>
  Have a TikZ image you'd like to share with attribution?
  <a href="https://github.com/janosh/tikz/pulls">Submit a PR</a> and add it to this list.
</p>

<div class="filters">
  <input name="Search" bind:value={$search} placeholder="Search..." />
  <MultiSelect
    options={tags.map(([label, count]) => ({ label, count }))}
    placeholder="Filter by tag..."
    bind:selected={$filter_tags}
  >
    <span slot="option" let:option style="display: flex; gap: 3pt;">
      {option.label} <span style="flex: 1;" />
      {option.count}
    </span>
  </MultiSelect>
  {#if $filter_tags?.length > 1}
    <RadioButtons bind:selected={$tag_filter_mode} options={[`and`, `or`]} />
  {/if}
</div>

{#if cols || prerendering}
  <div style:column-count={cols} style="column-gap: 1em;">
    {#each filtered_figs as item (item.slug)}
      <Card {item} style="margin-bottom: 1em; break-inside: avoid;" />
    {/each}
  </div>
{/if}

<style>
  h1 {
    font-size: clamp(2rem, 2rem + 2vw, 3.5rem);
  }
  p {
    font-size: 2.2ex;
  }
  input {
    outline: none;
    padding: 4px 1ex;
    border-radius: 3pt;
    color: inherit;
    background: black;
    border: 1px dashed gray;
    font-size: 16px;
  }
  input::placeholder {
    color: white;
  }
  div.filters {
    display: flex;
    flex-wrap: wrap;
    place-content: center;
    place-items: center;
    gap: 1ex 1em;
    margin: 2em;

    --sms-bg: black;
    --sms-min-width: 18em;
    --sms-max-width: 22em;
    --sms-selected-bg: rgba(255, 255, 255, 0.15);
    --sms-options-bg: #0f0422;
    --sms-border: 1px dashed gray;
    --sms-li-active-bg: rgba(255, 255, 255, 0.15);
    --sms-placeholder-color: gray;
  }
  :global(div.multiselect) {
    width: 18em;
    text-align: initial;
  }
</style>
