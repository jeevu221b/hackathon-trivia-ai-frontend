import SwiftUI
import Pow

struct Example: View {
  @State var stars = 18

  var body: some View {
    ZStack {
      Color.black
        
      Button {
        stars += 1
      } label: {
        Text("update")
      }.padding(.bottom, 100)
        
        Text("\(stars)").contentTransition(.numericText())
//              .foregroundColor(scoreTextColor)
              .font(Font.custom("CircularSpUIv3T-Bold", size: 20))
              .opacity(0.65)
      .changeEffect(
        .rise(origin: UnitPoint(x: 0.75, y: 0.25)) {
          Text("+1").font(Font.custom("CircularSpUIv3T-Bold", size: 27))
        }, value: stars)
      .foregroundStyle(.yellow)
    }
  }
}


#Preview {
    Example()
}
