import SwiftUI


struct UserProfileView: View {
    var body: some View {
        VStack {
            Spacer().frame(height: 50)
            
            // Profile Image and Details
            VStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding()
                    .background(Color.yellow.opacity(0.3))
                    .clipShape(Circle())
                
                Text("Lillie Brown")
                    .font(.title2)
                    .fontWeight(.medium)
                
                HStack(spacing: 5) {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                    Text("Ambassador")
                        .font(.subheadline)
                }
                
                HStack(spacing: 40) {
                    VStack {
                        Text("112")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("Following")
                            .font(.caption)
                    }
                    VStack {
                        Text("627")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("Likes")
                            .font(.caption)
                    }
                    VStack {
                        Text("8")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("Collections")
                            .font(.caption)
                    }
                }
                .padding(.top, 20)
            }
            
            Spacer().frame(height: 40)
            
            // Options
            VStack(spacing: 20) {
                OptionRow(icon: "bell.fill", text: "Notifications")
                OptionRow(icon: "paintbrush.fill", text: "Become an artist on Flamingo")
                OptionRow(icon: "folder.fill", text: "My downloads")
                OptionRow(icon: "creditcard.fill", text: "Payment settings")
            }
            
            Spacer()
            
            Button(action: {
                // Action for becoming a pro member
            }) {
                Text("Become a pro member")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(25)
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 40)
        }
    }
}

struct OptionRow: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.pink)
            Text(text)
                .font(.body)
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
}



#Preview {
    UserProfileView()
        .statusBar(hidden: true)
}

