import SwiftUI

struct ProfileView: View {
    @Environment(UserVM.self) var userVm
    @Environment(RecipesVM.self) var recipesVm
    @State private var showEditProfile = false
    @State private var showLogoutAlert = false
    @State private var showUpdatePassword = false
    @State private var selectedList: ProfileListType = .myRecipes
    @Binding var showLogin: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if let user = userVm.userProfile {
                    VStack(spacing: 20) {
                        ProfileHeader(user: user)
                        
                        Divider()
                        
                        Picker(selection: $selectedList) {
                            ForEach(ProfileListType.allCases) { type in
                                Text(type.rawValue)
                                    .tag(type)
                            }
                        } label: {
                            Text("User Lists")
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 10)
                        
                        switch selectedList {
                        case .myRecipes:
                            Group {
                                if recipesVm.userRecipes.isEmpty {
                                    ContentUnavailableView("No recipes",
                                                           systemImage: "exclamationmark.magnifyingglass",
                                                           description: Text("No custom recipes yet. Create one!"))
                                } else {
                                    ForEach(recipesVm.userRecipes) { recipe in
                                        NavigationLink {
                                            RecipeDetailsView(recipeDetailsVm: RecipeDetailsVM(recipeId: recipe.id))
                                        } label: {
                                            RecipeRow(recipe: recipe)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        case .favorites:
                            Group {
                                if recipesVm.favoriteRecipes.isEmpty {
                                    ContentUnavailableView("No recipes",
                                                           systemImage: "exclamationmark.magnifyingglass",
                                                           description: Text("No favorites recipes yet. Add one!"))
                                } else {
                                    ForEach(recipesVm.favoriteRecipes) { recipe in
                                        NavigationLink {
                                            RecipeDetailsView(recipeDetailsVm: RecipeDetailsVM(recipeId: recipe.id))
                                        } label: {
                                            RecipeRow(recipe: recipe)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                } else {
                    ProgressView("Loading Profile...")
                        .padding()
                        .task {
                            await userVm.loadUserProfile()
                        }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showEditProfile = true
                        } label: {
                            Label("Edit Profile", systemImage: "pencil")
                        }
                        
                        Button {
                            showUpdatePassword = true
                        } label: {
                            Label("Update Password", systemImage: "lock")
                        }
                        
                        Button(role: .destructive) {
                            showLogoutAlert = true
                        } label: {
                            Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right.fill")
                        }
                        
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Log Out?", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    userVm.logOut()
                    showLogin = true
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showUpdatePassword) {
                UpdatePasswordView()
            }
        }
    }
}


struct ProfileHeader: View {
    let user: UserProfile
    
    var body: some View {
        VStack {
            Group {
                if let avatarUrl = user.avatar {
                    NetworkCircleImage(urlString: avatarUrl)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
            
            Text(user.username)
                .font(.title)
                .bold()
            
            Text(user.name)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ProfileView.preview
}
