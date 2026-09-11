<script lang="ts">
  import { Icon, Popover } from 'svelte-widgets'
  import { Info } from 'svelte-widgets/icons'
  import type { HTMLAttributes } from 'svelte/elements'
  import { type Diagram, Tags } from './index'
  import { filters, preserve_filter_links } from './state.svelte'

  let {
    item,
    navigation = false,
    style,
    ...rest
  }: HTMLAttributes<HTMLAnchorElement> & {
    item: Diagram
    navigation?: boolean
  } = $props()
  let { slug, title, description, tags } = $derived(item)
</script>

<svelte:head>
  {#if navigation}
    <link rel="prefetch" as="image" type="image/avif" href={item.image} />
  {/if}
</svelte:head>

<div class="card" data-slug={slug} {style}>
  <a href={filters.url_for(slug)} data-diagram-link {...rest}>
    <h2 id={slug}>{title}</h2>
    {#key slug}
      <img
        src={item.thumbnail.img.src}
        srcset={item.thumbnail.sources.avif}
        width={item.thumbnail.img.w}
        height={item.thumbnail.img.h}
        sizes="(max-width: 600px) 100vw, (max-width: 1000px) 50vw, 33vw"
        loading="lazy"
        alt={title}
        class="diagram"
        data-preserve-colors={item.preserve_colors || undefined}
      />
    {/key}
  </a>
  {#if !navigation}
    <Tags {tags} style="color: var(--text-color); margin-block: 0 1em" />
  {/if}
  {#if description && !navigation}
    <Popover
      trigger_mode="hover"
      trap_focus={false}
      placement="top"
      class="diagram-description"
      style="text-align: left; font-size: 0.75em; --popover-padding: 5pt 6pt"
      aria-label={title}
    >
      {#snippet trigger(trigger_props)}
        <button type="button" aria-label="About {title}" {...trigger_props}>
          <Icon icon={Info} style="--icon-size: 18px" />
        </button>
      {/snippet}
      {#key description}
        <div {@attach preserve_filter_links}>{@html description}</div>
      {/key}
    </Popover>
  {/if}
</div>

<style>
  .card {
    position: relative;
    display: grid;
    background: var(--card-bg);
    border-radius: 3pt;
    box-shadow: 0 2px 8px var(--shadow);
    button {
      position: absolute;
      top: 0.5em;
      right: 0.5em;
      display: grid;
      place-items: center;
      padding: 0;
      border: 0;
      background: none;
      color: var(--text-color);
      cursor: pointer;
    }
    @media (hover: hover) {
      &:not(:hover, :focus-within) button:not([aria-expanded='true']) {
        opacity: 0;
        pointer-events: none;
      }
    }
  }
  a {
    display: grid;
    place-content: center;
    cursor: pointer;
    transform-style: preserve-3d;
    transition: transform 0.5s;
    color: var(--text-color);
    border-radius: 3pt;
  }
  a:focus-visible {
    outline-offset: -3px;
  }
  a:hover {
    transform: scale(1.005);
  }
  h2 {
    color: var(--text-color);
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
