import { expect, test, type Locator, type Page } from '@playwright/test'
// oxlint-disable vitest/prefer-each -- Playwright uses loops for parameterization and has no test.each.

// The production pages are the fixtures: retain native fullscreen, real images, and CSS.
const open_diagram = async (page: Page, slug: string) => {
  await page.goto(`/${slug}`, { waitUntil: `domcontentloaded` })
  await expect(page.getByRole(`heading`, { level: 1 })).not.toBeEmpty()
  await expect(page.locator(`.diagram-wrapper source`).first()).toHaveAttribute(
    `srcset`,
    /^\S+ \d+w(?:, \S+ \d+w)*$/u,
  )
  const diagram = page.locator(`.diagram-wrapper img`)
  await expect(diagram).toBeVisible()
  await expect
    .poll(() =>
      diagram.evaluate(
        (image: HTMLImageElement) => image.complete && image.naturalWidth > 0,
      ),
    )
    .toBe(true)
  await page.evaluate(() => document.fonts.ready)
  return page.locator(`.diagram-wrapper`)
}

const set_theme = async (page: Page, theme: `light` | `dark`) => {
  await page.evaluate((next_theme) => {
    document.documentElement.dataset.theme = next_theme
    document.documentElement.style.colorScheme = next_theme
  }, theme)
  // Wait for the body's theme transition before comparing it with a fullscreen element.
  await expect(page.locator(`body`)).toHaveCSS(
    `background-color`,
    theme === `light` ? `rgb(248, 249, 250)` : `rgb(9, 0, 25)`,
  )
}

const enter_fullscreen = async (wrapper: Locator) => {
  await wrapper.getByRole(`button`, { name: `Enter fullscreen` }).click()
  await expect
    .poll(() => wrapper.evaluate((element) => element === document.fullscreenElement))
    .toBe(true)
}

test.beforeEach(async ({ page }) => {
  // Analytics is irrelevant to screenshots and must not depend on external availability.
  await page.route(`https://plausible.io/**`, (route) => route.abort())
})

test(`gallery descriptions preserve rich links and open from keyboard focus`, async ({
  page,
}) => {
  await page.goto(`/`, { waitUntil: `domcontentloaded` })
  await page.getByPlaceholder(`Search...`, { exact: true }).fill(`Euler Angles`)
  const card = page.locator(`a[href="euler-angles"]`).first()
  await card.focus()
  const description = page.getByRole(`dialog`, { name: `Euler Angles` })
  await expect(description).toBeVisible()
  await expect(
    description.locator(`a[href="../cartesian-vs-polar-coordinates"]`),
  ).toBeVisible()
  expect(await description.evaluate((element) => element.closest(`a`))).toBeNull()
  await page.keyboard.press(`Escape`)
  await expect(description).toBeHidden()
})

for (const direction of [`Next`, `Previous`]) {
  test(`${direction} navigation clears old artwork while the new image loads`, async ({
    page,
  }) => {
    let release_images = () => {}
    const images_released = new Promise<void>((resolve) => {
      release_images = resolve
    })
    await page.route(`**/*`, async (route) => {
      const url = route.request().url()
      if (
        route.request().resourceType() === `image` &&
        url.includes(`-hd`) &&
        !url.includes(`euler-angles`)
      )
        await images_released
      await route.fallback()
    })
    try {
      const wrapper = await open_diagram(page, `euler-angles`)
      // Exercise a handler first so navigation happens after hydration.
      await enter_fullscreen(wrapper)
      await wrapper.getByRole(`button`, { name: `Exit fullscreen` }).click()
      const artwork = page.locator(`.diagram-wrapper img, .prev-next img`)
      await expect(artwork).toHaveCount(3)
      const old_images = await artwork.elementHandles()
      const nav_link = page.getByRole(`link`, { name: new RegExp(direction) })
      const target = await nav_link.getAttribute(`href`)
      if (!target) throw new Error(`Missing ${direction} navigation target`)
      const preloaded_srcset = await page
        .locator(`head link[rel="preload"][as="image"]`)
        .evaluateAll((links) =>
          links.map((link) =>
            link.getAttribute(`imagesrcset`)?.replaceAll(location.origin, ``),
          ),
        )
      await nav_link.click()
      await expect(page).toHaveURL(new RegExp(`/${target}$`))
      await expect(wrapper.locator(`img`)).not.toHaveAttribute(`alt`, `Euler Angles`)
      for (const image of old_images) {
        expect(await image.evaluate((element) => element.isConnected)).toBe(false)
      }
      const new_image = wrapper.locator(`img`)
      await expect(new_image).toHaveJSProperty(`naturalWidth`, 0)
      expect(preloaded_srcset).toContain(
        await wrapper.locator(`source[type="image/avif"]`).getAttribute(`srcset`),
      )
      release_images()
      await expect(new_image).toHaveJSProperty(`complete`, true)
      await expect(new_image).not.toHaveJSProperty(`naturalWidth`, 0)
      await enter_fullscreen(wrapper)
      await wrapper.getByRole(`button`, { name: `Exit fullscreen` }).click()
    } finally {
      release_images()
    }
  })
}

