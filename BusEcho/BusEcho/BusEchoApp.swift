import SwiftUI

@main
struct BusEchoApp: App {
    @StateObject var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            BaseNavigationView{
                AppLaunchView()
                    .environmentObject(appState)
            }
        }
    }
}

