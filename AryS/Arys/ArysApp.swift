import SwiftUI
import FirebaseCore
import FirebaseAuth // ← ① インポートを追加

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Firebase初期化開始！")
        FirebaseApp.configure()
        
        // ↓ ② ここに言語設定を追加
        Auth.auth().languageCode = "ja"
        
        return true
    }
}

@main
struct ArysApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
