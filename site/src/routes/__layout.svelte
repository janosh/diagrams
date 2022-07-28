<script lang="ts">
  import { page } from '$app/stores'
  import GitHubCorner from 'svelte-github-corner'
  import LawIcon from '~icons/octicon/law'
  import '../app.css'
</script>

{JSON.stringify($page.stuff, null, 2)}

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
