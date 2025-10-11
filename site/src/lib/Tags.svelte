<script lang="ts">
  import type { HTMLAttributes } from 'svelte/elements'
  import { filters } from './state.svelte'

  interface Props extends HTMLAttributes<HTMLParagraphElement> {
    tags: string[]
    btn_props?: HTMLAttributes<HTMLButtonElement>
  }
  let { tags = [], btn_props = {}, ...rest }: Props = $props()
</script>

<p class="tags" {...rest}>
  {#each tags as tag (tag)}
    <button
      onclick={(event) => {
        event.preventDefault()
        event.stopPropagation()
        if (filters.tags.some((t) => t.label === tag)) {
          filters.tags = filters.tags.filter((t) => t.label !== tag)
        } else {
          filters.tags = [...filters.tags, { label: tag, count: 0 }]
        }
      }}
      {...btn_props}
    >
      {tag}
    </button>
  {/each}
</p>

<style>
  p.tags {
    display: flex;
    flex-wrap: wrap;
    place-content: center;
    gap: 4pt;
    margin: 1em;
  }
  p.tags button {
    background-color: var(--nav-bg);
    font-size: smaller;
    color: var(--text-secondary);
    padding: 2pt 4pt;
    border-radius: 3pt;
  }
</style>
