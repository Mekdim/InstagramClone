//
//  LogInVC.swift
//  InstagramClone
//
//  Created by Mekua on 11/10/20.
//  Copyright © 2020 cs61. All rights reserved.
//

import UIKit
import Firebase
class LogInVC: UIViewController {
    
    let logoContainerView: UIView = {
        let view = UIView()
        // image literal didnt work for  me here
        let logoImageView = UIImageView(image:UIImage(named: "Instagram_logo_white"))
        
        logoImageView.contentMode = .scaleAspectFit
        view.addSubview(logoImageView)
        logoImageView.anchor(top: nil, bottom: nil, left: nil, right: nil, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 200, height: 50)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 175/255, alpha: 1)
        
        return view
    }()
    
    let emailTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white:0.0, alpha:0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "password"
        tf.backgroundColor = UIColor(white:0.0, alpha:0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let logInButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("LogIn", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red:149/255, green:204/255, blue: 244/255, alpha:1)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogIn), for: .touchUpInside)
        return button
    }()
    @objc func handleSignUp(){
        print("sign up clicked")
        let signUpVC = SignUpVC()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    @objc func handleLogIn(){
        print("log in clicked")
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text else{
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print("unable to sign in with error", error.localizedDescription)
                return
            }
            print("successfully signed in")
            // I got this from stack overfow because UIApplication.shared.keyWindow?.rootViewController? isnt working
            guard let mainTabVC = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController as? MainTabVC
                else{
                    print("main tab vc didnt get instantiated")
                    return
                }
            self.dismiss(animated: true, completion: nil)
        }
        
        
        
    }
    @objc func formValidation(){
          
        guard emailTextField.hasText, passwordTextField.hasText else {
            logInButton.isEnabled = false
            logInButton.backgroundColor = UIColor(red: 149/256, green: 204/256, blue: 244/255, alpha: 1)
            return
        }
        logInButton.isEnabled = true
        logInButton.backgroundColor = UIColor(red: 17/256, green: 154/256, blue: 237/255, alpha: 1)
        
    }
    
    let dontHaveAccountButton:UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account? ", attributes: [NSAttributedString.Key.font :UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSMutableAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    func configureViewComponents (){
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, logInButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        view.addSubview(stackView)
        stackView.anchor(top: logoContainerView.bottomAnchor, bottom: nil, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingBottom: 0, paddingLeft: 20, paddingRight: 20, width: 0, height: 140)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.topAnchor, bottom: nil, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 150)
        configureViewComponents()
        view.addSubview(dontHaveAccountButton)
        
        dontHaveAccountButton.anchor(top: nil, bottom: view.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 50)
        //view.addSubview(emailTextField)
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
