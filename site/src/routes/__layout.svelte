<script lang="ts">
  import GitHubCorner from 'svelte-github-corner'
  import LawIcon from '~icons/octicon/law'
  import '../app.css'
</script>

<GitHubCorner
  href="https://github.com/janosh/tikz"
  --ghc-bg="white"
  --ghc-color="var(--body-bg)"
/>

<slot />

<footer style="margin: 2em 0;">
  <small>
    <LawIcon height="14pt" style="vertical-align: middle;" /> MIT License - Janosh Riebesell
    2021
  </small>
</footer>
