import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showRegisterForm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                    
                    Text("Login")
                        .font(.largeTitle)
                        .bold()
                    
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Username")
                                .bold()
                            TextField("Enter your username", text: $username)
                                .textContentType(.username)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray6)))
                            
                            Text("Password")
                                .bold()
                            SecureField("Enter your password", text: $password)
                                .textContentType(.password)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray6)))
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("No account?")
                            .foregroundStyle(.secondary)
                        Button("Click here to register") {
                            showRegisterForm = true
                        }
                        .foregroundColor(.blue)
                        .bold()
                    }
                    
                    Button(action: login) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(isLoading ? "Logging in..." : "Login")
                                .bold()
                        }
                        .frame(width: 200)
                        .padding()
                        .background(isLoading || username.isEmpty || password.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(isLoading || username.isEmpty || password.isEmpty)
                    .padding(.horizontal)
                    
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.email, .fullName]
                    } onCompletion: { result in
                        switch result {
                        case .success(let authResult):
                            Task {
                                do {
                                    try await SecManager.shared.SIWACredentials(credential: authResult.credential)
                                    dismiss()
                                } catch {
                                    showError = true
                                    errorMessage = error.localizedDescription
                                }
                            }
                        case .failure(let error):
                            showError = true
                            errorMessage = error.localizedDescription
                        }
                    }
                    .signInWithAppleButtonStyle(.whiteOutline)
                    .frame(width: 250, height: 50)
                }
                .padding()
                .textFieldStyle(.roundedBorder)
                .sheet(isPresented: $showRegisterForm) {
                    RegisterView(username: username)
                }
                .alert("Login Failed", isPresented: $showError) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(errorMessage)
                }
            }
        }
    }
    
    private func login() {
        isLoading = true
        errorMessage = ""

        Task {
            do {
                try await Network.shared.login(username: username, password: password)
                dismiss()
            } catch {
                errorMessage = "Invalid username or password. Please try again."
                showError = true
            }

            isLoading = false
        }
    }
}

#Preview {
    LoginView()
}

