import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    
    @State var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var email = ""
    @State private var fullname = ""
    
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    @State private var usernameError = false
    @State private var passwordError = false
    @State private var confirmPasswordError = false
    @State private var emailError = false
    @State private var fullnameError = false
    
    var isFormValid: Bool {
        !usernameError &&
        !fullnameError &&
        !emailError &&
        !passwordError &&
        !confirmPasswordError
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Image(systemName: "person.crop.circle.fill.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                    
                    Text("Register")
                        .font(.largeTitle)
                        .bold()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        CustomTextField(label: "Username",
                                        value: $username,
                                        isError: $usernameError,
                                        hint: "Enter a unique username",
                                        validation: validateUsername,
                                        initial: false)
                        .textInputAutocapitalization(.never)
                        .focused($focusedField, equals: .username)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .name
                        }
                        
                        CustomTextField(label: "Full Name",
                                        value: $fullname,
                                        isError: $fullnameError,
                                        hint: "Enter your full name",
                                        validation: validateFullName,
                                        initial: false)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .email
                        }
                        
                        CustomTextField(label: "Email",
                                        value: $email,
                                        isError: $emailError,
                                        hint: "Enter a valid email",
                                        validation: validateEmail,
                                        initial: false)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .password
                        }
                        
                        SecureCustomTextField(label: "Password",
                                              value: $password,
                                              isError: $passwordError,
                                              hint: "Enter a strong password",
                                              validation: validatePassword,
                                              initial: false,
                                              isNewPassword: true)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .confirmPassword
                        }
                        
                        SecureCustomTextField(label: "Confirm Password",
                                              value: $confirmPassword,
                                              isError: $confirmPasswordError,
                                              hint: "Re-enter your password",
                                              validation: validateConfirmPassword,
                                              initial: false,
                                              isNewPassword: true)
                        .focused($focusedField, equals: .confirmPassword)
                        .submitLabel(.done)
                        .onSubmit {
                            focusedField = nil
                        }
                    }
                    .padding()
                    
                    Button(action: registerUser) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(isLoading ? "Creating account..." : "Register")
                                .bold()
                        }
                        .frame(width: 200)
                        .padding()
                        .background(isLoading || !isFormValid ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(isLoading || !isFormValid)
                    .padding(.horizontal)
                }
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        HStack {
                            Button {
                                focusedField?.previous()
                            } label: {
                                Image(systemName: "chevron.up")
                            }
                            Button {
                                focusedField?.next()
                            } label: {
                                Image(systemName: "chevron.down")
                                
                            }
                            Spacer()
                            Button {
                                focusedField = nil
                            } label: {
                                Image(systemName: "keyboard.chevron.compact.down.fill")
                            }
                        }
                    }
                }
                .padding()
                .alert("Registration Failed", isPresented: $showError) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(errorMessage)
                }
                .alert("Success", isPresented: $showSuccess) {
                    Button("OK") { dismiss() }
                } message: {
                    Text("Your account has been created successfully!")
                }
            }
        }
        .onTapGesture {
            if let _ = focusedField {
                focusedField = nil
            }
        }
    }
    
    private func registerUser() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                try await Network.shared.register(user: CreateUser(name: fullname,
                                                                   username: username,
                                                                   password: password,
                                                                   email: email))
                showSuccess = true
            } catch {
                errorMessage = "Registration failed. Please check your details and try again."
                showError = true
            }
            isLoading = false
        }
    }
    
    private func validateUsername(_ text: String) -> String? {
        if text.isEmpty { return "cannot be empty" }
        if text.count < 4 { return "must be at least 4 characters" }
        return nil
    }
    
    private func validateFullName(_ text: String) -> String? {
        if text.isEmpty { return "cannot be empty" }
        return nil
    }
    
    private func validateEmail(_ text: String) -> String? {
        if text.isEmpty { return "cannot be empty" }
        if !text.isValidEmail { return "has invalid email format" }
        return nil
    }
    
    private func validatePassword(_ text: String) -> String? {
        if text.isEmpty { return "cannot be empty" }
        if text.count < 8 { return "must be at least 8 characters" }
        return nil
    }
    
    private func validateConfirmPassword(_ text: String) -> String? {
        if text.isEmpty { return "cannot be empty" }
        if text != password { return "do not match" }
        return nil
    }
}

extension RegisterView {
    enum Field: Hashable {
        case username, name, email, password, confirmPassword
        
        mutating func next() {
            switch self {
            case .username:
                self = .name
            case .name:
                self = .email
            case .email:
                self = .password
            case .password:
                self = .confirmPassword
            case .confirmPassword:
                self = .username
            }
        }
        
        mutating func previous() {
            switch self {
            case .username:
                self = .confirmPassword
            case .name:
                self = .username
            case .email:
                self = .name
            case .password:
                self = .email
            case .confirmPassword:
                self = .password
            }
        }
    }
}

#Preview {
    RegisterView()
}
