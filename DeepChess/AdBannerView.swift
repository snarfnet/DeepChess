import SwiftUI

#if targetEnvironment(simulator)
struct AdBannerView: View {
    let adUnitID: String
    var body: some View {
        Rectangle()
            .fill(Color.black.opacity(0.15))
            .overlay(
                Text("AD")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.secondary)
            )
    }
}
#else
import GoogleMobileAds

struct AdBannerView: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = adUnitID
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {
        if uiView.rootViewController == nil,
           let windowScene = uiView.window?.windowScene,
           let root = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            uiView.rootViewController = root
            uiView.load(GADRequest())
        }
    }
}
#endif
