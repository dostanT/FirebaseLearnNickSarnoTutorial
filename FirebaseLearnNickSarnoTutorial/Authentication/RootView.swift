//
//  RootView.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 23.06.2025.
//
import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false
    
    var body: some View {
        ZStack{
            if !showSignInView{
                NavigationStack{
                    SettingsView(showSignInView: $showSignInView)
                }
            }
        }
        .onAppear {
            //try to fetch email from firebase
            let authUser = try? AuthenticationManager.shared.getAuthenticationUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack{
                AuthenticationView(showSignInView: $showSignInView)
            }
        }
    }
}
