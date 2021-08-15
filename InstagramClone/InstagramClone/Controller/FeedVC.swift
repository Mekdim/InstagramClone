//
//  FeedVC.swift
//  InstagramClone
//
//  Created by Mekua on 11/23/20.
//  Copyright © 2020 cs61. All rights reserved.
//

import UIKit
import Firebase
private let reuseIdentifier = "Cell"

class FeedVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, FeedCellDelegate {
    
    var usersLikesRef = Database.database().reference().child("users_likes")
    
    var UserFeedRef = Database.database().reference().child("users_feed")
    
    var posts = [Post]()
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        configureNavigationBar()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        fetchPosts()
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    // Mark : UICollectionViewFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width  = view.frame.width
        var height = width + 8 + 8 + 40 + 50 + 60
        return CGSize(width: width, height: height)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        cell.post = self.posts[indexPath.row]
        cell.delegate = self
        // Configure the cell
    
        return cell
    }
    
    func configureNavigationBar(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogOut))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "send2") , style: .plain, target: self, action: #selector(handleShowMessages))
        self.navigationItem.title = "Feed"
    }
    @objc func handleShowMessages(){
        print("handle show messages tapped")
    }
    @objc func handleLogOut(){
        print("log out called")
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // add alert action
        alertController.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (_) in
            do{
                try Auth.auth().signOut()
                // prsent view controller -  change this to root view controller
                let navController = UINavigationController(rootViewController: LogInVC())
                self.present(navController, animated: true, completion: nil)
            } catch{
                print ("Attempted to signout but failed")
            }
        }))
        // add cancel action 
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    func fetchPosts(){
        guard let currentId = Auth.auth().currentUser?.uid else{
            return
        }
        UserFeedRef.child(currentId).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            Database.fetchPosts(with: postId) { (post) in
                self.posts.append(post)
                // FIXME - image flicker happens here because we are reloading table a lot of times. Sometimes, image.loadImages() takes a lot of times and when we do didset on the postcells again and again after sorting and all it udates the post cell with many images many times - race condition maybe?
                self.posts.sort(by: {(post1, post2)->Bool in
                    return post1.creationDate > post2.creationDate
                })
                self.collectionView?.reloadData()
            }
           
        }
    }
    // Mark Feed cell delegatehandlers
    func handleUserNameTapped(for cell: FeedCell) {
        print("user name tapped")
        guard let post = cell.post else{
            return
        }
        // what if UICollectionViewLayout()
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = post.user
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    func handleOptionsTapped(for cell: FeedCell) {
        print("options tapped")
    }
    
    func handleLikeTapped(for cell: FeedCell) {
        print("like tapped")
        guard let post = cell.post else{
            return
        }
        if post.didLike{
            
           post.adjustLikes(addLike: false) { (likes) in
                          
                          cell.likesLabel.text = "\(likes) likes"
            }
            cell.likesButton.setImage(UIImage(named: "like_unselected"), for: .normal)
            
        } else {
            
            post.adjustLikes(addLike: true) { (likes) in
                
                cell.likesLabel.text = "\(likes) likes"
            }
            cell.likesButton.setImage(UIImage(named: "like_selected"), for: .normal)
        }
        
        
    }
    func handleShowLikes(for cell : FeedCell){
        guard let postId = cell.post?.postId else{
            return
        }
        let followLikeVC = FollowLikeVc()
        followLikeVC.postId = postId
        followLikeVC.viewingMode = FollowLikeVc.ViewingMode(index :2)
        navigationController?.pushViewController(followLikeVC, animated: true)
    }
    func handleCommentTapped(for cell: FeedCell) {
        guard let postId = cell.post?.postId else{
            return
        }
        let commentVC = CommentVc(collectionViewLayout: UICollectionViewFlowLayout())
        commentVC.postId = postId
        navigationController?.pushViewController(commentVC, animated: true)
    }
    // makes this updates in batch updates in firestore and also use call backs as well
    
    // there is some bug because of sorting maybe
    func handleConfigureLikeButton(for cell: FeedCell) {
        guard let currentUid = Auth.auth().currentUser?.uid else{
            return
        }
        guard let postId = cell.post?.postId else{
            return
        }
        usersLikesRef.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(postId){
                print("user has liked post")
                cell.post?.didLike = true
                cell.likesButton.setImage(UIImage(named: "like_selected"), for: .normal)
            } else{
                print ("user hasnt like post")
                
            }
        }
    }
    

    
  

}
