/// <reference types="@sveltejs/kit" />

declare module '*tikz-figures.json' {
  const tex_files: import('./types').TexFile[]
  export default tex_files
}
