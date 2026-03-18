import yaml from '@rollup/plugin-yaml'
import { enhancedImages } from '@sveltejs/enhanced-img'
import { sveltekit } from '@sveltejs/kit/vite'
import { readFileSync } from 'node:fs'
import { defineConfig } from 'vite-plus'

export default defineConfig({
  plugins: [
    {
      // serve .tex/.typ files as raw text so rolldown doesn't try to parse them as JS
      name: `raw-text-loader`,
      enforce: `pre`,
      load(id) {
        const clean_id = id.split(`?`)[0]
        if (clean_id.endsWith(`.tex`) || clean_id.endsWith(`.typ`))
          return `export default ${JSON.stringify(readFileSync(clean_id, `utf-8`))}`
      },
    },
    enhancedImages(),
    sveltekit(),
    yaml(),
  ],
  css: { lightningcss: { exclude: 0x1fffff } },
  fmt: {
    semi: false,
    singleQuote: true,
    printWidth: 90,
  },
  lint: {
    plugins: [`oxc`, `typescript`, `unicorn`, `import`],
    options: {
      typeAware: true,
      typeCheck: true,
    },
    categories: {
      correctness: `error`,
      suspicious: `error`,
      perf: `error`,
      pedantic: `error`,
    },
    ignorePatterns: [`build/`, `.svelte-kit/`, `dist/`],
    rules: {
      // Rules in enabled categories that are too noisy for this codebase
      'no-unused-vars': `off`,
      '@typescript-eslint/no-unused-vars': [
        `error`,
        { argsIgnorePattern: `^_`, varsIgnorePattern: `^_` },
      ],
      'no-console': [`error`, { allow: [`warn`, `error`] }],
      'no-self-assign': `off`, // Svelte reactive `x = x` assignments
      'no-await-in-loop': `off`,
      'no-shadow': `off`, // closures intentionally shadow outer names
      'prefer-const': `off`,
      '@typescript-eslint/no-unnecessary-condition': `off`,
      '@typescript-eslint/consistent-type-imports': `off`,
      'eslint-plugin-unicorn/consistent-function-scoping': `off`,
      '@typescript-eslint/no-unsafe-argument': `off`,
      '@typescript-eslint/no-unsafe-assignment': `off`,
      '@typescript-eslint/no-unsafe-call': `off`,
      '@typescript-eslint/no-unsafe-member-access': `off`,
      '@typescript-eslint/no-unsafe-return': `off`,
      'no-inline-comments': `off`,
      'no-confusing-void-expression': `off`,
      'no-promise-executor-return': `off`,
      'strict-boolean-expressions': `off`,
      'max-lines-per-function': `off`,
      'max-lines': `off`,
      'max-depth': `off`,
      'max-classes-per-file': `off`,
      'sort-vars': `off`,
      'eslint-plugin-unicorn/no-array-callback-reference': `off`,
      'eslint-plugin-unicorn/no-useless-undefined': `off`,
      'eslint-plugin-unicorn/no-object-as-default-parameter': `off`,
      'eslint-plugin-import/no-self-import': `off`,
      'eslint-plugin-import/no-unassigned-import': `off`, // CSS imports are side-effect-only
      'eslint-plugin-import/max-dependencies': `off`,
      'no-warning-comments': `off`,
      '@typescript-eslint/only-throw-error': `off`, // SvelteKit error() is designed to be thrown
      '@typescript-eslint/no-deprecated': `off`,
    },
  },
  staged: {
    '*.{js,ts,svelte,html,css,md,json,yaml}': `vp check --fix`,
    '*.{ts,svelte}': `sh -c 'npx svelte-kit sync && npx svelte-check-rs --threshold error'`,
    '*': `codespell --check-filenames`,
  },

  server: {
    fs: {
      allow: [`..`], // needed to import package.json
    },
    port: 3000,
  },

  preview: {
    port: 3000,
  },
})
