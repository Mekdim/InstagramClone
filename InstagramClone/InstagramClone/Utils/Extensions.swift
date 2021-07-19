//
//  Extensions.swift
//  InstagramClone
//
//  Created by Mekua on 11/10/20.
//  Copyright © 2020 cs61. All rights reserved.
//

import UIKit
import Firebase
var imageCache = [String: UIImage]()
var UserFollowingRef = Database.database().reference().child("users_following")
var UserFollowerRef = Database.database().reference().child("users_followers")
var USERS_REF = Database.database().reference().child("users")
extension UIImageView{
    func loadImage(with urlString : String) {
        if let catchedImage = imageCache[urlString] {
            self.image = catchedImage
            return
        }
        guard let url = URL(string: urlString) else {
            return
        }
        URLSession.shared.dataTask(with: url) { (data, urlResponse, error) in
            if let error = error {
                print ("failed to load with error with ", error.localizedDescription)
                return
            }
            guard let imageData = data else {
                return
            }
            let photoImage = UIImage(data: imageData)
            imageCache[url.absoluteString] = photoImage
            //Mark :  set image - why dispatch queue?
            DispatchQueue.main.async {
                self.image = photoImage
            }
        }.resume()
    }
}
extension UIWindow {
    // to return key window I used extension
    //stackoverflow.com/questions/57134259/how-to-resolve-keywindow-was-deprecated-in-ios-13-0
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?,bottom: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, right: NSLayoutXAxisAnchor?,paddingTop:CGFloat, paddingBottom:CGFloat, paddingLeft:CGFloat, paddingRight:CGFloat, width:CGFloat, height:CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        if width != 0{
            widthAnchor.constraint(equalToConstant: width ).isActive = true
        }
        if height != 0{
            heightAnchor.constraint(equalToConstant: height ).isActive = true
        }
        
    }
}

extension Database{
    static func fetchUser(with uid: String, completion: @escaping(User)->() ){
        USERS_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dic  = snapshot.value as? Dictionary<String, AnyObject> else{
                return
            }
               
            let user = User(uid: uid, dictionary: dic)
            completion(user)
            
        }
    }
    static func fetchPosts(with postId : String, completion: @escaping(Post)->() ){
        PostsRef.child(postId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {
                return
            }
            guard let ownerUid = dictionary["ownerUid"] as? String else{
                return
            }
            Database.fetchUser(with: ownerUid) { (user) in
                let post = Post(postId: postId, user: user, dictionary: dictionary)
                completion(post)
            }
            
        }
    }
}
