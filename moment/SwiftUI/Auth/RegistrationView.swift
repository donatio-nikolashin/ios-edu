import SwiftUI

struct RegistrationView: View {
    
    @EnvironmentObject var session: SessionStore

    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var repeatPassword: String = ""
    @State private var error: String = ""
    @State private var signingUp: Bool = false

    var body: some View {
        VStack(spacing: 15) {
            Text("Sign Up").font(.system(size: 26, weight: .medium))
            SignUpCredentialFields(email: $email, username: $username, password: $password, repeatPassword: $repeatPassword)
            Button(action: {
                signIn()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }) {
                Text("Sign Up")
                    .padding()
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(signUpButtonColor)
                    .cornerRadius(5)
            }
            .disabled(signUpButtonDisabled)
            Text(error)
                .foregroundColor(.red)
                .hidden(error.isEmpty)
        }
        .padding()
    }

    var signUpButtonDisabled: Bool {
        email.isEmpty || username.isEmpty || password.isEmpty || password.count < 8 || repeatPassword != password || signingUp
    }

    var signUpButtonColor: Color {
        signUpButtonDisabled ? .gray : .green
    }

    var signInButtonTextColor: Color {
        signUpButtonDisabled ? .gray : .white
    }
    
    func signIn() {
        signingUp = true
        session.signUp(email: email, password: password) { (result, error) in
            self.signingUp = false
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

struct SignUpCredentialFields: View {
    
    @Binding var email: String
    @Binding var username: String
    @Binding var password: String
    @Binding var repeatPassword: String
    
    var body: some View {
        Group {
            TextField("Email", text: $email)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 5.0)
                        .strokeBorder(Color.textFieldBorderColor, style: StrokeStyle(lineWidth: 1.0))
                )
                .textCase(.none)
            TextField("Username", text: $username)
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
            SecureField("Repeat password", text: $repeatPassword)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 5.0)
                        .strokeBorder(Color.textFieldBorderColor, style: StrokeStyle(lineWidth: 1.0))
                )
        }
    }
    
}

struct RegistrationView_Previews: PreviewProvider {

    static var previews: some View {
        RegistrationView()
    }

}
