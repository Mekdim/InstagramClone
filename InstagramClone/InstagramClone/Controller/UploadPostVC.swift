//
//  UploadPostVC.swift
//  InstagramClone
//
//  Created by Mekua on 11/23/20.
//  Copyright © 2020 cs61. All rights reserved.
//

import UIKit
import Firebase
var PostsRef = Database.database().reference().child("posts")
var UsersPostsRef = Database.database().reference().child("users_posts")
class UploadPostVC: UIViewController, UITextViewDelegate {
    // Mark properties
    var UserFollowingRef = Database.database().reference().child("users_following")
    var UserFollowerRef = Database.database().reference().child("users_followers")
    var UserFeedRef = Database.database().reference().child("users_feed")
    
    var selectedImage : UIImage?
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .blue
        return iv
    }()
    let captionTextView : UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor.groupTableViewBackground
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    let shareButton : UIButton = {
        let button  = UIButton(type: .system)
        button.backgroundColor = UIColor(red:149/255, green: 204/255, blue: 244/255, alpha:1)
        button.setTitle("Publish", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSharePost), for: .touchUpInside)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewComponents()
        loadImage()
        captionTextView.delegate = self
        // without setting this the previosus controler shows in the back
        view.backgroundColor = .white
        
        // Do any additional setup after loading the view.
    }
    func configureViewComponents(){
        view.addSubview(photoImageView)
        // 92 from top anchor b/c the top bar is hiding it
        photoImageView.anchor(top: view.topAnchor, bottom: nil, left: view.leftAnchor, right: nil, paddingTop: 92, paddingBottom: 0, paddingLeft: 12, paddingRight: 0, width: 100, height: 100)
        view.addSubview(captionTextView)
        captionTextView.anchor(top: view.topAnchor, bottom: nil, left: photoImageView.rightAnchor, right: view.rightAnchor, paddingTop: 92, paddingBottom: 0, paddingLeft: 12, paddingRight: 12, width: 0, height: 100)
        view.addSubview(shareButton)
        shareButton.anchor(top: photoImageView.bottomAnchor, bottom: nil, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 12, paddingBottom: 0, paddingLeft: 24, paddingRight: 24, width: 0, height: 40)
        
    }
    func loadImage(){
        guard let selectedImage = self.selectedImage else{
            return
        }
        photoImageView.image = selectedImage
    }
    func textViewDidChange(_ textView: UITextView) {
        guard !textView.text.isEmpty else{
            shareButton.isEnabled = false
            shareButton.backgroundColor = UIColor(red:149/255, green: 204/255, blue: 244/255, alpha:1)
            return
        }
        shareButton.isEnabled = true
        shareButton.backgroundColor = UIColor(red:17/255, green: 154/255, blue: 237/255, alpha:1)
    }
    func updateUserFeeds(with postId: String){
        guard let currentUid = Auth.auth().currentUser?.uid else{
            return
        }
        let values = [postId : 1]
        // update follower feeds
        UserFollowerRef.child(currentUid).observe(.childAdded) { (snapshot) in
            let follower_id = snapshot.key
            self.UserFeedRef.child(follower_id).updateChildValues(values)
            
        }
        // update current user feeds
         UserFeedRef.child(currentUid).updateChildValues(values)
    }
    // handler section
    // I should fix - it uploads multiple times if internet is slow and I tap share button again and again
    @objc func handleSharePost(){
        guard let caption = captionTextView.text,
            let posting = photoImageView.image,
            let currentUid = Auth.auth().currentUser?.uid else{
                return
        }
        guard let uploadData = posting.jpegData(compressionQuality: 0.5) else{
            return
        }
        // number of seconds since 1970
        let creationDate = Int(NSDate().timeIntervalSince1970)
        let fileName = NSUUID().uuidString
        let storageReference = Storage.storage().reference().child("postImages").child(fileName)
        storageReference.putData(uploadData, metadata: nil) { (metadata, error) in
            if let error = error {
                print ("failed to upload data with error ", error.localizedDescription)
                return
            }
            storageReference.downloadURL(completion: {(url, error) in
               if let error = error {
                   print(error.localizedDescription)
                   print("there is an error")
                
               }
               guard let PostImageUrl = url?.absoluteString else{
                   return
               }
                let values = ["caption":caption, "creationDate": creationDate, "likes":0, "imageUrl": PostImageUrl, "ownerUid": currentUid] as [String:Any]
                let postId = PostsRef.childByAutoId()
                postId.updateChildValues(values) { (error, ref) in
                    // return to home feed
                    if let error = error{
                        // I havent returned here but I should
                        print ("there was error posting image with error ", error.localizedDescription)
                    }
                    // update user post structure
                    // if I put postid without casting it it doesnt update the userpost strcture but it somehow goes successfully
                    let postIdkey = postId.key! as String
                    UsersPostsRef.child(currentUid).updateChildValues([postIdkey: 1]) { (err, ref) in
                        if let error = error{
                            // I havent returned here but I should
                            print ("there was error posting image in user_posts with error ", error.localizedDescription)
                        }
                        self.updateUserFeeds(with: postIdkey)
                        // did this work? Also will this dismiss before the function above finishes?
                        self.dismiss(animated: true) {
                            self.tabBarController?.selectedIndex = 0
                        }
                    }
                    
                }
            
           })
    }
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
