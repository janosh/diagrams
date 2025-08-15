<script lang="ts">
  interface Props {
    tags: string[]
    [key: string]: unknown
  }
  let { tags = [], ...rest }: Props = $props()
</script>

<p class="tags" {...rest}>
  {#each tags as tag}
    <small>{tag}</small>
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
  p.tags small {
    background-color: var(--nav-bg);
    color: var(--text-secondary);
    padding: 2pt 4pt;
    border-radius: 3pt;
    line-height: 1;
    transition: background-color 0.2s ease;
  }
  p.tags small:hover {
    background-color: var(--card-bg);
    color: var(--text-color);
  }
</style>
