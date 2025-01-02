import SwiftUI

let timer = Timer
    .publish(every: 1, on: .main, in: .common)
    .autoconnect()

struct Clock: View {
    var counter: Int
    var countTo: Int
    @State private var scaleEffect: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            VStack {
                Text(counterToMinutes())
                    .contentTransition(.numericText())
                    .font(.custom("DINAlternate-Bold", size: 20))
                    .foregroundStyle(textColor())
                    .scaleEffect(scaleEffect)
                    .animation(.easeInOut(duration: 0.5), value: scaleEffect)
            }
        }
    }
    
    func counterToMinutes() -> String {
        let currentTime = countTo - counter
        let seconds = currentTime % 60
        let minutes = Int(currentTime / 60)
        return "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
    }
    
    func textColor() -> Color {
        let remainingTime = countTo - counter
        if remainingTime < 10 {
            return  Color(uiColor: hexStringToUIColor(hex: "FF918C"))
        } else if remainingTime < 30 {
            return Color(uiColor: hexStringToUIColor(hex: "FFD582"))
        } else {
            return .white
        }
    }
}
