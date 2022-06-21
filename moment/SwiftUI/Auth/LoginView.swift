import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var session: SessionStore

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var error: String = ""
    @State private var loggingIn: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                Image("moment_logo_big")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 250)
                    .padding()
                Text("Log In").font(.system(size: 26, weight: .medium))
                SignInCredentialFields(email: $email, password: $password)
                Button(action: {
                    signIn()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }) {
                    Text("Sign In")
                        .padding()
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(signInButtonColor)
                        .cornerRadius(5)
                }
                .disabled(signInButtonDisabled)
                Text(error)
                    .foregroundColor(.red)
                    .hidden(error.isEmpty)
                NavigationLink(destination: {
                    RegistrationView()
                }) {
                    Text("Haven't got account yet? Sign up")
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
    }

    var signInButtonDisabled: Bool {
        email.isEmpty || password.isEmpty || password.count < 8 || loggingIn
    }

    var signInButtonColor: Color {
        signInButtonDisabled ? .gray : .green
    }

    var signInButtonTextColor: Color {
        signInButtonDisabled ? .gray : .white
    }
    
    func signIn() {
        loggingIn = true
        session.signIn(email: email, password: password) { (result, error) in
            self.loggingIn = false
            if error != nil {
                self.error = error?.localizedDescription ?? "Unknown error occurred"
            } else {
                self.email = ""
                self.password = ""
                self.error = ""
            }
        }
    }

}

struct SignInCredentialFields: View {
    
    @Binding var email: String
    @Binding var password: String
    
    var body: some View {
        Group {
            TextField("Email", text: $email)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 5.0)
                        .strokeBorder(Color.textFieldBorderColor, style: StrokeStyle(lineWidth: 1.0))
                )
                .textCase(.none)
            SecureField("Password", text: $password)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 5.0)
                        .strokeBorder(Color.textFieldBorderColor, style: StrokeStyle(lineWidth: 1.0))
                )
        }
    }
    
}

struct LoginView_Previews: PreviewProvider {

    static var previews: some View {
        LoginView()
    }

}
