<script lang="ts">
  import { filters } from './state.svelte'

  interface Props {
    tags: string[]
    [key: string]: unknown
  }
  let { tags = [], ...rest }: Props = $props()
</script>

<p class="tags" {...rest}>
  {#each tags as tag}
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
    padding: 0;
    margin: 1em;
  }
  p.tags button {
    background-color: var(--nav-bg);
    font-size: smaller;
    color: var(--text-secondary);
    padding: 2pt 4pt;
    border-radius: 3pt;
    line-height: 1;
    transition: background-color 0.2s ease;
  }
  p.tags button:hover {
    background-color: var(--card-bg);
    color: var(--text-color);
  }
</style>
