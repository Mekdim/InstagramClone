//
//  UserProfileVC.swift
//  InstagramClone
//
//  Created by Mekua on 11/23/20.
//  Copyright © 2020 cs61. All rights reserved.
//

import UIKit
import Firebase
private let reuseIdentifier = "Cell"
private let headerIdentifier = "UserProfileHeaderCollectionViewCell"
// shall I disbble landscape mode - not to rotate 
class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {
    // pust these in constant files outside classes
    var UsersPostsRef = Database.database().reference().child("users_posts")
    var PostsRef = Database.database().reference().child("posts")
    
    var UserFollowingRef = Database.database().reference().child("users_following")
    var UserFollowerRef = Database.database().reference().child("users_followers")
    
    var user : User?
    var posts =  [Post]()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(" view will appear called for user profile vc!!!")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load called for user profile vc!!!")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UserPostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        // coulnt get this UICollectionElementSectionKindSectionHeader
        self.collectionView!.register(UserProfileHeaderCollectionViewCell.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader , withReuseIdentifier: headerIdentifier)
        
        self.collectionView.backgroundColor = .white
        
        if (self.user == nil){
            fetchCurrentUserData()
        }
        // should we do this on view did appear too?
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
    // Mark UICollectionViewFlow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2)/3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        1
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserPostCell
        cell.post = self.posts[indexPath.item]
        // Configure the cell
    
        return cell
    }
    // adding override data here
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = self.collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeaderCollectionViewCell
        header.delegate = self
        
        header.user = user
        navigationItem.title = user?.userName
           
       
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    func fetchPosts(){
        var uid : String!
        if let user = self.user {
            uid = user.uid
        }
        else{
            uid = Auth.auth().currentUser?.uid
        }
        
        self.UsersPostsRef.child(uid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            Database.fetchPosts(with: postId) { (post) in
                self.posts.append(post)
                // FIXME - image flicker happens here because we are reloading table a lot of times. Sometimes, image.loadImages() takes a lot of times and when we do didset on the postcells again and again after sorting and all it udates the post cell with many images many times - race condition maybe?
                self.posts.sort(by: {(post1, post2)->Bool in
                    return post1.creationDate > post2.creationDate
                })
                print("About to reload dataaa!!!!!!!!!!!!")
                self.collectionView?.reloadData()
            }
                
                
        }
        
    }
    func fetchCurrentUserData(){
        guard let currentUid = Auth.auth().currentUser?.uid else {
            return
        }
        print("current user is is \(currentUid)")
        Database.database().reference().child("users").child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
        guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else{
            return
        }
        let uid = snapshot.key
        let user = User(uid: uid, dictionary: dictionary)
        self.user = user
        self.navigationItem.title = user.userName
        self.collectionView.reloadData()
    }
    }
    // Mark -- UserProfileHeader Protocol
    func setUserStats(for header: UserProfileHeaderCollectionViewCell) {
        // set user stat
        guard let uid = header.user?.uid else {
            return
        }
        var numberOfFollowers : Int!
        var numberOfFollowing : Int!
        // observe instead of ObservesingleEvent observe so that it observes more than one time - in real time updates follow
        UserFollowerRef.child(uid).observe(.value) { (snapshot) in
            if let snapshot =  snapshot.value as? Dictionary<String, AnyObject> {
                numberOfFollowers = snapshot.count
            }
            else{
                numberOfFollowers = 0
            }
            let attributedString = NSMutableAttributedString(string: "\(numberOfFollowers!)\n", attributes: [NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)])
            // naming - follower here
            let followersAttributedString = NSMutableAttributedString(string: "Follower", attributes: [NSAttributedString.Key.font :UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            attributedString.append(followersAttributedString)
            header.followersLabel.attributedText = attributedString
        }
        
        UserFollowingRef.child(uid).observe(.value) { (snapshot) in
            if let snapshot =  snapshot.value as? Dictionary<String, AnyObject> {
                numberOfFollowing = snapshot.count
            }
            else{
                numberOfFollowing = 0
            }
            let attributedString = NSMutableAttributedString(string: "\(numberOfFollowing!)\n", attributes: [NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)])
            // naming - following here
            let followingAttributedString = NSMutableAttributedString(string: "Following", attributes: [NSAttributedString.Key.font :UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            attributedString.append(followingAttributedString)
            header.followingLabel.attributedText = attributedString
        }
    }
    func handleEditFollowTapped(for header : UserProfileHeaderCollectionViewCell){
       
        guard let user  = header.user else{
            return
        }
        if header.editProfileButton.titleLabel?.text == "Edit Profile" {
            print ("edit Profile")
           
        }
        else{
            if header.editProfileButton.titleLabel?.text == "Follow"{
                // shouldnt this wait until user follow finishes
                header.editProfileButton.setTitle("Following", for: .normal)
                user.follow()
            }
            else{
                header.editProfileButton.setTitle("Follow", for: .normal)
                user.unFollow()
            }
        }
        
    }
    func handleFollowersTapped(for header: UserProfileHeaderCollectionViewCell) {
        print("handle followers tapped")
        let followVC = FollowLikeVc()
        followVC.viewingMode = FollowLikeVc.ViewingMode(index : 1)
        followVC.uid = user?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    func handleFollowingTapped(for header: UserProfileHeaderCollectionViewCell) {
        print("handle following tapped")
        let followVC = FollowLikeVc()
        followVC.viewingMode = FollowLikeVc.ViewingMode(index :0)
        followVC.uid = user?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

