declare module '*.yml' {
  // oxlint-disable-next-line typescript/consistent-type-imports
  const metadata: import('./lib/index.js').YamlMetadata
  export default metadata
}
