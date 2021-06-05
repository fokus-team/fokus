package io.fokus

import android.annotation.SuppressLint
import android.content.Context
import androidx.core.app.NotificationCompat
import com.onesignal.OSNotification
import com.onesignal.OSNotificationReceivedEvent
import com.onesignal.OneSignal
import org.json.JSONArray
import org.json.JSONObject
import java.util.*


class OneSignalNotificationService : OneSignal.OSRemoteNotificationReceivedHandler {
	override fun remoteNotificationReceived(context: Context, event: OSNotificationReceivedEvent) {
		val notification: OSNotification = event.getNotification()
		val mutableNotification = notification.mutableCopy()
		val payload = mutableNotification.additionalData
		if (payload != null && payload.has("buttons")) {
			mutableNotification.setExtender(addLocalizedButtons(JSONArray(payload.optString("buttons"))))
			event.complete(mutableNotification)
		}
	}

	private fun addLocalizedButtons(buttons: JSONArray): NotificationCompat.Extender {
		return NotificationCompat.Extender(
			fun(builder: NotificationCompat.Builder): NotificationCompat.Builder {
				val lang = Locale.getDefault().language
				for (i in 0 until buttons.length()) {
					val button = buttons.opt(i) as JSONObject
					val id = button.optString("id")
					@SuppressLint("RestrictedApi")
					val action = builder.mActions.find { it.title.toString() == id } ?: continue

					val text = JSONObject(button.optString("text"))
					var buttonText = text.optString(lang, null)
					if (buttonText == null)
						buttonText = text.optString("en")
					action?.title = buttonText;
				}
				return builder;
			}
		)
	}
}
