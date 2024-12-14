import SwiftUI

struct ScreenThree: View {
    @EnvironmentObject private var navigationStore: NavigationStore
    @State private var isTapped1 = false
    @State private var isLeaderTapped = false
    @State private var categories: [Category] = DataManager.shared.getCategories()
    @EnvironmentObject var AppState: Game

    var body: some View {
        VStack(spacing: 0) {
            Menu()
            categoryTitle
            favoriteGenresCard
            categoryCardsScrollView
            Spacer()
            LeaderboardButton()
                .padding(.bottom, 10)
                .scaleEffect(isLeaderTapped ? 1.04 : 1)
                .animation(.spring(response: 0.4, dampingFraction: 0.6))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isLeaderTapped.toggle()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isLeaderTapped.toggle()
                        navigationStore.push(to: .leaderBoardPage)
                    }
                }
        }
        .background(Color(uiColor: hexStringToUIColor(hex: "171819")))
        .frame(alignment: .topLeading)
        .navigationBarBackButtonHidden(true)
    }
    
    
    private var categoryTitle: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Select")
            Text("a category")
                .padding(.top, -14)
        }
        .padding(.leading, 20)
        .padding(.bottom, 20)
        .tracking(-1.85)
        .foregroundColor(.white)
        .font(Font.custom("CircularSpUIv3T-Bold", size: 50))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private var favoriteGenresCard: some View {
        if let bannerCategory = categories.first(where: { $0.isBanner }),
           let image = bannerCategory.image,
           let displayName = bannerCategory.displayName {
            let displayNameParts = displayName.components(separatedBy: "$n")
            
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Play your")
                            .tracking(-0.1)
                            .font(Font.custom("CircularStd-Book", size: 12))
                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "5F672D")))
                        
                        VStack(alignment: .leading, spacing: 0) {
                            if displayNameParts.indices.contains(0) {
                                Text(displayNameParts[0])
                                    .foregroundColor(.black)
                            }
                            if displayNameParts.indices.contains(1) {
                                Text(displayNameParts[1])
                                    .padding(.top, -4)
                                    .foregroundColor(.black)
                            }
                        }
                        .tracking(-1)
                        .font(Font.custom("CircularSpUIv3T-Bold", size: 24))
                        
                        HStack(spacing: 0) {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "5F672D")))
                                .font(.system(size: 10))
                                .padding(.trailing, 2)
                            
                            Text(bannerCategory.subtext ?? "")
                                .font(Font.custom("CircularSpUIv3T-Book", size: 12))
                                .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "5F672D")))
                        }
                        .padding(.top, 55)
                    }
                    
                    Spacer()
                    
                    AsyncImage(url: URL(string: "\(baseS3)\(image)")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 130, height: 130, alignment: .trailing)
                            .padding(.trailing, -5)
                    } placeholder: {
                        ProgressView()
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: hexStringToUIColor(hex: "EBFF6E")))
            }
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .padding(.horizontal, 22)
            .scaleEffect(isTapped1 ? 1.2 : 1)
            .animation(.spring(response: 0.4, dampingFraction: 0.6))
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isTapped1.toggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    isTapped1.toggle()
                    navigationStore.push(to: .screen4(bannerCategory.id))
                }
            }
            .padding(.bottom, 16)
        } else {
            EmptyView()
        }
    }
    
    private var categoryCardsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(categories.filter({ !$0.isBanner })) { category in
                    CategoryCard(
                        title: category.displayName ?? category.name,
                        description: category.subtext ?? "",
                        imageName: category.image ?? "",
                        categoryId: category.id
                    )
                }
            }
            .padding(.horizontal, 13)
        }
        .padding(.top, 5)
        .transition(.move(edge: .bottom))
    }
}

struct CategoryCard: View {
    @EnvironmentObject private var navigationStore: NavigationStore
    let title: String
    let description: String
    let imageName: String
    let categoryId: String
    @State private var isTapped = false
    
    var body: some View {
        HStack {
            ZStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text(title)
                        .foregroundColor(.black)
                        .tracking(-0.5)
                        .font(Font.custom("CircularSpUIv3T-Bold", size: 19))
                    
                    HStack(spacing: 0) {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "5F672D")))
                            .font(.system(size: 8))
                            .padding(.trailing, 2)
                        Text(description)
                            .font(Font.custom("CircularStd-Book", size: 9))
                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "5F672D")))
                    }
                }
                .padding(.top, -87)
                .padding(.leading, 16)
                .zIndex(1)
                
                AsyncImage(url: URL(string: "\(baseS3)\(imageName)")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150, alignment: .trailing)
                        .padding(.top, 60)
                        .padding(.leading, 48)
                } placeholder: {
                    ProgressView()
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.5, alignment: .topLeading)
        .background(.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white, lineWidth: isTapped ? 10 : 0)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 10)
        .scaleEffect(isTapped ? 1.2 : 1)
        .animation(.spring(response: 0.4, dampingFraction: 0.6))
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                isTapped.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                isTapped.toggle()
                navigationStore.push(to: .screen4(categoryId))
            }
        }
    }
}

#Preview {
    ScreenThree()
        .statusBar(hidden: true)
        .environmentObject(NavigationStore())
        .environmentObject(Game())
}
