import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var name: String
    @Binding var play: Bool
    var loopMode: LottieLoopMode = .loop // Add this line to allow customization of loop mode

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        let animation = LottieAnimation.named(name)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode // Set the loop mode here
        
        if play {
            animationView.play()
        }
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let animationView = uiView.subviews.first as? LottieAnimationView {
            if play {
                animationView.play()
            } else {
                animationView.stop()
            }
        }
    }
}

#Preview {
    GeometryReader { geometry in
        LottieView(name: "info3", play: .constant(true), loopMode: .loop)
            .frame(width: geometry.size.width)
            .padding(0)
            .edgesIgnoringSafeArea(.all)
            .ignoresSafeArea(.all)
            .navigationBarBackButtonHidden(true)
    }
}
