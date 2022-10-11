<script lang="ts">
  import { dev } from '$app/environment'
  import { fade } from 'svelte/transition'
  import type { TexFile } from '../types'
  import Tags from './Tags.svelte'

  export let item: TexFile
  export let style = ''

  // development server fetches files from local folder (specified by svelte.config.js kit.files.assets)
  // production server fetches files from GitHub (so we don't need to upload assets to netlify)
  const asset_uri = dev ? `` : `https://raw.githubusercontent.com/janosh/tikz/main/assets`
  $: base_uri = `${asset_uri}/${slug}/${slug}`
  $: ({ slug, title, description, width, height, tags } = item)
</script>

<a href={slug} transition:fade={{ duration: 200 }} {style}>
  <h2 id={slug}>{title}</h2>

  <Tags {tags} />
  <img src="{base_uri}.png" alt={title} {width} {height} />
  {#if description}
    <p class="description">{@html description}</p>
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
    color: white;
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
  p.description {
    padding: 1ex 1em;
    position: absolute;
    bottom: 0;
    background: rgba(0, 0, 0, 0.7);
    margin: 0;
    visibility: hidden;
    opacity: 0;
    transition: opacity 0.4s, visibility 0.4s;
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
