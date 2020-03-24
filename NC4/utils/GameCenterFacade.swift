//
//  GameCenterFacade.swift
//  NC4
//
//  Created by Bruno Pastre on 11/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import GameKit

let kAuthSuccess = Notification.Name("Player authenticated")

class GameCenterFacade: NSObject, GKLocalPlayerListener {
    
    private let player = GKLocalPlayer.local
    var authVc: UIViewController?
    
    static let instance = GameCenterFacade()
    
    enum Leaderboard: String {
        case score = "scores"
    }
    
    private override  init() {
        super.init()
    }
    
    func auth() {
        
        self.player.authenticateHandler = { vc, error in
            print("Chamou")
            
            if let error = error {
                print("Error on auth handler!", error)
                return
            }
        
            
            self.authVc = vc
            
            if self.authVc == nil {
                
                NotificationCenter.default.post(name: kAuthSuccess, object: nil)
            }
        }
    }
    
    func getGameCenterVc() -> GKGameCenterViewController? {
        guard self.isAuthenticated() else { return nil }
        
        let gkVC = GKGameCenterViewController()
        
        gkVC.viewState = .leaderboards
        gkVC.leaderboardIdentifier = GameCenterFacade.Leaderboard.score.rawValue
        
        return gkVC
    }
    
    func isAuthenticated() -> Bool { self.authVc == nil && self.player.isAuthenticated }
    
    
    func onScore(_ value: Int) {
        guard self.isAuthenticated() else { return }
        
        let score = GKScore(leaderboardIdentifier: Leaderboard.score.rawValue)
        score.value = Int64(value)
        
        GKScore.report([score]) { (error) in
            if let error = error {
                print("Erro ao reportar o record!", error)
                return
            }
            print("[GameCenter] Reported new walking record")
        }
    }
    
    func loadFromGamecenter() {
        guard self.isAuthenticated() else { return }
        
        let leaderboard = GKLeaderboard(players: [self.player])
        
        leaderboard.timeScope = .allTime
        leaderboard.identifier = Leaderboard.score.rawValue
        
        leaderboard.loadScores { (scores, error) in
            guard let scores = scores else {
                if let error = error {
                    print("Teve erro!", error)
                }
                print("No scores")
                return
                
            }
            if let score = scores.first {
                let value = Int(score.value)
                
                if !StorageFacade.instance.updateScoreIfNeeded(to: value) {
                    self.onScore(StorageFacade.instance.getHighScore())
                }
            }
            
        }
    }
}
