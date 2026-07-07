import SwiftUI

@main
struct JetlaglyApp: App {
    @StateObject private var store = Store()
    @StateObject private var purchases = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(purchases)
                .accentColor(Theme.accent)
        }
    }
}