for (const theme of [`light`, `dark`] as const) {
  test(`transparent diagram keeps its background in fullscreen (${theme})`, async ({
    page,
  }) => {
    const wrapper = await open_diagram(page, `euler-angles`)
    await set_theme(page, theme)
    await expect(wrapper.locator(`img`)).toHaveCSS(
      `filter`,
      theme === `dark` ? `invert(0.9) hue-rotate(180deg)` : `none`,
    )
    await expect(wrapper.locator(`img`)).toHaveCSS(`background-color`, `rgba(0, 0, 0, 0)`)
    await enter_fullscreen(wrapper)
    await expect(wrapper).toHaveJSProperty(`scrollTop`, 0)
    for (const next_theme of [theme === `light` ? `dark` : `light`, theme] as const) {
      await set_theme(page, next_theme)
      const page_bg = await page
        .locator(`body`)
        .evaluate((body) => getComputedStyle(body).backgroundColor)
      await expect(wrapper).toHaveCSS(`background-color`, page_bg)
      await expect(wrapper.locator(`img`)).toHaveCSS(
        `filter`,
        next_theme === `dark` ? `invert(0.9) hue-rotate(180deg)` : `none`,
      )
    }
    await wrapper.getByRole(`button`, { name: `Exit fullscreen` }).click()
    await expect.poll(() => page.evaluate(() => document.fullscreenElement)).toBeNull()
  })

  test(`tall diagram scrolls with a reachable exit (${theme})`, async ({ page }) => {
    const wrapper = await open_diagram(page, `xc-functional`)
    const artwork = wrapper.locator(`img`)
    const normal_size = await artwork.evaluate((image: HTMLImageElement) => {
      const {
        paddingLeft: padding_left,
        paddingRight: padding_right,
        paddingTop: padding_top,
        paddingBottom: padding_bottom,
      } = getComputedStyle(image)
      return {
        // eslint-disable-next-line unicorn/prefer-number-coercion -- Computed CSS lengths include px.
        width: image.clientWidth - parseFloat(padding_left) - parseFloat(padding_right),
        // eslint-disable-next-line unicorn/prefer-number-coercion -- Computed CSS lengths include px.
        height: image.clientHeight - parseFloat(padding_top) - parseFloat(padding_bottom),
        aspect: image.naturalHeight / image.naturalWidth,
      }
    })
    // Use the available width; fitting tall artwork into one viewport makes text tiny.
    expect(normal_size.height).toBeGreaterThan(720)
    expect(
      Math.abs(normal_size.height - normal_size.width * normal_size.aspect),
    ).toBeLessThanOrEqual(1) // client dimensions round to whole CSS pixels.
    await set_theme(page, theme)
    await enter_fullscreen(wrapper)
    const top_bounds = await artwork.boundingBox()
    if (!top_bounds) throw new Error(`Missing fullscreen artwork bounds`)
    expect(top_bounds.y).toBeGreaterThanOrEqual(0)
    expect(top_bounds.y).toBeLessThanOrEqual(1)
    expect(top_bounds.height).toBeGreaterThan(720)
    expect(top_bounds.x).toBeGreaterThanOrEqual(0)
    expect(top_bounds.x + top_bounds.width).toBeLessThanOrEqual(1280)
    // Navigate from the entry button instead of forcing focus onto an unfocusable region.
    await page.keyboard.press(`Shift+Tab`)
    await expect(wrapper).toBeFocused()
    await expect(wrapper).toHaveCSS(`outline-style`, `solid`)
    // Install the listener before sending input; an unawaited evaluate can miss scrollend.
    await wrapper.evaluate((element) => {
      element.addEventListener(
        `scrollend`,
        () => element.setAttribute(`data-scroll-ended`, ``),
        {
          once: true,
        },
      )
    })
    await page.keyboard.press(`PageDown`)
    await expect
      .poll(() => wrapper.evaluate((element) => element.scrollTop))
      .toBeGreaterThan(0)
    await expect(wrapper).toHaveAttribute(`data-scroll-ended`, ``)
    await page.mouse.move(640, 360)
    await page.mouse.wheel(0, 10000)
    await expect
      .poll(() =>
        wrapper.evaluate(
          (element) => element.scrollHeight - element.scrollTop - element.clientHeight,
        ),
      )
      .toBeLessThanOrEqual(1)
    const bottom_bounds = await artwork.boundingBox()
    if (!bottom_bounds) throw new Error(`Missing scrolled artwork bounds`)
    expect(Math.abs(bottom_bounds.y + bottom_bounds.height - 720)).toBeLessThanOrEqual(1)
    await expect(wrapper.getByRole(`button`, { name: `Exit fullscreen` })).toBeInViewport(
      { ratio: 1 },
    )
    await expect(page).toHaveScreenshot(`xc-fullscreen-bottom-${theme}.png`)
    await wrapper.getByRole(`button`, { name: `Exit fullscreen` }).click()
    await expect.poll(() => page.evaluate(() => document.fullscreenElement)).toBeNull()
  })
}

