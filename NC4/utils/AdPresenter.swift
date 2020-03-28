//
//  AdPresenter.swift
//  NC4
//
//  Created by Bruno Pastre on 28/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import GoogleMobileAds

protocol AdPresenter: UIViewController {
    func onUserDidEarn(reward: GADAdReward)
    func onRewardedAdDismiss()
    func onInterAdDismiss()
}


