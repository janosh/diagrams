import { render } from 'svelte/server'
import { execFileSync } from 'node:child_process'
import { expect, it, vi } from 'vitest'
import { gallery_count_for } from '../src/lib/gallery'
import euler_angles from '../../assets/euler-angles/euler-angles.yml'
import euler_angles_source from '../../assets/euler-angles/euler-angles.typ?raw'
import Layout from '../src/routes/+layout.svelte'
import config from '../vite.config'

vi.mock(`$lib`, () => ({
  diagrams: [
    { slug: `euler-angles`, title: `Euler Angles` },
    { slug: `euler-angles-alternative`, title: `Euler Angles` },
  ],
}))
vi.mock(`$app/navigation`, () => ({ goto: vi.fn() }))

it(`renders the gallery command menu with unique IDs even when titles repeat`, () => {
  expect(() => render(Layout)).not.toThrow()
})

it(`loads YAML metadata with string dates and rendered descriptions`, () => {
  expect(euler_angles.date).toBe(`2020-10-08`)
  expect(euler_angles.title).toBe(`Euler Angles`)
  expect(euler_angles.description).toMatch(/^<p>Named after the mathematician/u)
  expect(euler_angles.description).toContain(
    `<a href="../cartesian-vs-polar-coordinates">`,
  )
})

it(`keeps diagram sources standalone with only package imports`, () => {
  const sources = import.meta.glob<string>(`../../assets/**/*.typ`, {
    eager: true,
    query: `?raw`,
    import: `default`,
  })
  expect(Object.keys(sources).length).toBeGreaterThan(0)
  for (const [path, source] of Object.entries(sources)) {
    expect(source, path).not.toMatch(/#(?:import|include)\s+["'](?!@)/u)
  }
})

it(`renders coincident Euler axes without zero-length arcs`, () => {
  const source = euler_angles_source.replaceAll(
    /#let (?<angle>precession|nutation|rotation) = 15deg/gu,
    `#let $<angle> = 0deg`,
  )
  expect(source).not.toBe(euler_angles_source)
  expect(() =>
    execFileSync(`typst`, [`compile`, `-`, `-`], { input: source }),
  ).not.toThrow()
})

it(`keeps visible gallery entries complete and internal links resolvable after consolidation`, () => {
  const metadata = import.meta.glob<{ hide?: boolean; description?: string }>(
    `../../assets/**/*.yml`,
    { eager: true, import: `default` },
  )
  const files = new Set(Object.keys(import.meta.glob(`../../assets/**/*`)))
  const visible = new Set(
    Object.entries(metadata)
      .filter(([, data]) => !data.hide)
      .map(([path]) => path.split(`/`).at(-2)),
  )
  for (const [path, data] of Object.entries(metadata)) {
    if (data.hide) continue
    const base = path.slice(0, -4)
    for (const extension of [`.png`, `-hd.png`, `.pdf`]) {
      expect(files.has(`${base}${extension}`), `${path}: missing ${extension}`).toBe(true)
    }
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
    `<hr>\n<h2 id="title-keep-me">title: Keep me</h2>\n<p>After</p>\n`,
  ],
  [`  `, null],
])(`renders YAML description %j without frontmatter`, async (description, expected) => {
  const plugin = config.plugins.find((candidate) => `transform` in candidate)
  if (!plugin || !(`transform` in plugin) || typeof plugin.transform !== `function`)
    throw new Error(`Missing YAML transform`)
  const result = await plugin.transform(
    JSON.stringify({ title: `Example`, description }),
    `/assets/example/example.yml`,
  )
  if (!result) throw new Error(`Expected YAML module`)
  const { default: data } = await import(
    /* @vite-ignore */ `data:text/javascript,${encodeURIComponent(result.code)}`
  )
  expect(data).toEqual({ title: `Example`, description: expected })
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
