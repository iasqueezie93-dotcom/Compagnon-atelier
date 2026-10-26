package fr.compagnon.compagnon_atelier

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/** Gives priority to workshop Wi-Fi even if mobile data remains enabled. */
class MainActivity : FlutterActivity() {
    private val channelName = "compagnon_atelier/network"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method != "bindWifi") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                try {
                    val manager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                    val wifi = manager.allNetworks.firstOrNull { network ->
                        manager.getNetworkCapabilities(network)?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true
                    }
                    if (wifi == null) {
                        manager.bindProcessToNetwork(null)
                        result.success(mapOf("bound" to false, "message" to "Aucun réseau Wi-Fi détecté"))
                    } else {
                        val bound = manager.bindProcessToNetwork(wifi)
                        result.success(mapOf("bound" to bound,
                            "message" to if (bound) "Trafic application dirigé vers le Wi-Fi" else "Impossible de privilégier le Wi-Fi"))
                    }
                } catch (ex: Exception) {
                    result.error("NETWORK", ex.message, null)
                }
            }
    }
}
