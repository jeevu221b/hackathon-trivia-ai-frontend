import SwiftUI
import UIKit
import Pow
import SystemNotification

let containerWidth_: CGFloat = UIScreen.main.bounds.width - 68.0


struct ScreenSixMultiplayer: View {
    let levelId: String
    @State private var questions: [Question] = []
    @State private var isLoading = true
    @State private var streakActive = false
    @State private var streakText = ""
    @State private var sessionId: String = ""
    @State private var image: String = ""
    @State private var level: Int = 0
    @State private var currentQuestionIndex = 0
    @State private var subcategoryName: String = ""
    @EnvironmentObject var AppState: Game
    @EnvironmentObject private var socketHandler: SocketHandler
    @EnvironmentObject private var navigationStore : NavigationStore

    
    private let loadingGradientColor = Color(uiColor: hexStringToUIColor(hex: "137662"))
    private let loadingTextColor = Color.white
    var body: some View {
        ZStack {
            if isLoading {
                ZStack(alignment: .top) {
                    Color(uiColor: hexStringToUIColor(hex: "137662"))
                    .edgesIgnoringSafeArea(.all)
                }
                
                VStack {
                    ReadyView(levelId: levelId)
                }
            } else {
                QuizView_(questions: questions, sessionId: sessionId, level: level, levelId: levelId, image: image, currentQuestionIndex: $currentQuestionIndex, subcategoryName: subcategoryName)
            }
        }.systemNotification(isActive: $streakActive) {
            StreakNotification(text: streakText, imageName: getRandomImageName())

        }
        .onAppear {
            socketHandler.socket.on("socketConnected") { data, ack in
                if !AppState.partySession.isEmpty {
                    AppState.isHost = false
                    AppState.inParty = false
                    AppState.partySession = ""
                    AppState.roomUsers = []
                    navigationStore.popToRoot()
                    navigationStore.push(to: .screen3)
                }
            }
            
            socketHandler.socket.on("streak") { data, ack in
                guard let data = data[0] as? [String: Any],
                      let userId = data["userId"] as? String,
                      let allText = data["allText"] as? String,
                      let userText = data["userText"] as? String else {
                    print("Invalid data received")
                    return
                }
                
                // Assuming you have a user object and a way to get the current user ID
                let currentUserId = AppState.user?.id
                
                // Determine which text to use
                let text = (currentUserId == userId) ? userText : allText
                
                // Set streak text
                streakText = text
                
                // Toggle streak
                streakActive.toggle()
            }


            if AppState.isHost {
                socketHandler.startGame(sessionId: AppState.partySession)
            }
            Task {
                if let levelData = getLevel(by: levelId) {
                    self.level = levelData.level
                    print(levelData)
                    if let image = levelData.image, !image.isEmpty {
                        self.image = image
                    }
                    if let subcategoryName = getSubcategoryNameByLevelId(levelId) {
                        print("Subcategory name for \(levelId): \(subcategoryName)")
                        self.subcategoryName = subcategoryName
                    } else {
                        print("No subcategory found for \(levelId)")
                    }
                    if let categoryName = getCategoryNameByLevelId(levelId) {
                        print("Category name for \(levelId): \(categoryName)")
                    } else {
                        print("No category found for \(levelId)")
                    }
                    AppState.currentSubCategory = levelData.subCategory
                }
                sessionId = await createSession(levelId: levelId, multiplayer: false) ?? ""
                await fetchQuestions()
                AppState.isPlaying = true
                print(sessionId)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func fetchQuestions() async {
        do {
            let fetchedQuestions = try await getQuestions(levelId: levelId, multiplayer: true)
            questions = fetchedQuestions
            socketHandler.isReadyNow(sessionId: AppState.partySession)
            socketHandler.socket.on("allReady") { data, ack in
                print("allready")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isLoading = false
                }
            }
            
            socketHandler.socket.on("sendToLobby") { data, ack in
                print("sending to lobby")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    currentQuestionIndex = 0
                    navigationStore.popAllScreen7()
                    navigationStore.popAllLobby()
                    navigationStore.push(to: .lobbyView(true))
                }
            }
           
        } catch {
            print("Error fetching questions: \(error)")
        }
    }
}

struct QuizView_: View {
    @State private var selectedAnswer: Int?
    @State private var isAnswered = false
    @State private var score: Int = 0
    @State private var lastScore: Int = 0
    @State private var isActive = false

    var questions: [Question]
    var sessionId: String
    var level: Int
    var levelId: String
    var image: String
    @Binding var currentQuestionIndex: Int
    var subcategoryName: String = ""
    
