// Reexport the native module. On web, it will be resolved to BundleUpdaterModule.web.ts
// and on native platforms to BundleUpdaterModule.ts
export { default } from './src/BundleUpdaterModule';
export { default as BundleUpdaterView } from './src/BundleUpdaterView';
export * from  './src/BundleUpdater.types';
