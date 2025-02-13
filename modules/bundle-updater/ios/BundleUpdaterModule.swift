import ExpoModulesCore

public class BundleUpdaterModule: Module {
    public func definition() -> ModuleDefinition {
        Name("BundleUpdater")

        AsyncFunction("applyBundle") { (bundlePath: String, bundleVersion: String, promise: Promise) in
            let bundleUpdater = BundleUpdater()
            bundleUpdater.applyBundle(bundlePath, bundleVersion: bundleVersion, resolver: { result in
                promise.resolve(result)
            }, rejecter: { code, message, error in
                promise.reject(code ?? "internal error", message ?? "Fail to apply bundle")
            })
        }

        AsyncFunction("getBundlePath") { (promise: Promise) in
            let bundleUpdater = BundleUpdater()
            let results = bundleUpdater.getBundlePath
            promise.resolve(results)
        }

        Function("getBundleInfo") { () -> String in
            let bundleUpdater = BundleUpdater()
            return bundleUpdater.getBundleInfo()
        }

        Function("clearBundle") {
            let bundleUpdater = BundleUpdater()
            bundleUpdater.clearBundle()
        }
    }
} 
