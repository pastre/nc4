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
}

class GameOverViewController: UIViewController, GADInterstitialDelegate {
    
    
    var interstitial: GADInterstitial?
    var dataSource: GameOverDataSource?
    
    @IBOutlet weak var headsView: UIView!
    @IBOutlet weak var scoreView: UIView!
    
    @IBOutlet weak var buyLifesView: UIView!
    @IBOutlet weak var viewAdView: UIView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadAd()
        self.setupGestures()
        self.setupRoundedViews()
        // Do any additional setup after loading the view.
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
    
    
    // MARK: - GADInterstitialDelegate
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
      print("interstitialDidDismissScreen")
        
        Analytics.logEvent("completedAdPresentation", parameters: nil)
        self.loadAd()
        self.onAdCompleted()
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
        Crashlytics.crashlytics().record(error: error)
        
        self.onAdCompleted()
    }
    
    
    // MARK: - Ad methods
    
    func loadAd() {
        
        // TEST AD
                self.interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        
        // REAL AD
//        self.interstitial = GADInterstitial(adUnitID: "ca-app-pub-3760704996981292/8000561485")
        
        self.interstitial?.delegate = self
        
        let request = GADRequest()
        interstitial?.load(request)
        
    }
    
    func presentAd() {
//        #if DEBUG
//        return
//        #endif
        Analytics.logEvent("showAd", parameters: nil)
        guard let interstitial = self.interstitial else { return }
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
            print("presenting ad")
        } else {
            print("Tried to present fucking ad, but it didnt load")
        }
    }
    
    func onAdCompleted() {
        self.dismiss(animated: false) {
            self.dataSource?.onGameOverDismissed()
        }
        
    }
    // MARK: - Callbacks
    
    @objc func onViewAd() {
        
    }
    
    @objc func onBuy() {
        
    }
    
    @objc func onNext() {
        self.presentAd()
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
