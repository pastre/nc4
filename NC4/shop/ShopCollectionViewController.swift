//
//  ShopCollectionViewController.swift
//  NC4
//
//  Created by Bruno Pastre on 31/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import UIKit

private let reuseIdentifier = "shopCell"

class ShopViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let manager = ShopItemManager.instance
    
    @IBOutlet weak var playerHeadCountLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var buyButton: UIButton!
    
    @IBOutlet weak var currentItemImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var backLabel: UILabel!
    
    var currentSelectedItem: ShopItem!
    
    var playerHeadCount: Int!
    var delegate: GameViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.currentSelectedItem = self.manager.getDefaultItem()
        
        self.updateSpotlightItem()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onTap))

        self.backLabel.addGestureRecognizer(tap)
        self.backLabel.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.buyButton.layer.cornerRadius = self.buyButton.frame.height / 2
        self.buyButton.addTarget(self, action: #selector(self.onBuy), for: .touchDown)
        buyButton.setTitle("Equipped", for: .disabled)
        self.updateBuyButton()
    }
    
    // UI Methods
    
    func updateBuyButton() {
        
        let green = #colorLiteral(red: 0, green: 0.7262999415, blue: 0.3584215641, alpha: 1)
        
        self.buyButton.isEnabled =  self.currentSelectedItem != self.manager.equippedItem
        self.buyButton.backgroundColor = self.buyButton.isEnabled ? green : UIColor.gray
        if self.currentSelectedItem.isUnlocked {
            self.buyButton.setTitle("Equip", for: .normal)
        } else {
            self.buyButton.setTitle("Buy", for: .normal)
        }
    }
    
    func updateUI() {
        
        self.updateSpotlightItem()
        self.updateBuyButton()
        
        self.collectionView.reloadData()
    }
    
    
    func updateSpotlightItem() {
        self.currentItemImage.image = self.currentSelectedItem.getDisplayImage()
        self.playerHeadCount = StorageFacade.instance.getHeadCount()
        
        self.priceLabel.text = String(self.currentSelectedItem.price)
        self.playerHeadCountLabel.text = String(format: "%03d", self.playerHeadCount)
    }

    // MARK: UICollectionViewDataSource & Delegate

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.manager.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ShopCollectionViewCell
    
        let item = self.manager.item(at: indexPath)
        
        cell.backView.layer.cornerRadius = 16
        cell.imageView.image = item.getDisplayImage()
    
        cell.border.isHidden = item != self.currentSelectedItem
        
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let mult: CGFloat = 0.3
        return CGSize(width: collectionView.frame.size.width * mult, height: collectionView.frame.size.width * mult)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.currentSelectedItem = self.manager.item(at: indexPath)
        
        self.updateUI()
    }
    
    // MARK: - Callbacks
    
    @objc func onBuy() {
        if self.currentSelectedItem.isUnlocked {
            self.equipItem()
        } else {
            self.buyAndEquipItem()
        }
    }
    
    @objc func onTap() {
        self.delegate?.updatePlayerSkin()
        self.dismiss(animated: true, completion: nil)
    }
    
    func buyAndEquipItem() {
        guard self.manager.buy(item: currentSelectedItem) else {
            
            self.playerHeadCountLabel.transform = self.playerHeadCountLabel.transform.translatedBy(x: 10, y: 0)
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.playerHeadCountLabel.transform = .identity
                
                       }, completion: nil)
            
        UINotificationFeedbackGenerator().notificationOccurred(.error)
            
            return
        }
        
        self.equipItem()
    }
    
    func equipItem() {
        self.manager.equip(item: self.currentSelectedItem)
        self.updateUI()
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
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */


}
