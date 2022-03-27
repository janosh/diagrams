<script lang="ts">
  import { prerendering } from '$app/env'
  import Law from '@svicons/octicons/law.svelte'
  import MarkGithub from '@svicons/octicons/mark-github.svelte'
  import Card from '../components/Card.svelte'
  import texFiles from '../texFiles'

  let query: string
  let innerWidth: number

  const clamp = (num: number, min: number, max: number) =>
    Math.min(Math.max(num, min), max)

  $: filtered = texFiles.filter(
    (itm) => !query || JSON.stringify(itm).includes(query.toLowerCase())
  )
  $: cols = clamp(Math.floor(innerWidth / 300), 1, 6)
</script>

<svelte:window bind:innerWidth />

<h1>Random Tikz Collection</h1>
<p>
  {texFiles.length} standalone TikZ images, mostly about physics and machine learning.
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

<input name="Search" bind:value={query} placeholder="Search..." />

{#if cols || prerendering}
  <div style:column-count={cols} style="column-gap: 1em;">
    {#each filtered as item (item.slug)}
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
    margin-bottom: 2em;
    font-size: 2ex;
    outline: none;
    padding: 4pt 1ex;
    border-radius: 1ex;
    color: inherit;
    background: black;
    border: 1px dashed darkgrey;
  }
  input::placeholder {
    color: white;
  }
</style>
