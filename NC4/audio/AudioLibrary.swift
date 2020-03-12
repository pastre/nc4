import AVFoundation

enum SongLibrary : String, CaseIterable {
    case theme = "theme"
}

enum IntroWithLoopLibrary: CaseIterable {
    case first
    
    var info : (intro: String, loop: String) {
        switch self {
        case .first:
            return ("theme", "theme")
        }
    }
}

enum SoundEffectLibrary : String, CaseIterable {
    case gameOver = "gameOver"
    case infect = "infect"
    case pick = "Deixando Vírus"
}
