//
//  MainTabVC.swift
//  InstagramClone
//
//  Created by Mekua on 11/23/20.
//  Copyright © 2020 cs61. All rights reserved.
//

import UIKit
import Firebase
class MainTabVC: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        checkIfUserIsLoggedIn()
        configureViewControllers()
        
    }
    // configure view controllers in main tabbar vc
    func configureViewControllers(){
        // make sure the images exist - force unwrapping now
        let feedVC = constructNavController(unSelectedImage: UIImage(named: "home_unselected")!, selectedImage: UIImage(named: "home_selected")!, rootViewController:FeedVC(collectionViewLayout: UICollectionViewFlowLayout() ) )
        let searchVC = constructNavController(unSelectedImage: UIImage(named: "search_unselected")!, selectedImage: UIImage(named: "search_selected")!, rootViewController:SearchVC() )
        //let uploadPostVC = constructNavController(unSelectedImage: //UIImage(named: "plus_unselected")!, selectedImage: //UIImage(named: "plus_unselected")!, //rootViewController:UploadPostVC() )
        let selectImageVC = constructNavController(unSelectedImage: UIImage(named: "plus_unselected")!, selectedImage: UIImage(named: "plus_unselected")!)
        
        let notoficationsVC = constructNavController(unSelectedImage: UIImage(named: "like_unselected")!, selectedImage: UIImage(named: "like_selected")!, rootViewController:NotificationVC() )
        let userProfileVC = constructNavController(unSelectedImage: UIImage(named: "profile_unselected")!, selectedImage: UIImage(named: "profile_selected")!, rootViewController:UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout() ) )
        // temporary class
        let postLocationVC = PostLocationVC()
        // view controller to be added to tab bar
        viewControllers = [feedVC, searchVC, selectImageVC, notoficationsVC, userProfileVC]
        tabBar.tintColor = .black
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.index(of: viewController)
        if (index == 2){
            let selectImageVC = SelectImageVC(collectionViewLayout: UICollectionViewFlowLayout())
            let navController = UINavigationController(rootViewController: selectImageVC)
            navController.navigationBar.tintColor = .black
            present(navController, animated: true, completion: nil)
            return false
        }
        // why return true here and false up
        // Aha this is just to show view controller’s tab should be selected or the other one to be active - so false
        return true
    }
    
    func constructNavController(unSelectedImage:UIImage, selectedImage:UIImage, rootViewController: UIViewController = UIViewController())->UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.selectedImage = selectedImage
        navController.tabBarItem.image = unSelectedImage
        navController.navigationBar.tintColor = .black
        return navController
    }
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser != nil {
            print("user is logged in")
        }
        else{
            // change this so this is the root controller
            DispatchQueue.main.async {
                let navController = UINavigationController(rootViewController: LogInVC())
                print("user is logged out")
                UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController = navController
                   
                //self.dismiss(animated: true, completion: nil)
                //self.present(navController, animated: true, //completion: nil)
                
            }
            
        }
    }
    // construct nav controller
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
