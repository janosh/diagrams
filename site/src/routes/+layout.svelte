<script lang="ts">
  import { base } from '$app/paths'
  import Icon from '@iconify/svelte'
  import GitHubCorner from 'svelte-github-corner'
  import '../app.css'
  import { repository, name } from '../../package.json'
</script>

<svelte:head>
  <link rel="icon" href="{base}/favicon.svg" />
  <base href={import.meta.env.CI ? `/${name}/` : ``} />
</svelte:head>

<GitHubCorner href={repository} --ghc-bg="white" --ghc-color="var(--body-bg)" />

<slot />

<footer style="margin: 6em 0 3em;">
  &copy; Janosh Riebesell 2021 &ensp;-&ensp;
  <Icon icon="octicon:law" inline />
  <a href="{repository}/blob/main/license">MIT License</a>
</footer>
