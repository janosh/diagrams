import fs from 'fs'
import glob from 'glob'
import image_dims from 'image-size'
import yaml from 'js-yaml'
import rehype_katex from 'rehype-katex'
import rehype_stringify from 'rehype-stringify'
import remark_math from 'remark-math'
import remark_parse from 'remark-parse'
import remark_rehype from 'remark-rehype'
import { unified } from 'unified'

const asset_dir = `../assets`

const figure_dirs = fs
  .readdirSync(asset_dir, { withFileTypes: true })
  .filter((itm) => itm.isDirectory())
  .map((dir) => dir.name) // remove hidden system files

const tikz_figures = figure_dirs.map((slug) => {
  const figure_dir_path = `${asset_dir}/${slug}/${slug}`

  const downloads = glob
    .sync(`${figure_dir_path}*.{png,pdf,svg,tex}`)
    .map((str) => str.split(`/`).at(-1))

  const code = fs.readFileSync(`${figure_dir_path}.tex`, `utf8`)

  const { width, height } = image_dims(`${figure_dir_path}.png`)
  const metadata = yaml.load(fs.readFileSync(`${figure_dir_path}.yml`))

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
  `src/lib/tikz-figures.ts`,
  `export default ` + JSON.stringify(tikz_figures, null, 2)
)
