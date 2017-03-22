//: Playground - noun: a place where people can play

// 1

import UIKit

typealias User = (firstName: String, lastName: String)

class View: UIViewController {
    var emailTextField = UITextField()
    var passwordTextField = UITextField()
    
    var network = Network()
    var persistentStore = PersistentStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.text = "toto@toto.fr"
        passwordTextField.text = "password"
    }
    
    
    @IBAction func loginButtonAction(sender: UIButton) {
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            showError(withError: nil)
            return
        }
        
        if let error = validate(email: email, password: password) {
            showError(withError: error)
            return
        }
        
        network.signInUser(email: email, password: password) { [weak self] (user) in
            if let user = user {
                self?.persistentStore.saveUser(user: user, completion: { [weak self] (error) in
                    if let error = error {
                        self?.showError(withError: error)
                    } else {
                        print("complete user Name : \(user.firstName) \(user.lastName)")
                        self?.performSegue(withIdentifier: "DashboardSegueIdentifier", sender: nil)
                    }
                })
            } else {
                self?.showError(withError: SignInError.unknown)
            }
        }
    }
    
    func showError(withError error: Error?) {
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

