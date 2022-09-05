<script lang="ts">
  import { prerendering } from '$app/environment'
  import Card from '$lib/Card.svelte'
  import RadioButtons from '$lib/RadioButtons.svelte'
  import tikz_figs from '$lib/tikz-figures'
  import MultiSelect from 'svelte-multiselect'
  import Law from '~icons/octicon/law'
  import MarkGithub from '~icons/octicon/mark-github'
  import { filter_tags, search, tag_filter_mode } from '../stores'

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

  const meta_description = `Random collection of ${tikz_figs.length} TikZ figures`
</script>

<svelte:head>
  <meta name="description" content={meta_description} />
  <meta property="og:title" content="TikZ Diagrams on Physics and Machine Learning" />
  <meta property="og:description" content={meta_description} />
  <meta
    property="og:image"
    content="https://tikz.netlify.app/index-page-2021-08-04.png"
  />
  <meta property="og:image:alt" content="TikZ collection index page" />
  <meta property="og:url" content="https://tikz.netlify.app" />
  <meta name="twitter:card" content="summary" />
</svelte:head>

<svelte:window bind:innerWidth />

<h1>
  Random
  <img src="favicon.svg" alt="Logo" style="height: 2em; vertical-align: middle;" />
  Collection
</h1>
<p>
  {tikz_figs.length} standalone TikZ figures, mostly about physics and machine learning.
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
    <span
      slot="option"
      let:option
      style="display: flex; gap: 5pt; text-align: left; align-items: center;"
    >
      {option.label} <span style="flex: 1;" />
      {option.count}
    </span>
  </MultiSelect>
  {#if $filter_tags?.length > 1}
    <RadioButtons bind:selected={$tag_filter_mode} options={[`and`, `or`]} />
  {/if}
</div>

{#if $search?.length || $filter_tags?.length}
  <p>{filtered_figs.length} match{filtered_figs.length != 1 ? `es` : ``}</p>
{/if}

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
    --sms-max-width: 26em;
    --sms-selected-bg: rgba(255, 255, 255, 0.15);
    --sms-options-bg: #0f0422;
    --sms-border: 1px dashed gray;
    --sms-li-active-bg: rgba(255, 255, 255, 0.15);
  }
</style>
