import type { YamlMetadata } from '$lib'
import { sveltekit } from '@sveltejs/kit/vite'
import * as fs from 'fs'
import image_dims from 'image-size'
import * as yaml from 'js-yaml'
import rehype_katex from 'rehype-katex'
import rehype_stringify from 'rehype-stringify'
import remark_math from 'remark-math'
import remark_parse from 'remark-parse'
import remark_rehype from 'remark-rehype'
import { unified } from 'unified'
import type { UserConfig } from 'vite'

const vite_config: UserConfig = {
  plugins: [sveltekit()],

  server: {
    fs: {
      allow: [`..`], // needed to import package.json
    },
    port: 3000,
  },

  preview: {
    port: 3000,
  },
}

export default vite_config

const figure_dirs = fs
  .readdirSync(`../assets`, { withFileTypes: true })
  .filter((itm) => itm.isDirectory())
  .map((dir) => dir.name) // remove hidden system files

const tikz_figures = figure_dirs.map((slug) => {
  const figure_basename = `../assets/${slug}/${slug}`

  const downloads = fs.readdirSync(`../assets/${slug}`)

  const code = fs.readFileSync(`${figure_basename}.tex`, `utf8`)

  const { width, height } = image_dims(`${figure_basename}.png`)
  const metadata = yaml.load(
    fs.readFileSync(`${figure_basename}.yml`).toString()
  ) as YamlMetadata

  if (metadata.description) {
    metadata.description = unified()
      .use(remark_parse)
      .use(remark_math)
      .use(remark_rehype)
      .use(rehype_katex)
      .use(rehype_stringify)
      .processSync(metadata.description).value
  }

  // assemble TeX file attributes
  return { ...metadata, slug, width, height, downloads, code }
})

fs.writeFileSync(
  `src/lib/tikz-figures.json`,
  JSON.stringify(tikz_figures, null, 2)
)
