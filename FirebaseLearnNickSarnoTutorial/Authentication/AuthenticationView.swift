//
//  AuthenticationView.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 23.06.2025.
//
import SwiftUI
import GoogleSignIn
import GoogleSignInSwift



@MainActor
final class AuthenticationViewModel: ObservableObject {
    func signInWithGoogle() async throws {
        let helper = SignInGoogleHelper.shared
        let tokens = try await helper.signInWithGoogle()
        try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens )
    }
}

struct AuthenticationView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View{
        VStack{
            NavigationLink {
                SignInEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Sign in with email")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
            
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                Task{
                    do{
                        try await viewModel.signInWithGoogle()
                        showSignInView = false
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Sign in")
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            AuthenticationView(showSignInView: .constant(false))
        }
    }
}
