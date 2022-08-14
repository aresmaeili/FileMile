import NotificationBannerSwift
import Foundation
import UIKit

class BannerManager {
    
    static func showBanners(
        _ banners: [FloatingNotificationBanner],
        in notificationBannerQueue: NotificationBannerQueue
    ) {
        banners.forEach { banner in
            banner.show(
                bannerPosition: .top,
                queue: notificationBannerQueue,
                cornerRadius: 8,
                shadowColor: UIColor(red: 0.431, green: 0.459, blue: 0.494, alpha: 1),
                shadowBlurRadius: 16,
                shadowEdgeInsets: UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
            )
        }
    }
    
    /**
     This function shows an error message on top half of the screen.
     - parameter errorMessageStr: error message that we want to display.
     - parameter color: color of status bar (default is brandOrange(MCI's orange))
     */
    static func showMessage(errorMessageStr: String, _ style: BannerStyle = .warning)  {
        DispatchQueue.main.async {
            let banner = FloatingNotificationBanner(title: "", subtitle: errorMessageStr, style: style, colors: CustomBannerColors())
            banner.titleLabel?.textAlignment = .center
            banner.subtitleLabel?.textAlignment = .center
            banner.dismissOnTap = true
            banner.haptic = .light
            showBanners([banner], in: NotificationBannerQueue(maxBannersOnScreenSimultaneously: 1))
        }
    }
    
}
class CustomBannerColors: BannerColorsProtocol {
    internal func color(for style: BannerStyle) -> UIColor {
        switch style {
        case .danger:
            return .red
        case .warning:
            return .orange
        case .success:
            return .green
        case .info:
            return .blue
        default:
            return .lightGray
        }
    }
}

