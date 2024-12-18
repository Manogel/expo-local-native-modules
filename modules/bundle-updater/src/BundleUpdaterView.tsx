import { requireNativeView } from 'expo';
import * as React from 'react';

import { BundleUpdaterViewProps } from './BundleUpdater.types';

const NativeView: React.ComponentType<BundleUpdaterViewProps> =
  requireNativeView('BundleUpdater');

export default function BundleUpdaterView(props: BundleUpdaterViewProps) {
  return <NativeView {...props} />;
}
