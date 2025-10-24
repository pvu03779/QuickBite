import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            Image("profile_avatar")
                .resizable()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .padding(.top, 40)
            
            Text("Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 30)
            
            VStack(alignment: .leading) {
                NavigationLink(destination: Text("Personal Information")) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("Personal Information")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                }
                Divider()
                
                NavigationLink(destination: Text("Reminder Settings")) {
                    HStack {
                        Image(systemName: "bell.fill")
                        Text("Reminder")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                }
                Divider()
                
                NavigationLink(destination: Text("Unit Switch Settings")) {
                    HStack {
                        Image(systemName: "globe")
                        Text("Unit Switch")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                }
                Divider()
                
                NavigationLink(destination: Text("Weekly Meals Chart")) {
                    HStack {
                        Image(systemName: "heart.fill")
                        Text("Weekly Meals Chart")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("Profile")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
