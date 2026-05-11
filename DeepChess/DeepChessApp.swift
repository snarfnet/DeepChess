import SwiftUI
import AppTrackingTransparency

#if !targetEnvironment(simulator)
import GoogleMobileAds
#endif

@main
struct DeepChessApp: App {
    init() {
        #if !targetEnvironment(simulator)
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    try? await Task.sleep(for: .seconds(1))
                    ATTrackingManager.requestTrackingAuthorization { _ in }
                }
        }
    }
}
