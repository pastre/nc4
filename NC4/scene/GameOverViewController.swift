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

class GameOverViewController: UIViewController, GADInterstitialDelegate, GADRewardedAdDelegate {
    
    
    // MARK: - GADRewardedAdDelegate
    var completedReward: Bool! = false
    var canAdRevive: Bool!
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        
        self.completedReward = true
        
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
        print("Failed to present ad", error)
    }
    
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        
        guard self.completedReward else { return }
        self.dismiss(animated: false, completion: nil)
        self.dataSource?.onRevive()
        self.loadRewardedAd()
        
    }
    
    var isAdMissing: Bool?
    
    var interstitial: GADInterstitial?
    var rewarded: GADRewardedAd?
    
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
        
        self.loadRewardedAd()
        self.loadInterAd()
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
    
    // MARK: - Rewarded based ad methods
    
    func loadRewardedAd() {
        let id = "ca-app-pub-3760704996981292/5214330633"
        
        let testId = "ca-app-pub-3940256099942544/1712485313"
        self.rewarded = GADRewardedAd(adUnitID: id)
        
        #if DEBUG
            self.rewarded = GADRewardedAd(adUnitID: testId)
        #endif
        rewarded?.load(GADRequest()) { (error) in
            if let error = error {
                print("Vixi, deu ruim! Sem ad :(", error)
                self.isAdMissing = true
                return
            }
        }
    }
    
    func presentRewardedAd() {
        if let missing = self.isAdMissing, missing {
            self.devLabel.text = "No ad to show :("
            self.animateDevText()
        }
        
        guard let ad = self.rewarded, ad.isReady else { return }
        Analytics.logEvent("presentRewardedAd", parameters: nil)
        ad.present(fromRootViewController: self, delegate: self)
    }
    
    // MARK: - Interstitial ad methods
    
    func loadInterAd() {
        
        
        self.interstitial = GADInterstitial(adUnitID: "ca-app-pub-3760704996981292/8000561485")
        
        #if DEBUG
            self.interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        #endif
        self.interstitial?.delegate = self
        
        let request = GADRequest()
        interstitial?.load(request)
        
    }
    
    func presentInterAd() -> Bool {
//        #if DEBUG
//        return
//        #endif
        Analytics.logEvent("showAd", parameters: nil)
        guard let interstitial = self.interstitial else { return false }
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
            print("presenting ad")
            return true
        }
        
        return false
    }
    
    func onAdInterCompleted() {
        self.dismiss(animated: false) {
            self.dataSource?.onGameOverDismissed()
        }
        
    }
    
    
    // MARK: - GADInterstitialDelegate
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
      print("interstitialDidDismissScreen")
        
        Analytics.logEvent("completedAdPresentation", parameters: nil)
        self.loadInterAd()
        self.onAdInterCompleted()
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
        Crashlytics.crashlytics().record(error: error)
        
//        self.onAdInterCompleted()
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
