<script lang="ts">
  import Icon from '@iconify/svelte'
  import { onMount } from 'svelte'

  let theme: `light` | `dark` = $state(`dark`)
  let next_theme = $derived(({ light: `dark`, dark: `light` } as const)[theme])

  function apply_theme(new_theme: `light` | `dark`) {
    theme = new_theme
    document.documentElement.style.colorScheme = theme
    document.documentElement.dataset.theme = theme

    // Update syntax highlighting stylesheets
    const starry_light = document.getElementById(`starry-light`)
    const starry_dark = document.getElementById(`starry-dark`)
    if (starry_light && starry_dark) {
      starry_light.media = theme === `light` ? `all` : `not all`
      starry_dark.media = theme === `dark` ? `all` : `not all`
    }
  }

  onMount(() => {
    const media_query = window.matchMedia(`(prefers-color-scheme: dark)`).matches
    const saved_theme = localStorage.theme || (media_query ? `dark` : `light`)
    apply_theme(saved_theme)
  })

  function toggle_theme() {
    apply_theme(next_theme)
    localStorage.theme = theme
  }
</script>

<button onclick={toggle_theme} title="Switch to {next_theme} theme">
  <Icon icon={{ dark: 'ph:sun-bold', light: 'ph:moon-bold' }[theme]} />
</button>

<style>
  button {
    position: fixed;
    z-index: var(--z-index-theme-toggle, 1);
    bottom: clamp(9pt, 2vw, 1.5em);
    right: clamp(9pt, 2vw, 1.5em);
    background: var(--card-bg);
    color: var(--text-color);
    border: 1px solid var(--card-border);
    box-sizing: border-box;
    width: 32pt;
    height: 32pt;
    border-radius: 50%;
    display: flex;
    place-items: center;
    place-content: center;
    box-shadow: 0 2px 8px var(--shadow);
  }
  button:hover {
    transform: scale(1.1);
    box-shadow: 0 4px 12px var(--shadow);
  }
  @media print {
    button {
      display: none;
    }
  }
</style>
