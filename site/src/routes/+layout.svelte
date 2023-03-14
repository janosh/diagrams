<script lang="ts">
  import { goto } from '$app/navigation'
  import figs from '$lib/tikz-figures.json'
  import { repository } from '$root/package.json'
  import Icon from '@iconify/svelte'
  import { CmdPalette } from 'svelte-multiselect'
  import { GitHubCorner } from 'svelte-zoo'
  import '../app.css'

  const actions = figs.map(({ title, slug }) => {
    return { label: title, action: () => goto(slug) }
  })
</script>

<CmdPalette {actions} placeholder="Go to..." />

<GitHubCorner
  href={repository}
  --zoo-github-corner-bg="white"
  --zoo-github-corner-color="var(--body-bg)"
/>

<slot />

<footer style="margin: 6em 0 3em;">
  &copy; Janosh Riebesell 2021 &ensp;-&ensp;
  <Icon icon="octicon:law" inline />
  <a href="{repository}/blob/main/license">MIT License</a>
</footer>
