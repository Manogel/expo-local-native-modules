"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const config_plugins_1 = require("@expo/config-plugins");
const withBundleUpdater = (config) => {
    return (0, config_plugins_1.withMainApplication)(config, async (config) => {
        const mainApplication = config.modResults;
        console.log('[BundleUpdater] Starting plugin configuration...');
        // Adiciona os imports necessários
        if (!mainApplication.contents.includes('import expo.modules.bundleupdater.BundleUpdaterModule')) {
            console.log('[BundleUpdater] Adding import statement...');
            mainApplication.contents = mainApplication.contents.replace(/import com\.facebook\.react\.ReactApplication/, `import com.facebook.react.ReactApplication\nimport expo.modules.bundleupdater.BundleUpdaterModule`);
            console.log('[BundleUpdater] Import added successfully');
        }
        // Modifica o getJSBundleFile para incluir nossa lógica
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
        console.log('[BundleUpdater] Plugin configuration completed');
        return config;
    });
};
exports.default = withBundleUpdater;
