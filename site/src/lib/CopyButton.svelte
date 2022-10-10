<script lang="ts">
  import Icon from '@iconify/svelte'

  export let content: string

  let state: 'default' | 'success' | 'error' = `default`

  const labels = {
    default: [`Copy`, `octicon:copy-16`],
    success: [`Copied`, `octicon:check`],
    error: [`Error`, `octicon:alert`],
  }

  async function copy() {
    try {
      await navigator.clipboard.writeText(content)
      state = `success`
    } catch (err) {
      console.error(err)
      state = `error`
    }
    setTimeout(() => (state = `default`), 2000)
  }
</script>

<button on:click={copy}>
  <Icon icon={labels[state][1]} inline />
  <span>{labels[state][0]}</span>
</button>
