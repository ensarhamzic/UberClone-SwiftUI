//
//  LoginView.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 24.08.23.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var authFailed = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.black)
                    .ignoresSafeArea()
                
                VStack {
                    VStack(spacing: -16) {
                        Image("uber-app-icon")
                            .resizable()
                            .frame(width: 200, height: 200)
                        
                        Text("UBER")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                    }
                    
                    
                    VStack(spacing: 32) {
                        CustomInputField(text: $email, title: "Email Address", placeholder: "name@example.com")
                        CustomInputField(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    
                    Button {
                        
                    } label: {
                        Text("Forgot password?")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 28)
                    
                    
                    
                    VStack {
                        HStack(spacing: 24) {
                            Rectangle()
                                .frame(width: 76, height: 1)
                                .foregroundColor(.white)
                                .opacity(0.5)
                            
                            Text("Sign in with social")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                            
                            
                            Rectangle()
                                .frame(width: 76, height: 1)
                                .foregroundColor(.white)
                                .opacity(0.5)
                        }
                        
                        HStack(spacing: 24) {
                            Button {
                                
                            } label: {
                                Image("facebook-sign-in-icon")
                                    .resizable()
                                    .frame(width: 44, height: 44)
                            }
                            
                            Button {
                                
                            } label: {
                                Image("google-sign-in-icon")
                                    .resizable()
                                    .frame(width: 44, height: 44)
                            }
                            
                        }
                    }
                    .padding(.vertical)
                    
                    
                    Spacer()
                    
                    
                    Button {
                        let result = authViewModel.login(email: email, password: password) as! [String: Any]
                        if let token = result["token"] as? String {
                            let user = result["user"] as! [String: Any]
                            let loggedInUser = Converters.dictionaryToUser(user: user)
                            authViewModel.authSuccess(token: token, user: loggedInUser)
                        }
                        else if result["error"] is String {
                            authFailed.toggle()
                        }
                        print(result)
                    } label: {
                        HStack {
                            Text("SIGN IN")
                                .foregroundColor(.black)
                            
                            Image(systemName: "arrow.right")
                                .foregroundColor(.black)
                        }
                        .frame(width: UIScreen.main.bounds.width - 32, height: 50)
                        
                    }
                    .background((Color.white))
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    NavigationLink {
                        RegisterView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        HStack {
                            Text("Don't have an account?")
                                .font(.system(size: 14))
                            
                            Text("Sign Up")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                    }
                
                }
            }
            .alert(isPresented: $authFailed) {
                        Alert(title: Text("Authorization failed"), message: Text("Please try again!"), dismissButton: .default(Text("Got it!")))
                    }
        }
    }
}

//struct TextFieldModifier: ViewModifier {
//
//    func body(content: Content) -> some View {
//            content
//            .padding()
//            .background(Color(.init(white: 1, alpha: 0.15)))
//            .cornerRadius(10)
//            .foregroundColor(.white)
//            .padding(.horizontal)
//        }
//
//}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

