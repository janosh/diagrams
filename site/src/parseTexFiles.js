import fs from 'fs'
import glob from 'glob'
import sizeOf from 'image-size'
import yaml from 'js-yaml'
import rehypeKatex from 'rehype-katex'
import rehypeStringify from 'rehype-stringify'
import remarkMath from 'remark-math'
import remarkParse from 'remark-parse'
import remarkRehype from 'remark-rehype'
import { unified } from 'unified'

const assetDir = `../assets`

const slugs = fs
  .readdirSync(assetDir)
  .filter((filename) => !filename.startsWith(`.`)) // remove hidden system files

const tikz_figures = slugs.map((slug) => {
  const downloads = glob.sync(`${assetDir}/${slug}/*.{png, pdf, svg, tex}`)

  const code = fs.readFileSync(`${assetDir}/${slug}/${slug}.tex`, `utf-8`)

  const { width, height } = sizeOf(`${assetDir}/${slug}/${slug}.png`)

  let { title, tags, description } = yaml.load(
    fs.readFileSync(`${assetDir}/${slug}/${slug}.yml`)
  )

  if (description) {
    description = unified()
      .use(remarkParse)
      .use(remarkMath)
      .use(remarkRehype)
      .use(rehypeKatex)
      .use(rehypeStringify)
      .processSync(description).value
  }

  // assemble TeX file attributes
  return { title, slug, width, height, downloads, tags, description, code }
})

fs.writeFileSync(
  `src/slugs.ts`,
  `export default ` + JSON.stringify(slugs, null, 2)
)
fs.writeFileSync(
  `src/tikz-figures.ts`,
  `export default ` + JSON.stringify(tikz_figures, null, 2)
)
