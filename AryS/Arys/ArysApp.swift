import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct ArysApp: App {
    
    init() {
        print("Firebase初期化開始！")
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
