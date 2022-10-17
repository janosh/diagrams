/// <reference types="@sveltejs/kit" />

declare module '*tikz-figures.json' {
  const tex_files: import('./types').TikzFigure[]
  export default tex_files
}
