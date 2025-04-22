<script lang="ts">
  import { goto } from '$app/navigation'
  import { diagrams } from '$lib'
  import { repository } from '$root/package.json'
  import Icon from '@iconify/svelte'
  import { CmdPalette } from 'svelte-multiselect'
  import { GitHubCorner } from 'svelte-zoo'
  import '../app.css'
  import type { Snippet } from 'svelte'

  interface Props {
    children?: Snippet<[]>
  }
  let { children }: Props = $props()

  let actions = $derived(
    diagrams.map(({ title, slug }) => {
      return { label: title, action: () => goto(slug) }
    }),
  )
</script>

<CmdPalette {actions} placeholder="Go to..." />

<GitHubCorner
  href={repository}
  --zoo-gh-corner-bg="var(--text-color)"
  --zoo-gh-corner-color="var(--body-bg)"
/>

{@render children?.()}

<footer style="margin: 6em 0 3em">
  &copy; Janosh Riebesell 2021 &ensp;-&ensp;
  <Icon icon="octicon:law" inline />
  <a href="{repository}/blob/main/license">MIT License</a>
  &ensp;-&ensp;
  <Icon icon="octicon:quote" inline />
  <a href="{repository}/#--how-to-cite">How to cite</a>
</footer>