test(`theme overrides apply to cards while atom surface colors stay fixed`, async ({
  page,
}) => {
  await page.emulateMedia({ colorScheme: `dark` })
  await page.addInitScript(() => localStorage.setItem(`theme`, `dark`))
  await page.goto(`/`)
  // The persisted mode is applied during hydration; wait before overriding it.
  await expect(page.getByRole(`button`, { name: `Switch to light theme` })).toBeVisible()
  await page
    .getByPlaceholder(`Search...`, { exact: true })
    .fill(`Feynman Building Blocks`)
  const artwork = page.locator(`a[href='feynman-building-blocks'] img`)
  await artwork.hover()
  const description = page.getByRole(`dialog`, { name: `Feynman Building Blocks` })
  await expect(description.locator(`p`)).toContainText(`Lines connect fields`)
  await page.keyboard.press(`Escape`)
  await expect(description).toBeHidden()
  await page.getByRole(`button`, { name: `Switch to light theme` }).click()
  await page.getByRole(`button`, { name: `Switch to system (auto) theme` }).click()
  await expect(artwork).toHaveCSS(`filter`, `invert(0.9) hue-rotate(180deg)`)
  await page.emulateMedia({ colorScheme: `light` })
  await expect(artwork).toHaveCSS(`filter`, `none`)
  await page.emulateMedia({ colorScheme: `dark` })
  await expect(artwork).toHaveCSS(`filter`, `invert(0.9) hue-rotate(180deg)`)
  for (const theme of [`light`, `dark`] as const) {
    await set_theme(page, theme)
    await expect(artwork).toHaveCSS(
      `filter`,
      theme === `dark` ? `invert(0.9) hue-rotate(180deg)` : `none`,
    )
  }
  const wrapper = await open_diagram(page, `sierpinski-triangle`)
  await set_theme(page, `dark`)
  await expect(wrapper.locator(`img`)).toHaveCSS(`filter`, `none`)
})

test(`a diagram that fits remains centered`, async ({ page }) => {
  await page.setViewportSize({ width: 1280, height: 2000 })
  const wrapper = await open_diagram(page, `xc-functional`)
  await enter_fullscreen(wrapper)
  const bounds = await wrapper.locator(`img`).boundingBox()
  if (!bounds) throw new Error(`Fullscreen diagram has no bounding box`)
  expect(bounds.y).toBeGreaterThan(0)
  // Browser subpixel layout may distribute at most one CSS pixel asymmetrically.
  expect(Math.abs(bounds.y - (2000 - bounds.y - bounds.height))).toBeLessThanOrEqual(1)
  expect(await wrapper.evaluate((element) => element.scrollHeight)).toBe(2000)
})

