//
//  WatchConnectivityManager.swift
//  SpinifyWatch Watch App
//
//  Created by Muslim Mirzajonov on 18/05/26.
//

import WatchConnectivity
import Combine

final class WatchConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var receivedLangCode: String? = nil

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext context: [String: Any]) {
        if let lang = context["lang"] as? String {
            DispatchQueue.main.async {
                UserDefaults.standard.set(lang, forKey: "spinify_lang_code")
                self.receivedLangCode = lang
            }
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {}
}
