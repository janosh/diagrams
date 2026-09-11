<script lang="ts">
  import { afterNavigate, goto } from '$app/navigation'
  import { page } from '$app/state'
  import { diagrams } from '$lib'
  import { filters, replace_url } from '$lib/state.svelte'
  import { repository } from '$root/package.json'
  import { untrack, type Snippet } from 'svelte'
  import { CommandMenu, Footer, GitHubCorner, Icon, ThemeToggle } from 'svelte-widgets'
  import { FileCertificate, Quote } from 'svelte-widgets/icons'
  import { sync_url_params } from 'svelte-widgets/url-params'
  // oxlint-disable-next-line import/no-unassigned-import -- KaTeX styles for description math
  import 'katex/dist/katex.min.css'
  // oxlint-disable-next-line import/no-unassigned-import -- global app styles
  import '../app.css'

  let { children }: { children?: Snippet<[]> } = $props()

  let navigation_ready = $state(false)
  // Wait for hydration: changing cards earlier leaves SSR image URLs paired with new dimensions.
  afterNavigate(() => {
    filters.read_url(page.url.searchParams)
    navigation_ready = true
  })
  $effect(() => {
    if (!navigation_ready) return
    const entries = filters.url_entries
    untrack(() => sync_url_params(entries, page.url, replace_url))
  })

  const actions = diagrams.map(({ title, slug }) => ({
    id: slug,
    label: title,
    action: () => goto(filters.url_for(slug)),
  }))
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
  <a href="{repository}/blob/main/license"><Icon icon={FileCertificate} /> MIT License</a>
  &ensp;&mdash;&ensp;
  <a href="{repository}/#--how-to-cite"><Icon icon={Quote} /> How to cite</a>
  &ensp;&mdash;&ensp;
  <ThemeToggle tooltip={false} />
</Footer>
