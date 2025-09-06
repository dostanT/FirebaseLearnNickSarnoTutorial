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
    
    func addUserPreference(preference: String) {
        guard let user else {return}
        Task {
            try await UserManager.shared.addUserPreferences(userID: user.userId, preference: preference)
            self.user = try await UserManager.shared.getUser(userID: user.userId)
        }
    }
    
    func removeUserPreference(preference: String) {
        guard let user else {return}
        Task {
            try await UserManager.shared.removeUserPreferences(userID: user.userId, preference: preference)
            self.user = try await UserManager.shared.getUser(userID: user.userId)
        }
    }
    
    func addFavoriteMovie() {
        guard let user else {return}
        let movie = Movie(id: "1", title: "Avatar", isPopular: true)
        Task {
            try await UserManager.shared.addFavoriteMovie(userID: user.userId, movie: movie)
            self.user = try await UserManager.shared.getUser(userID: user.userId)
        }
    }
    
    func removeFavoriteMovie() {
        guard let user else {return}
        Task {
            try await UserManager.shared.removeFavoriteMovie(userID: user.userId)
            self.user = try await UserManager.shared.getUser(userID: user.userId)
        }
    }
    
}

struct ProfileView: View {
    
    @StateObject private var profileVM: ProfileViewModel = .init()
    @Binding var showSignInView: Bool
    let prefrenceOptions: [String] = ["Sports", "Movies", "Book"]
    
    private func preferenceIsSelected(_ preference: String) -> Bool{
        profileVM.user?.preferences?.contains(preference) == true
    }
    
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
                
                VStack{
                    HStack {
                        ForEach(prefrenceOptions, id: \.self) {prefernce in
                            Button {
                                if preferenceIsSelected(prefernce) {
                                    profileVM.removeUserPreference(preference: prefernce)
                                } else {
                                    profileVM.addUserPreference(preference: prefernce)
                                }
                                
                            } label: {
                                Text(prefernce)
                            }
                            .font(.headline)
                            .buttonStyle(.borderedProminent)
                            .tint(preferenceIsSelected(prefernce) ? Color.green : Color.red)
                        }
                    }
                    Text("User Preferences: \((user.preferences ?? []).joined(separator: ", "))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button {
                    if user.favoriteMovie == nil {
                        profileVM.addFavoriteMovie()
                    } else {
                        profileVM.removeFavoriteMovie()
                    }
                } label: {
                    Text("Favotite Modvie: \(user.favoriteMovie?.title ?? "")")
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
