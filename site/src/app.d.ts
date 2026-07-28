/// <reference types="@sveltejs/kit" />

declare module '*package.json'

// slug -> description rendered to HTML at build time, see vite-plugin-descriptions.ts
declare module 'virtual:descriptions' {
  const descriptions: Record<string, string>
  export default descriptions
}
