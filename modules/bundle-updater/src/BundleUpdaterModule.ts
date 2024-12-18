import { NativeModule, requireNativeModule } from 'expo';

import { BundleUpdaterModuleEvents } from './BundleUpdater.types';

declare class BundleUpdaterModule extends NativeModule<BundleUpdaterModuleEvents> {
  PI: number;
  hello(): string;
  setValueAsync(value: string): Promise<void>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<BundleUpdaterModule>('BundleUpdater');
