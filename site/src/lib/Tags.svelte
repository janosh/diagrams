<script lang="ts">
  import { ButtonGroup } from 'svelte-widgets'
  import type { HTMLAttributes } from 'svelte/elements'
  import { filters } from './state.svelte.js'

  let { tags = [], ...rest }: HTMLAttributes<HTMLDivElement> & { tags: string[] } =
    $props()
</script>

<div class="tags" {...rest}>
  <ButtonGroup
    options={tags}
    mode="multiple"
    label="Filter by tag"
    bind:value={filters.tags}
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
    --btn-group-btn-cursor: var(--tags-cursor, pointer);
    --btn-group-justify-content: center;
  }
</style>
