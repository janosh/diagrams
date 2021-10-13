<p align="center">
  <img src="static/favicon.svg" alt="TikZ" height=150>
</p>

# Random TikZ Collection

Gallery site of standalone TikZ images along with their source code. Built with [SvelteKit](https://kit.svelte.dev).

## Running this site locally

1. Clone this repo and install dependencies:

   ```sh
   git clone https://github.com/janosh/tikz
   cd tikz/site
   yarn
   ```

2. Start the dev server:

   ```sh
   yarn dev
   ```

Navigate to `http://localhost:3000`. You should see this app running. Edit a component file in `src`, save it and the page will hot-reload to display your changes.

## Building and running in production mode

To build and serve an optimized version of the app, run

```sh
yarn build && yarn preview
```

## Deploying to Netlify

Install `netlify` if you haven't already:

```sh
yarn global add netlify-cli
```

Then, from within this project's folder after creating a production build with `yarn build`:

```sh
netlify init && netlify deploy --prod
```

## Formatting

When using VS Code, install the [official Svelte extension](https://marketplace.visualstudio.com/items?itemName=svelte.svelte-vscode) and add the following to your `settings.json` to enable autoformatting Svelte files on save:

```json
"[svelte]": {
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "svelte.svelte-vscode"
}
```

To get ESLint validation, also add

```json
"eslint.validate": ["svelte"]
```
