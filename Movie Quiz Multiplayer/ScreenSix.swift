import SwiftUI
import UIKit
//import AVFAudio
import SystemNotification

struct ScreenSix: View {
    let levelId: String
    @State private var navigationStore = NavigationStore()
    @State private var questions: [Question] = []
    @State private var isLoading = true
    @State private var sessionId: String = ""
    @State private var image: String = ""
    @State private var level: Int = 0
    @State private var currentQuestionIndex = 0
    @State private var subcategoryName: String = ""
    @EnvironmentObject var AppState: Game
    
    private let loadingGradientColor = Color(uiColor: hexStringToUIColor(hex: "137662"))
    private let loadingTextColor = Color.white
    
    var body: some View {
        ZStack {
            if isLoading {
                ZStack(alignment: .top) {
                    LinearGradient(
                        colors: [loadingGradientColor, loadingGradientColor],
                        startPoint: .topLeading,
                        endPoint: .bottomLeading
                    )
                    .edgesIgnoringSafeArea(.all)
                }
                
                VStack {
                    Spacer()
                    ThreeBounceAnimation(color: .white, width: CGFloat(25), height: CGFloat(25))
                    Text("Loading questions")
                        .font(Font.custom("CircularSpUIv3T-Book", size: 24))
                        .foregroundColor(loadingTextColor)
                        .padding()
                        .padding(.bottom, 50)
                }
            } else {
                QuizView(questions: questions, sessionId: sessionId, level: level, levelId: levelId, image: image, currentQuestionIndex: $currentQuestionIndex, subcategoryName: subcategoryName)
            }
        }
        .onAppear {
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
                    AppState.currentSubCategory = levelData.subCategory
                }
                sessionId = await createSession(levelId: levelId) ?? ""
                await fetchQuestions()
                print(sessionId)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func fetchQuestions() async {
        do {
            let fetchedQuestions = try await getQuestions(levelId: levelId)
            questions = fetchedQuestions
            isLoading = false
        } catch {
            print("Error fetching questions: \(error)")
        }
    }
}

struct QuizView: View {
    @State private var selectedAnswer: Int?
    @State private var isAnswered = false
    @State private var score: Int = 0
    @State private var isActive = false
    
    var questions: [Question]
    var sessionId: String
    var level: Int
    var levelId: String
    var image: String
    @Binding var currentQuestionIndex: Int
    var subcategoryName: String = ""
    
    @EnvironmentObject var AppState: Game
    
    private let quizBackgroundColor = Color(uiColor: hexStringToUIColor(hex: "137662"))
    private let completedBackgroundColor = Color(uiColor: hexStringToUIColor(hex: "faf0e3"))
    private let questionTextColor = Color.white
    private let levelTextColor = Color(uiColor: hexStringToUIColor(hex: "F5E169"))
    private let scoreTextColor = Color.white
    
    struct CountdownView: View {
        @Binding var currentQuestionIndex: Int
        @Binding var isActive: Bool
        @State var counter: Int = 0
        var countTo: Int = 120
        @EnvironmentObject var AppState: Game
        
        var body: some View {
            VStack {
                ZStack {
                    Clock(counter: counter, countTo: countTo)
                }
            }
            .onReceive(timer) { time in
                if self.counter < self.countTo {
                    withAnimation {
                        self.counter += 1
                    }
                }
            }
            .onChange(of: counter) { newValue in
                if newValue == countTo {
                    timer.upstream.connect().cancel()
                    isActive = true
                    currentQuestionIndex = 10
                    AppState.isPlaying = false
                }
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            if currentQuestionIndex > 9 {
                Image("spider")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
            } else {
                (currentQuestionIndex > 9 ? completedBackgroundColor : quizBackgroundColor)
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack {
                if currentQuestionIndex < 10 && !questions.isEmpty {
                    VStack(spacing: 0) {
                        Text("\(currentQuestionIndex + 1)")
                            .font(Font.custom("CircularSpUIv3T-Bold", size: 25))
                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "1A6E5C")))
                            .padding(17)
                            .clipShape(Circle())
                            .contentTransition(.numericText())
                            .padding(.top, 20)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, currentQuestionIndex == 0 ? 33 : currentQuestionIndex == 9 ? 25 : 31)
                    .padding(.top, 53)
                    .zIndex(1)
                    
                    ZStack(alignment: .trailing) {
                        Image("popcorn")
                            .resizable()
                                .scaledToFit()
                                .frame(width: 110, height: 110)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, -119)
                                .padding(.leading, 0)
                        
                        
                        CountdownView(currentQuestionIndex: $currentQuestionIndex, isActive: $isActive)
                            .padding(.top, -9)
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
                            }
                            .frame(alignment: .trailing)
                            
                            HStack(spacing: 0) {
                                Text("\(score)")
                                    .contentTransition(.numericText())
                                    .foregroundColor(scoreTextColor)
                                    .font(Font.custom("CircularStd-Book", size: 20))
                                    .opacity(0.6)
                                
                                Text("/100")
                                    .foregroundColor(scoreTextColor)
                                    .font(Font.custom("CircularStd-Book", size: 20))
                                    .opacity(0.3)
                            }
                            .frame(alignment: .trailing)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, -109)
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
                            .padding(.top, -115)
                            .shake(with: CGFloat($score.wrappedValue))
                        }
                    }
                }
                
                if currentQuestionIndex > 9 {
                    CompleteLevelView(score: $score, sessionId: sessionId, level: level)
                } else {
                    VStack {
                        Text(questions[currentQuestionIndex].question)
                            .frame(height: 200)
                            .font(Font.custom("CircularSpUIv3T-Book", size: 25))
                            .tracking(-0.6)
                            .foregroundColor(questionTextColor)
                            .padding()
                            .padding(.top, -35)
                            .multilineTextAlignment(.center)
                            .padding(.leading, 3)
                            .padding(.trailing, 3)
                            .fixedSize(horizontal: false, vertical: true)
                            .animation(nil)
                        
                        OptionsView(
                            options: questions[currentQuestionIndex].options,
                            selectedAnswer: $selectedAnswer,
                            correctAnswer: questions[currentQuestionIndex].answer,
                            isAnswered: $isAnswered,
                            onNextQuestion: nextQuestion,
                            updateScore: updateScore
                        )
                        .padding(.leading, 30)
                        .padding(.trailing, 30)
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
        .systemNotification(isActive: $isActive) {
            SystemNotificationContent()
        }
    }
    
    func nextQuestion() {
        if currentQuestionIndex == 9 {
            AppState.isPlaying = false
        }
        if currentQuestionIndex < questions.count {
            if currentQuestionIndex < 9 {
                AppState.isPlaying = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                
                withAnimation {
                    currentQuestionIndex += 1
                }
                selectedAnswer = nil
                isAnswered = false
            }
        }
    }
    
    func updateScore(isCorrect: Bool) {
        if isCorrect {
            withAnimation {
                score += 10
            }
        }
    }
}

