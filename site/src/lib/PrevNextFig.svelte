<script lang="ts">
  import Icon from '@iconify/svelte'
  import Card from './Card.svelte'
  import type { TikzFigure } from './types'

  export let prev: TikzFigure
  export let next: TikzFigure
  let style = `max-width: 250px; align-content: space-around; height: 100%;`
</script>

<ul>
  <li>
    <h3>
      <a href={prev.slug}>
        <Icon icon="carbon:previous-filled" inline />
        Previous
      </a>
    </h3>
    <Card item={prev} {style} />
  </li>
  <li>
    <h3>
      <a href={next.slug}>
        Next
        <Icon icon="carbon:next-filled" inline />
      </a>
    </h3>
    <Card item={next} {style} />
  </li>
</ul>

<style>
  ul {
    display: flex;
    list-style: none;
    padding: 0;
    place-content: space-between;
    gap: 2em;
    max-width: 55em;
    margin: auto;
  }
  ul li {
    display: flex;
    flex-direction: column;
  }
</style>
