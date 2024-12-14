import SwiftUI
import Combine

struct ThreeBounceAnimation: View {
    
    struct AnimationData {
        var delay: TimeInterval
    }
    
    static let DATA = [
        AnimationData(delay: 0.0),
        AnimationData(delay: 0.2),
        AnimationData(delay: 0.4),
    ]
    
    @State var color: Color
    @State var width: CGFloat
    @State var height: CGFloat
    @State var scales: [CGFloat] = DATA.map { _ in return 0 }
    
    var animation = Animation.easeInOut.speed(0.5)
    
    init(color: Color, width: CGFloat, height: CGFloat) {
        self.color = color
        self.width = width
        self.height =  height
    }
    
    var body: some View {
        HStack {
            DotView(color: .constant(color), scale: .constant(scales[0]), width: width, height: height)
            DotView(color: .constant(color), scale: .constant(scales[1]), width: width, height: height)
            DotView(color: .constant(color), scale: .constant(scales[2]), width: width, height: height)
        }
        .onAppear {
            animateDots()
        }
    }
    
    func animateDots() {
        for (index, data) in Self.DATA.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + data.delay) {
                animateDot(binding: $scales[index], animationData: data)
            }
        }
        
        //Repeat
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            animateDots()
        }
    }
    
    func animateDot(binding: Binding<CGFloat>, animationData: AnimationData) {
        withAnimation(animation) {
            binding.wrappedValue = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(animation) {
                binding.wrappedValue = 0.2
            }
        }
    }
}

private struct DotView: View {
    
    @Binding var color: Color
    @Binding var scale: CGFloat
    var width: CGFloat
    var height: CGFloat
    
    
    var body: some View {
        Circle()
            .scale(scale)
            .fill(color.opacity(scale >= 0.7 ? scale : scale - 0.1))
            .frame(width: width, height: height, alignment: .center)
    }
}

struct ThreeBounceAnimation_Previews: PreviewProvider {
    static var previews: some View {
        ThreeBounceAnimation(color: .black, width: 50, height: 50)
    }
}


