import Foundation

@MainActor
struct AICoach {
    static func insight(for game: ChessGame) -> String {
        if game.isThinking {
            return "相手が考え中です。中央、王の安全、次に取られそうな駒を見ています。"
        }

        switch game.result {
        case .checkmate:
            return game.turn == game.playerColor
                ? "チェックメイトです。王のまわりに守る駒を残せると、次はもっと粘れます。"
                : "チェックメイトです。逃げ道を消してから王手できました。"
        case .stalemate:
            return "ステイルメイトです。勝ちそうな時ほど、相手の合法手を一つ残す意識が大事です。"
        case .playing:
            break
        }

        if game.isCheck {
            return game.turn == game.playerColor
                ? "王手です。取る、防ぐ、逃げる。この順番で候補を見てみましょう。"
                : "相手の王にプレッシャーがかかっています。逃げ道を減らす手が良さそうです。"
        }

        if let move = game.lastMove {
            let from = squareName(move.from)
            let to = squareName(move.to)
            if game.turn == game.playerColor {
                return "直前の手は \(from) から \(to)。浮いている駒がないか、まず探してみましょう。"
            }
            return "\(from) から \(to)。返し方を見て、次の作戦を考えます。"
        }

        return "序盤は中央を取り、ナイトとビショップを外へ出すと指しやすいです。"
    }

    static func squareName(_ index: Int) -> String {
        let files = ["a", "b", "c", "d", "e", "f", "g", "h"]
        return "\(files[index % 8])\(index / 8 + 1)"
    }
}
