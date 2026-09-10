/// <reference types="node" />
import { defineConfig } from '@playwright/test'
import { env } from 'node:process'

export default defineConfig({
  testDir: `./tests/visual`,
  testMatch: `**/*.visual.ts`,
  fullyParallel: true,
  forbidOnly: Boolean(env.CI),
  workers: 2,
  timeout: 15_000,
  updateSnapshots: `none`,
  reporter: [[`list`], [`html`, { open: `never` }]],
  use: {
    baseURL: `http://127.0.0.1:4173`,
    viewport: { width: 1280, height: 720 },
    browserName: `chromium`,
    launchOptions: { args: [`--hide-scrollbars`] },
    contextOptions: { reducedMotion: `reduce` },
    trace: `retain-on-failure`,
  },
  expect: {
    timeout: 3000,
    // Diagram screenshots contain raster artwork and SVG controls, not OS-dependent text.
    // Allow up to 100 antialiased edge pixels, never broad layout/color changes.
    toHaveScreenshot: { animations: `disabled`, maxDiffPixels: 100, threshold: 0.1 },
  },
  snapshotPathTemplate: `{testDir}/screenshots/{arg}{ext}`,
  webServer: {
    command: `vite preview --host 127.0.0.1 --port 4173 --strictPort`,
    url: `http://127.0.0.1:4173`,
  },
})
