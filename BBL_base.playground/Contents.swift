//: Playground - noun: a place where people can play

import UIKit

typealias User = (firstName: String, lastName: String)

class View {
    var emailTextField = UITextField()
    var passwordTextField = UITextField()

    init() {
        emailTextField.text = "toto@toto.fr"
        passwordTextField.text = "password"
    }
    
    func loginButtonAction() {
        
    }
    
    func displayCompleteUserName(user: User) {
        print("complete user Name : \(user.firstName) \(user.lastName)")
    }
    
    func prepareDashboardView() {
        print("prepare dashboard view")
    }
    
    func showError(withError error: Error) {
        var errorMessage = "generic error"
        if let networkError = error as? SignInError {
            errorMessage = networkError.description
        }

        print("error : \(errorMessage)")
    }
    
    private func validate(email: String, password: String) -> SignInError? {
        if email.isEmpty {
            return .missingEmail
        }
        if password.isEmpty {
            return .missingPassword
        }
        
        if !email.contains("@") {
            return .badEmailFormat
        }
        if password.characters.count < 5 {
            return .badPasswordFormat
        }
        
        return nil
    }
}

class Network {
    func signInUser(email: String, password: String, completion: (User) -> Void) {
        // call Alamofire
        completion((firstName: "Rahim", lastName: "Ben"))
    }
}

class PersistentStore {
    func saveUser(user: User, completion: (Error?) -> Void) {
        completion(nil)
    }
}

enum SignInError: Error {
    case missingEmail, missingPassword, badEmailFormat, badPasswordFormat, unknown
    
    var description: String {
        switch self {
        case .missingEmail:
            return "Missing Email"
        case .missingPassword:
            return "missingPassword"
        case .badEmailFormat:
            return "badEmailFormat"
        case .badPasswordFormat:
            return "badPasswordFormat"
        case .unknown:
            return ""
        }
    }
}
