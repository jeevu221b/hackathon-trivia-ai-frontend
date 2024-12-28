import SwiftUI
import UIKit
import SystemNotification
import Pow
let containerWidth: CGFloat = UIScreen.main.bounds.width - 72.0

struct ScreenSix: View {
    let levelId: String
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
                    Color(uiColor: hexStringToUIColor(hex: "137662"))
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
                sessionId = await createSession(levelId: levelId, multiplayer: false) ?? ""
                await fetchQuestions()
                print(sessionId)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func fetchQuestions() async {
        do {
            let fetchedQuestions = try await getQuestions(levelId: levelId, multiplayer: false)
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
    @State private var showConfetti = false
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
    @EnvironmentObject private var navigationStore : NavigationStore

    
    private let quizBackgroundColor = Color(uiColor: hexStringToUIColor(hex: "137662"))
    private let completedBackgroundColor = Color(uiColor: hexStringToUIColor(hex: "faf0e3"))
    private let questionTextColor = Color.white
    private let levelTextColor = Color(uiColor: hexStringToUIColor(hex: "F5E169"))
    private let scoreTextColor = Color.white
    
    struct CountdownView: View {
        @Binding var currentQuestionIndex: Int
        @Binding var isActive: Bool
        let toCompletedView: ()-> Void
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
                    toCompletedView()
                }
            }
        }
    }
    
    func scoreScale(for score: Int) -> CGFloat {
            return score == 0 ? 1.0 : 1.2
        }
    
    var body: some View {
        ZStack(alignment: .top) {
             quizBackgroundColor.edgesIgnoringSafeArea(.all)
                    
            
            
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
                        
                        
                        CountdownView(currentQuestionIndex: $currentQuestionIndex, isActive: $isActive, toCompletedView: toCompletedView)
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
                                    .foregroundColor(scoreTextColor)
                                    .font(Font.custom("CircularSpUIv3T-Bold", size: 20))
                                    .opacity(0.65)
                                    .changeEffect(
                                      .rise(origin: UnitPoint(x: -0.75, y: -0.25)) {
                                        Text("+10").font(Font.custom("CircularSpUIv3T-Bold", size: 37))
                                      }, value: score)
                                    .foregroundStyle(levelTextColor)
                                
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
                
                if currentQuestionIndex < 10 {
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
        }.displayConfetti(isActive: $showConfetti)
        .navigationBarBackButtonHidden(true)
        .edgesIgnoringSafeArea(.all)
        .environmentObject(AppState)
        .systemNotification(isActive: $isActive) {
            SystemNotificationContent()
        }
    }
    
    func toCompletedView(){
        navigationStore.popAllScreen6()
        navigationStore.push(to: .completeLevel(score, sessionId, level))
    }
    
    func nextQuestion() {
        print(currentQuestionIndex)
        if currentQuestionIndex == 9 {
            AppState.isPlaying = false
            print(score, sessionId, level)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                navigationStore.popAllScreen6()
                navigationStore.push(to: .completeLevel(score, sessionId, level))
                return
            }
            
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
                score += 10
            if (score == 50 || score == 90) {
                showConfetti.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showConfetti.toggle()
                }
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
                
                  .zIndex(1)
                .onTapGesture {
                    if !isAnswered {
                        let isCorrect = options.firstIndex(of: option.text) == correctAnswer
                        feedbackGenerator.notificationOccurred(isCorrect ? .success : .error)
                        
                        selectedAnswer = options.firstIndex(of: option.text)
                        isAnswered = true
                        updateScore(isCorrect)
                        onNextQuestion()
                        
                    }
                }
            }
        }
    }
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
            .font(Font.custom("DINAlternate-Bold", size: 15))
            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "212322")))
            .padding(10)
            .padding(.leading, 12)
            .padding(.trailing, 12)
            .padding(.top, 20)
            .padding(.bottom, 20)
            .frame(width: containerWidth)
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
            .transition(.movingParts.wipe(
                angle: .degrees(-125),
                blurRadius: 40
              ))
        
    }
}


struct ScreenSixView: PreviewProvider {
   static var previews: some View {
       ScreenSix(levelId: "6632af18a9e41ee423fe03e3")
           .environmentObject(Game())
           .environmentObject(NavigationStore())
       
   }
}
