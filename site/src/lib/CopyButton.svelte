<script lang="ts">
  import Icon from '@iconify/svelte'

  export let content: string

  let span: HTMLSpanElement

  async function copy() {
    try {
      await navigator.clipboard.writeText(content)
      span.innerText = `Copied!`
      setTimeout(() => (span.innerText = `Copy`), 2000)
    } catch (err) {
      console.error(err)
      span.innerText = `Error`
    }
  }
</script>

<button on:click={copy}>
  <Icon icon="octicon:copy-16" inline />
  <span bind:this={span}>Copy</span>
</button>
