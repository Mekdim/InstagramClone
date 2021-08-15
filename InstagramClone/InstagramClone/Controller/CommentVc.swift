//
//  CommentVc.swift
//  InstagramClone
//
//  Created by Mekua on 7/31/21.
//  Copyright © 2021 cs61. All rights reserved.
//

import Foundation
import Firebase
import UIKit
private let reuseIdentifier = "Cell"
class CommentVc : UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // var because we are going to mutate it
    var commentRef = Database.database().reference().child("comments")
    var postId : String?
    var comments = [Comment]()
    lazy var containerView: UIView = {
        let containerview = UIView()
        containerview.backgroundColor = .white
        containerview.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        containerview.addSubview(commentTextField)
        commentTextField.anchor(top: containerview.topAnchor, bottom: containerview.bottomAnchor, left: containerview.leftAnchor, right: containerview.rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, width: 0, height: 0)
        containerview.addSubview(postButton)
        postButton.anchor(top: nil, bottom: nil, left: nil, right: containerview.rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 8, width: 0, height: 0)
        postButton.centerYAnchor.constraint(equalTo: containerview.centerYAnchor).isActive = true
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        containerview.addSubview(separatorView)
        separatorView.anchor(top: containerview.topAnchor, bottom: nil, left: containerview.leftAnchor, right: containerview.rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 0.5)
        return containerview
    }()
    let commentTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Comment"
        tf.backgroundColor = UIColor(white:0.0, alpha:0.03)
        //tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        
        return tf
    }()
    let postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Post", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleUploadComment), for: .touchUpInside)
       return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white
        navigationItem.title  = "Comments"
        fetchComments()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    // accessory view when key board is touched
    override var inputAccessoryView: UIView?{
        get {
            return containerView
        }
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    // Mark - UICollectionView
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as!  CommentCell
        cell.comment = comments[indexPath.item]
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    @objc func handleUploadComment(){
        guard let postId = self.postId else{
            return
        }
        guard let commentText = commentTextField.text else{
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        let values = [ "commentText":  commentText, "creationdate": creationDate, "uid": uid] as [String : Any]
        // should be done with call backs
        commentRef.child(postId).childByAutoId().updateChildValues(values){err, ref in
            self.commentTextField.text = ""
        }
    }
    
    func fetchComments(){
        guard let postId = self.postId else{
                return
            }
            commentRef.child(postId).observe(.childAdded) { (snapshot) in
                
                guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else{return}
                guard let uid = dictionary["uid"] as? String else{
                    return
                }
                Database.fetchUser(with: uid) { (user) in
                               
                    let comment = Comment(user:user ,dictionary: dictionary)
                    self.comments.append(comment)
                        
                    self.collectionView?.reloadData()
                }
                
                
            }
    }
}
