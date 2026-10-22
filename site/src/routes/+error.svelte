<script lang="ts">
  import { page } from '$app/state'
  import favicon from '#assets/favicon.svg'
  import { name, repository } from '#package.json'
  import { ErrorPage } from 'svelte-widgets'
</script>

<ErrorPage
  status={page.status}
  message={page.error?.message}
  {name}
  bugs_url="{repository}/issues"
  status_page_url="https://githubstatus.com"
  home_href="."
  logo={favicon}
/>
