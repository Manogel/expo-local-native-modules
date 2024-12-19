import { NativeModule, requireNativeModule } from 'expo';

import { BundleUpdaterModuleEvents } from './BundleUpdater.types';

declare class BundleUpdaterModule extends NativeModule<BundleUpdaterModuleEvents> {
  applyBundle(bundlePath: string, bundleVersion: string | number): Promise<string>;
  getBundleInfo(): Promise<{
    currentAppVersion: string;
    bundleVersion: string;
    haveBundleSaved: boolean;
    bundlePath: string;
  }>;
  clearBundle(): void;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<BundleUpdaterModule>('BundleUpdater');