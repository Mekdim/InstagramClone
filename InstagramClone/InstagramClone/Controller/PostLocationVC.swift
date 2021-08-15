//
//  PostLocationVC.swift
//  InstagramClone
//
//  Created by Mekua on 7/29/21.
//  Copyright © 2021 cs61. All rights reserved.
//

import UIKit
import Firebase
import GeoFire
class PostLocationVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        view.addSubview(postView)
        postView.anchor(top: view.topAnchor, bottom: nil, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 50)
        view.addSubview(postButton)
        postButton.anchor(top: postView.bottomAnchor, bottom: nil, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 35)
        
        //view.addSubview(emailTextField)
        
        // Do any additional setup after loading the view.
    }
    let postView : UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor(white:0.0, alpha:0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    let postButton : UIButton  = {
        let button = UIButton(type: .system)
        button.setTitle("post", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        return button
    }()
    func sendCoordinates(){
        let latitude = 51.5074
        let longitude = 0.12780
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        let hash = GFUtils.geoHash(forLocation: location)
        let documentData: [String: Any] = [
            "geohash": hash,
            "lat": latitude,
            "lng": longitude
        ]

        //let londonRef = db.collection("cities").document("LON")
    }
    
}
