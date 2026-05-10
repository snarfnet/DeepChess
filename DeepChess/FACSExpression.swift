import Foundation

enum OpponentCharacter: String, CaseIterable, Identifiable {
    case kouhai
    case senpai
    case janitor

    var id: String { rawValue }

    var name: String {
        switch self {
        case .kouhai: return "日向 あかり"
        case .senpai: return "成瀬 澪"
        case .janitor: return "用務員のおじさん"
        }
    }

    var role: String {
        switch self {
        case .kouhai: return "後輩"
        case .senpai: return "先輩"
        case .janitor: return "用務員"
        }
    }

    var strength: String {
        switch self {
        case .kouhai: return "弱い"
        case .senpai: return "強い"
        case .janitor: return "すごい強い"
        }
    }

    var depth: Int {
        switch self {
        case .kouhai: return 2
        case .senpai: return 4
        case .janitor: return 5
        }
    }

    var prefix: String {
        switch self {
        case .kouhai: return "KouhaiExpression"
        case .senpai: return "PosterExpression"
        case .janitor: return "JanitorExpression"
        }
    }

    var intro: String {
        switch self {
        case .kouhai: return "まだ勉強中。表情がすぐ顔に出る。"
        case .senpai: return "静かに読むチェス部の先輩。"
        case .janitor: return "掃除の合間に現れる謎の強者。"
        }
    }

    func assetName(for expression: FACSExpression) -> String {
        switch self {
        case .kouhai:
            return prefix + expression.kouhaiKey
        case .senpai:
            return prefix + expression.senpaiKey
        case .janitor:
            return prefix + expression.janitorKey
        }
    }
}

struct FACSExpression: Identifiable, Hashable {
    let id: Int
    let name: String
    let note: String
    let senpaiKey: String
    let kouhaiKey: String
    let janitorKey: String

    var code: String { "FACS \(id)/46" }

    static let all: [FACSExpression] = [
        item(1, "ふつう", "落ち着いて盤面を見る", "Calm"),
        item(2, "考え中", "次の手を読む", "Thinking"),
        item(3, "小さく笑う", "良い手が見えた", "SmallSmile"),
        item(4, "大きく笑う", "作戦が通った", "BigSmile", janitor: "BigLaugh"),
        item(5, "得意げ", "少しだけ自信あり", "Proud"),
        item(6, "AU46 ウィンク", "片目を閉じる", "AU46Wink"),
        item(7, "むっとする", "読みを外された", "Pout", janitor: "Grumpy"),
        item(8, "くやしい", "駒を取られた", "Frustrated"),
        item(9, "心配", "王手が近い", "Worried"),
        item(10, "泣きそう", "かなり苦しい", "AlmostCrying", janitor: "Teary"),
        item(11, "ほっとする", "危ない手を避けた", "Relieved"),
        item(12, "びっくり", "予想外の一手", "Surprised"),
        item(13, "真剣", "深く読む", "Serious"),
        item(14, "眠そう", "長考中", "Sleepy"),
        item(15, "照れる", "ほめられた気分", "Shy"),
        item(16, "すねる", "交換が気に入らない", "Sulking"),
        item(17, "負けず嫌い", "反撃を探す", "Competitive"),
        item(18, "ため息", "読み直し", "Sigh"),
        item(19, "じっと見る", "一点を読む", "Thinking"),
        item(20, "安心", "交換後に落ち着く", "Calm"),
        item(21, "にこにこ", "やさしく見守る", "BigSmile", janitor: "BigLaugh"),
        item(22, "小さく怒る", "手痛いミス", "Pout", janitor: "Grumpy"),
        item(23, "強気", "攻めに出る", "Competitive"),
        item(24, "弱気", "守りたい", "Worried"),
        item(25, "口を開く", "手を見つけた", "Surprised"),
        item(26, "集中", "終盤を数える", "Serious"),
        item(27, "大きく驚く", "大駒が動いた", "Surprised"),
        item(28, "口を閉じる", "静かに待つ", "Calm"),
        item(29, "左を見る", "別の筋を見る", "Thinking"),
        item(30, "右を見る", "別案を探す", "Thinking"),
        item(31, "上を見る", "ひらめき待ち", "Relieved"),
        item(32, "下を見る", "盤面に集中", "Thinking"),
        item(33, "目をそらす", "困った局面", "Worried"),
        item(34, "見つめる", "相手の狙いを見る", "Calm"),
        item(35, "眉を上げる", "意外な手", "Surprised"),
        item(36, "眉を寄せる", "不満そう", "Frustrated"),
        item(37, "怒る", "勝負どころ", "Sulking", janitor: "Grumpy"),
        item(38, "勝負の顔", "ここで攻める", "Proud"),
        item(39, "しょんぼり", "形勢が悪い", "AlmostCrying", janitor: "Teary"),
        item(40, "安全", "少し落ち着く", "Relieved"),
        item(41, "まばたき", "一瞬の間", "Calm"),
        item(42, "目を閉じる", "深呼吸", "Sleepy"),
        item(43, "長いまばたき", "長考の間", "Thinking"),
        item(44, "薄目", "疑って見る", "Frustrated"),
        item(45, "ゆっくり休む", "少し休む", "Relieved"),
        item(46, "AU46 ウィンク", "勝負の合図", "AU46Wink")
    ]

    @MainActor
    static func current(for game: ChessGame) -> FACSExpression {
        if game.result == .checkmate {
            return game.turn == game.playerColor ? all[9] : all[5]
        }
        if game.result == .stalemate { return all[10] }
        if game.isThinking { return all[1] }
        if game.isCheck {
            return game.turn == game.playerColor ? all[8] : all[36]
        }
        if let lastMove = game.lastMove, game.board[lastMove.to] != nil {
            return all[4]
        }
        return game.turn == game.playerColor ? all[0] : all[18]
    }

    private static func item(
        _ id: Int,
        _ name: String,
        _ note: String,
        _ key: String,
        senpai: String? = nil,
        kouhai: String? = nil,
        janitor: String? = nil
    ) -> FACSExpression {
        FACSExpression(
            id: id,
            name: name,
            note: note,
            senpaiKey: senpai ?? key,
            kouhaiKey: kouhai ?? key,
            janitorKey: janitor ?? key
        )
    }
}
