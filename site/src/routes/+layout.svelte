<script lang="ts">
  import { goto } from '$app/navigation'
  import { diagrams } from '$lib'
  import { repository } from '$root/package.json'
  import type { Snippet } from 'svelte'
  import { CommandMenu, Footer, GitHubCorner, Icon, ThemeToggle } from 'svelte-widgets'
  import { License, Quote } from 'svelte-widgets/icons'
  // oxlint-disable-next-line import/no-unassigned-import -- KaTeX styles for description math
  import 'katex/dist/katex.min.css'
  // oxlint-disable-next-line import/no-unassigned-import -- global app styles
  import '../app.css'

  let { children }: { children?: Snippet<[]> } = $props()

  let actions = $derived(
    diagrams.map(({ title, slug }) => ({ label: title, action: () => goto(slug) })),
  )
</script>

<CommandMenu {actions} placeholder="Go to..." />

<GitHubCorner
  href={repository}
  --github-corner-bg="var(--text-color)"
  --github-corner-color="var(--page-bg)"
/>

{@render children?.()}

<Footer style="margin: 6em 0 3em; text-align: center" --footer-padding="0">
  &copy; Janosh Riebesell 2021 &ensp;&mdash;&ensp;
  <a href="{repository}/blob/main/license"><Icon icon={License} /> MIT License</a>
  &ensp;&mdash;&ensp;
  <a href="{repository}/#--how-to-cite"><Icon icon={Quote} /> How to cite</a>
  &ensp;&mdash;&ensp;
  <ThemeToggle tooltip={false} style="transform: scale(1.5); vertical-align: middle;" />
</Footer>
