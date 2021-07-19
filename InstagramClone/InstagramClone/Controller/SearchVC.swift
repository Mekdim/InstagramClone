//
//  SearchVC.swift
//  InstagramClone
//
//  Created by Mekua on 11/23/20.
//  Copyright © 2020 cs61. All rights reserved.
//

import UIKit
import Firebase
class SearchVC: UITableViewController {
    var users = [User]()
    private let reuseIdentifier = "SearchUserCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavController()
         
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)
        fetchUsers()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath :IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchUserCell
        cell.user = users[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        print("user name clicked is ", user.userName)
        
        // create instance of user profile as
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = user
        
        // push view controller
        
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    // configure navigation controller
    func configureNavController(){
        navigationItem.title = "Explore"
    }
    func fetchUsers(){
        // shall I use singleObserve here ?
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
            guard let dictionary  = snapshot.value as? Dictionary<String, AnyObject> else{
                return
            }
            let uid  = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            self.users.append(user)
            self.tableView.reloadData()
        }
    }

}
