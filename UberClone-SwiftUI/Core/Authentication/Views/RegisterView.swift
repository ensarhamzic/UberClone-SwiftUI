//
//  RegisterView.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 24.08.23.
//

import SwiftUI

struct RegisterView: View {
    @State private var fullname = ""
    @State private var email = ""
    @State private var password = ""
    @State private var userType: UserType = .passenger
    @State private var carType: RideType = .uberX
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @Namespace var bottomId
    
    @State private var authError: String = ""
    @State private var authFailed: Bool = false
    
    var body: some View {
        ZStack {
            Color(.black)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.title)
                        .imageScale(.medium)
                        .padding()
                }
                
                Text("Create new account")
                    .font(.system(size: 40))
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .frame(width: 250)
                
                Spacer()
                
                ScrollViewReader { proxy in
                    ScrollView  {
                        VStack {
                            VStack(spacing: 56) {
                                CustomInputField(text: $fullname, title: "Full Name", placeholder: "John Doe")
                                
                                CustomInputField(text: $email, title: "Email Address", placeholder: "name@example.com")
                                
                                CustomInputField(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                            }
                            .padding(.leading)
                            
                            VStack {
                                Text("I register as")
                                HStack(spacing: 20) {
                                    Button {
                                        userType = .passenger
                                    } label: {
                                        Text("Passenger")
                                            .frame(width: 120, height: 40)
                                            .foregroundColor(userType == .passenger ? Color.black : Color.white)
                                            .background(userType == .passenger ? Color.white : Color.black)
                                            .cornerRadius(10)
                                    }
                                    
                                    Button {
                                        userType = .driver
                                        
                                    } label: {
                                        Text("Driver")
                                            .frame(width: 120, height: 40)
                                            .foregroundColor(userType == .driver ? Color.black : Color.white)
                                            .background(userType == .driver ? Color.white : Color.black)
                                            .cornerRadius(10)
                                    }
                                }
                                .padding(.top, 5)
                            }
                            .padding()
                            
                            
                            if(userType == .driver) {
                                ScrollView(.horizontal) {
                                    HStack(spacing: 12) {
                                        ForEach(RideType.allCases) { type in
                                            VStack(alignment: .leading) {
                                                Image(type.imageName)
                                                    .resizable()
                                                    .scaledToFit()
                                                
                                                
                                                    Text(type.description)
                                                        .font(.system(size: 14, weight: .semibold))
                                                    
                                                    
                                                .padding()
                                            }
                                            .frame(width: 112, height: 140)
                                            .foregroundColor(type == carType ? .black : Color.white)
                                            .background(type == carType ? .white : Color.black)
                                            .scaleEffect(type == carType ? 1.2 : 1.0)
                                            .cornerRadius(10)
                                            .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Color.white, lineWidth: 2)
                                                    )
                                            .onTapGesture {
                                                withAnimation(.spring()) {
                                                    carType = type
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .id(bottomId)
                                .onAppear {
                                    withAnimation {
                                        proxy.scrollTo(bottomId)
                                    }
                                }
                            }
                        }
                    }
                }
                
                
                Spacer()
                
                Button {
                    let result = authViewModel.registerUser(email: email, fullName: fullname, password: password, userType: userType, carType: carType) as! [String: Any]
                    if let token = result["token"] as? String {
                        let user = result["user"] as! [String: Any]
                        let loggedInUser = Converters.dictionaryToUser(user: user)
                        authViewModel.authSuccess(token: token, user: loggedInUser)
                    }
                    else if let error = result["error"] as? String {
                        authError = error
                        authFailed = true
                    }
                } label: {
                    HStack {
                        Text("SIGN UP")
                            .foregroundColor(.black)
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(.black)
                        
                    }
                    .frame(width: UIScreen.main.bounds.width - 32, height: 50)
                    
                }
                .background((Color.white))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .foregroundColor(.white)
        }
        .alert(isPresented: $authFailed) {
                    Alert(title: Text("Authorization failed"), message: Text(authError), dismissButton: .default(Text("Got it!")))
                }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
