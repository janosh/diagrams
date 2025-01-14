<script lang="ts">
  import { fade } from 'svelte/transition'
  import type { Diagram } from '.'
  import { Tags } from '.'

  export let item: Diagram
  export let style = ``
  export let format: `short` | `full` = `full`

  $: ({ slug, title, description, tags } = item)
</script>

<a href={slug} transition:fade={{ duration: 200 }} {style}>
  <h2 id={slug}>{title}</h2>
  <Tags {tags} />
  <enhanced:img src={item.images.sd} alt={title} class="diagram" />
  {#if description && format === `full`}
    <p class="description">{@html description}</p>
  {/if}
</a>

<style>
  a {
    display: grid;
    place-content: center;
    cursor: pointer;
    transform-style: preserve-3d;
    background: #595975;
    transition: transform 0.5s;
    color: var(--text-color);
    border-radius: 3pt;
  }
  a:hover {
    transform: scale(1.005);
  }
  h2 {
    margin: 4pt 1ex 1ex;
  }
  .diagram {
    box-sizing: border-box;
    width: calc(100% - 2ex);
    background: #ffffff85;
    margin: 2ex 1ex 1ex;
    padding: 1ex;
    border-radius: 4pt;
    height: auto;
  }
  p.description {
    padding: 1ex 1em;
    position: absolute;
    bottom: 0;
    background: rgba(0, 0, 0, 0.7);
    margin: 0;
    visibility: hidden;
    opacity: 0;
    transition:
      opacity 0.4s,
      visibility 0.4s;
    overflow-wrap: break-word;
    width: 100%;
    box-sizing: border-box;
    max-height: 50%;
    overflow: scroll;
    font-size: 1.5ex;
  }
  a:hover p.description {
    visibility: visible;
    opacity: 1;
  }
</style>
