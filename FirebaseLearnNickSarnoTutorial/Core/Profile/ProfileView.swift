//
//  ProfileView.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 26.08.2025.
//
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published var user: DBUser?
    
    init(){
        user = loadCurrentUser()
    }
    
    func createUser() {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticationUser()
            Task{
                try await UserManager.shared.createNewUser(auth: authDataResult)
            }
        } catch {
            
        }
    }
    
    func loadCurrentUser() -> DBUser? {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticationUser()
            createUser()
            Task {
                
                let result = try await UserManager.shared.getUser(userID: authDataResult.uid)
                return result
            }
            
        } catch {
            print(error)
        }
        return nil
    }
    
}

struct ProfileView: View {
    
    @State private var profileVM: ProfileViewModel = .init()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            if let user = profileVM.user {
                Text(user.userID)
                
                if let isAnonymous = user.isAnonymous {
                    Text("Is anonymous: \(isAnonymous.description.capitalized)")
                }
            }
            
        }
        .navigationTitle("Profile")
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
                    profileVM.user = profileVM.loadCurrentUser()
                } label: {
                    Image(systemName: "arrow.2.squarepath")
                        .font(.headline)
                }

            }
        }
        
    }
}
