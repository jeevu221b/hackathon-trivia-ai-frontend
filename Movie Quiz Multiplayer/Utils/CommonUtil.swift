import SwiftUI

func hexStringToUIColor(hex: String) -> UIColor {
var cString:String = hex.trimmingCharacters(in:.whitespacesAndNewlines).uppercased()

if (cString.hasPrefix("#")) {

cString.remove(at: cString.startIndex)
}

if ((cString.count) != 6) {

return UIColor.gray

}

var rgbValue:UInt32 = 0

Scanner(string: cString).scanHexInt32(&rgbValue)

return UIColor(
red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,

green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,

blue: CGFloat(rgbValue & 0x0000FF) / 255.0,

alpha: CGFloat(1.0)
)
}


struct ImageView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            Image("score")
                .resizable()
                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                .frame(width: 400, height: 400)
                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                .offset(y: isAnimating ? 0 : UIScreen.main.bounds.height)
                .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: isAnimating)
        }
        .onAppear {
            isAnimating = true
        }
    }
}



struct BigStarsView: View {
    let stars: Int
    @State private var starScales: [CGFloat] = [0, 0, 0]
    @State private var starOpacities: [Double] = [0, 0, 0]
    
    var body: some View {
        VStack {
            HStack(spacing: 2) {
                ForEach(0..<3) { index in
                    self.starView(for: index)
                }
            }
        }
    }
    
    func starView(for index: Int) -> some View {
        print(index)
        print(stars)
        let isStarFilled = stars >= index + 1
        let topPadding: CGFloat = index == 1 ? -68 : -31
        
        return Image(isStarFilled ? "filledstar" : "emptystar 1")
            .resizable()
            .frame(width: 41, height: 41)
            .padding(10)
            .padding(.trailing, index == 1 ? 16:0)
            .padding(.leading, index == 1 ? 16:0)
            .padding(.top, topPadding)
            .scaleEffect(starScales[index])
            .opacity(starOpacities[index])
            .animation(Animation.easeInOut(duration: 0.4).delay(Double(index) * 0.2))
            .onAppear {
                self.starScales[index] = 1.5
                self.starOpacities[index] = 0.95
            }
            .transition(.scale.combined(with: .opacity))
    }
}




func getLevel(by levelId: String) -> Level? {
    let allLevels = DataManager.shared.getLevels()
    return allLevels.first(where: { $0.id == levelId })
}


func getSubcategoryNameByLevelId(_ levelId: String) -> String? {
    let allLevels = DataManager.shared.getLevels()
    
    if let level = allLevels.first(where: { $0.id == levelId }) {
        let subcategories = DataManager.shared.getSubcategories()
        if let subcategory = subcategories.first(where: { $0.id == level.subCategory }) {
            return subcategory.name
        }
    }
    
    return nil
}

func getCategoryNameByLevelId(_ levelId: String) -> String? {
    let allLevels = DataManager.shared.getLevels()
    let allSubcategories = DataManager.shared.getSubcategories()
    let allCategories = DataManager.shared.getCategories()
    
    if let level = allLevels.first(where: { $0.id == levelId }) {
        if let subcategory = allSubcategories.first(where: { $0.id == level.subCategory }) {
            if let category = allCategories.first(where: { $0.id == subcategory.category }) {
                return category.name
            }
        }
    }
    
    return nil
}

// Helper function to randomly pick an image name
func getRandomImageName() -> String {
    let imageNames = ["flame.fill", "party.popper.fill"]
    return imageNames.randomElement() ?? "flame.fill"
}

struct StreakNotification: View {
    var text: String
    var imageName: String

    var body: some View {
        HStack {
            Image(systemName: imageName)
                .font(.system(size: 14))
                .foregroundColor(.red)
                .padding(.trailing, -22)
                .padding(.leading, 17)
            Text(text)
                .font(.custom("CircularSpUIv3T-Book", size: 11))
                .foregroundColor(.black)
                .padding(.leading, 2)
                .padding(.trailing, 3)
                .padding(15)
        }
        .background(Color.white.opacity(0.8))
        .cornerRadius(8)
        .opacity(0.7)

    }
}
