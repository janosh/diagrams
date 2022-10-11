<script lang="ts">
  import Icon from '@iconify/svelte'
  import GitHubCorner from 'svelte-github-corner'
  import '../app.css'
  import { repo_url } from './+layout'
</script>

<GitHubCorner href={repo_url} --ghc-bg="white" --ghc-color="var(--body-bg)" />

<slot />

<footer style="margin: 6em 0 3em;">
  &copy; Janosh Riebesell 2021 &ensp;-&ensp; <Icon icon="octicon:law" inline /> MIT License
</footer>
