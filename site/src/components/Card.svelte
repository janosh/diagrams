<script lang="ts">
  import { TexFile } from '../types'
  import { fade } from 'svelte/transition'

  export let item: TexFile
  export let style = ''

  $: ({ slug, title, desc, width, height } = item)
</script>

<a href={slug} sveltekit:prefetch transition:fade={{ duration: 200 }} {style}>
  <h2 id={slug}>{title}</h2>
  <img src="assets/{slug}/{slug}.png" alt={title} {width} {height} />
  {#if desc}
    <p>{@html desc}</p>
  {/if}
</a>

<style>
  a {
    display: grid;
    place-content: center;
    border-radius: 1ex;
    cursor: pointer;
    transform-style: preserve-3d;
    background: #595975;
    transition: transform 0.5s;
  }
  a:hover {
    transform: scale(1.01);
  }
  h2 {
    margin: 1ex;
    color: white;
  }
  img {
    box-sizing: border-box;
    width: calc(100% - 2ex);
    background: #ffffff85;
    margin: 1ex;
    padding: 1ex;
    border-radius: 4pt;
    height: auto;
  }
  p {
    padding: 1ex 1em;
    position: absolute;
    bottom: 0;
    background: rgba(0, 0, 0, 0.7);
    margin: 0;
    color: white;
    visibility: hidden;
    opacity: 0;
    transition: opacity 0.5s;
    overflow-wrap: break-word;
    max-width: 100%;
    box-sizing: border-box;
    max-height: 70%;
    overflow: scroll;
    font-size: 1.5ex;
  }
  a:hover p {
    visibility: visible;
    opacity: 1;
  }
</style>
