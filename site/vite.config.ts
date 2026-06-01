import { config } from "@janosh/vite-config";
import yaml from "@rollup/plugin-yaml";
import { enhancedImages } from "@sveltejs/enhanced-img";
import { sveltekit } from "@sveltejs/kit/vite";
import { readFileSync } from "node:fs";
import { defineConfig } from "vite-plus";

export default defineConfig({
  ...config, // shared lint/fmt/build from @janosh/vite-config (dotfiles)
  plugins: [
    {
      // serve .tex/.typ files as raw text so rolldown doesn't try to parse them as JS
      name: `raw-text-loader`,
      enforce: `pre`,
      load(id) {
        const clean_id = id.split(`?`)[0];
        if (clean_id.endsWith(`.tex`) || clean_id.endsWith(`.typ`))
          return `export default ${JSON.stringify(readFileSync(clean_id, `utf-8`))}`;
      },
    },
    enhancedImages(),
    sveltekit(),
    yaml(),
  ],
  server: {
    fs: {
      allow: [`..`], // needed to import package.json
    },
    port: 3000,
  },
  preview: {
    port: 3000,
  },
});
