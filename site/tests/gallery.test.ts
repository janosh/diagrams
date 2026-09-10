import { render } from 'svelte/server'
import { execFileSync } from 'node:child_process'
import { readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { expect, it, vi } from 'vitest'
import { gallery_count_for } from '../src/lib/gallery'
import euler_angles from '../../assets/euler-angles/euler-angles.yml'
import euler_angles_source from '../../assets/euler-angles/euler-angles.typ?raw'
import Layout from '../src/routes/+layout.svelte'
import { load } from '../src/routes/[slug]/+page.server'
import config from '../vite.config'

vi.mock(`$lib`, () => {
  const diagrams = [
    { slug: `euler-angles`, title: `Euler Angles` },
    { slug: `euler-angles-alternative`, title: `Euler Angles` },
  ]
  return { diagrams, sorted_diagrams: diagrams }
})
vi.mock(`$app/navigation`, () => ({ goto: vi.fn() }))

it(`renders the gallery command menu with unique IDs even when titles repeat`, () => {
  expect(() => render(Layout)).not.toThrow()
})

it(`loads only the requested diagram and rejects unknown slugs`, async () => {
  const event = { params: { slug: `euler-angles` } } as Parameters<typeof load>[0]
  expect(await load(event)).toEqual({
    diagram: { slug: `euler-angles`, title: `Euler Angles` },
  })
  event.params.slug = `unknown`
  await expect(Promise.resolve().then(() => load(event))).rejects.toMatchObject({
    status: 404,
    body: { message: `Page 'unknown' not found` },
  })
})

it(`loads YAML metadata with string dates and rendered descriptions`, () => {
  expect(euler_angles.date).toBe(`2020-10-08`)
  expect(euler_angles.title).toBe(`Euler Angles`)
  expect(euler_angles.description).toMatch(/^<p>/u)
  expect(euler_angles.description).toContain(
    `<a href="../cartesian-vs-polar-coordinates">`,
  )
})

const typst_sources = import.meta.glob<string>(`../../assets/**/*.typ`, {
  eager: true,
  query: `?raw`,
  import: `default`,
})

const shared_layout_sources = Object.entries(typst_sources).filter(([path]) =>
  readFileSync(new URL(path, import.meta.url), `utf-8`).includes(`../_shared/layout.typ`),
)

it(`keeps gallery sources standalone with only package imports`, () => {
  expect(shared_layout_sources.length).toBeGreaterThan(0)
  for (const [path, source] of Object.entries(typst_sources)) {
    expect(source, path).not.toMatch(/#(?:import|include)\s+["'](?!@)/u)
  }
})

it.each(shared_layout_sources)(
  `renders copied %s exactly like its repository source`,
  // The fractal atlas can exceed 25 seconds; allow a minute for each compilation.
  { timeout: 125_000 },
  (path, source) => {
    const compile_args = [`compile`, `--format`, `svg`, `--pages`, `1`]
    const compile_options = { timeout: 60_000, maxBuffer: 32 * 1024 ** 2 }
    const standalone = execFileSync(`typst`, [...compile_args, `-`, `-`], {
      input: source,
      ...compile_options,
    })
    const repository = execFileSync(
      `typst`,
      [
        ...compile_args,
        `--root`,
        `${import.meta.dirname}/../..`,
        fileURLToPath(new URL(path, import.meta.url)),
        `-`,
      ],
      compile_options,
    )
    expect(standalone.equals(repository)).toBe(true)
  },
)

// A cold Typst package cache can exceed Vitest's default five-second limit in CI.
it(`renders coincident Euler axes without zero-length arcs`, { timeout: 30_000 }, () => {
  const source = euler_angles_source.replaceAll(
    /#let (?<angle>precession|nutation|rotation) = [^\n]+/gu,
    `#let $<angle> = 0deg`,
  )
  expect(source.match(/#let (?:precession|nutation|rotation) = 0deg/gu)).toHaveLength(3)
  execFileSync(`typst`, [`compile`, `-`, `-`], { input: source, timeout: 25_000 })
})

it(`keeps visible gallery entries complete and internal links resolvable after consolidation`, () => {
  const metadata = import.meta.glob<{ hide?: boolean; description?: string }>(
    `../../assets/**/*.yml`,
    { eager: true, import: `default` },
  )
  const files = new Set(Object.keys(import.meta.glob(`../../assets/**/*`)))
  const visible_entries = Object.entries(metadata).filter(([, data]) => !data.hide)
  const visible = new Set(visible_entries.map(([path]) => path.split(`/`).at(-2)))
  for (const [path, data] of visible_entries) {
    const base = path.slice(0, -4)
    for (const extension of [`.avif`, `.png`, `.pdf`]) {
      expect(files.has(`${base}${extension}`), `${path}: missing ${extension}`).toBe(true)
    }
    expect(files.has(`${base}-hd.png`), `${path}: obsolete HD suffix`).toBe(false)
    expect(files.has(`${base}-dark.png`), `${path}: obsolete dark PNG`).toBe(false)
    expect(files.has(`${base}.typ`) || files.has(`${base}.tex`), path).toBe(true)
    for (const match of (data.description ?? ``).matchAll(
      /href="(?:\.\.\/|https:\/\/(?:diagrams\.janosh\.dev|janosh\.github\.io\/diagrams)\/)(?<slug>[^/"#?]+)(?:["#?])/gu,
    )) {
      const slug = match.groups?.slug
      expect(visible.has(slug), `${path}: broken diagram link ${slug}`).toBe(true)
    }
  }
})

it(`matches oscillator energies and Bose occupations to a Boltzmann sum`, () => {
  const inputs = [0.1, 1, 10, 100]
  const result = JSON.parse(
    execFileSync(
      `typst`,
      [
        `eval`,
        `--root`,
        `${import.meta.dirname}/../..`,
        `--in`,
        `-`,
        `query(<values>).first().value`,
      ],
      {
        encoding: `utf8`,
        input: `
#import "/assets/quantum-harmonic-oscillator/quantum-harmonic-oscillator.typ": energy-in-quanta, energy-in-thermal-units
#import "/assets/particle-statistics/particle-statistics.typ": bose-occupation
#metadata((
  energy: (${inputs.join(`,`)}).map(energy-in-quanta),
  occupation: (${inputs.join(`,`)}).map(bose-occupation),
  classical: (0, 1e-8).map(energy-in-thermal-units),
  ground: energy-in-quanta(1000),
)) <values>`,
      },
    ),
  ) as { energy: number[]; occupation: number[]; classical: number[]; ground: number }
  for (const [idx, inverse_temperature] of inputs.entries()) {
    let partition = 0
    let occupation = 0
    for (let level = 0; level < 1000; level++) {
      const weight = Math.exp(-inverse_temperature * level)
      partition += weight
      occupation += level * weight
    }
    occupation /= partition
    // At the smallest input the omitted tail is below 4e-42; allow accumulated f64 error.
    const tolerance = 1e-12 * Math.max(1, occupation + 0.5)
    expect(Math.abs(result.energy[idx] - occupation - 0.5)).toBeLessThan(tolerance)
    expect(Math.abs(result.occupation[idx] - occupation)).toBeLessThan(tolerance)
  }
  expect(result.classical).toEqual([1, 1])
  expect(result.ground).toBe(0.5)
})

it.each([
  [`---\n\n**Visible**`, `<hr>\n<p><strong>Visible</strong></p>\n`],
  [
    `---\ntitle: Keep me\n---\nAfter`,
    expect.stringMatching(
      /^<hr>\n<h2 id="title-keep-me">title: Keep me<a data-heading-anchor[^>]* href="#title-keep-me">[\s\S]+<\/a><\/h2>\n<p>After<\/p>\n$/u,
    ),
  ],
  [`  `, null],
])(`renders YAML description %j without frontmatter`, async (description, expected) => {
  const plugin = config.plugins.find((candidate) => `transform` in candidate)
  if (!plugin || !(`transform` in plugin) || typeof plugin.transform !== `function`)
    throw new Error(`Missing YAML transform`)
  const result = await plugin.transform(
    JSON.stringify({ title: `Example`, description }),
    `${import.meta.dirname}/../../assets/complex-sign-function/complex-sign-function.yml`,
  )
  if (!result) throw new Error(`Expected YAML module`)
  const { default: data } = await import(
    /* @vite-ignore */ `data:text/javascript,${encodeURIComponent(result.code)}`
  )
  expect(data).toEqual({
    title: `Example`,
    description: expected,
    image_width: 4333,
    image_height: 3402,
  })
})

it.each([
  [1, 160, 24],
  [24, 160, 24],
  [25, 160, 48],
  [145, 160, 160],
  [24, 1, 1],
  [24, 0, 0],
])(
  `shows enough cards for a request of %i out of %i`,
  (required_count, total_count, expected_count) =>
    expect(gallery_count_for(required_count, total_count)).toBe(expected_count),
)
