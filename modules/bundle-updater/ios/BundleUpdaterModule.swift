import ExpoModulesCore

public class BundleUpdaterModule: Module {
  // Each module class must implement the definition function. The definition consists of components
  // that describes the module's functionality and behavior.
  // See https://docs.expo.dev/modules/module-api for more details about available components.
  public func definition() -> ModuleDefinition {
    // Sets the name of the module that JavaScript code will use to refer to the module. Takes a string as an argument.
    // Can be inferred from module's class name, but it's recommended to set it explicitly for clarity.
    // The module will be accessible from `requireNativeModule('BundleUpdater')` in JavaScript.
    Name("BundleUpdater")

    // Defines a JavaScript synchronous function that runs the native code on the JavaScript thread.
    Function("applyBundle") { (bundlePath: String, bundleVersion: String) in
      // log the bundle path and version
      print("[NativeSide] bundlePath: \(bundlePath), bundleVersion: \(bundleVersion)")
    }

    AsyncFunction("getBundleInfo") { () -> [String: Any] in
        print("[NativeSide] getBundleInfo")
        
        // Get current app version from main bundle
        let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        
        // TODO: These values should be retrieved from your actual bundle storage mechanism
        let bundleVersion = "1.0.0" // Replace with actual stored bundle version
        let haveBundleSaved = false // Replace with actual check if bundle exists
        let bundlePath = "" // Replace with actual bundle path if it exists
        
        return [
            "currentAppVersion": currentAppVersion,
            "bundleVersion": bundleVersion,
            "haveBundleSaved": haveBundleSaved,
            "bundlePath": bundlePath
        ]
    }

    Function("clearBundle") {
      print("[NativeSide] clearBundle")
    }
  }
}
