package io.fokus

import android.app.PendingIntent
import android.content.Intent
import androidx.core.app.NotificationCompat
import com.onesignal.NotificationExtenderService
import com.onesignal.OSNotificationReceivedResult
import org.json.JSONArray
import org.json.JSONObject
import java.util.*


class OneSignalNotificationService : NotificationExtenderService() {
	override fun onNotificationProcessing(notification: OSNotificationReceivedResult): Boolean {
		val payload = notification.payload
		if (payload.additionalData.has("buttons")) {
			addLocalizedButtons(JSONArray(payload.additionalData.optString("buttons")))
			return true
		}
		return false
	}

	private fun addLocalizedButtons(buttons: JSONArray) {
		val overrideSettings = OverrideSettings()
		overrideSettings.extender = NotificationCompat.Extender (
			fun (builder: NotificationCompat.Builder): NotificationCompat.Builder {
				val lang = Locale.getDefault().language
				for (i in 0 until buttons.length()) {
					val button = buttons.opt(i) as JSONObject
					val intent = Intent(this, MainActivity::class.java)
					intent.action = button.optString("id")
					val pendingIntent = PendingIntent.getActivity(this, 1, intent, PendingIntent.FLAG_UPDATE_CURRENT)
					val text = JSONObject(button.optString("text"))
					var buttonText = text.optString(lang, null)
					if (buttonText == null)
						buttonText = text.optString("en")
					builder.addAction(0, buttonText, pendingIntent)
				}
				return builder;
			}
		)
		displayNotification(overrideSettings)
	}
}
