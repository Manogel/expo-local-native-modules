package expo.modules.bundleupdater

import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import java.io.File

class BundleUpdaterModule : Module() {
    companion object {
        private const val NAME = "BundleUpdater"
        
        fun getBundlePath(ctx: Context): File {
            return File(ctx.filesDir.path + "/index.android.custom.bundle")
        }

        fun getJSBundleFile(context: Context): String? {
            val bundlePath = getBundlePath(context)
            val preferencesStorage = BundlePreferencesStorage.getInstance(context)
            val prefs = preferencesStorage.getPreferences()
            
            try {
                val pInfo = context.packageManager?.getPackageInfo(context.packageName ?: "", 0)
                val currentAppVersion = pInfo?.versionName ?: ""

                // Valida se o bundle é compatível com a versão atual do app
                if (prefs.appVersion == currentAppVersion && bundlePath.exists()) {
                    Log.d(NAME, "Custom bundle found, using it...")
                    return bundlePath.path
                }

                // Limpa o bundle se estiver desatualizado
                if (prefs.bundleVersion.isNotEmpty() || bundlePath.exists()) {
                    Log.d(NAME, "Removing obsolete bundle...")
                    FSUtil.removeFile(bundlePath)
                    Log.d(NAME, "Clearing storage...")
                    preferencesStorage.clearPreferences()
                }
            } catch (e: Exception) {
                Log.e(NAME, "Error validating bundle: ${e.message}")
            }

            Log.d(NAME, "Custom bundle not found or invalid, using default bundle")
            return null
        }
    }

    private fun getAppVersion(): String {
        val context = appContext.reactContext
        if (context == null) {
            Log.e(NAME, "React Context is not available")
            return ""
        }
        return try {
            val pInfo = context.packageManager?.getPackageInfo(context.packageName ?: "", 0)
            pInfo?.versionName ?: ""
        } catch (e: PackageManager.NameNotFoundException) {
            ""
        }
    }

    private fun clearBundle() {
        val context = appContext.reactContext
        if (context != null) {
            val preferencesStorage = BundlePreferencesStorage.getInstance(context)
            Log.d(NAME, "Removing obsolete bundle...")
            FSUtil.removeFile(getBundlePath(context))
            Log.d(NAME, "Clearing storage...")
            preferencesStorage.clearPreferences()
        } else {
            Log.e(NAME, "React Context is not available")
            return
        }
    }

    override fun definition() = ModuleDefinition {
        Name("BundleUpdater")

        AsyncFunction("getBundleInfo") {
            val context = appContext.reactContext
            if (context == null) {
                Log.e(NAME, "React Context is not available")
                return@AsyncFunction null
            }
            val preferencesStorage = BundlePreferencesStorage.getInstance(context)
            val prefs = preferencesStorage.getPreferences()
            val bundlePath = getBundlePath(context)
            mapOf(
                "currentAppVersion" to getAppVersion(),
                "bundleVersion" to prefs.bundleVersion,
                "haveBundleSaved" to bundlePath.exists(),
                "bundlePath" to bundlePath.path
            )
        }

        AsyncFunction("applyBundle") { bundlePath: String, bundleVersion: String ->
            val context = appContext.reactContext
            if (context == null) {
                Log.e(NAME, "React Context is not available")
                return@AsyncFunction null
            }
            val preferencesStorage = BundlePreferencesStorage.getInstance(context)
            if (getBundlePath(context).exists()) {
                getBundlePath(context).delete()
            }
            FSUtil.moveWithOverride(bundlePath, getBundlePath(context).path)
            preferencesStorage.savePreferences(
                PreferenceData(getAppVersion(), bundleVersion)
            )
            getBundlePath(context).path
        }

        Function("clearBundle") {
            clearBundle()
        }
    }
}
