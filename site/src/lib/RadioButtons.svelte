<script lang="ts">
  import { fade } from 'svelte/transition'

  export let options: (string | number)[]
  export let selected: string | number | undefined = undefined
</script>

<div transition:fade={{ duration: 150 }}>
  {#each options as value}
    <label>
      <input type="radio" bind:group={selected} {value} />
      <span>{value}</span>
    </label>
  {/each}
</div>

<style>
  div {
    display: flex;
    border-radius: 3pt;
    max-width: max-content;
    overflow: hidden;
    height: fit-content;
  }
  input {
    display: none;
  }
  span {
    cursor: pointer;
    display: inline-block;
    color: white;
    padding: 2pt 1ex;
    background: black;
    transition: 0.3s;
  }
  input:not(:checked) + span:hover {
    background: cornflowerblue;
    transform: scale(1.01);
  }
  input:checked + span {
    box-shadow: inset 0 0 1em -3pt black;
    background: darkcyan;
  }
</style>
