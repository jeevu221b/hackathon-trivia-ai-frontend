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
                    .opacity(0.8)
                    .scaleEffect(scaleEffect)
                    .animation(.easeInOut(duration: 0.5), value: scaleEffect)
            }
        }
        .onChange(of: counter) { newValue in
            if newValue % 30 == 0 {
                withAnimation {
                    scaleEffect = 1.2
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        scaleEffect = 1.0
                    }
                }
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
            return  Color(uiColor: hexStringToUIColor(hex: "FFB4B1"))
        } else if remainingTime < 30 {
            return Color(uiColor: hexStringToUIColor(hex: "BEB36D"))
        } else {
            return .white
        }
    }
}
