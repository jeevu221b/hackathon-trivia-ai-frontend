import SwiftUI

struct TimeCounter: View {
    let utcDateString: String
    @State private var currentTime = Date()
    
    let digitBackground = Color(hexStringToUIColor(hex: "#1A6642")).opacity(0.2)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                if days > 0 {
                    let daysString = formatComponent(value: days)
                    ForEach(0..<daysString.count, id: \.self) { index in
                        let digitIndex = daysString.index(daysString.startIndex, offsetBy: index)
                        let digit = String(daysString[digitIndex])
                        HStack{
                            Text(digit)
                                .font(Font.custom("CircularSpUIv3T-Bold", size: 28))
                                .foregroundColor(Color(hexStringToUIColor(hex: "#1A6642")))
                                .frame(width: 25, alignment: .center)
                                .background(digitBackground)
                                .cornerRadius(5)
                        }
                        .padding(.leading, index == 1 ? 1 : 0)
                    }
                } else {
                    let hoursString = formatComponent(value: hours)
                    ForEach(0..<hoursString.count, id: \.self) { index in
                        let digitIndex = hoursString.index(hoursString.startIndex, offsetBy: index)
                        let digit = String(hoursString[digitIndex])
                        HStack{
                            Text(digit)
                                .font(Font.custom("CircularSpUIv3T-Bold", size: 28))
                                .foregroundColor(Color(hexStringToUIColor(hex: "#1A6642")))
                                .frame(width: 25, alignment: .center)
                                .background(digitBackground)
                                .cornerRadius(5)
                        }
                        .padding(.leading, index == 1 ? 2 : 0)
                    }
                }
                
                Text(" : ")
                    .font(Font.custom("CircularSpUIv3T-Bold", size: 28))
                    .foregroundColor(Color(hexStringToUIColor(hex: "#1A6642")))
                
                let minutesString = formatComponent(value: minutes)
                ForEach(0..<minutesString.count, id: \.self) { index in
                    let digitIndex = minutesString.index(minutesString.startIndex, offsetBy: index)
                    let digit = String(minutesString[digitIndex])
                    HStack{
                        Text(digit)
                            .font(Font.custom("CircularSpUIv3T-Bold", size: 28))
                            .foregroundColor(Color(hexStringToUIColor(hex: "#1A6642")))
                            .frame(width: 25, alignment: .center)
                            .background(digitBackground)
                            .cornerRadius(5)
                    }
                    .padding(.leading, index == 1 ? 2 : 0)
                    
                    
                }
                
                Text(" : ")
                    .frame(height: 25, alignment: .center)
                    .font(Font.custom("CircularSpUIv3T-Bold", size: 28))
                    .foregroundColor(Color(hexStringToUIColor(hex: "#1A6642")))
                
                let secondsString = formatComponent(value: seconds)
                ForEach(0..<secondsString.count, id: \.self) { index in
                    let digitIndex = secondsString.index(secondsString.startIndex, offsetBy: index)
                    let digit = String(secondsString[digitIndex])
                    HStack{
                        Text(digit)
                            .font(Font.custom("CircularSpUIv3T-Bold", size: 28))
                            .foregroundColor(Color(hexStringToUIColor(hex: "#1A6642")))
                            .frame(width: 25, alignment: .center)
                            .background(digitBackground)
                            .cornerRadius(5)
                    }
                    .padding(.leading, index == 1 ? 2 : 0)
                }
            }.contentTransition(.numericText())
            
                HStack(spacing: 2) {
                                if hours >= 24 {
                                    Text("day\(days > 1 ? "s" : "")")
                                        .font(.system(size: 8, weight: .regular, design: .default))
                                        .foregroundColor(.white)
                                        .frame(width: 55, alignment: .center)
                                } else {
                                    Text("hours")
                                        .font(.system(size: 8, weight: .regular, design: .default))
                                        .foregroundColor(.white)
                                        .frame(width: 55, alignment: .center)
                                }
                                
                                Text("minutes")
                                    .font(.system(size: 8, weight: .regular, design: .default))
                                    .foregroundColor(.white)
                                    .frame(width: 90, alignment: .center)
                                
                                Text("seconds")
                                    .font(.system(size: 8, weight: .regular, design: .default))
                                    .foregroundColor(.white)
                                    .frame(width: 55, alignment: .center)
                }.padding(.top, 2)
                        
            
        }
        .onAppear {
            startTimer()
        }
    }

    private var timeInterval: TimeInterval {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        guard let utcDate = dateFormatter.date(from: utcDateString) else {
            return 0
        }

        return currentTime.timeIntervalSince(utcDate)
    }

    private var days: Int {
        Int(timeInterval / (24 * 60 * 60))
    }

    private var hours: Int {
        Int(timeInterval / (60 * 60))
    }

    private var minutes: Int {
        Int(timeInterval / 60) % 60
    }

    private var seconds: Int {
        Int(timeInterval) % 60
    }

    private func formatComponent(value: Int) -> String {
        String(format: "%02d", value)
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            withAnimation {
                self.currentTime = Date()
            }
        }
    }
}

struct ContentView2: View {
    var body: some View {
        ZStack {
            Color(uiColor: hexStringToUIColor(hex: "359D88"))
                .edgesIgnoringSafeArea(.all)
            
            TimeCounter(utcDateString: "2024-05-26T13:29:44.398Z")
                .padding(.top, 16)
            
        }
    }
    
}

#Preview {
    ContentView2()
}

