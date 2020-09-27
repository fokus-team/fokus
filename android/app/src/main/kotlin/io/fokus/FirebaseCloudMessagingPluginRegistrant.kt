package io.fokus

import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin
import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin

object FirebaseCloudMessagingPluginRegistrant {
	fun registerWith(registry: PluginRegistry) {
		if (alreadyRegisteredWith(registry))
			return

		FirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"))
		FlutterLocalNotificationsPlugin.registerWith(registry.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"));
	}

	private fun alreadyRegisteredWith(registry: PluginRegistry): Boolean {
		val key: String = FirebaseCloudMessagingPluginRegistrant::class.java.getCanonicalName()
		if (registry.hasPlugin(key))
			return true
		registry.registrarFor(key)
		return false
	}
}
