import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            
            VStack(spacing: 20) {
                // 1. Avatar Image
                Image("profile_avatar")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .padding(.top, 40)

                // 2. Profile Title
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)

                // 3. Menu Items
                VStack(alignment: .leading, spacing: 0) {
                    ProfileMenuItem(iconName: "person.fill", text: "Personal Information", destination: Text("Personal Information"))
                    Divider()
                    ProfileMenuItem(iconName: "bell.fill", text: "Reminder", destination: Text("Reminder Settings"))
                    Divider()
                    ProfileMenuItem(iconName: "globe", text: "Unit Switch", destination: Text("Unit Switch Settings"))
                    Divider()
                    ProfileMenuItem(iconName: "heart.fill", text: "Weekly meals chart", destination: Text("Weekly Meals Chart"))
                    Divider()
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Helper View for a reusable menu item
struct ProfileMenuItem<Destination: View>: View {
    let iconName: String
    let text: String
    let destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 20) {
                Image(systemName: iconName)
                    .font(.title2)
                    .frame(width: 30)
                
                Text(text)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
            }
            .padding(.vertical, 20)
            .foregroundColor(.black.opacity(0.8))
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
