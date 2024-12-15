import SwiftUI
import Pow
import SwiftfulLoadingIndicators


struct PopCorn: View {
    @State var isAdded = false
    @State var val = 0

    var body: some View{
        Spacer()
            if isAdded {
                Image("popcorn")
                    .resizable()
                    .scaledToFill()
                    .padding(.top, 504)
                    .padding(.leading, -30)
                    .frame(width: 120, height: 120, alignment: .center)
                    .changeEffect(.shake(rate: .fast), value: val)

                LoadingIndicator(animation: .pulse, color: .black.opacity(0.5), size: .medium, speed: .normal)
                    .padding(.top, 310)
                    .padding(.leading, -30)
//                Text("Updting your score")
            }
        ZStack{}.onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.spring()) {
                    isAdded.toggle()
                }
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                val = 1
            }
        }
        
    }
    
}

struct PopcornView: View {
    
    var body: some View {
                        PopCorn().transition(
                .asymmetric(
                    insertion: .movingParts.swoosh,
                    removal: .opacity
                )
            )
            
        
    }
}
        

#Preview {
    PopcornView()
}
