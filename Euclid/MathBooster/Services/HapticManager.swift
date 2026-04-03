import UIKit

/// Singleton that provides haptic feedback throughout the app.
final class HapticManager {
    static let shared = HapticManager()
    private init() {}

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()

    func buttonTap() {
        lightImpact.impactOccurred()
    }

    func submit() {
        mediumImpact.impactOccurred()
    }

    func correct() {
        notification.notificationOccurred(.success)
    }

    func wrong() {
        notification.notificationOccurred(.error)
    }

    func tick() {
        lightImpact.impactOccurred(intensity: 0.4)
    }

    func gameEvent() {
        heavyImpact.impactOccurred()
    }
}
