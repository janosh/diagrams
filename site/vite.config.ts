import type { YamlMetadata } from '$lib'
import { sveltekit } from '@sveltejs/kit/vite'
import { exec } from 'child_process'
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

export default {
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
} satisfies UserConfig

const figure_dirs: string[] = fs
  .readdirSync(`../assets`, { withFileTypes: true })
  .filter((itm: fs.Dirent) => itm.isDirectory())
  .map((dir: fs.Dirent) => dir.name) // remove hidden system files

const tikz_figures = figure_dirs.map((slug) => {
  const figure_basename = `../assets/${slug}/${slug}`

  const downloads = fs.readdirSync(`../assets/${slug}`)

  // check tex file exists
  const src_path = fs.existsSync(`${figure_basename}.tex`)
    ? `${figure_basename}.tex`
    : `${figure_basename}.typ`
  const code = fs.readFileSync(src_path, `utf-8`)

  const { width, height } = image_dims(`${figure_basename}.png`)
  const metadata = yaml.load(
    fs.readFileSync(`${figure_basename}.yml`).toString(),
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
  JSON.stringify(tikz_figures, null, 2),
)

exec(
  `python ../scripts/update-readme-table.py`,
  (err: string, _stdout: string, _stderr: string) => {
    if (err) console.error(err)
  },
)
