import SwiftUI

struct UpdatePasswordView: View {
    @Environment(\.dismiss) private var dismiss
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
                    
                    SecureCustomTextField(label: "New Password",
                                          value: $newPassword,
                                          isError: $hasNewPasswordError,
                                          hint: "Must be at least 8 characters",
                                          validation: validateNewPassword,
                                          initial: false)
                    
                    SecureCustomTextField(label: "Confirm Password",
                                          value: $confirmPassword,
                                          isError: $hasConfirmPasswordError,
                                          hint: "Confirm your new password",
                                          validation: validateConfirmPassword,
                                          initial: false)
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

#Preview {
    UpdatePasswordView.preview
}
