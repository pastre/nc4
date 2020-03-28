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
    // MARK: - AdPresenter
    func onUserDidEarn(reward: GADAdReward) {
        self.completedReward = true
    }
    
    func onRewardedAdDismiss() {
        
        guard self.completedReward else { return }
        self.dismiss(animated: false, completion: nil)
        self.dataSource?.onRevive()
    }
    
    func onInterAdDismiss() {
        self.onAdInterCompleted()
    }

    var completedReward: Bool! = false
    var canAdRevive: Bool!
    
    
    
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
        
        
        self.setupGestures()
        self.setupRoundedViews()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let src = self.dataSource else { return }
        
        self.scoreLabel.text = String(src.getScore())
        self.headsLabel.text = String(src.getHeadCount())
    }
    
    
    
    
    func setupGestures() {
        let buyTap = UITapGestureRecognizer(target: self, action: #selector(self.onBuy))
        let adTap = UITapGestureRecognizer(target: self, action: #selector(self.onViewAd))
        
        self.buyLifesView.addGestureRecognizer(buyTap)
        self.viewAdView.addGestureRecognizer(adTap)
        
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
        
    }
    
    // MARK: - Ad methods
    

    
    func presentRewardedAd() {
        AdManager.instance.presentReward(on: self)
        
    }
    
    func presentInterAd() -> Bool {
        
        AdManager.instance.presentInterAd(on: self)
        return AdManager.instance.interAd.isReady
    }
    
    func onAdInterCompleted() {
        self.dismiss(animated: false) {
            self.dataSource?.onGameOverDismissed()
        }
        
    }
    
    
    func animateDevText() {
        
        self.devLabel.alpha = 1
        UIView.animate(withDuration: 2, delay: 1, options: [], animations: {
            self.devLabel.alpha = 0
        }, completion: nil)
    }
    
    // MARK: - Callbacks
    
    @objc func onViewAd() {
        Analytics.logEvent("gameOverReviveAd", parameters: nil)
        guard self.canAdRevive else {
            self.devLabel.text = "Vc ja reviveu, brow, joga mais uma ai"
            self.animateDevText()
            return
        }
        self.presentRewardedAd()
    }
    
    @objc func onBuy() {
        Analytics.logEvent("gameOverBuyLifes", parameters: nil)
        
        self.devLabel.text = ""
        self.animateDevText()
    }
    
    @objc func onNext() {
        if !self.presentInterAd() {
            self.onAdInterCompleted()
        }
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
