//
//  FollowVc.swift
//  InstagramClone
//
//  Created by Mekua on 12/2/20.
//  Copyright © 2020 cs61. All rights reserved.
//

import UIKit
import Firebase
private let reuseIdentifier = "FollowCell"
class FollowVc : UITableViewController, FollowCellDelegate{
    
    
    // Mark -- Properties
    var viewFollowers  = false
    var viewFollowing = false
    var uid : String?
    var users = [User]()
    
    var UserFollowingRef = Database.database().reference().child("users_following")
    var UserFollowerRef = Database.database().reference().child("users_followers")
    var USERS_REF = Database.database().reference().child("users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // register cell class
        tableView.register(FollowCell.self, forCellReuseIdentifier: reuseIdentifier)
        // configure nav controller
        if viewFollowers{
             navigationItem.title = "Followers"
        }
        else{
            navigationItem.title = "Following"
        }
        // clear separator lines
        tableView.separatorColor = .clear
        fetchUsers()
        if let uid = self.uid {
            print("the uid to follow or following is \(uid)")
        }
        
    }
    // Mark -- UITableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FollowCell
        cell.user = users[indexPath.row]
        cell.delegate = self
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let userProfileVc = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVc.user = user
        print(navigationController)
        navigationController?.pushViewController(userProfileVc, animated: true)
    }
    
    // Mark -- protocol conform
    func handleFollowTapped(for cell: FollowCell) {
        guard let user = cell.user else{
            return
        }
        if user.isFollowed{
            user.unFollow()
            cell.followButton.setTitle("Follow", for: .normal)
            cell.followButton.setTitleColor(.white, for: .normal)
            cell.followButton.layer.borderWidth = 0
            cell.followButton.layer.borderColor = UIColor.lightGray.cgColor
            cell.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        }
        else{
            user.follow()
            cell.followButton.setTitle("Following", for: .normal)
            cell.followButton.setTitleColor(.black, for: .normal)
            cell.followButton.layer.borderWidth = 0.5
            cell.followButton.layer.borderColor = UIColor.lightGray.cgColor
            cell.followButton.backgroundColor = .white
        }
        print ("follow tapped from follow cells")
    }
    // Mark -- ApI
    
    func fetchUsers(){
        guard let uid = self.uid else {
            return
        }
        var ref : DatabaseReference!
        if viewFollowers {
            // fetch followers
            ref  = UserFollowerRef
        } else{
            // fetch following
            ref = UserFollowingRef
        }
        // I didnt do childadded here because it listens everytime child is added even if it was removed - duplicate entry can show
        ref.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else{
                    return
                }
                print(allObjects.count)
                allObjects.forEach { (snapshot) in
                    let userId = snapshot.key
                    // using extension to avoid duplication to fetchuser
                    Database.fetchUser(with: userId) { (user) in
                        self.users.append(user)
                        self.tableView.reloadData()
                    }
                }
        }
    }
}
