//
//  GameOverViewController.swift
//  NC4
//
//  Created by Bruno Pastre on 27/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase

protocol GameOverDataSource {
    
    func getScore() -> Int
    func getHeadCount() -> Int
    
    func onGameOverDismissed()
    func onRevive()
}

class GameOverViewController: UIViewController, AdPresenter {


    var completedReward: Bool! = false
    var canAdRevive: Bool!
    var reviveCount: Int!
    var dataSource: GameOverDataSource?
    
    @IBOutlet weak var headsView: UIView!
    @IBOutlet weak var scoreView: UIView!
    
    @IBOutlet weak var buyLifesView: UIView!
    @IBOutlet weak var viewAdView: UIView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var headsLabel: UILabel!
    @IBOutlet weak var devLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onUserDidBuyLifes), name: kON_PLAYER_BOUGHT_LIFES, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Will appear", self.dataSource)
        self.reviveCount = StorageFacade.instance.getReviveCount()
        
        guard let src = self.dataSource else { return }
        
        if !self.canReallyAdRevive() {
            self.hideReviveWithAds()
        }
        
        self.scoreLabel.text = String(src.getScore())
        self.headsLabel.text = String(src.getHeadCount())
        
        self.setupGestures()
        self.setupRoundedViews()
        
    }
    
    func hideReviveWithAds() {
        let overlay = UIView(frame: self.viewAdView.frame)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        self.viewAdView.addSubview(overlay)
        
        self.viewAdView.bringSubviewToFront(overlay)
        
        overlay.centerXAnchor.constraint(equalTo: self.viewAdView.centerXAnchor).isActive = true
        overlay.centerYAnchor.constraint(equalTo: self.viewAdView.centerYAnchor).isActive = true
        overlay.widthAnchor.constraint(equalTo: self.viewAdView.widthAnchor).isActive = true
        overlay.heightAnchor.constraint(equalTo: self.viewAdView.heightAnchor).isActive = true
    }
    
    func setupGestures() {
        
        let buyTap = UITapGestureRecognizer(target: self, action: #selector(self.onBuy))
        let adTap = UITapGestureRecognizer(target: self, action: #selector(self.onViewAd))
        
        
        
       
        self.viewAdView.addGestureRecognizer(adTap)
        self.buyLifesView.addGestureRecognizer(buyTap)
        self.nextButton.addTarget(self, action: #selector(self.onNext), for: .touchDown)
    }
    
    func setupRoundedViews() {
        self.configureBorders(on: self.headsView, isCircular: false)
        
        self.configureBorders(on: self.scoreView, isCircular: false)
        
        self.configureBorders(on: self.buyLifesView, isCircular: true)
        
        self.configureBorders(on: self.viewAdView, isCircular: true)
    }
    
    func configureBorders(on view: UIView, isCircular: Bool = true) {
        
        var radius: CGFloat = 10
        if isCircular {
            radius = view.frame.width / 2
        }
        
        view.layer.cornerRadius = radius
        view.clipsToBounds = true
        
        view.layoutIfNeeded()
        
    }
    
    func revivePlayer() {
        
        self.dismiss(animated: false, completion: nil)
        self.dataSource?.onRevive()
    }
    
    // MARK: - AdPresenter
    func onUserDidEarn(reward: GADAdReward) {
        self.completedReward = true
    }
    
    func onRewardedAdDismiss() {
        
        guard self.completedReward else { return }
        self.revivePlayer()
    }
    
    func onInterAdDismiss() {
        self.onAdInterCompleted()
    }
    
    // MARK: - Ad methods
    

    
    func presentRewardedAd() {
        AdManager.instance.presentReward(on: self)
        
    }
    
    func presentInterAd() -> Bool {
        
        AdManager.instance.presentInterAd(on: self)
        return AdManager.instance.interAd.isReady && StorageFacade.instance.canShowAds()
    }
    
    func onAdInterCompleted() {
        self.dismiss(animated: false) {
            self.dataSource?.onGameOverDismissed()
        }
        
    }
    
    //MARK: - Utils
    
    func animateDevText() {
        
        self.devLabel.alpha = 1
        UIView.animate(withDuration: 2, delay: 1, options: [], animations: {
            self.devLabel.alpha = 0
        }, completion: nil)
    }
    
    func canReallyAdRevive() -> Bool {
        self.canAdRevive && AdManager.instance.canDisplayRewarded()
    }
    // MARK: - Callbacks
    
    @objc func onViewAd() {
        Analytics.logEvent("gameOverReviveAd", parameters: nil)
        guard self.canReallyAdRevive() else {
        
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            let view = self.viewAdView!
            view.transform = CGAffineTransform(translationX: 20, y: 0)
            
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                view.transform = .identity
            }, completion: nil)
            return
        }
        self.presentRewardedAd()
    }
    
    @objc func onBuy() {
        Analytics.logEvent("gameOverBuyLifes", parameters: nil)
    
        if reviveCount == 0 {
            StoreManager.instance.buy(product: .lifePack)
        } else {
            StorageFacade.instance.onReviveUsed()
            self.revivePlayer()
        }
    }
    
    @objc func onNext() {
        if !self.presentInterAd() {
            self.onAdInterCompleted()
        }
    }
    
    @objc func onUserDidBuyLifes() {
        StorageFacade.instance.onReviveUsed()
        self.revivePlayer()
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
