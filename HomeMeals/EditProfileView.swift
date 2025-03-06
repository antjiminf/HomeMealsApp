import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusField: Field?
    @Environment(UserVM.self) var userVm
    
    @State private var name = ""
    @State private var email = ""
    @State private var username = ""
    
    @State private var hasNameError = false
    @State private var hasEmailError = false
    @State private var hasUsernameError = false
    
    @State private var showSuccess = false
    @State private var hasError = false
    @State private var errorMessage: String?
    
    var isFormValid: Bool {
        return !hasNameError && !hasEmailError && !hasUsernameError
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Info") {
                    CustomTextField(label: "Name",
                                    value: $name,
                                    isError: $hasNameError,
                                    hint: "Enter your full name",
                                    validation: validateName,
                                    initial: false)
                    .focused($focusField, equals: .name)
                    .submitLabel(.next)
                    .onSubmit {
                        focusField = .username
                    }
                    
                    CustomTextField(label: "Username",
                                    value: $username,
                                    isError: $hasUsernameError,
                                    hint: "Choose a unique username",
                                    validation: validateUsername,
                                    initial: false
                    )
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($focusField, equals: .username)
                    .submitLabel(.next)
                    .onSubmit {
                        focusField = .email
                    }
                    
                    CustomTextField(label: "Email",
                                    value: $email,
                                    isError: $hasEmailError,
                                    hint: "Enter a valid email address",
                                    validation: validateEmail,
                                    initial: false
                    )
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($focusField, equals: .email)
                    .onSubmit {
                        focusField = nil
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            do {
                                try await userVm.updateProfile(UpdateProfile(name: name,
                                                                             username: username,
                                                                             email: email))
                                showSuccess = true
                            } catch {
                                hasError = true
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                    .disabled(!isFormValid)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    
                    Button {
                        focusField?.previous()
                    } label: {
                        Image(systemName: "chevron.up")
                    }
                    Button {
                        focusField?.next()
                    } label: {
                        Image(systemName: "chevron.down")
                    }
                    Spacer()
                    Button {
                        focusField = nil
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down.fill")
                    }
                    
                }
            }
            .alert("Error", isPresented: $hasError) {
                Button("OK", role: .cancel) { hasError = false }
            } message: {
                if let errorMessage {
                    Text(errorMessage)
                }
            }
            .confirmationDialog("Success", isPresented: $showSuccess, titleVisibility: .visible) {
                Button("OK", role: .cancel) { dismiss() }
            } message: {
                Text("Your profile has been updated successfully.")
            }
            .onAppear {
                if let user = userVm.userProfile {
                    name = user.name
                    email = user.email
                    username = user.username
                }
                focusField = .name
            }
            .onTapGesture {
                if let _ = focusField {
                    focusField = nil
                }
            }
        }
    }
    
    private func validateName(_ name: String) -> String? {
        if name.isEmpty { return "cannot be empty" }
        if name.count < 3 { return "must be at least 3 characters" }
        return nil
    }
    
    private func validateUsername(_ username: String) -> String? {
        if username.isEmpty { return "cannot be empty" }
        if username.count < 3 { return "must be at least 3 characters" }
        if username.contains(" ") { return "cannot contain spaces" }
        return nil
    }
    
    private func validateEmail(_ email: String) -> String? {
        if email.isEmpty { return "cannot be empty" }
        if !email.isValidEmail { return "does not have a valid format" }
        return nil
    }
}

extension EditProfileView {
    enum Field: Hashable {
        case name, username, email
        
        mutating func next() {
            switch self {
            case .name:
                self = .username
            case .username:
                self = .email
            case .email:
                self = .name
            }
        }
        
        mutating func previous() {
            switch self {
            case .name:
                self = .email
            case .username:
                self = .name
            case .email:
                self = .username
            }
        }
    }
}

#Preview {
    EditProfileView.preview
}
