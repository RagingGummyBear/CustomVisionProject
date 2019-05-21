//
//  LikedCoffeeViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 5/16/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit
import Spring
import PopupDialog

class LikedCoffeeViewController: UIViewController, Storyboarded {

    // MARK: - Custom references and variables
    weak var coordinator: LikedCoffeeCoordinator? // Don't remove
    public let navigationBarHidden = false
    
    var allLikedCoffeeModels: [LikedCoffeeModel] = []
    var selectedCoffeeModel: LikedCoffeeModel?
    
    var dataSource: CollectionViewDataSource<LikedCoffeeModel>!
    public var selectedCell:ImageDisplayCollectionViewCell?

    // MARK: - IBOutlets references
    @IBOutlet weak var starPhotoButton: PopAnimatedButton!
    @IBOutlet weak var removePhotoButton: PopAnimatedButton!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var fullDescriptionLabel: UILabel!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    // MARK: - IBOutlets actions
    @IBAction func starPhotoButtonAction(_ sender: Any) {
        print("Unbelivable it became true")
        self.coordinator?.starButtonPressed()
    }
    
    @IBAction func removePhotoButtonAction(_ sender: Any) {
        if let selectedModel = self.selectedCoffeeModel {
//            self.coordinator?.requestRemoveSelectedCoffee(coffeeModel: selectedModel)
            self.coordinator?.removeSelectedButtonPressed()
        }
    }
    
    
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
            self.setSelectedCell(index: IndexPath(row: 0, section: 0))
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
                    self.shortDescriptionLabel.text = self.coordinator?.requestShortDescription(coffeeModel: self.selectedCoffeeModel!)
                    self.fullDescriptionLabel.text = self.coordinator?.requestFullDescription(coffeeModel: self.selectedCoffeeModel!)
                    self.mainImageView.image = image
                    self.scrollView.setContentOffset(.zero, animated: true)
                }
            }).catch({ (error: Error) in
                print(error)
            })
        }
    }
    
    func setupCollectionView(){
        self.dataSource = CollectionViewDataSource.make(for: self.allLikedCoffeeModels, photoFetch: self.coordinator!, reuseIdentifier: "likedPhotoImageCollectionView")
        self.collectionView.dataSource = self.dataSource
        
        self.collectionView.delegate = self
        self.collectionView.reloadData()
    }

    // MARK: - Other functions
    // Remember keep the logic and processing in the coordinator
    func newCoffeeModelsData(models:[LikedCoffeeModel]){
        self.allLikedCoffeeModels = models
        if !models.contains(where: { (elem: LikedCoffeeModel) -> Bool in
            return elem.saveDirectoryName == self.selectedCoffeeModel?.saveDirectoryName
        }) {
            if models.count > 0 {
                self.selectedCoffeeModel = models[0]
                self.setSelectedCell(index: IndexPath(row: 0, section: 0))
                self.refreshMainImage()
            }
        }
        self.dataSource.models = models
        
        self.collectionView.reloadData()
        self.collectionView.invalidateIntrinsicContentSize()
        self.collectionView.setCollectionViewLayout(HorizontalCollectionLayout(), animated: false)
    }
    
    func requestRemoveSelectedPhoto(){
        
    }
    
    func presentPopup(popupDialog: PopupDialog){
        self.present(popupDialog, animated: true)
    }
    
}

extension LikedCoffeeViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedCoffeeModel = self.allLikedCoffeeModels[indexPath.row]
        self.collectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
        DispatchQueue.global().async {
            self.refreshMainImage()
            self.setSelectedCell(index: indexPath)
        }
    }
    
    func setSelectedCell(index:IndexPath){
        DispatchQueue.main.async {
            let prevIndexPath = IndexPath(row: self.dataSource.getSelectedModel(), section: 0)
            self.dataSource.setSelectedModel(index: index.row)
            if prevIndexPath.row > -1 && index.row != prevIndexPath.row {
                self.collectionView.reloadItems(at: [index, prevIndexPath])
            } else {
                self.collectionView.reloadItems(at: [index])
            }
        }
    }
}

