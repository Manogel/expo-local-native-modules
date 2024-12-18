import * as React from 'react';

import { BundleUpdaterViewProps } from './BundleUpdater.types';

export default function BundleUpdaterView(props: BundleUpdaterViewProps) {
  return (
    <div>
      <iframe
        style={{ flex: 1 }}
        src={props.url}
        onLoad={() => props.onLoad({ nativeEvent: { url: props.url } })}
      />
    </div>
  );
}
