//
//  SignInEmailView.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 23.06.2025.
//

import SwiftUI
import Foundation

final class SignInEmailViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    func signIn(){
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found")
            return
        }
        
        Task{
            do{
                let returnedUserData = try await AuthenticationManager.shared.createUser(email: email, password: password)
                print("Success")
                print(returnedUserData)
            } catch {
                print("Error signing in: \(error.localizedDescription)")
            }
        }
        
    }
}

struct SignInEmailView: View {
    @StateObject private var viewModel: SignInEmailViewModel = .init()
    
    var body: some View {
        VStack {
            TextField(
                "Email",
                text: $viewModel.email
            )
            .padding()
            .background(Color.gray.opacity(0.4))
            .cornerRadius(10)
            
            SecureField(
                "Password",
                text: $viewModel.password
            )
            .padding()
            .background(Color.gray.opacity(0.4))
            .cornerRadius(10)
            
            Button {
                viewModel.signIn()
            } label: {
                Text("Sign in")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
            Spacer()
        }
        .padding()
        .navigationTitle(Text("Sign in with email"))
    }
}

struct SignInEmailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            SignInEmailView()
        }
    }
}
