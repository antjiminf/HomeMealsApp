import SwiftUI

struct UpdatePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    @Environment(UserVM.self) var userVm
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    @State private var hasCurrentPasswordError = false
    @State private var hasNewPasswordError = false
    @State private var hasConfirmPasswordError = false
    
    @State private var showSuccess = false
    @State private var hasError = false
    @State private var errorMessage: String?
    
    
    var isFormValid: Bool {
        return !hasCurrentPasswordError && !hasNewPasswordError && !hasConfirmPasswordError
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureCustomTextField(label: "Current Password",
                                          value: $currentPassword,
                                          isError: $hasCurrentPasswordError,
                                          hint: "Enter your current password",
                                          validation: validatePassword,
                                          initial: false)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .newPassword
                    }
                    
                    SecureCustomTextField(label: "New Password",
                                          value: $newPassword,
                                          isError: $hasNewPasswordError,
                                          hint: "Must be at least 8 characters",
                                          validation: validateNewPassword,
                                          initial: false,
                                          isNewPassword: true)
                    .focused($focusedField, equals: .newPassword)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .confirmPassword
                    }
                    
                    SecureCustomTextField(label: "Confirm Password",
                                          value: $confirmPassword,
                                          isError: $hasConfirmPasswordError,
                                          hint: "Confirm your new password",
                                          validation: validateConfirmPassword,
                                          initial: false,
                                          isNewPassword: true)
                    .focused($focusedField, equals: .confirmPassword)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                    }
                }
            }
            .navigationTitle("Update Password")
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
                                try await userVm.updatePassword(UpdatePassword(oldPassword: currentPassword,
                                                                               newPassword: newPassword))
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
                Text("Your password has been updated successfully.")
            }
            .onAppear {
                focusedField = .password
            }
        }
        .onTapGesture {
            if let _ = focusedField {
                focusedField = nil
            }
        }
    }
    
    private func validatePassword(_ password: String) -> String? {
        if password.isEmpty { return "cannot be empty" }
        if password.count < 8 { return "must have at least 8 characters" }
        return nil
    }
    
    private func validateNewPassword(_ password: String) -> String? {
        if password.isEmpty { return "cannot be empty" }
        if password.count < 8 { return "must have at least 8 characters" }
        if password == currentPassword { return "cannot match current password" }
        return nil
    }
    
    private func validateConfirmPassword(_ confirmPassword: String) -> String? {
        if confirmPassword.isEmpty { return "cannot be empty" }
        if confirmPassword != newPassword { return "do not match" }
        return nil
    }
}

extension UpdatePasswordView {
    enum Field: Hashable {
        case password, newPassword, confirmPassword
        
        mutating func next() {
            switch self {
            case .password:
                self = .newPassword
            case .newPassword:
                self = .confirmPassword
            case .confirmPassword:
                self = .password
            }
        }
        
        mutating func previous() {
            switch self {
            case .password:
                self = .confirmPassword
            case .newPassword:
                self = .password
            case .confirmPassword:
                self = .newPassword
            }
        }
    }
}

#Preview {
    UpdatePasswordView.preview
}
