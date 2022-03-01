//
//  LoginViewController.swift
//  MessangerProject
//
//  Created by Nathaniel Whittington on 2/21/22.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
import FBSDKLoginKit

class LoginViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    
    let loginButton : FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email", "public_profile"]
        return button
    }()
    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
        
    }()
    
    private let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
        
    }()
    
    private let emailField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        return field
    }()
    
    private let passwordField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let registorButton : UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log in"
        loginButton.delegate = self
        view.backgroundColor = . yellow
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        registorButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
//        emailField.delegate = self
//        passwordField.delegate = self
        //add subviews
        
        
        
        
        view.addSubview(loginButton)
        
        view.addSubview(scrollView)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(registorButton)
        scrollView.addSubview(passwordField)
        
       
       
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width - size)/2, y: 20, width: size, height: size)
        emailField.frame = CGRect(x: 30, y: imageView.bottom + 10, width: scrollView.width - 60, height: 50)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom + 10, width: scrollView.width - 60, height: 50)
        registorButton.frame = CGRect(x: 30, y: passwordField.bottom + 10, width: scrollView.width - 60, height: 50)
        loginButton.frame = CGRect(x: 30, y: registorButton.bottom + 10, width: scrollView.width - 60, height: 50)
    }
    
    
   
    
    
    @objc func loginButtonTapped(){
       
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLogin()
            return
        }
        
        spinner.show(in: view)
        //FireBaseloging
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) {[weak self] (AuthDataResult, Error) in
            guard let strongSelf = self else {return}
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let results = AuthDataResult,  Error == nil else {
                 print("Unable to sign in with email \(email)")
                return
            }
          
            let user = results.user
            
            UserDefaults.standard.setValue(email, forKey: "email")
            print("Sign in with \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            
        }
        
        
    }
    
    
    @objc func alertUserLogin(){
        let alert = UIAlertController(title: "Whoops", message: "Please enter all information to login", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    @objc func didTapRegister(){
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
        
    }
   

}

extension LoginViewController : LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        //no operation
    }
    
    
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("Usser failed to log in with facebook.")
            return
        }
        let credentails = FacebookAuthProvider.credential(withAccessToken: token)
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "first_name, last_name,picture.type(large)",], tokenString: token, version: nil, httpMethod: .get)
        facebookRequest.start { (results, respons, Error) in
            guard let result = results as? [String : Any], error == nil else {
                print("Failed to make facebook graph request")
                return
            }
            print(results)
            
            guard let firstName = result["first_name"] as? String, let lastName = result["last_name"] as? String,
                  let email = result["email"] as? String, let picture = result["picture"] as? [String:Any], let date = result["data"] as? [String:Any], let pictureUrl = result["url"] as? String else {
                print("Failed to get email and name from fb result")
                return
                
            }
            UserDefaults.standard.set(email, forKey: "email")

            
           
            
            DatabaseManager.shared.userExists(with: email) {[weak self] (exists) in
                guard let strongSelf = self else {return}
                
                if !exists {
                    
                    let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                    DatabaseManager.shared.insertUser(with:chatUser,completion: {
                        success in
                        //upload image
                        if success{
                            
                            guard let url = URL(string: pictureUrl) else {
                                return
                            }
                            print("downloading data from facebook image")
                            URLSession.shared.dataTask(with: url) { (Data, _, _) in
                               
                                guard let data = Data else{
                                    
                                    print("failed to get data from facebook")
                                    return
                                }
                                print("got data from fb, uploading ...")
                                
                                let fileName = chatUser.profilePictureFileName
                                StoreManager.shared.uploadProfilePictures(with: data, fileName: fileName) { (result) in
                                    switch result {
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.setValue(downloadUrl, forKey: "profilea_picture_png")
                                        print("download")
                                    case .failure(let error):
                                        print("Storage manager error : \(error)")
                                    }
                                }
                            }.resume()
                            
                            
                        }
                    })
                }
            }
            
            FirebaseAuth.Auth.auth().signIn(with: credentails) {[weak self] (AuthDataResult, Error) in
               
                guard let strongSelf = self else {return}
                guard let _ = AuthDataResult, Error == nil else {
                    if let error = error {
                    print("Facebook credential login filed, MFA may be needed. -\(error) ")
                    }
                    return
                }
                print("Successfully logged user in")
                strongSelf.dismiss(animated: true, completion: nil)
            }
            
        }
        
       
    }
    
    
}


