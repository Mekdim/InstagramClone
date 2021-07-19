//
//  FollowCell.swift
//  InstagramClone
//
//  Created by Mekua on 12/2/20.
//  Copyright © 2020 cs61. All rights reserved.
//

import UIKit
import Firebase
class FollowCell: UITableViewCell {
     // Mark -- Property section
    var delegate : FollowCellDelegate?
    var user : User? {
        didSet {
           
            guard let userName = user?.userName else{
                return
            }
            guard let profileImageUrl = user?.profileImageUrl else{
                return
            }
            guard let fullName = user?.name else{
                return
            }
            profileImageView.loadImage(with: profileImageUrl)
            self.textLabel?.text = userName
            self.detailTextLabel?.text = fullName
            self.selectionStyle = .none
            // hide follow button for current user
            if user?.uid == Auth.auth().currentUser?.uid{
                self.followButton.isHidden = true
            }
            user?.checkIfUserIsFollowed(completion: { (followed) in
                if followed{
                    self.followButton.setTitle("Following", for: .normal)
                    self.followButton.setTitleColor(.black, for: .normal)
                    self.followButton.layer.borderWidth = 0.5
                    self.followButton.layer.borderColor = UIColor.lightGray.cgColor
                    self.followButton.backgroundColor = .white
                    
                }
                else{
                    self.followButton.setTitle("Follow", for: .normal)
                                       self.followButton.setTitleColor(.white, for: .normal)
                                       self.followButton.layer.borderWidth = 0
                                       self.followButton.layer.borderColor = UIColor.lightGray.cgColor
                                       self.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
                }
            })
        }
    }
    let profileImageView: UIImageView = {
           let iv = UIImageView()
           
           iv.contentMode = .scaleAspectFill
           iv.clipsToBounds = true
           iv.backgroundColor = .lightGray
           return iv
       }()
    // should I make this lazy var
    let followButton : UIButton = {
        let button  = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
         followButton.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, bottom: nil, left: leftAnchor, right: nil, paddingTop: 0, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, width: 48, height: 48)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 48/2
        
        addSubview(followButton)
        followButton.anchor(top: nil, bottom: nil, left: nil, right: rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 12, width: 90, height: 30)
        followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        followButton.layer.cornerRadius = 3
        
    }
    override func layoutSubviews() {
           super.layoutSubviews()
           textLabel?.frame = CGRect(x: 68, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
           textLabel?.font  = UIFont.boldSystemFont(ofSize: 12)
           detailTextLabel?.frame = CGRect(x: 68, y: detailTextLabel!.frame.origin.y , width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
           detailTextLabel?.font  = UIFont.systemFont(ofSize: 12)
           detailTextLabel?.textColor = .lightGray
           
       }
    // functions we are adding
    @objc func handleFollowTapped(){
        
        delegate?.handleFollowTapped(for: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
