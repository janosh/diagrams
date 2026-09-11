import { expect, test, type Locator, type Page } from '@playwright/test'
import { readFileSync } from 'node:fs'
// oxlint-disable vitest/prefer-each -- Playwright uses loops for parameterization and has no test.each.

// The production pages are the fixtures: retain native fullscreen, real images, and CSS.
const open_diagram = async (page: Page, slug: string) => {
  await page.goto(`/${slug}`, { waitUntil: `domcontentloaded` })
  await expect(page.getByRole(`heading`, { level: 1 })).not.toBeEmpty()
  const diagram = page.locator(`.diagram-wrapper img`)
  await expect(diagram).toHaveAttribute(`src`, /\.avif$/u)
  await expect(page.locator(`.diagram-wrapper source`)).toHaveCount(0)
  await expect(diagram).toBeVisible()
  await expect
    .poll(() =>
      diagram.evaluate(
        (image: HTMLImageElement) => image.complete && image.naturalWidth > 0,
      ),
    )
    .toBe(true)
  const dimensions = await diagram.evaluate((image: HTMLImageElement) => ({
    width: Number(image.getAttribute(`width`)),
    height: Number(image.getAttribute(`height`)),
    natural_width: image.naturalWidth,
    natural_height: image.naturalHeight,
  }))
  expect(dimensions.width).toBe(dimensions.natural_width)
  expect(dimensions.height).toBe(dimensions.natural_height)
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

const gallery_card = (page: Page, slug: string) =>
  page.locator(`.gallery .card[data-slug="${slug}"]`)

test.beforeEach(async ({ context }) => {
  // Analytics is irrelevant to screenshots and must not depend on external availability.
  await context.route(`https://plausible.io/**`, (route) => route.abort())
})

test(`gallery restores URL filters through reloads and detail navigation`, async ({
  page,
  context,
}) => {
  const filter_query = `?search=angle&tag=physics,geometry&tag_mode=any`
  const home_url = `.${filter_query}`
  const page_errors: string[] = []
  page.on(`pageerror`, (error) => page_errors.push(error.message))
  await page.goto(`/?search=angle&tag=physics,geometry,physics&tag_mode=any`)
  const search = page.getByPlaceholder(`Search...`, { exact: true })
  const selected_tags = page.locator(`.filters ul.selected > li`)
  await expect(search).toHaveValue(`angle`)
  await expect(selected_tags).toHaveCount(2)
  await expect(page.locator(`input[type=radio][value=any]`)).toBeChecked()
  await expect(page).toHaveURL(
    (url) => url.searchParams.get(`tag`) === `physics,geometry`,
  )
  await expect(gallery_card(page, `euler-angles`).locator(`img`)).toHaveAttribute(
    `src`,
    /\/euler-angles\.[^/]+\.avif$/u,
  )
  await search.fill(``)
  await expect(page).toHaveURL((url) => !url.searchParams.has(`search`))
  await search.pressSequentially(`angle`)
  await expect(page).toHaveURL((url) => url.searchParams.get(`search`) === `angle`)
  await page.reload()
  await expect(search).toHaveValue(`angle`)
  await expect(selected_tags).toHaveCount(2)
  await expect(page.locator(`input[type=radio][value=any]`)).toBeChecked()

  await gallery_card(page, `euler-angles`).locator(`a[data-diagram-link]`).click()
  const home = page.getByRole(`link`, { name: `home`, exact: true })
  await expect(home).toHaveAttribute(`href`, home_url)
  await expect(home).toHaveCSS(`position`, `absolute`)
  const detail_url = page.url()
  expect(new URL(detail_url).search).toBe(filter_query)
  const nav_links = page.locator(`.prev-next h3 a`)
  const nav_urls = await nav_links.evaluateAll((links) =>
    links.map((link) => link.getAttribute(`href`)),
  )
  expect(nav_urls).toHaveLength(2)
  await page.reload()
  await expect(home).toHaveAttribute(`href`, home_url)
  await expect
    .poll(() =>
      nav_links.evaluateAll((links) => links.map((link) => link.getAttribute(`href`))),
    )
    .toEqual(nav_urls)

  // A new tab has no in-memory filter store from the gallery.
  const fresh_page = await context.newPage()
  await fresh_page.goto(detail_url)
  for (const direction of [`Next`, `Previous`]) {
    const link = fresh_page.getByRole(`link`, {
      name: new RegExp(`^${direction}|${direction}$`, `u`),
    })
    await expect(link).toHaveAttribute(
      `href`,
      /\?search=angle&tag=physics,geometry&tag_mode=any$/u,
    )
    await link.click()
    await expect(
      fresh_page.getByRole(`link`, { name: `home`, exact: true }),
    ).toHaveAttribute(`href`, home_url)
  }
  await fresh_page.close()
  await page.goBack()
  await expect(search).toHaveValue(`angle`)
  await expect(selected_tags).toHaveCount(2)
  await page.goForward()
  await home.click()
  await expect(search).toHaveValue(`angle`)
  await expect(page.locator(`input[type=radio][value=any]`)).toBeChecked()
  expect(page_errors).toEqual([])
})

test(`gallery restores deep browsing position and focus after Back and reload`, async ({
  page,
}) => {
  test.setTimeout(30_000)
  await page.goto(`/?search=Euler&tag_mode=any`)
  const search = page.getByRole(`textbox`, { name: `Search diagrams` })
  await expect(search).toHaveValue(`Euler`)
  await search.fill(``)
  await expect(page).toHaveURL(`/?tag_mode=any`)
  await page.locator(`body`).click({ position: { x: 2, y: 2 } })
  await page.keyboard.press(`ArrowLeft`)
  const active_link = page.locator(`.diagram-item.active a[data-diagram-link]`)
  await expect(active_link).toBeFocused()
  await active_link.scrollIntoViewIfNeeded()
  const slug = await active_link.locator(`h2`).getAttribute(`id`)
  if (!slug) throw new Error(`Missing active diagram slug`)
  const card_count = await page.locator(`.diagram-item`).count()
  expect(card_count).toBeGreaterThan(24)
  const scroll_y = await page.evaluate(() => scrollY)
  expect(scroll_y).toBeGreaterThan(720)
  await active_link.click()
  await expect(page.getByRole(`link`, { name: `home`, exact: true })).toBeVisible()

  for (const reload_detail of [false, true]) {
    if (reload_detail) {
      await page.goForward()
      await page.reload()
      // The query-bearing Home link confirms hydration before sending Back to the router.
      await expect(page.getByRole(`link`, { name: `home`, exact: true })).toHaveAttribute(
        `href`,
        `.?tag_mode=any`,
      )
    }
    await page.goBack()
    await expect(page.locator(`.diagram-item`)).toHaveCount(card_count)
    await expect(gallery_card(page, slug).locator(`a[data-diagram-link]`)).toBeFocused()
    // Allow two CSS pixels for layout rounding, not a jump to a different row.
    await expect
      .poll(async () => Math.abs((await page.evaluate(() => scrollY)) - scroll_y))
      .toBeLessThanOrEqual(2)
    // Late card measurements must preserve scroll without stealing focus again.
    const gallery = page.locator(`.gallery`)
    const old_height = await gallery.evaluate((element) => element.clientHeight)
    await search.evaluate((input) => input.focus({ preventScroll: true }))
    await page.locator(`.diagram-item`).evaluateAll((elements) => {
      for (const element of elements) element.style.paddingBottom = `100px`
    })
    await expect
      .poll(() => gallery.evaluate((element) => element.clientHeight))
      .toBeGreaterThan(old_height)
    await expect
      .poll(async () => Math.abs((await page.evaluate(() => scrollY)) - scroll_y))
      .toBeLessThanOrEqual(2)
    await expect(search).toBeFocused()
  }
  await search.click()
  await search.fill(`Euler Angles`)
  await expect(page.locator(`.diagram-item`)).toHaveCount(2)
  await expect(page.locator(`.diagram-item.active`)).toHaveCount(0)
  await expect(search).toBeInViewport()
})

test(`gallery keyboard navigation respects controls and focuses card links`, async ({
  page,
}) => {
  await page.goto(`/?search=Euler`)
  const search = page.getByRole(`textbox`, { name: `Search diagrams` })
  await expect(search).toHaveValue(`Euler`)
  await search.focus()
  await expect(search).toHaveCSS(`outline-style`, `solid`)
  await search.press(`ArrowLeft`)
  await expect(page.locator(`.diagram-item.active`)).toHaveCount(0)
  await expect(page.locator(`.gallery a :is(button, input, a)`)).toHaveCount(0)
  await page.locator(`body`).click({ position: { x: 2, y: 2 } })
  await page.keyboard.press(`ArrowRight`)
  await expect(page.locator(`.gallery a[data-diagram-link]`).first()).toBeFocused()
  await page.keyboard.press(`Escape`)
  await expect(page.locator(`.diagram-item.active`)).toHaveCount(0)

  const card = gallery_card(page, `euler-angles`)
  const physics = card.getByRole(`button`, { name: `physics`, exact: true })
  const geometry = card.getByRole(`button`, { name: `geometry`, exact: true })
  await physics.focus()
  await physics.press(`ArrowRight`)
  await expect(geometry).toBeFocused()
  await expect(page.locator(`.diagram-item.active`)).toHaveCount(0)
  await geometry.press(`Enter`)
  await expect(page).toHaveURL(
    (url) => url.pathname === `/` && url.searchParams.get(`tag`) === `geometry`,
  )
  await geometry.press(`Space`)
  await expect(page).toHaveURL(
    (url) => url.pathname === `/` && !url.searchParams.has(`tag`),
  )

  const link = card.locator(`a[data-diagram-link]`)
  await link.focus()
  await link.press(`Control+ArrowRight`)
  await expect(link).toBeFocused()
  await link.press(`ArrowRight`)
  await expect(link).not.toBeFocused()
  const active_link = page.locator(`.diagram-item.active a[data-diagram-link]`)
  await expect(active_link).toBeFocused()
  await expect(active_link).toHaveCSS(`outline-style`, `solid`)
  await active_link.press(`ArrowLeft`)
  await expect(link).toBeFocused()
  await link.press(`Enter`)
  await expect(page).toHaveURL(`/euler-angles?search=Euler`)
})

test(`gallery writes every filter and preserves unrelated URL state`, async ({
  page,
}) => {
  await page.goto(`/?keep=1#results`)
  const search = page.getByPlaceholder(`Search...`, { exact: true })
  await search.fill(`Euler`)
  await expect(page).toHaveURL((url) => url.searchParams.get(`search`) === `Euler`)
  const tag_input = page.locator(`.filters`).getByRole(`combobox`)
  for (const tag of [`physics`, `geometry`]) {
    await tag_input.fill(tag)
    await expect(tag_input).toHaveAttribute(`aria-expanded`, `true`)
    await page.getByRole(`option`, { name: new RegExp(`^${tag} `, `u`) }).click()
  }
  await page.locator(`input[type=radio][value=any]`).check()
  await expect(page).toHaveURL(
    (url) =>
      url.searchParams.get(`search`) === `Euler` &&
      url.searchParams.get(`tag`) === `physics,geometry` &&
      url.searchParams.get(`tag_mode`) === `any` &&
      url.searchParams.get(`keep`) === `1` &&
      url.hash === `#results`,
  )

  // Card tags and the introductory shortcuts update the same shared filter state.
  await tag_input.press(`Escape`)
  await expect(tag_input).toHaveAttribute(`aria-expanded`, `false`)
  await gallery_card(page, `euler-angles`)
    .getByRole(`button`, { name: `geometry`, exact: true })
    .click()
  await expect(page).toHaveURL((url) => url.searchParams.get(`tag`) === `physics`)
  await page.getByRole(`button`, { name: `chemistry`, exact: true }).click()
  await expect(page).toHaveURL((url) => url.searchParams.get(`tag`) === `chemistry`)
  await page.getByRole(`button`, { name: /^\d+ total$/u }).click()
  await expect(search).toHaveValue(``)
  await expect(page.locator(`.filters ul.selected > li`)).toHaveCount(0)
  await expect(page).toHaveURL(`/?keep=1#results`)

  const result_count = page.locator(`.filters [role=status]`)
  await expect(result_count).toHaveAttribute(`aria-live`, `polite`)
  for (const [action, expected_url, tag_count] of [
    [`Clear search`, `/?keep=1&tag=chemistry#results`, 1],
    [`Reset filters`, `/?keep=1#results`, 0],
  ] as const) {
    await test.step(action, async () => {
      await search.fill(`no-diagram-has-this-name`)
      await page.getByRole(`button`, { name: `chemistry`, exact: true }).click()
      await expect(result_count).toHaveText(`0 matches`)
      await expect(
        page.getByRole(`heading`, { name: `No matching diagrams` }),
      ).toBeVisible()
      await page.getByRole(`button`, { name: action, exact: true }).click()
      await expect(search).toBeFocused()
      await expect(search).toHaveValue(``)
      await expect(page).toHaveURL(expected_url)
      await expect(page.locator(`.filters ul.selected > li`)).toHaveCount(tag_count)
      await expect(result_count).not.toHaveText(`0 matches`)
      await expect(page.locator(`.diagram-item`).first()).toBeVisible()
    })
  }
})

for (const [tag_mode, predicted_count] of [
  [`all`, 0],
  [`any`, 2],
] as const) {
  test(`gallery tag counts predict results with ${tag_mode} matching`, async ({
    page,
  }) => {
    await page.goto(`/?search=Euler+Angles&tag_mode=${tag_mode}`)
    const search = page.getByRole(`textbox`, { name: `Search diagrams` })
    await expect(search).toHaveValue(`Euler Angles`)
    const tag_input = page.locator(`.filters`).getByRole(`combobox`)
    await tag_input.fill(`coordinate systems`)
    // A tag used by only one diagram remains discoverable.
    await expect(
      page.getByRole(`option`, { name: `coordinate systems 1`, exact: true }),
    ).toBeVisible()
    await tag_input.fill(`physics`)
    await page.getByRole(`option`, { name: `physics 1`, exact: true }).click()
    await expect(page.locator(`.diagram-item`)).toHaveCount(1)
    await tag_input.fill(`coordinate systems`)
    await page
      .getByRole(`option`, {
        name: `coordinate systems ${predicted_count}`,
        exact: true,
      })
      .click()
    await expect(page.locator(`.diagram-item`)).toHaveCount(predicted_count)
    await expect(page.locator(`.filters [role=status]`)).toHaveText(
      `${predicted_count} matches`,
    )
    await tag_input.press(`Escape`)
    await search.fill(`no-diagram-has-this-name`)
    await tag_input.fill(`geometry`)
    await expect(
      page.getByRole(`option`, { name: `geometry 0`, exact: true }),
    ).toBeEnabled()
  })
}

test(`source deep links survive reloads, fresh tabs, and filter updates`, async ({
  page,
  context,
}) => {
  const page_errors: string[] = []
  page.on(`pageerror`, (error) => page_errors.push(error.message))
  await page.goto(
    `/euler-angles?source=tex&search=angle&tag=physics,physics&tag_mode=invalid&keep=1`,
  )
  const source = page.locator(`pre`)
  const description = page.locator(`.description`)
  const tikz = page.getByRole(`tab`, { name: `TikZ`, exact: true })
  await expect(tikz).toHaveAttribute(`aria-selected`, `true`)
  await expect(source).toHaveAttribute(`aria-label`, `euler-angles.tex`)
  await expect(page).toHaveURL(
    (url) =>
      url.searchParams.get(`source`) === `tex` &&
      url.searchParams.get(`tag`) === `physics` &&
      !url.searchParams.has(`tag_mode`) &&
      url.searchParams.get(`keep`) === `1` &&
      url.hash === ``,
  )
  for (const [language, extension] of [
    [`Typst`, `typ`],
    [`TikZ`, `tex`],
  ]) {
    await test.step(`switch to ${language} and reload`, async () => {
      const tab = page.getByRole(`tab`, { name: language, exact: true })
      await tab.click()
      await expect(source).toHaveCount(1)
      await expect(source).toHaveAttribute(`aria-label`, `euler-angles.${extension}`)
      await expect(page).toHaveURL(
        (url) =>
          url.searchParams.get(`source`) === (extension === `typ` ? null : extension) &&
          url.searchParams.get(`search`) === `angle` &&
          url.searchParams.get(`tag`) === `physics` &&
          url.searchParams.get(`keep`) === `1` &&
          url.hash === `#code`,
      )
      await page.reload()
      await expect(tab).toHaveAttribute(`aria-selected`, `true`)
      await expect(source).toHaveAttribute(`aria-label`, `euler-angles.${extension}`)
      await expect(page.locator(`#code`)).toBeInViewport()
    })
  }

  const fresh_page = await context.newPage()
  await fresh_page.goto(page.url())
  await expect(fresh_page.locator(`pre`)).toHaveAttribute(
    `aria-label`,
    `euler-angles.tex`,
  )
  await fresh_page.close()

  // Updating another URL-backed control keeps the selected source.
  await description.getByRole(`button`, { name: `geometry`, exact: true }).click()
  await expect(page).toHaveURL(
    (url) => url.searchParams.get(`tag`) === `physics,geometry`,
  )
  await expect(source).toHaveAttribute(`aria-label`, `euler-angles.tex`)
  await expect(tikz).toHaveAttribute(`aria-selected`, `true`)
  const related_link = description.getByRole(`link`, {
    name: `Cartesian vs Polar Coordinates`,
  })
  const related_url = `/cartesian-vs-polar-coordinates?search=angle&tag=physics,geometry`
  await expect(related_link).toHaveAttribute(`href`, related_url)
  const related_page = await context.newPage()
  await related_page.goto(
    await related_link.evaluate((link: HTMLAnchorElement) => link.href),
  )
  await expect(
    related_page.getByRole(`link`, { name: `home`, exact: true }),
  ).toHaveAttribute(`href`, `.?search=angle&tag=physics,geometry`)
  await related_page.close()
  await related_link.click()
  await expect(page).toHaveURL(related_url)
  await expect(page.getByRole(`link`, { name: `home`, exact: true })).toHaveAttribute(
    `href`,
    `.?search=angle&tag=physics,geometry`,
  )
  await expect(source).toHaveAttribute(`aria-label`, `cartesian-vs-polar-coordinates.typ`)
  await expect(description.getByRole(`link`, { name: `Euler Angles` })).toHaveAttribute(
    `href`,
    `/euler-angles?search=angle&tag=physics,geometry`,
  )
  await page.goBack()
  await expect(source).toHaveAttribute(`aria-label`, `euler-angles.tex`)
  await expect(tikz).toHaveAttribute(`aria-selected`, `true`)
  expect(page_errors).toEqual([])
})

for (const [slug, source] of [
  [`euler-angles`, `invalid`],
  [`wannierization-and-wannier-centers`, `tex`],
  [`wannierization-and-wannier-centers`, `typ`],
]) {
  test(`source links validate ${source} for ${slug}`, async ({ page }) => {
    await page.goto(`/${slug}?source=${source}#code`)
    await expect(page.locator(`pre`)).toHaveCount(1)
    await expect(page.locator(`pre`)).toHaveAttribute(`aria-label`, `${slug}.typ`)
    await expect(page.locator(`#code`)).toBeInViewport()
  })
}

test(`gallery info buttons reveal descriptions on hover and keyboard focus`, async ({
  page,
}) => {
  await page.goto(`/`, { waitUntil: `domcontentloaded` })
  const search = page.getByPlaceholder(`Search...`, { exact: true })
  await search.fill(`Convex Hull of Stability`)
  await expect(page.locator(`head link[rel="prefetch"][as="image"]`)).toHaveCount(0)
  const hull_info = page.getByRole(`button`, { name: `About Convex Hull of Stability` })
  await expect(hull_info).toHaveCSS(`opacity`, `0`)
  await gallery_card(page, `convex-hull-of-stability`).hover()
  const hull_description = page.getByRole(`dialog`, { name: `Convex Hull of Stability` })
  await expect(hull_description).toHaveCount(0)
  await expect(hull_info).toHaveCSS(`opacity`, `1`)
  await expect(hull_info).toHaveCSS(`padding`, `0px`)
  await expect(hull_info).toHaveCSS(`border-width`, `0px`)
  await expect(hull_info.locator(`svg`)).toHaveCSS(`width`, `18px`)
  await expect(hull_info).toHaveCSS(
    `color`,
    await page.locator(`body`).evaluate((body) => getComputedStyle(body).color),
  )
  await hull_info.hover()
  await expect(hull_description).toBeVisible()
  await expect(hull_description).toHaveCSS(`padding`, `6.66667px 8px`)
  await expect(page).toHaveURL(
    (url) =>
      url.pathname === `/` &&
      url.searchParams.get(`search`) === `Convex Hull of Stability`,
  )
  for (const selector of [`p`, `li`]) {
    await expect(hull_description.locator(selector).first()).toHaveCSS(
      `font-size`,
      `14px`,
    )
    await expect(hull_description.locator(selector).first()).toHaveCSS(
      `text-align`,
      `left`,
    )
  }
  await search.hover()
  await expect(hull_description).toBeHidden()
  await search.fill(`Euler Angles`)
  const card = gallery_card(page, `euler-angles`)
  const card_link = card.locator(`a[data-diagram-link]`)
  const thumbnail = card.locator(`img`)
  await expect(thumbnail).toHaveAttribute(`loading`, `lazy`)
  await expect(card.locator(`picture`)).toHaveCount(0)
  await expect(thumbnail).toHaveAttribute(`src`, /\.avif$/u)
  await expect(thumbnail).toHaveAttribute(`srcset`, /\S+ 480w, \S+ 960w/u)
  await expect(thumbnail).toHaveAttribute(`sizes`, /33vw/u)
  await card_link.focus()
  const description = page.getByRole(`dialog`, { name: `Euler Angles` })
  await expect(description).toHaveCount(0)
  // Tag filters precede the info button in the card's tab order.
  await card.locator(`.tags`).getByRole(`button`).last().focus()
  await page.keyboard.press(`Tab`)
  const info = page.getByRole(`button`, { name: `About Euler Angles` })
  await expect(info).toBeFocused()
  await expect(info).toHaveCSS(`opacity`, `1`)
  await expect(description).toBeVisible()
  await expect(
    description.getByRole(`link`, { name: `Cartesian vs Polar Coordinates` }),
  ).toBeVisible()
  await expect(
    description.getByRole(`link`, { name: `Cartesian vs Polar Coordinates` }),
  ).toHaveAttribute(`href`, `/cartesian-vs-polar-coordinates?search=Euler+Angles`)
  expect(await description.evaluate((element) => element.closest(`a`))).toBeNull()
  await page.keyboard.press(`Escape`)
  await expect(description).toBeHidden()
  await card_link.click()
  await expect(page).toHaveURL(`/euler-angles?search=Euler+Angles`)
})

test.describe(`touch gallery`, () => {
  test.use({ hasTouch: true, isMobile: true, viewport: { width: 390, height: 844 } })
  test(`info buttons open descriptions without hover`, async ({ page }) => {
    await page.goto(`/`)
    await page.getByPlaceholder(`Search...`, { exact: true }).fill(`Euler Angles`)
    const info = page.getByRole(`button`, { name: `About Euler Angles` })
    await expect(info).toHaveCSS(`opacity`, `1`)
    await info.tap()
    await expect(page.getByRole(`dialog`, { name: `Euler Angles` })).toBeVisible()
    await expect(page).toHaveURL(
      (url) => url.pathname === `/` && url.searchParams.get(`search`) === `Euler Angles`,
    )
  })
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
      if (url.endsWith(`.avif`) && !url.includes(`euler-angles`)) await images_released
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
      const nav_card = page.locator(`.prev-next a[href="${target}"]:has(img)`)
      await expect(page.locator(`.prev-next button[aria-haspopup]`)).toHaveCount(0)
      await expect(nav_card).not.toHaveAttribute(`aria-haspopup`)
      await nav_card.hover()
      await expect(page.getByRole(`dialog`)).toHaveCount(0)
      await nav_card.focus()
      await expect(page.getByRole(`dialog`)).toHaveCount(0)
      await expect(page.locator(`head link[rel="preload"][as="image"]`)).toHaveCount(0)
      const prefetched_images = await page
        .locator(`head link[rel="prefetch"][as="image"]`)
        .evaluateAll((links) =>
          links.map((link) => link.getAttribute(`href`)?.replaceAll(location.origin, ``)),
        )
      await nav_link.click()
      await expect(page).toHaveURL(new RegExp(`/${target}$`))
      await expect(wrapper.locator(`img`)).not.toHaveAttribute(`alt`, `Euler Angles`)
      for (const image of old_images) {
        expect(await image.evaluate((element) => element.isConnected)).toBe(false)
      }
      const new_image = wrapper.locator(`img`)
      await expect(new_image).toHaveJSProperty(`naturalWidth`, 0)
      expect(prefetched_images).toContain(await new_image.getAttribute(`src`))
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
  const artwork = gallery_card(page, `feynman-building-blocks`).locator(`img`)
  await artwork.hover()
  await page.getByRole(`button`, { name: `About Feynman Building Blocks` }).hover()
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
    await artwork.hover()
    await expect(gallery_card(page, `feynman-building-blocks`).locator(`h2`)).toHaveCSS(
      `color`,
      await page.locator(`body`).evaluate((body) => getComputedStyle(body).color),
    )
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

for (const slug of [
  `which-band-gap-do-you-mean`,
  `how-atoms-become-energy-bands`,
  `complex-sign-function`,
]) {
  test(`diagram ${slug} has rendered artwork, downloads, and source`, async ({
    page,
  }) => {
    await open_diagram(page, slug)
    const image_url = await page.locator(`.diagram-wrapper img`).getAttribute(`src`)
    if (!image_url) throw new Error(`Missing AVIF URL for ${slug}`)
    const response = await page.request.get(image_url)
    expect(await response.body()).toEqual(
      readFileSync(`${import.meta.dirname}/../../../assets/${slug}/${slug}.avif`),
    )
    await expect(page.locator(`pre`)).toContainText(`@preview/cetz`)
    await expect(page.locator(`section.description p`).first()).toHaveCSS(
      `text-align`,
      `left`,
    )
    await expect(page.getByRole(`link`, { name: `PDF`, exact: true })).toHaveAttribute(
      `href`,
      new RegExp(`/assets/${slug}/${slug}\\.pdf$`),
    )
    await expect(page.getByRole(`link`, { name: `PNG`, exact: true })).toHaveAttribute(
      `href`,
      new RegExp(`/assets/${slug}/${slug}\\.png$`),
    )
    await expect(page.locator(`meta[property="og:image"]`)).toHaveAttribute(
      `content`,
      new RegExp(`/assets/${slug}/${slug}\\.png$`),
    )
    await expect(page.getByRole(`link`, { name: `PNG (HD)`, exact: true })).toHaveCount(0)
  })
}
