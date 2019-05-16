//
//  LikedCoffeeViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 5/16/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit

class LikedCoffeeViewController: UIViewController, Storyboarded {

    // MARK: - Custom references and variables
    weak var coordinator: LikedCoffeeCoordinator? // Don't remove
    public let navigationBarHidden = false
    
    var allLikedCoffeeModels: [LikedCoffeeModel] = []
    var selectedCoffeeModel: LikedCoffeeModel?
    
    var dataSource: CollectionViewDataSource<LikedCoffeeModel>!

    // MARK: - IBOutlets references
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - IBOutlets actions

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.initalUISetup()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.async {
            self.finalUISetup()
        }
    }

    // MARK: - UI Functions
    func initalUISetup(){
        self.registerCollectionViewCells()
        
        let bundlePath = Bundle.main.path(forResource: "blackSteamy", ofType: "jpg")
        self.backgroundImageView.image = UIImage(contentsOfFile: bundlePath!)
        
        self.coordinator?.requestAllLikedCoffeeModels().done({ [unowned self] (models: [LikedCoffeeModel]) in
            self.allLikedCoffeeModels = models
            self.selectedCoffeeModel = models.first
            self.refreshMainImage()
            self.setupCollectionView()
        }).catch({ (error: Error) in
            print(error)
        })
    }

    func finalUISetup(){
        
    }
    
    func registerCollectionViewCells(){
        self.collectionView.register(UINib(nibName: "ImageDisplayCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "likedPhotoImageCollectionView")
    }
    
    func refreshMainImage(){
        if let model = self.selectedCoffeeModel {
            self.coordinator?.fetchHighQualityPhoto(fromModel: model).done({ (image: UIImage) in
                DispatchQueue.main.async {
                    self.mainImageView.image = image
                }
            }).catch({ (error: Error) in
                print(error)
            })
        }
    }
    
    func setupCollectionView(){
        self.dataSource = CollectionViewDataSource.make(for: self.allLikedCoffeeModels, photoFetch: self.coordinator!, reuseIdentifier: "likedPhotoImageCollectionView")
        self.collectionView.dataSource = self.dataSource
        
        self.itemsPerRow = 4.0
        self.collectionView.delegate = self
        self.collectionView.reloadData()
    }

    // MARK: - Other functions
    // Remember keep the logic and processing in the coordinator
    private var itemsPerRow: CGFloat = 4
    private let sectionInsetsMiddle = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 0)
    private let sectionInsetsFirst = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
    private let sectionInsetsLast = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
}

extension LikedCoffeeViewController : UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(self.itemsPerRow)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 10 * (self.itemsPerRow + 1)) / self.itemsPerRow
        return CGSize(width: width, height: collectionView.frame.height)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        print("here \(section)")
//        if section == 0 {
//            return sectionInsetsFirst
//        } else if section == self.allLikedCoffeeModels.count - 2 {
//            return sectionInsetsLast
//        }
//        print("sectionNum: \(section) and max : \(self.allLikedCoffeeModels.count)")
//        return sectionInsetsMiddle
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        print("Hallo")
        return 8
    }
    
}
