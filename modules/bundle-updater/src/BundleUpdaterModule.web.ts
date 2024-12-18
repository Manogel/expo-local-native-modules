import { registerWebModule, NativeModule } from 'expo';

import { ChangeEventPayload } from './BundleUpdater.types';

type BundleUpdaterModuleEvents = {
  onChange: (params: ChangeEventPayload) => void;
}

class BundleUpdaterModule extends NativeModule<BundleUpdaterModuleEvents> {
  PI = Math.PI;
  async setValueAsync(value: string): Promise<void> {
    this.emit('onChange', { value });
  }
  hello() {
    return 'Hello world! 👋';
  }
};

export default registerWebModule(BundleUpdaterModule);
