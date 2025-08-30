//
//  ProfileView.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 26.08.2025.
//
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticationUser()
            print(authDataResult)
            let result = try await UserManager.shared.getUser(userID: authDataResult.uid)
            print(result)
            self.user = result
        } catch {
            print("NAH")
            print(error)
            print(error.localizedDescription)
        }
    }
    
    func tooglePremiumStatus() {
        guard let user else {return}
        
        Task{
            try await UserManager.shared.updateUserPremiumStatus(user: user, isPremium: user.isPremium == false)
            self.user = try await UserManager.shared.getUser(userID: user.userId)
        }
    }
    
}

struct ProfileView: View {
    
    @StateObject private var profileVM: ProfileViewModel = .init()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            if let user = profileVM.user {
                Text(user.userId)
                
                if let isAnonymous = user.isAnonymous {
                    Text("Is anonymous: \(isAnonymous.description.capitalized)")
                }
                
                Button {
                    profileVM.tooglePremiumStatus()
                } label: {
                    Text("User is premium: \((user.isPremium ?? false).description.capitalized)")
                }
            }
            
        }
        .navigationTitle("Profile")
        .task {
            try? await profileVM.loadCurrentUser()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView(showSignInView: $showSignInView)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }
                
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    Task {
                        try? await profileVM.loadCurrentUser()
                    }
                } label: {
                    Image(systemName: "arrow.2.squarepath")
                        .font(.headline)
                }
                
            }
        }
        
    }
}
