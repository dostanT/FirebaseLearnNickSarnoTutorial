//
//  SettingsView.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 23.06.2025.
//
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderOption] = []
    
    func loadAuthProviders()  {
        if let provaiders = try? AuthenticationManager.shared.getProviders() {
            authProviders = provaiders
        }
    }
    
    func logOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticationUser()
        
        guard let email = authUser.email else {
            fatalError("User email not found")
        }
        
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updateEmail(email: String) async throws {
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func updatePassword(password: String) async throws {
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
}

struct SettingsView: View {
    
    @State private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    @State private var password: String = ""
    
    var body: some View {
        List {
            Button("Log out") {
                do{
                    try viewModel.logOut()
                    showSignInView = true
                } catch {
                    print(error)
                }
            }
            
            if viewModel.authProviders.contains(where: { $0 == .email }) {
                Button("Reset Password") {
                    Task{
                        do{
                            try await viewModel.resetPassword()
                            print("Password reset")
                        } catch {
                            print(error)
                        }
                    }
                }
                
                Section{
                    TextField("password", text: $password)
                    
                    Button("Update Password") {
                        Task{
                            do{
                                try await viewModel.updatePassword(password: password)
                                print("Password updated")
                            } catch {
                                print(error)
                            }
                        }
                    }
                }
            }
        }
        .onAppear{
            viewModel.loadAuthProviders()
        }
        .navigationTitle(Text("Settings"))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            SettingsView(showSignInView: .constant(false))
        }
        
    }
}


