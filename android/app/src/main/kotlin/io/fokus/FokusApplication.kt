package io.fokus

import android.content.Context
import androidx.multidex.MultiDex
import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService

class FokusApplication : FlutterApplication(), PluginRegistrantCallback {
	override fun attachBaseContext(base: Context) {
		super.attachBaseContext(base)
		MultiDex.install(this)
	}

	override fun onCreate() {
		super.onCreate();
		FlutterFirebaseMessagingService.setPluginRegistrant(this)
	}

	override fun registerWith(registry: PluginRegistry) {
		//FirebaseCloudMessagingPluginRegistrant.registerWith(registry);
	}
}
