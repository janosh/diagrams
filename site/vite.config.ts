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
    },
    ignorePatterns: [`build/`, `.svelte-kit/`, `dist/`],
    rules: {
      '@typescript-eslint/no-explicit-any': `error`,
      '@typescript-eslint/no-non-null-asserted-optional-chain': `error`,
      '@typescript-eslint/no-non-null-assertion': `error`,
      'no-unused-vars': `error`,
      'no-eval': `error`,
      eqeqeq: `error`,
      'no-var': `error`,
      'no-throw-literal': `error`,
      'no-useless-rename': `error`,
      'no-self-compare': `error`,
      'no-template-curly-in-string': `error`,
      'no-constructor-return': `error`,
      'no-console': [`error`, { allow: [`warn`, `error`] }],
      'default-param-last': `error`,
      'guard-for-in': `error`,
      'require-await': `error`,
      'eslint-plugin-unicorn/no-useless-spread': `error`,
      'eslint-plugin-unicorn/prefer-string-replace-all': `error`,
      'eslint-plugin-unicorn/catch-error-name': `error`,
      'eslint-plugin-unicorn/prefer-set-has': `error`,
      'eslint-plugin-unicorn/prefer-array-find': `error`,
      'eslint-plugin-unicorn/prefer-dom-node-append': `error`,
      'eslint-plugin-import/no-duplicates': `error`,
      'no-inner-declarations': `error`,
      'eslint-plugin-unicorn/prefer-global-this': `error`,
      'eslint-plugin-unicorn/no-lonely-if': `error`,
      'eslint-plugin-unicorn/no-negated-condition': `error`,
      'eslint-plugin-unicorn/no-typeof-undefined': `error`,
      'eslint-plugin-unicorn/prefer-optional-catch-binding': `error`,
      'eslint-plugin-unicorn/no-length-as-slice-end': `error`,
      'eslint-plugin-unicorn/prefer-node-protocol': `error`,
      'eslint-plugin-unicorn/prefer-regexp-test': `error`,
      'eslint-plugin-unicorn/throw-new-error': `error`,
      'eslint-plugin-unicorn/prefer-includes': `error`,
      'eslint-plugin-unicorn/prefer-type-error': `error`,
      'eslint-plugin-unicorn/prefer-date-now': `error`,
      'eslint-plugin-unicorn/require-number-to-fixed-digits-argument': `error`,
      'eslint-plugin-unicorn/no-useless-promise-resolve-reject': `error`,
      // Rules in enabled categories that are too noisy for this codebase
      'no-self-assign': `off`, // Svelte reactive `x = x` assignments
      'no-shadow': `off`, // closures intentionally shadow outer names
      'eslint-plugin-unicorn/consistent-function-scoping': `off`,
      'eslint-plugin-import/no-unassigned-import': `off`, // CSS imports are side-effect-only
    },
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