struct SystemNotificationContent: View {
    var body: some View {
        HStack {
            Image(systemName: "gauge.with.needle.fill")
                .padding(.trailing, -25)
                .padding(.leading, 10)
            Text("You've run out of time")
                .padding(.leading, 5)
                .padding(15)
        }
    }
}

struct OptionsView: View {
    struct Option: Identifiable {
        let id = UUID()
        let text: String
    }
    
    let options: [String]
    @Binding var selectedAnswer: Int?
    let correctAnswer: Int
    @Binding var isAnswered: Bool
    let onNextQuestion: () -> Void
    let updateScore: (Bool) -> Void
    
    @State private var feedbackGenerator = UINotificationFeedbackGenerator()
//    @State private var audioPlayer: AVAudioPlayer?
    
    private let selectedColor = Color(uiColor: hexStringToUIColor(hex: "76F6DB"))
    private let incorrectColor = Color(uiColor: hexStringToUIColor(hex: "FEC0C0"))
    private let unselectedColor = Color.white.opacity(0.7)
    
    var body: some View {
        VStack(spacing: 22) {
            ForEach(options.indices.map { Option(text: options[$0]) }) { option in
                OptionButton(
                    text: option.text,
                    isSelected: selectedAnswer == options.firstIndex(of: option.text),
                    isCorrect: options.firstIndex(of: option.text) == correctAnswer,
                    isAnswered: isAnswered
                )
                .onTapGesture {
                    if !isAnswered {
                        let isCorrect = options.firstIndex(of: option.text) == correctAnswer
//                        playSound(isCorrect: isCorrect)
                        feedbackGenerator.notificationOccurred(isCorrect ? .success : .error)
                        
                        selectedAnswer = options.firstIndex(of: option.text)
                        isAnswered = true
                        
                        withAnimation {
                            updateScore(isCorrect)
                        }
                        
                        onNextQuestion()
                        
                    }
                }
            }
        }
    }
    
//    func playSound(isCorrect: Bool) {
//        guard let soundData = NSDataAsset(name: isCorrect ? "correct" : "wrong")?.data else {
//            print("Sound file not found in Assets")
//            return
//        }
//
//        do {
//            audioPlayer = try AVAudioPlayer(data: soundData)
//            audioPlayer?.play()
//        } catch {
//            print("Error playing sound: \(error)")
//        }
//    }
}

struct OptionButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isAnswered: Bool
    
    private let selectedColor = Color(uiColor: hexStringToUIColor(hex: "76F6DB"))
    private let incorrectColor = Color(uiColor: hexStringToUIColor(hex: "FEC0C0"))
    private let unselectedColor = Color.white.opacity(0.7)
    
    var body: some View {
        Text(text)
            .font(Font.custom("DINAlternate-Bold", size: 16))
            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "212322")))
            .padding(10)
            .padding(.leading, 12)
            .padding(.trailing, 12)
            .padding(.top, 20)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity)
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
            .animation(.spring(response: 0.3, dampingFraction: 0.5))
    }
}


struct ScreenSixView: PreviewProvider {
   static var previews: some View {
       ScreenSix(levelId: "6632af18a9e41ee423fe03e3")
           .environmentObject(Game())
           .environmentObject(NavigationStore())
       
   }
}
