<script lang="ts">
  import { building } from '$app/environment'
  import { goto } from '$app/navigation'
  import { Card } from '$lib'
  import { filtered_figs, filter_tags, search, tag_filter_mode } from '$lib/stores'
  import figs from '$lib/tikz-figures.json'
  import { homepage, repository } from '$root/package.json'
  import Icon from '@iconify/svelte'
  import MultiSelect from 'svelte-multiselect'
  import { RadioButtons } from 'svelte-zoo'

  let innerWidth: number
  $: cols = clamp(Math.floor(innerWidth / 300), 1, 6)

  const tags = Object.entries(
    figs
      .flatMap((file) => file.tags)
      .reduce((acc, el) => {
        acc[el] = (acc[el] ?? 0) + 1
        return acc
      }, {} as Record<string, number>)
  ).filter(([, count]) => count > 2)
  tags.sort(([a], [b]) => a.localeCompare(b))

  const clamp = (num: number, min: number, max: number) =>
    Math.min(Math.max(num, min), max)

  $: $filtered_figs = figs
    .filter((file) => {
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
    .sort((a, b) => {
      return a.title.localeCompare(b.title)
    })

  const meta_description = `Random collection of ${figs.length} TikZ figures`

  let active_idx = -1

  function handle_keyup(event: KeyboardEvent) {
    if (event.key === `Enter` && active_idx >= 0) {
      const site = figs[active_idx]
      goto(site.slug)
    }
    const to = {
      // wrap around
      ArrowLeft: (active_idx - 1 + figs.length) % figs.length,
      ArrowRight: (active_idx + 1) % figs.length,
      Escape: -1,
    }[event.key]
    if (to !== undefined && to >= 0) active_idx = to
    // keep active_idx in viewport
    const active = document.querySelector(`ul > li.active`)
    if (active) active.scrollIntoViewIfNeeded()
  }
</script>

<svelte:head>
  <meta name="description" content={meta_description} />
  <meta property="og:title" content="TikZ Diagrams on Physics and Machine Learning" />
  <meta property="og:description" content={meta_description} />
  <meta property="og:image" content="{homepage}/index-page-2021-08-04.png" />
  <meta property="og:image:alt" content="TikZ collection index page" />
  <meta property="og:url" content={homepage} />
  <meta name="twitter:card" content="summary" />
</svelte:head>

<svelte:window bind:innerWidth on:keyup={handle_keyup} />

<h1>
  Random
  <img src="favicon.svg" alt="Logo" style="height: 2em; vertical-align: middle;" />
  Collection
</h1>
<p>
  {figs.length} standalone TikZ figures, mostly about physics and machine learning.
</p>
<p>
  <Icon icon="octicon:mark-github" inline />&nbsp; TikZ code on
  <a href={repository}>GitHub</a>. &ensp;

  <Icon icon="octicon:law" inline />&nbsp;
  <a href="{repository}/blob/main/license">MIT licensed</a>. Free to reuse.
</p>
<p>
  Have a TikZ image you'd like to share with attribution?
  <a href="{repository}/pulls">Submit a PR</a> and add it to this list.
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
  <p>{$filtered_figs.length} match{$filtered_figs.length != 1 ? `es` : ``}</p>
{/if}

{#if cols || building}
  <ul style:column-count={cols} style="column-gap: 1em;">
    {#each $filtered_figs as item, idx (item.slug)}
      <li class:active={active_idx == idx}>
        <Card {item} style="break-inside: avoid;" />
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
  }
  ul {
    list-style: none;
    padding: 0;
  }
  ul > li {
    margin-bottom: 1em;
    border-radius: 1ex;
    overflow: hidden;
  }
  ul > li.active {
    border: 2px dashed;
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
    --sms-max-width: 20em;
    --sms-selected-bg: rgba(255, 255, 255, 0.15);
    --sms-options-bg: #0f0422;
    --sms-border: 1px dashed gray;
    --sms-li-active-bg: rgba(255, 255, 255, 0.15);
  }
</style>
