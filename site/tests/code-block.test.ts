import { render } from 'svelte/server'
import { expect, it } from 'vitest'
import CodeBlock from '../src/lib/CodeBlock.svelte'

it.each([
  [`example.typ`, `#let value = 1 < 2`, `#let value = 1 &lt; 2`],
  [`example.tex`, `\\text{<tag>}`, `\\text{&lt;tag>}`],
])(
  `renders escaped source in a keyboard-accessible region for %s before highlighting finishes`,
  (title, code, escaped_code) => {
    const { body } = render(CodeBlock, { props: { title, code, repo_link: `` } })
    expect(body).toContain(escaped_code)
    expect(body).not.toContain(`<tag>`)
    expect(body).toContain(`<pre role="region" aria-label="${title}" tabindex="0"`)
  },
)
