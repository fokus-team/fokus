package io.fokus

import android.content.Context
import androidx.multidex.MultiDex
import io.flutter.app.FlutterApplication

class FokusApplication : FlutterApplication() {
	override fun attachBaseContext(base: Context) {
		super.attachBaseContext(base)
		MultiDex.install(this)
	}
}
