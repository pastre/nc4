//
//  AdManager.swift
//  NC4
//
//  Created by Bruno Pastre on 28/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import GoogleMobileAds
import Firebase

class AdManager: NSObject {
    
    
    var interAd: GADInterstitial!
    var rewardAd: GADRewardedAd!
    var currentPresenter: AdPresenter?
    
    static let instance = AdManager()
    
    override private init() {
        super.init()
        
    }
    
    func start() {
        
        self.loadReward()
        self.loadInterAd()
    }
    
    func canDisplayRewarded() -> Bool { self.rewardAd.isReady }
    func canDisplayInter() -> Bool { self.interAd.isReady }
    
    
}

// Reward ads
extension AdManager: GADRewardedAdDelegate {
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
        self.loadReward()
    }
    
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        self.loadReward()
        self.currentPresenter?.onRewardedAdDismiss()
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        self.currentPresenter?.onUserDidEarn(reward: reward)
        print("O player ganhou", reward.amount, reward.type)
    }
    
    func loadReward() {
        let id = "ca-app-pub-3760704996981292/5214330633"
        
        let testId = "ca-app-pub-3940256099942544/1712485313"
        let newAd = GADRewardedAd(adUnitID: testId)
        
        newAd.load(GADRequest()) { (error) in
            if let error = error {
                if !self.rewardAd.isReady {
                    self.loadReward()
                }
                return
            }
        }
        
        self.rewardAd = newAd
        
    }
    
    func presentReward(on rootViewController: AdPresenter) {
        guard self.rewardAd.isReady else { return }
        
        Analytics.logEvent("presentRewardedAd", parameters: nil)
        self.currentPresenter = rootViewController
        self.rewardAd.present(fromRootViewController: rootViewController, delegate: self)
    }
}



// Interstitial ads
extension AdManager: GADInterstitialDelegate {
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        self.loadInterAd()
    }
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.loadInterAd()
        self.currentPresenter?.onInterAdDismiss()
    }
    
    func loadInterAd() {
        var id = "ca-app-pub-3760704996981292/8000561485"
        
        #if DEBUG
           id = "ca-app-pub-3940256099942544/4411468910"
        #endif

        let newAd = GADInterstitial(adUnitID: id)
        
        newAd.delegate = self
        newAd.load(GADRequest())
        
        self.interAd = newAd
    }
    
    func presentInterAd(on rootViewController: AdPresenter) {
        guard self.interAd.isReady else { return }
        
        self.currentPresenter = rootViewController
        self.interAd.present(fromRootViewController: rootViewController)
    }
}

