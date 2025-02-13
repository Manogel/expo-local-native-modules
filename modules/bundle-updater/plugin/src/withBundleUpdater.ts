import { ConfigPlugin, withMainApplication, withAppDelegate } from '@expo/config-plugins';

const withBundleUpdater: ConfigPlugin = (config) => {
  // Handle Android modifications
  config = withMainApplication(config, async (config) => {
    const mainApplication = config.modResults;
    console.log('[BundleUpdater] Starting Android plugin configuration...');

    // Add imports
    if (!mainApplication.contents.includes('import expo.modules.bundleupdater.BundleUpdaterModule')) {
      console.log('[BundleUpdater] Adding import statement...');
      mainApplication.contents = mainApplication.contents.replace(
        /import com\.facebook\.react\.ReactApplication/,
        `import com.facebook.react.ReactApplication\nimport expo.modules.bundleupdater.BundleUpdaterModule`
      );
      console.log('[BundleUpdater] Import added successfully');
    }

    // Modify getJSBundleFile
    if (!mainApplication.contents.includes('override fun getJSBundleFile')) {
      console.log('[BundleUpdater] Adding getJSBundleFile override...');
      const hostPattern = /object\s*:\s*DefaultReactNativeHost\(this\)\s*{([^}]*)}/s;
      const replacement = `object : DefaultReactNativeHost(this) {
        override fun getJSBundleFile(): String? {
            android.util.Log.d("BundleUpdater", "Getting JS bundle file...")
            // Try to get custom bundle
            val customBundle = BundleUpdaterModule.getJSBundleFile(application)
            
            android.util.Log.d("BundleUpdater", "Custom bundle path: " + (customBundle ?: "null"))
            
            if (customBundle != null) {
                return customBundle
            }
            
            // If no custom bundle, return null to use the default bundle
            val defaultBundle = super.getJSBundleFile()
            android.util.Log.d("BundleUpdater", "Using default bundle: " + (defaultBundle ?: "null"))
            return defaultBundle
        }
        $1
      }`;

      mainApplication.contents = mainApplication.contents.replace(hostPattern, replacement);
      console.log('[BundleUpdater] Override added successfully');
    }

    console.log('[BundleUpdater] Android plugin configuration completed');
    return config;
  });

  // Handle iOS modifications
  config = withAppDelegate(config, async (config) => {
    const appDelegate = config.modResults;
    console.log('[BundleUpdater] Starting iOS plugin configuration...');

    // Add import
    if (!appDelegate.contents.includes('#import "BundleUpdater.h"')) {
      console.log('[BundleUpdater] Adding import statement...');
      appDelegate.contents = appDelegate.contents.replace(
        /#import <React\/RCTLinkingManager\.h>/,
        `#import <React/RCTLinkingManager.h>\n#import "BundleUpdater.h"`
      );
      console.log('[BundleUpdater] Import added successfully');
    }

    // Modify sourceURLForBridge method
    if (!appDelegate.contents.includes('customBundleURL = [BundleUpdater getBundleURL]')) {
      console.log('[BundleUpdater] Modifying sourceURLForBridge method...');
      const sourceURLPattern = /- \(NSURL \*\)sourceURLForBridge:\(RCTBridge \*\)bridge\s*{[^}]*}/s;
      const replacement = `- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@".expo/.virtual-metro-entry"];
#else
  NSURL *customBundleURL = [BundleUpdater getBundleURL];
  if (customBundleURL) {
    return customBundleURL;
  }
  NSLog(@"[BundleUpdater] Using default bundle");
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}`;

      appDelegate.contents = appDelegate.contents.replace(sourceURLPattern, replacement);
      console.log('[BundleUpdater] sourceURLForBridge method modified successfully');
    }

    console.log('[BundleUpdater] iOS plugin configuration completed');
    return config;
  });

  return config;
};

export default withBundleUpdater;
