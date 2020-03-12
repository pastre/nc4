import AVFoundation

class SoundEffect {
    
    private var players = [AVAudioPlayer]()
    private var url: URL
    
    init(fileName: String, soundType: String? = "wav") {
        let path = Bundle.main.path(forResource: fileName, ofType : soundType)!
        url = URL(fileURLWithPath: path)

        load()
    }
    
    private func load() {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players.append(player)
        } catch {
            fatalError("Fatal Error - Sound Effects Player")
        }
    }
    
    func play() {
        for player in players {
            if player.isPlaying == false {
                player.play()
                return
            }
        }
        
        load()
        players.last?.play()
    }
}
