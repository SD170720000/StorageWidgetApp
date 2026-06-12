import AppKit
import SwiftUI

struct DriveIconView: View {
    let drive: DriveInfo
    var size: CGFloat = 54

    var body: some View {
        Image(nsImage: NSWorkspace.shared.icon(forFile: drive.mountPath))
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}
