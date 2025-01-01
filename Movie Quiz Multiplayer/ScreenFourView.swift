import SwiftUI

struct ScreenFour: View {
    let catId: String
    @State private var subcategories: [Subcategory] = []
    @State private var categories: [Category] = DataManager.shared.getCategories()
    
    @EnvironmentObject private var navigationStore : NavigationStore
    let columns = [
        GridItem(.adaptive(minimum: 110))
    ]
    @State private var cat: Category?
    var body: some View {
        ZStack {
//            Color(uiColor: hexStringToUIColor(hex: "171819"))
//                .frame(alignment: .topLeading)
//                .edgesIgnoringSafeArea(.all)
            
            VStack {
                VStack(spacing: 0){
                    Menu()
                    PartyBox()
                        .padding(.top, 30)
                        .padding(.bottom, 20)
                        .padding(.leading, 18)
                        .padding(.trailing, 20)
                    VStack(alignment: .leading, spacing:0){
                        Text(cat?.name ?? "")
                    }
                    .padding(.leading, 22)
                    .padding(.bottom, 0)
                    .tracking(-1.55)
                    .foregroundColor(.white)
                    .font(Font.custom("CircularSpUIv3T-Bold", size: 45))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack{
                            Image(systemName: "bolt.fill")
                                .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "5F672D")))
                                .font(.system(size: 12))
                                .padding(.trailing, -4)
                                .padding(.leading, 24)
                            Text(cat?.subtext ?? "")
                                .foregroundColor(.white)
                                .opacity(0.3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(Font.custom("CircularSpUIv3T-Book", size: 16))
                                
                                
                        }
                    }.padding(.bottom, 35)
                }
                
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(subcategories, id: \.id) { subcategory in
                        GenreButton(title: subcategory.name, subcategoryId: subcategory.id)
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                Spacer()
            }
        }
        .background(Color(uiColor: hexStringToUIColor(hex: "171819")))
        .navigationBarBackButtonHidden(true)
        .onAppear {
            subcategories = DataManager.shared.getSubcategoriesForCategory(categoryId: catId)
            self.cat = categories.first(where: { $0.id == catId })
        }
    }
}

struct GenreButton: View {
    let title: String
    let subcategoryId: String
    @EnvironmentObject private var navigationStore : NavigationStore
    @EnvironmentObject private var socketHandler: SocketHandler
    @EnvironmentObject var AppState: Game
    @State var isTapped = false;
    
    
    var body: some View {
        VStack(alignment: .center){
            Text(title)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .font(Font.custom("CircularSpUIv3T-Bold", size: 17))
                .tracking(-0.65)
                .foregroundColor(.black)
//                .padding(.leading, 14)
//                .padding(.top, -28)
        }
        .frame(width: 110, height: 110, alignment: .center)
        .background(
            Text(String(title.first ?? " "))
                .font(Font.custom("CircularSpUIv3T-Bold", size: 190))
                .foregroundColor(Color(white: 0.9))
                .opacity(0.40)
                .offset(x: 0, y: 0)
                .lineLimit(1)
                .zIndex(-1)
                .allowsHitTesting(false)
        )
        .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(uiColor: hexStringToUIColor(hex: "FFFFF")).opacity(0.5), lineWidth: 8)
                )
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .scaleEffect(isTapped ? 1.5 : 1)
        .animation(.spring(response: 0.4, dampingFraction: 0.6))
        .onTapGesture {
            if !AppState.partySession.isEmpty {
                socketHandler.updatePartyData(name: title , id: "subcategory", value: subcategoryId, sessionId: AppState.partySession)
            }
            
            withAnimation(.easeInOut(duration: 0.3)) {
                isTapped.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                isTapped.toggle()
                navigationStore.push(to: .screen5(subcategoryId))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenFour(catId: "660d14235fc2cab79f75a6dc")
            .environmentObject(NavigationStore())
            .environmentObject(Game())

    }
}
