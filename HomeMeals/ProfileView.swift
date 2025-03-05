import SwiftUI

struct ProfileView: View {
    @Environment(UserVM.self) var userVm
    
    var body: some View {
        NavigationStack {
            VStack {
                if let user = userVm.userProfile {
                    VStack(spacing: 20) {
                        ProfileHeader(user: user) // Avatar + Nombre + Email
                        
                        Divider()
                        
                        Text("Your Recipes")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        List(user.recipes) { recipe in
                            HStack {
                                Text(recipe.name)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            userVm.logOut()
                        } label: {
                            Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right.fill")
                                .foregroundColor(.red)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .padding()
                    }
                } else {
                    ProgressView("Loading Profile...")
                        .padding()
                        .task {
                            await userVm.loadUserProfile()
                        }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

/// 📌 Subview: Avatar + Nombre + Email
struct ProfileHeader: View {
    let user: UserProfile
    
    var body: some View {
        VStack {
            if let avatarUrl = user.avatar, let url = URL(string: avatarUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray.opacity(0.5))
            }
            
            Text(user.name)
                .font(.title)
                .bold()
            
            Text(user.email)
                .foregroundStyle(.secondary)
        }
    }
}
