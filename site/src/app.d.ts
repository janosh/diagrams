/// <reference types="@sveltejs/kit" />

declare module '*package.json'

declare module '*.yml' {
  // oxlint-disable-next-line typescript/consistent-type-imports
  const metadata: import('./lib').YamlMetadata
  export default metadata
}
