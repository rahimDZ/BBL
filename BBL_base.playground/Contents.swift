//: Playground - noun: a place where people can play

import UIKit

typealias User = (firstName: String, lastName: String)

class View {
    var emailTextField = UITextField()
    var passwordTextField = UITextField()
    var useCase: UseCaseInput?

    init() {
        emailTextField.text = "toto@toto.fr"
        passwordTextField.text = "password"
    }
    
    func loginButtonAction() {
        useCase?.signIn(email: emailTextField.text, password: passwordTextField.text)
    }
    
    func displayCompleteUserName(user: User) {
        print("complete user Name : \(user.firstName) \(user.lastName)")
    }
    
    func prepareDashboardView() {
        print("prepare dashboard view")
    }
    
    func showError(withError error: Error?) {
        var errorMessage = "generic error"
        if let networkError = error as? SignInError {
            errorMessage = networkError.description
        }

        print("error : \(errorMessage)")
    }
    
}

protocol UseCaseInput {
    func signIn(email: String?, password: String?)
}

class UseCase {
    var view: View?
    var network = Network()
    var persistentStore = PersistentStore()

    fileprivate func validate(email: String, password: String) -> SignInError? {
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

extension UseCase: UseCaseInput {
    func signIn(email: String?, password: String?) {
        guard let email = email, let password = password else {
            view?.showError(withError: nil)
            return
        }
        
        if let error = validate(email: email, password: password) {
            view?.showError(withError: error)
            return
        }
        
        network.signInUser(email: email, password: password) { [weak self] (user) in
            if let user = user {
                self?.persistentStore.saveUser(user: user, completion: { [weak self] (error) in
                    if let error = error {
                        self?.view?.showError(withError: error)
                    } else {
                        self?.view?.displayCompleteUserName(user: user)
                        self?.view?.prepareDashboardView()
                    }
                })
            } else {
                self?.view?.showError(withError: SignInError.unknown)
            }
        }
    }
}

class Network {
    func signInUser(email: String, password: String, completion: (User?) -> Void) {
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
