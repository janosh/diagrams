import { render } from 'svelte/server'
import { expect, it, vi } from 'vitest'
import { gallery_count_for } from '../src/lib/gallery'
import euler_angles from '../../assets/euler-angles/euler-angles.yml'
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