for (const slug of [`xc-functional`, `regulated-and-unregulated-propagators`]) {
  test(`mobile source stays readable across themes (${slug})`, async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 720 })
    await page.addInitScript(() => localStorage.setItem(`theme`, `dark`))
    await open_diagram(page, slug)
    const code = page.locator(`pre`)
    // Explicit site themes must win over either OS preference, including after toggling.
    for (const color_scheme of [`dark`, `light`] as const) {
      await page.emulateMedia({ colorScheme: color_scheme })
      for (const theme of [`light`, `dark`] as const) {
        if (theme === `dark`)
          await page
            .getByRole(`button`, { name: `Switch to system (auto) theme` })
            .click()
        await page.getByRole(`button`, { name: `Switch to ${theme} theme` }).click()
        await expect(code.locator(`.pl-smi`).first()).toHaveCSS(
          `color`,
          theme === `light` ? `rgb(31, 35, 40)` : `rgb(240, 246, 252)`,
        )
        await expect(code.locator(`.pl-k`).first()).toHaveCSS(
          `color`,
          theme === `light` ? `rgb(207, 34, 46)` : `rgb(255, 123, 114)`,
        )
      }
    }
    const header = page.locator(`header`).filter({ has: page.locator(`aside`) })
    const filename = header.locator(`h3`)
    await filename.scrollIntoViewIfNeeded()
    const title_bounds = await filename.boundingBox()
    const code_bounds = await code.boundingBox()
    const toolbar_bounds = await header.locator(`aside`).boundingBox()
    if (!title_bounds || !code_bounds || !toolbar_bounds)
      throw new Error(`Missing source header or code bounds on ${slug}`)
    // The badge straddles the background; controls occupy their own row above code.
    const backdrop_top = await header.evaluate((element) => {
      const block = element.parentElement
      if (!block) throw new Error(`Missing code block`)
      const first_row = Number(getComputedStyle(block).gridTemplateRows.split(`px`)[0])
      return block.getBoundingClientRect().top + first_row
    })
    expect(backdrop_top).toBeCloseTo(title_bounds.y + title_bounds.height / 2, 0)
    expect(toolbar_bounds.y).toBeGreaterThanOrEqual(title_bounds.y + title_bounds.height)
    expect(toolbar_bounds.y + toolbar_bounds.height).toBeLessThanOrEqual(code_bounds.y)
    expect(
      code_bounds.x + code_bounds.width - toolbar_bounds.x - toolbar_bounds.width,
    ).toBeCloseTo(16, 0)
    const control_bounds = []
    for (const control of await header.locator(`h3, aside a, aside button`).all()) {
      const bounds = await control.boundingBox()
      if (!bounds) throw new Error(`Missing source control bounds on ${slug}`)
      expect(bounds.x).toBeGreaterThanOrEqual(0)
      expect(bounds.x + bounds.width).toBeLessThanOrEqual(320)
      expect(bounds.y + bounds.height).toBeLessThanOrEqual(code_bounds.y)
      // Every pair must be separated on at least one axis, including wrapped titles.
      for (const other of control_bounds) {
        expect(
          bounds.x >= other.x + other.width ||
            other.x >= bounds.x + bounds.width ||
            bounds.y >= other.y + other.height ||
            other.y >= bounds.y + bounds.height,
        ).toBe(true)
      }
      control_bounds.push(bounds)
    }
    await header.locator(`aside button`).focus()
    await page.keyboard.press(`Tab`)
    await expect(code).toBeFocused()
    await page.keyboard.press(`ArrowRight`, { delay: 100 })
    await expect
      .poll(() => code.evaluate((element) => element.scrollLeft))
      .toBeGreaterThan(0)
  })
}

for (const slug of [`which-band-gap-do-you-mean`, `how-atoms-become-energy-bands`]) {
  test(`new diagram ${slug} has rendered artwork and source`, async ({ page }) => {
    await open_diagram(page, slug)
    await expect(page.locator(`pre`)).toContainText(`@preview/cetz`)
    await expect(page.getByRole(`link`, { name: `PDF`, exact: true })).toHaveAttribute(
      `href`,
      new RegExp(`/assets/${slug}/${slug}\\.pdf$`),
    )
  })
}