    @EnvironmentObject var AppState: Game
    @EnvironmentObject private var navigationStore : NavigationStore
    @EnvironmentObject private var socketHandler: SocketHandler


    
    private let quizBackgroundColor = Color(uiColor: hexStringToUIColor(hex: "137662"))
    private let completedBackgroundColor = Color(uiColor: hexStringToUIColor(hex: "faf0e3"))
    private let questionTextColor = Color.white
    private let levelTextColor = Color(uiColor: hexStringToUIColor(hex: "F5E169"))
    private let scoreTextColor = Color.white
    
    struct CountdownView: View {
        @Binding var currentQuestionIndex: Int
        @Binding var isActive: Bool
        @Binding var isAnswered: Bool
        @State var counter: Int = 0
        var countTo: Int = 30
        @EnvironmentObject var AppState: Game
        
        var body: some View {
            VStack {
                ZStack {
                    Clock(counter: counter, countTo: countTo)
                }
            }
            .onReceive(timer) { time in
                if self.counter < self.countTo{
                    withAnimation {
                        self.counter += 1
                    }
                }
            }
            .onReceive(timer) { _ in
                guard isActive else { return }
                if counter < countTo {
                    counter += 1
                } else {
                    if currentQuestionIndex == 9 {
                        timer.upstream.connect().cancel()
                        isActive = false
                    } else {
                        currentQuestionIndex += 1
                    }
                    counter = 0
                }
            }
            .onChange(of: currentQuestionIndex) { _ in
                        counter = 0
                    }
        }
    }
    
    
    var body: some View {
        ZStack(alignment: .top) {
            quizBackgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack {
                PlayerScoresView(updateScoreFromSocket:updateScoreFromSocket)
                    .padding(.top, 39)
                    .padding(.bottom, 27)

                if currentQuestionIndex < 10 && !questions.isEmpty {
                    VStack(spacing: 0) {
                        Text("\(currentQuestionIndex + 1)")
                            .font(Font.custom("CircularSpUIv3T-Bold", size: 25))
                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "1A6E5C")))
                            .padding(17)
                            .clipShape(Circle())
                            .contentTransition(.numericText())
                            .padding(.top, 17)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, currentQuestionIndex == 0 ? 33 : currentQuestionIndex == 9 ? 25 : 31)
                    .padding(.top, -20)
                    .zIndex(1)
                    
                    ZStack(alignment: .trailing) {
                        Image("popcorn")
                            .resizable()
                                .scaledToFit()
                                .frame(width: 110, height: 110)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, -120)
                                .padding(.leading, 0)
                        
                        
                        CountdownView(currentQuestionIndex: $currentQuestionIndex, isActive: $isActive, isAnswered: $isAnswered
                        )
                            .padding(.top, -8)
                            .padding(.leading, 38.5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    ZStack {
                        VStack(alignment: .trailing) {
                            HStack {
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(levelTextColor)
                                    .font(.system(size: 18))
                                    .padding(.trailing, -2)
                                
                                Text("Level \(level)")
                                    .foregroundColor(questionTextColor)
                                    .opacity(0.6)
                                    .font(Font.custom("CircularSpUIv3T-Bold", size: 27))
                            }
                            HStack(spacing: 0) {
                                Text("\(subcategoryName)")
                                    .foregroundColor(questionTextColor)
                                    .font(Font.custom("CircularStd-Book", size: 18))
                                    .opacity(0.3)
                            }.padding(.bottom, -3)
                            .frame(alignment: .trailing)
                            
                            HStack(spacing: 0) {
                                Text("\(score)")
                                    .foregroundColor(scoreTextColor)
                                    .font(Font.custom("CircularSpUIv3T-Bold", size: 24))
                                    .opacity(0.85)
                                    .changeEffect(
                                      .rise(origin: UnitPoint(x: -0.75, y: -0.25)) {
                                        Text("+\(lastScore)").font(Font.custom("CircularSpUIv3T-Bold", size: 37))
                                      }, value: score)
                                    .foregroundStyle(levelTextColor)
                                
                            }.padding(.top, 1)
                            .frame(alignment: .trailing)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, -121)
                    .padding(.trailing, 25)
                    
                    if !image.isEmpty {
                        ZStack {
                            AsyncImage(url: URL(string: "\(baseS3)\(image).png")) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 100, height: 100, alignment: .center)
                            .padding(.top, -145)
                            .shake(with: CGFloat($score.wrappedValue))
                        }
                    }
                }
                
                if currentQuestionIndex < 10 {
                    VStack {
                        Text(questions[currentQuestionIndex].question)
                            .frame(height: 200, alignment: .center)
                            .font(Font.custom("CircularSpUIv3T-Book", size: 26))
                            .tracking(-0.8)
                            .foregroundColor(questionTextColor)
                            
                            .padding()
                            .padding(.top, -35)
                            .multilineTextAlignment(.center)
                            .padding(.leading, 3)
                            .padding(.trailing, 3)
                            .fixedSize(horizontal: false, vertical: true)
                            .animation(nil)
                        
                        OptionsView_(
                            options: questions[currentQuestionIndex].options,
                            selectedAnswer: $selectedAnswer,
                            correctAnswer:
                                questions[currentQuestionIndex].answer,
                            isAnswered: $isAnswered,
                            updateScore: updateScore
                        )
                        .padding(.leading, 2)
                        .padding(.trailing, 2)
                        .padding(.top, -15)
                        .padding(.bottom, 10)
                        
                        Spacer()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .edgesIgnoringSafeArea(.all)
        .environmentObject(AppState)
        .onAppear{
            socketHandler.socket.on("nextQuestion") { data, ack in
                print("nextQuestion")
                if let dataDict = data[0] as? [String: Int],
                   let index = dataDict["index"] {
                    DispatchQueue.main.async {
                        print(index)
                        nextQuestion(index: index)
                    }
                }
            }
        }
    }
    
    func nextQuestion(index: Int) {
        print(currentQuestionIndex)
        if currentQuestionIndex == 9 {
            AppState.isPlaying = false
            print(score, sessionId, level)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                navigationStore.popAllScreen7()
                navigationStore.popAllLobby()
                navigationStore.push(to: .lobbyView(true))
                return
            }
            
        }
        if currentQuestionIndex < questions.count {
            DispatchQueue.main.async{
                withAnimation {
                    currentQuestionIndex = index
                }
                selectedAnswer = nil
                isAnswered = false
            }
        }
    }
    
    func updateScore(isCorrect: Bool) {
        socketHandler.onAnswer(sessionId: AppState.partySession, index: currentQuestionIndex, answer: isCorrect)
        
//        if isCorrect {
//                score += 10
//        }
    }
    
    func updateScoreFromSocket(num: Int) {
            lastScore = num
            score += num
    }
}


struct OptionsView_: View {
    struct Option: Identifiable {
        let id = UUID()
        let text: String
    }
    
