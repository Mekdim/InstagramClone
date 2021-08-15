//
//  SignUpVC.swift
//  InstagramClone
//
//  Created by Mekua on 11/12/20.
//  Copyright © 2020 cs61. All rights reserved.
//

import UIKit
import Firebase
class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var imageSelected = false
    let photoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSelectProfilePhoto), for: .touchUpInside)
        return button
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
        tf.isSecureTextEntry = true
        tf.placeholder = "Password"
        tf.backgroundColor = UIColor(white:0.0, alpha:0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    let userNameTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "User name"
        tf.backgroundColor = UIColor(white:0.0, alpha:0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let fullNameextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Full Name"
        tf.backgroundColor = UIColor(white:0.0, alpha:0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    let SignUpButton:UIButton = {
           let button = UIButton(type: .system)
           button.setTitle("SignUp", for: .normal)
           button.setTitleColor(.white, for: .normal)
           button.backgroundColor = UIColor(red:149/255, green:204/255, blue: 244/255, alpha:1)
           button.layer.cornerRadius = 5
          button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
           button.isEnabled = false
           return button
       }()
    let AlreadyHaveAccountButton:UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSAttributedString.Key.font :UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSMutableAttributedString(string: "Log in", attributes: [NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowLogIn), for: .touchUpInside)
        return button
    }()
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let profilePicture = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            imageSelected = false
            return
        }
        imageSelected = true
        //photoButton.backgroundColor = .black
        //configure photo button with selected image
        photoButton.layer.cornerRadius = photoButton.frame.width/2
        photoButton.layer.masksToBounds = true
        photoButton.layer.borderColor = UIColor.black.cgColor
        photoButton.layer.borderWidth = 2
        photoButton.setImage(profilePicture.withRenderingMode(.alwaysOriginal), for: .normal)
        // why self dismiss here, picker.dismiss ?
        self.dismiss(animated: true, completion: nil)
    }
    @objc func handleSelectProfilePhoto (){
        // configure image picker
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        // present image picker
        self.present(imagePicker, animated: true, completion: nil)
    }
        
    @objc func handleShowLogIn(){
           print("hey")
        _ = navigationController?.popViewController(animated: true)
    }
    @objc func handleSignUp(){
          
        guard let email =  emailTextField.text else {return}
        guard let password =  passwordTextField.text else {return}
        guard let userName =  userNameTextField.text else {return}
        guard let fullName =  fullNameextField.text else {return}
         print("email is \(email) and password is \(password)")
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            // handle error
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let profileImg = self.photoButton.imageView?.image else{
                return
            }
            // upload data
            guard let uploadData = profileImg.jpegData(compressionQuality: 0.3) else {
                return
            }
            // place image in firebase . is this always unique?
            let fileName = NSUUID().uuidString
            let storageReference = Storage.storage().reference().child("profile_images").child(fileName)
            storageReference.putData(uploadData, metadata: nil, completion: {(metadata, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                storageReference.downloadURL(completion: {(url, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        print("there is an error")
                        
                    }
                    guard let ProfileImageUrl = url?.absoluteString else{
                        return
                    }
                    let dictionaryValues = ["userName": userName, "fullName": fullName, "profileImageUrl":ProfileImageUrl]
                    let values = [user?.user.uid: dictionaryValues]
                    // save to database
                   print("hey")
                    Database.database().reference().child("users").updateChildValues(values) { (err, ref) in
                                         if let error = err {
                                             print(error.localizedDescription)
                                             
                                         }
                                           print("succesfully new user signed up")
                                           guard let mainTabVC = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController as? MainTabVC else{
                                               print("main tab vc didnt get instantiated")
                                               return
                                           }
                                           self.dismiss(animated: true, completion: nil)
                                       }
            })
            // success
            print("succefully created")
        })
        }
    }
    @objc func formValidation(){
          
        guard emailTextField.hasText, passwordTextField.hasText, fullNameextField.hasText, userNameTextField.hasText, imageSelected == true else {
            SignUpButton.isEnabled = false
            SignUpButton.backgroundColor = UIColor(red: 149/256, green: 204/256, blue: 244/255, alpha: 1)
            return
        }
        SignUpButton.isEnabled = true
        SignUpButton.backgroundColor = UIColor(red: 17/256, green: 154/256, blue: 237/255, alpha: 1)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(photoButton)
        photoButton.anchor(top: view.topAnchor, bottom: nil, left: nil, right: nil, paddingTop: 40, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 140, height: 140)
        photoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        configureViewComponents()
        view.addSubview(AlreadyHaveAccountButton)
        AlreadyHaveAccountButton.anchor(top: nil, bottom: view.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 50)

        // Do any additional setup after loading the view.
    }
    func configureViewComponents (){
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, userNameTextField, fullNameextField, SignUpButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        view.addSubview(stackView)
        stackView.anchor(top: photoButton.bottomAnchor, bottom: nil, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingBottom: 0, paddingLeft: 20, paddingRight: 20, width: 0, height: 240)
        
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
