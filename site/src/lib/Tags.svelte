<script lang="ts">
  import { ButtonGroup } from 'svelte-widgets'
  import type { HTMLAttributes } from 'svelte/elements'
  import { filters } from './state.svelte'

  let { tags = [], ...rest }: HTMLAttributes<HTMLDivElement> & { tags: string[] } =
    $props()
</script>

<div class="tags" {...rest}>
  <ButtonGroup
    options={tags}
    multiple
    label="Filter by tag"
    bind:selected={
      () => filters.tags.map((tag) => tag.label),
      // reuse existing entries so counts picked up from the tag MultiSelect survive a toggle
      (labels) =>
        (filters.tags = labels.map(
          (label) =>
            filters.tags.find((tag) => tag.label === label) ?? { label, count: 0 },
        ))
    }
    onclick={(event) => {
      // tag rows sit inside clickable diagram cards, keep clicks off the enclosing link
      event.preventDefault()
      event.stopPropagation()
    }}
  />
</div>

<style>
  div.tags {
    display: flex;
    place-content: center;
    margin: 1em;
    font-size: 0.75em;
    --btn-group-btn-bg: var(--nav-bg);
    --btn-group-btn-hover-bg: var(--nav-bg);
    --btn-group-btn-color: var(--text-secondary);
    --btn-group-btn-padding: 2pt 4pt;
    --btn-group-btn-radius: 3pt;
  }
  /* ButtonGroup exposes no hook for its inner row's alignment or the button cursor */
  div.tags :global(.options) {
    justify-content: center;
  }
  div.tags :global(button) {
    cursor: var(--tags-cursor, pointer);
  }
</style>
