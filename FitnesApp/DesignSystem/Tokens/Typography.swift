import SwiftUI

extension Font {
    enum App {
        // Space Grotesk — data & headlines
        static let displayLg = Font.custom("SpaceGrotesk-Bold", size: 56)
        static let headlineLg = Font.custom("SpaceGrotesk-Medium", size: 32)

        // SF Pro — functional UI
        static let titleLg = Font.system(size: 22, weight: .semibold)
        static let bodyMd = Font.system(size: 14, weight: .regular)
        static let labelSm = Font.system(size: 11, weight: .bold)
    }
}
