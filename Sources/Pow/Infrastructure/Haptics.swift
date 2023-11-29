import SwiftUI

#if os(iOS)
import CoreHaptics

internal struct Haptics {
    private static var engine: CHHapticEngine? = {
        return try? CHHapticEngine()
    }()

    private static var supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics

    private static var counter: Int = 0 {
        didSet {
            guard supportsHaptics else { return }

            if oldValue == 0 && counter == 1 {
                #if DEBUG
                print("[Pow] Starting haptics engine.")
                #endif

                try? engine?.start()
            } else if counter == 0 {
                #if DEBUG
                print("[Pow] Stopping haptics engine.")
                #endif

                engine?.stop()
            }
        }
    }

    static func acquire() {
        counter += 1
    }

    static func release() {
        counter -= 1
    }

    static func play(_ pattern: CHHapticPattern, at time: TimeInterval = CHHapticTimeImmediate) {
        let player = try? engine?.makePlayer(with: pattern)

        try? player?.start(atTime: time)
    }
}

internal extension View {
    func usesCustomHaptics() -> some View {
        modifier(
            _AppearanceActionModifier {
                Haptics.acquire()
            } disappear: {
                Haptics.release()
            }
        )
    }
}
#else
internal extension View {
    func usesCustomHaptics() -> Self {
        self
    }
}
#endif
