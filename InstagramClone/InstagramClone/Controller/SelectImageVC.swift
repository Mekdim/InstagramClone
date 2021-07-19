//
//  SelectImageVC.swift
//  InstagramClone
//
//  Created by Mekua on 7/7/21.
//  Copyright © 2021 cs61. All rights reserved.
//

import UIKit
import Photos
private let reuseIdentifier = "SelectPhotoCell"
private let headerIdentifier = "SelectPhotoHeader"
class SelectImageVC : UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var images = [UIImage]()
    var assets = [PHAsset]()
    var selectedImage : UIImage?
    var header : SelectPhotoHeader?
    // Mark : properties
    override func viewDidLoad() {
        // register cell classes
        collectionView?.register(SelectPhotoCell.self,forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.register(SelectPhotoHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        collectionView?.backgroundColor = .white
        configureNavigationButtons()
        fetchPhotos()
        
    }
    // Mark : UICollectionViewFlowLayOut
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3)/4
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    // Mark : UICOllectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SelectPhotoCell
        cell.photoImageView.image = images[indexPath.row]
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! SelectPhotoHeader
        self.header = header
        
        if let selectedImage = self.selectedImage{
            // image is blurry here - if we do this
            //header.photoImageView.image = selectedImage
            if let index = self.images.index(of: selectedImage){
                // asset associated with selected image
                let  selectedAsset = self.assets[index]
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)
                // why image clearer here ?
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil) { (image, info) in
                    if let image = image{
                        header.photoImageView.image = image
                    }
                }
            }
        }
        return header
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = images[indexPath.row]
        self.collectionView?.reloadData()
        // scroll/go to top after selected image from the bottom cells
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    @objc func handleCancel(){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func handleNext(){
        print("handle next tapped")
        let uploadPostVc = UploadPostVC()
        // why using header here and not just image (The images gets blurry otherwise?)
        uploadPostVc.selectedImage = header?.photoImageView.image
        navigationController?.pushViewController(uploadPostVc, animated: true)
        
    }
    func getAssetFetchOPtions()->PHFetchOptions{
        let options = PHFetchOptions()
        options.fetchLimit  = 30
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortDescriptor]
        return options
    }
    func fetchPhotos(){
      
        let allPhotos = PHAsset.fetchAssets(with: .image, options: getAssetFetchOPtions())
        // fetch images on background thread
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects { (asset, count, stop) in
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                // request image representation for specified asset
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
                    if let image = image {
                        //append image to data source
                        self.images.append(image)
                        self.assets.append(asset)
                        if self.selectedImage == nil{
                            self.selectedImage = image
                        }
                        // reload collection view once photo count complete
                        if count == allPhotos.count - 1{
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    func configureNavigationButtons(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    
}
