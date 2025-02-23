<script lang="ts">
  interface Props {
    tags: string[]
    font_size?: string
    margin?: string
    style?: string | null
  }

  let { tags, font_size = `9pt`, margin = `auto`, style = null }: Props = $props()
</script>

<p class="tags" style:margin {style}>
  {#each tags ?? [] as tag}
    <small style:font-size={font_size} style:line-height={font_size}>{tag}</small>
  {/each}
</p>

<style>
  p.tags {
    display: flex;
    flex-wrap: wrap;
    place-content: center;
    gap: 4pt;
    padding: 0;
  }
  p.tags small {
    background-color: rgba(255, 255, 255, 0.2);
    padding: 2pt 4pt;
    border-radius: 3pt;
  }
</style>
