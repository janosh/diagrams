<script lang="ts">
  import { Popover } from 'svelte-widgets'
  import type { HTMLAttributes } from 'svelte/elements'
  import { type Diagram, Tags } from './index'

  let {
    item,
    format = `full`,
    prefetch = false,
    ...rest
  }: HTMLAttributes<HTMLAnchorElement> & {
    item: Diagram
    format?: `short` | `full`
    prefetch?: boolean
  } = $props()
  let { slug, title, description, tags } = $derived(item)
</script>

<svelte:head>
  {#if prefetch}
    <link rel="prefetch" as="image" type="image/avif" href={item.image} />
  {/if}
</svelte:head>

<Popover
  trigger_mode="hover"
  trap_focus={false}
  placement="top"
  class="diagram-description"
  aria-label={title}
>
  {#snippet trigger(trigger_props)}
    <a href={slug} {...rest} {...description ? trigger_props : {}}>
      <h2 id={slug}>{title}</h2>
      {#if format === `full`}
        <Tags {tags} style="color: var(--text-color); margin-block: 0 1em" />
      {/if}
      {#key slug}
        <enhanced:img
          src={item.thumbnail}
          sizes="(max-width: 600px) 100vw, (max-width: 1000px) 50vw, 33vw"
          loading="lazy"
          alt={title}
          class="diagram"
          data-preserve-colors={item.preserve_colors || undefined}
        />
      {/key}
    </a>
  {/snippet}
  {@html description ?? ``}
</Popover>

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
    text-align: center;
  }
  .diagram {
    box-sizing: border-box;
    width: calc(100% - 2ex);
    display: block;
    margin: auto auto 1ex;
    padding: 1ex;
    border-radius: 4pt;
    height: auto;
  }
  /* The popover is rendered outside the card link so description links remain usable. */
  :global(.diagram-description :is(p, ul, ol)) {
    margin-block: 0.4em;
  }
  :global(.diagram-description :is(p, ul, ol):first-child) {
    margin-block-start: 0;
  }
  :global(.diagram-description :is(p, ul, ol):last-child) {
    margin-block-end: 0;
  }
  :global(.diagram-description :is(ul, ol)) {
    padding-inline-start: 1.25em;
  }
</style>
