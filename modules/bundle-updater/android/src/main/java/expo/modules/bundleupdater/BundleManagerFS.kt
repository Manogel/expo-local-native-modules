package expo.modules.bundleupdater

import android.content.Context
import android.util.Log

class BundlePreferencesStorage(private val context: Context) {
    companion object {
        private const val NAME = "BundlePreferencesStorage"
        private const val STORE_FILENAME = "_RNBundleUpdater"
        private const val BUNDLE_VERSION = "_RNBundleUpdater_bundleVersion"
        private const val APP_VERSION = "_RNBundleUpdater_appVersion"
    }

    fun getPreferences(): PreferenceData {
        val prefs = context.getSharedPreferences(STORE_FILENAME, Context.MODE_PRIVATE)
        return if (prefs.contains(BUNDLE_VERSION)) {
            val bundleVersion = prefs.getString(BUNDLE_VERSION, "")!!
            val appVersion = prefs.getString(APP_VERSION, "")!!
            PreferenceData(appVersion, bundleVersion)
        } else {
            createEmptyStore()
        }
    }

    fun clearPreferences() {
        savePreferences(PreferenceData("", ""))
    }

    fun savePreferences(preferenceData: PreferenceData) {
        val prefs = context.getSharedPreferences(STORE_FILENAME, Context.MODE_PRIVATE)
        val editor = prefs.edit()

        editor.putString(BUNDLE_VERSION, preferenceData.bundleVersion)
        editor.putString(APP_VERSION, preferenceData.appVersion)
        editor.apply()
        Log.d(NAME, "Bundle info was saved to prefs.")
    }

    private fun createEmptyStore(): PreferenceData {
        Log.d(NAME, "Creating empty prefs...")
        val prefsData = PreferenceData("", "")
        savePreferences(prefsData)
        return prefsData
    }
} 