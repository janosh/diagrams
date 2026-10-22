<script lang="ts">
  import { afterNavigate, beforeNavigate, goto } from '$app/navigation'
  import { page } from '$app/state'
  import { diagrams } from '#lib'
  import { cancel_search_write, filters, write_filter_url } from '#lib/state.svelte.js'
  import favicon from '#assets/favicon.svg'
  import { repository } from '#package.json'
  import { untrack, type Snippet } from 'svelte'
  import {
    CommandMenu,
    Footer,
    GitHubCorner,
    Icon,
    ThemeScript,
    ThemeToggle,
  } from 'svelte-widgets'
  import { FileCertificate, Quote } from 'svelte-widgets/icons'
  // oxlint-disable-next-line import/no-unassigned-import -- Temml styles for description math
  import 'temml/dist/Temml-Local.css'
  // oxlint-disable-next-line import/no-unassigned-import -- global app styles
  import '../app.css'

  let { children }: { children?: Snippet<[]> } = $props()

  let navigation_ready = $state(false)
  // Wait for hydration: changing cards earlier leaves SSR image URLs paired with new dimensions.
  afterNavigate(() => {
    filters.read_url(page.url.searchParams)
    navigation_ready = true
  })
  // A pending search write must not land on the page the user is navigating to.
  beforeNavigate(cancel_search_write)
  $effect(() => {
    if (!navigation_ready) return
    void filters.url_entries // rerun on every filter change
    untrack(() => write_filter_url(page))
  })

  const actions = diagrams.map(({ title, slug }) => ({
    id: slug,
    label: title,
    action: () => goto(filters.url_for(slug)),
  }))
</script>

<ThemeScript />

<svelte:head>
  <link rel="icon" href={favicon} />
</svelte:head>

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