    let options: [String]
    @Binding var selectedAnswer: Int?
    let correctAnswer: Int
    @Binding var isAnswered: Bool
    let updateScore: (Bool) -> Void
    
    @State private var feedbackGenerator = UINotificationFeedbackGenerator()
    @State private var tapLocations: [CGPoint] = Array(repeating: .zero, count: 4)
    
    private let selectedColor = Color(uiColor: hexStringToUIColor(hex: "76F6DB"))
    private let incorrectColor = Color(uiColor: hexStringToUIColor(hex: "FEC0C0"))
    private let unselectedColor = Color.white.opacity(0.7)
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(options.indices.map { Option(text: options[$0]) }) { option in
                OptionButton_(
                    text: option.text,
                    isSelected: selectedAnswer == options.firstIndex(of: option.text),
                    isCorrect: options.firstIndex(of: option.text) == correctAnswer,
                    isAnswered: isAnswered,
                    tapLocation: tapLocations[options.firstIndex(of: option.text) ?? 0]
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            let index = options.firstIndex(of: option.text) ?? 0
                            tapLocations[index] = value.location
                            
                            if !isAnswered {
                                let isCorrect = options.firstIndex(of: option.text) == correctAnswer
                                feedbackGenerator.notificationOccurred(isCorrect ? .success : .error)
                                
                                selectedAnswer = options.firstIndex(of: option.text)
                                isAnswered = true
                                updateScore(isCorrect)
                            }
                        }
                )
            }
        }
    }
}

struct OptionButton_: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isAnswered: Bool
    let tapLocation: CGPoint
    
    @State private var showLottie = false
    
    private let selectedColor = Color(uiColor: hexStringToUIColor(hex: "76F6DB"))
    private let incorrectColor = Color(uiColor: hexStringToUIColor(hex: "FEC0C0"))
    private let unselectedColor = Color.white.opacity(0.7)
    
    var body: some View {
        Text(text)
            .font(Font.custom("DINAlternate-Bold", size: 12))
            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "212322")))
            .padding(10)
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .padding(.top, 19)
            .padding(.bottom, 19)
            .frame(width: containerWidth_)
            .background(
                !isAnswered ? Color.white :
                    isCorrect ? selectedColor :
                    isSelected ? incorrectColor :
                    unselectedColor
            )
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.7), lineWidth: isAnswered && isSelected ? 10 : 0)
            )
            .overlay(
                Group {
                    if isAnswered && isCorrect && isSelected {
                        LottieView(name: "square", play: .constant(true), loopMode: .playOnce)
                            .frame(width: 190, height: 190)
                            .position(x: tapLocation.x, y: 5)
                            .opacity(0.85)
                    }
                }
            )

    }
}


struct ScreenSixMultiplayerView: PreviewProvider {
   static var previews: some View {
       ScreenSixMultiplayer(levelId: "66795d246d44ae5ca1bbd79b")
           .environmentObject(Game())
           .environmentObject(NavigationStore())
           .environmentObject(SocketHandler())
       
   }
}
