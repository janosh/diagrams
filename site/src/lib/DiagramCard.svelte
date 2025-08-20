<script lang="ts">
  import { tooltip } from 'svelte-multiselect/attachments'
  import { fade } from 'svelte/transition'
  import { type Diagram, Tags } from './index'

  interface Props {
    item: Diagram
    format?: `short` | `full`
    [key: string]: unknown
  }
  let { item, format = `full`, ...rest }: Props = $props()
  let { slug, title, description, tags } = $derived(item)
</script>

<a href={slug} transition:fade={{ duration: 200 }} {...rest}>
  <h2 id={slug}>{title}</h2>
  {#if format === `full`}
    <Tags {tags} style="color: var(--text-color); margin-block: 0 1em" />
  {/if}
  <enhanced:img
    src={item.images.sd}
    alt={title}
    class="diagram"
    {@attach tooltip({ content: description })}
  />
</a>

<style>
  a {
    display: grid;
    place-content: center;
    cursor: pointer;
    transform-style: preserve-3d;
    background: var(--card-bg);
    transition: transform 0.5s;
    color: var(--text-color);
    border-radius: 3pt;
    box-shadow: 0 2px 8px var(--shadow);
  }
  a:hover {
    transform: scale(1.005);
  }
  h2 {
    margin: 1ex;
    line-height: 1.2;
  }
  .diagram {
    background-color: var(--diagram-bg);
    box-sizing: border-box;
    width: calc(100% - 2ex);
    display: block;
    margin: auto auto 1ex;
    padding: 1ex;
    border-radius: 4pt;
    height: auto;
  }
</style>
