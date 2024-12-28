import SwiftUI

struct BackAlertModifier: ViewModifier {
    @Binding var showBackAlert: Bool
    var onStay: () -> Void
    var onGoBack: () -> Void
    var lastView: () -> NavigationDestination?
    
    func body(content: Content) -> some View {
        content
            .alert(isPresented: $showBackAlert) {
                Alert(
                    title: Text(title()),
                    message: Text(message()),
                    primaryButton: .default(Text("Stay"), action: onStay),
                    secondaryButton: destructiveButton()
                )
            }
    }
    
    private func title() -> String {
        if let lastView = lastView() {
            if case .screen7 = lastView {
                return "Leave Party"
            }
        }
        return "Warning"
    }
    
    private func message() -> String {
        if let lastView = lastView() {
            if case .screen7 = lastView {
                return "Are you sure you want to leave the party?"
            }
        }
        return "You will lose your progress"
    }
    
    private func destructiveButton() -> Alert.Button {
        if let lastView = lastView() {
            if case .screen7 = lastView {
                return .destructive(Text("Leave Party"), action: onGoBack)
            }
        }
        return .destructive(Text("Go Back"), action: onGoBack)
    }
}
