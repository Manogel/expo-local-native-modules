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
    }

    private val mContext = appContext.reactContext
        ?: throw IllegalStateException("React context is not available")

    private val preferencesStorage by lazy {
        BundlePreferencesStorage(mContext)
    }

    private fun getAppVersion(): String {
        return try {
            val pInfo = mContext.packageManager.getPackageInfo(mContext.packageName, 0)
            pInfo.versionName ?: ""
        } catch (e: PackageManager.NameNotFoundException) {
            ""
        }
    }

    fun getBundleUrl(): String? {
        val isValid = this.validateBundle()

        if(isValid) {
            Log.d(NAME, "Custom bundle found, using it...")
            return getBundlePath(mContext).path
        }

        Log.d(NAME, "Custom bundle not found, using default bundle")
        return null
    }
    
    private fun clearBundle() {
      Log.d(NAME, "Removing obsolete bundle...")
        FSUtil.removeFile(getBundlePath(mContext))
        Log.d(NAME, "Clearing storage...")
        preferencesStorage.clearPreferences()
    }

    private fun validateBundle(): Boolean {
        val currentAppVersion = getAppVersion()
        val prefs = preferencesStorage.getPreferences()

        if (prefs.appVersion == currentAppVersion && getBundlePath(mContext).exists()) return true

        if (prefs.bundleVersion.isNotEmpty() || getBundlePath(mContext).exists()) {
            clearBundle()
        }

        return false
    }

    override fun definition() = ModuleDefinition {
        Name("BundleUpdater")

        AsyncFunction("getBundleInfo") {
            val prefs = preferencesStorage.getPreferences()
            val bundlePath = getBundlePath(mContext)
            mapOf(
                "currentAppVersion" to getAppVersion(),
                "bundleVersion" to prefs.bundleVersion,
                "haveBundleSaved" to bundlePath.exists(),
                "bundlePath" to bundlePath.path
            )
        }

        AsyncFunction("applyBundle") { bundlePath: String, bundleVersion: String ->
            if (getBundlePath(mContext).exists()) {
                getBundlePath(mContext).delete()
            }
            FSUtil.moveWithOverride(bundlePath, getBundlePath(mContext).path)
            preferencesStorage.savePreferences(
                PreferenceData(getAppVersion(), bundleVersion)
            )
            getBundlePath(mContext).path
        }

        Function("clearBundle") {
            clearBundle()
        }
    }
}
