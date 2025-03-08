import SwiftUI

struct UsersLikesList: View {
    @Environment(\.dismiss) private var dismiss
    var recipeDetailsVm: RecipeDetailsVM
    
    var body: some View {
        NavigationStack {
            List(recipeDetailsVm.likes) { like in
                HStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                    Spacer()
                    Text(like.name)
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
            }
            .toolbar {
                // SI AÑADO MÁS NAVEGACIÓN DESPUES DE ESTA VIEW LO QUITO
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.backward")
                            Text("Back")
                        }
                    }
                }
            }
            .refreshable {
                Task {
                    await recipeDetailsVm.loadRecipeLikes()
                }
            }
        }
        .onAppear {
            Task {
                await recipeDetailsVm.loadRecipeLikes()
            }
        }
    }
}

#Preview {
    UsersLikesList.preview
}
