import AVFoundation
import Foundation

struct CharacterDialogueLine: Identifiable, Equatable {
    let id: String
    let text: String
    let expressionID: Int

    var fileName: String { id }
}

@MainActor
final class CharacterVoicePlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published private(set) var currentLine: CharacterDialogueLine?
    @Published private(set) var currentExpression: FACSExpression?
    @Published private(set) var isSpeaking = false

    private var player: AVAudioPlayer?
    private var timer: Timer?
    private var opponent: OpponentCharacter = .senpai

    func start(for opponent: OpponentCharacter) {
        self.opponent = opponent
        scheduleNextLine(after: 1.2)
    }

    func playMoveLine(for opponent: OpponentCharacter, move: Move, isPlayerTurn: Bool) {
        self.opponent = opponent
        let line = CharacterDialogue.moveLine(for: opponent, move: move, isPlayerTurn: isPlayerTurn)
        play(line, allowTextOnly: true)
        scheduleNextLine(after: 10)
    }

    func playResultLine(for opponent: OpponentCharacter, didPlayerWin: Bool) {
        self.opponent = opponent
        let line = CharacterDialogue.resultLine(for: opponent, didPlayerWin: didPlayerWin)
        play(line, allowTextOnly: true)
        timer?.invalidate()
    }

    private func scheduleNextLine(after delay: TimeInterval? = nil) {
        timer?.invalidate()
        let interval = delay ?? TimeInterval.random(in: 14...26)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.playRandomLine()
            }
        }
    }

    private func playRandomLine() {
        let lines = CharacterDialogue.casualLines(for: opponent)
        let playable = lines.filter { hasAudio(for: $0) }
        guard let line = (playable.isEmpty ? lines : playable).randomElement() else { return }
        play(line, allowTextOnly: playable.isEmpty)
        scheduleNextLine()
    }

    private func play(_ line: CharacterDialogueLine, allowTextOnly: Bool = false) {
        currentLine = line
        currentExpression = FACSExpression.byID(line.expressionID)
        isSpeaking = true

        player?.stop()
        player = nil

        if let url = Bundle.main.url(
            forResource: line.fileName,
            withExtension: "mp3",
            subdirectory: "Voices"
        ) {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.delegate = self
                player?.prepareToPlay()
                player?.play()
            } catch {
                finishSpeakingSoon()
            }
        } else {
            finishSpeakingSoon()
        }
    }

    private func hasAudio(for line: CharacterDialogueLine) -> Bool {
        Bundle.main.url(
            forResource: line.fileName,
            withExtension: "mp3",
            subdirectory: "Voices"
        ) != nil
    }

    private func finishSpeakingSoon() {
        Task {
            try? await Task.sleep(for: .seconds(3))
            await MainActor.run {
                self.isSpeaking = false
                self.currentExpression = nil
            }
        }
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.isSpeaking = false
            self.currentExpression = nil
        }
    }
}
