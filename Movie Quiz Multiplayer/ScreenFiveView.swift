import SwiftUI


struct FactsView: View {
    let facts: [String]
    @State private var shuffledFacts: [String] = []
    @State private var currentFactIndex = 0
    
    var body: some View {
        VStack {
            if !shuffledFacts.isEmpty {
                Text(shuffledFacts[currentFactIndex])
                    .font(Font.custom("CircularSpUIv3T-Book", size: 15))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding()
                    .id(shuffledFacts[currentFactIndex])
                    .transition(.opacity.animation(.linear))
            }
        }
        .onAppear {
            resetCounter()
            shuffledFacts = facts.shuffled()
            startFactRotation()
        }
    }
    
    private func resetCounter() {
           currentFactIndex = 0
       }
    
    private func startFactRotation() {
        Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
            withAnimation {
                currentFactIndex = (currentFactIndex + 1) % shuffledFacts.count
            }
        }
    }
}


struct CrownView: View {
    let score: Int
    
    var body: some View {
        ZStack {
                if score >= 8 {
                    Image(score == 10 ? "goldcrown" : score == 9 ? "silvercrown" : "bronzecrown")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding(.top, -73)
                        .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "F2C504")))
                        .zIndex(2)
                        .rotationEffect(.degrees(8))
                } else {
                    EmptyView()
                }
        }
    }
}

struct StarsView: View {
    let stars: Int
    
    var body: some View {
        VStack {
            HStack(spacing: 2) {
                Image(stars >= 1 ? "filledstar" : "emptystar")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .padding(.top, -21)
                
                Image(stars >= 2 ? "filledstar" : "emptystar")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .padding(.top, -28)
                
                Image(stars >= 3 ? "filledstar" : "emptystar")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundColor(Color(uiColor: hexStringToUIColor(hex: stars >= 3 ? "FFB800" : "9E9E9E")))
                    .padding(.top, -21)
            }
        }
    }
}

struct ScreenFive: View {
    let subcategoryId: String
    @State private var subcategory: Subcategory?
    @State private var levels: [Level] = []
    
    let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 140))
    ]
    
    var body: some View {
        ZStack {
            Color(uiColor: hexStringToUIColor(hex: "171819"))
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                VStack(spacing: 0) {
                    Menu()
                    PartyBox()
                        .padding(.top, 30)
                        .padding(.bottom, 20)
                        .padding(.leading, 18)
                        .padding(.trailing, 20)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Levels")
                    }
                    .padding(.leading, 22)
                    .padding(.bottom, 0)
                    .tracking(-1.55)
                    .foregroundColor(.white)
                    .font(Font.custom("CircularSpUIv3T-Bold", size: 45))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(subcategory?.name ?? "")
                            .foregroundColor(.white)
                            .opacity(0.3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(Font.custom("CircularSpUIv3T-Book", size: 20))
                            .padding(.leading, 27)
                            .padding(.bottom, 35)
                    }
                }
                
                LazyVGrid(columns: columns, spacing: 17) {
                    ForEach(levels) { level in
                        LevelButton(number: level.level, isLocked: !level.isUnlocked, star: level.star ?? 0, levelId:level.id, score: level.score ?? 0)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 20)
                .padding(.leading, 20)
                
                Spacer()
                
                if let subcategory = subcategory {
                    if let facts = subcategory.facts, !facts.isEmpty {
                        FactsView(facts: facts)
                            .padding(.trailing, 20)
                            .padding(.leading, 20)
                    }
                }
                    
            }
            .frame(alignment: .leading)
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            fetchSubcategoryAndLevels()
        }
    }
    
    private func fetchSubcategoryAndLevels() {
        let subcategories = DataManager.shared.getSubcategories()
        let allLevels = DataManager.shared.getLevels()
        
        if let subcategory = subcategories.first(where: { $0.id == subcategoryId }) {
            self.subcategory = subcategory
            
            let uniqueLevels = allLevels.filter { $0.subCategory == subcategoryId }
                .reduce(into: [String: Level]()) { result, level in
                    result[level.id] = level
                }
                .values
                .sorted { $0.level < $1.level }
            
            self.levels = Array(uniqueLevels)
        }
    }
}

struct LevelButton: View {
    let number: Int
    let isLocked: Bool
    let star: Int
    let levelId: String
    let score: Int
    @EnvironmentObject private var navigationStore: NavigationStore
    @EnvironmentObject private var socketHandler: SocketHandler
    @EnvironmentObject var AppState: Game
    @State var isTapped = false
    
    var body: some View {
        ZStack{
            CrownView(score: score)
            ZStack {
                if isLocked {
                    Image(systemName: "lock")
                        .font(.title)
                        .foregroundColor(.white)
                        .opacity(0.8)
                } else {
                    VStack {
                        StarsView(stars: star)
                    }
                    Text("\(number)")
                        .font(Font.custom("CircularSpUIv3T-Bold", size: 23))
                        .foregroundColor(.white)
                        .padding(.top, 15)
                }
            }
            .zIndex(0)
            .frame(width: 73, height: 80)
            .background(Color(uiColor: hexStringToUIColor(hex: "167763")))
            .clipShape(RoundedRectangle(cornerRadius: 13))
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(Color(uiColor: hexStringToUIColor(hex: "82A170")).opacity(0.4), lineWidth: 5)
                    )
            .scaleEffect(isTapped ? 1.5 : 1)
            .animation(.spring(response: 0.4, dampingFraction: 0.6))
            .onTapGesture {
                socketHandler.updatePartyData(name: String(number) , id: "level", value: levelId, sessionId: AppState.partySession)
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    isTapped.toggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    isTapped.toggle()
                    if(!isLocked){
                        navigationStore.push(to: .screen6(levelId))
                    }
                }
            }
            .opacity(isLocked ? 0.6 : 1)
            .padding(.bottom, 17)
        }
    }
}

#Preview {
    ScreenFive(subcategoryId: "660d195b229326feb00dfc12")
        .statusBar(hidden: true)
        .environmentObject(NavigationStore())
        .environmentObject(Game())
    
}
