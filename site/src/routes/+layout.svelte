<script lang="ts">
  import GitHubCorner from 'svelte-github-corner'
  import LawIcon from '~icons/octicon/law'
  import '../app.css'
  import { repo_url } from './+layout'
</script>

<GitHubCorner href={repo_url} --ghc-bg="white" --ghc-color="var(--body-bg)" />

<slot />

<footer style="margin: 2em 0;">
  <small>
    <LawIcon height="14pt" style="vertical-align: middle;" /> MIT License - Janosh Riebesell
    2021
  </small>
</footer>
