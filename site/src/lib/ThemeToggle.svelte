<script lang="ts">
  import Icon from '@iconify/svelte'
  import { onMount } from 'svelte'

  let theme: `light` | `dark` = $state(`dark`)
  let next_theme = $derived(({ light: `dark`, dark: `light` } as const)[theme])

  onMount(() => {
    theme = (localStorage.theme as `light` | `dark`) ||
      (window.matchMedia(`(prefers-color-scheme: dark)`).matches ? `dark` : `light`)
    document.documentElement.style.colorScheme = theme
  })

  function toggle_theme(): void {
    theme = next_theme
    document.documentElement.style.colorScheme = theme
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
