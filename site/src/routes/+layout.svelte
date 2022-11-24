<script lang="ts">
  import Icon from '@iconify/svelte'
  import GitHubCorner from 'svelte-github-corner'
  import { repository } from '../../package.json'
  import '../app.css'
</script>

<GitHubCorner href={repository} --ghc-bg="white" --ghc-color="var(--body-bg)" />

<slot />

<footer style="margin: 6em 0 3em;">
  &copy; Janosh Riebesell 2021 &ensp;-&ensp;
  <Icon icon="octicon:law" inline />
  <a href="{repository}/blob/main/license">MIT License</a>
</footer>
