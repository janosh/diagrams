/// <reference types="@sveltejs/kit" />

declare module '*tikz-figures.json' {
  const tex_files: import('./lib').TikzFigure[]
  export default tex_files
}

declare module '*package.json'
