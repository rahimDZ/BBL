//: Playground - noun: a place where people can play

import UIKit

typealias User = (firstName: String, lastName: String)


// VIEW


protocol ViewOutput {
    func displayCompleteUserName(completeUserName: String)
    func showError(withErrorMessage errorMessage: String)
}

class View {
    var emailTextField = UITextField()
    var passwordTextField = UITextField()
    var presenter: PresenterInput?

    init() {
        emailTextField.text = "toto@toto.fr"
        passwordTextField.text = "password"
    }
    
    func loginButtonAction() {
        presenter?.userDidClickedLoginButton(email: emailTextField.text, password: passwordTextField.text)
    }
}

extension View: ViewOutput {
    func displayCompleteUserName(completeUserName: String) {
        print("complete user Name : \(completeUserName)")
    }
    
    func showError(withErrorMessage errorMessage: String) {
        print("error : \(errorMessage)")
    }
}


// WIREFRAME


protocol WireframeInput {
    func presentDashboardView()
}

class Wireframe: WireframeInput {
    func presentDashboardView() {
        print("prepare dashboard view")
    }
}


// PRESENTER


protocol PresenterInput {
    func userDidClickedLoginButton(email: String?, password: String?)
}

protocol PresenterOutput {
    func displayCompleteUserName(user: User)
    func prepareDashboardView()
    func showError(withError error: Error?)
}

class Presenter {
    var view: ViewOutput?
    var useCase: UseCaseInput?
    var wireframe: WireframeInput?
}

extension Presenter: PresenterInput {
    func userDidClickedLoginButton(email: String?, password: String?) {
        useCase?.signIn(email: email, password: password)
    }
}

extension Presenter: PresenterOutput {
    func displayCompleteUserName(user: User) {
        view?.displayCompleteUserName(completeUserName: "\(user.firstName) \(user.lastName)")
    }
    
    func prepareDashboardView() {
        wireframe?.presentDashboardView()
    }
    
    func showError(withError error: Error?) {
        var errorMessage = "generic error"
        if let networkError = error as? SignInError {
            errorMessage = networkError.description
        }
        view?.showError(withErrorMessage: errorMessage)
    }
}


// USECASE


protocol UseCaseInput {
    func signIn(email: String?, password: String?)
}

class UseCase {
    var presenter: PresenterOutput?
    var network: NetworkInput?
    var persistentStore: PersistentStoreInput?
    
    init(presenter: PresenterOutput, network: NetworkInput, persistentStore: PersistentStoreInput) {
        self.presenter = presenter
        self.network = network
        self.persistentStore = persistentStore
    }

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
            presenter?.showError(withError: nil)
            return
        }
        
        if let error = validate(email: email, password: password) {
            presenter?.showError(withError: error)
            return
        }
        
        network?.signInUser(email: email, password: password) { [weak self] (user) in
            if let user = user {
                self?.persistentStore?.saveUser(user: user, completion: { [weak self] (error) in
                    if let error = error {
                        self?.presenter?.showError(withError: error)
                    } else {
                        self?.presenter?.displayCompleteUserName(user: user)
                        self?.presenter?.prepareDashboardView()
                    }
                })
            } else {
                self?.presenter?.showError(withError: SignInError.unknown)
            }
        }
    }
}


// NETWORK


protocol NetworkInput {
    func signInUser(email: String, password: String, completion: (User?) -> Void)
}

class Network: NetworkInput {
    func signInUser(email: String, password: String, completion: (User?) -> Void) {
        // call Alamofire
        completion((firstName: "Rahim", lastName: "Ben"))
    }
}


// PERSISTENT STORE


protocol PersistentStoreInput {
    func saveUser(user: User, completion: (Error?) -> Void)
}

class PersistentStore: PersistentStoreInput {
    func saveUser(user: User, completion: (Error?) -> Void) {
        completion(nil)
    }
}


// UTILS


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

// TESTS

// #MOCKING

class PresenterMock: PresenterOutput {
    
    var didDisplayCompleteUserName: Bool = false
    var didPrepareDashboardView: Bool = false
    var didShowError: Bool = false
    
    func displayCompleteUserName(user: User) {
        self.didDisplayCompleteUserName = true
    }
    
    func prepareDashboardView() {
        self.didPrepareDashboardView = true
    }
    
    func showError(withError error: Error?) {
        self.didShowError = true
    }
}

class NetworkMock: NetworkInput {
    func signInUser(email: String, password: String, completion: (User?) -> Void) {
        // call Alamofire
        completion((firstName: "Rahim", lastName: "Ben"))
    }
}

class PersistentStoreMock: PersistentStoreInput {
    func saveUser(user: User, completion: (Error?) -> Void) {
        completion(nil)
    }
}

let networkMock = NetworkMock()
let databaseMock = PersistentStoreMock()
let presenterMock = PresenterMock()
let useCase = UseCase(presenter: presenterMock, network: networkMock, persistentStore: databaseMock)

