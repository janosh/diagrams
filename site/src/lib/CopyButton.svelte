<script lang="ts">
  import CopyIcon from '~icons/octicon/copy-16'

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
  <CopyIcon height="14pt" style="vertical-align: -4px;" />
  <span bind:this={span}>Copy</span>
</button>
