import Foundation

enum CharacterDialogue {
    static func casualLines(for opponent: OpponentCharacter) -> [CharacterDialogueLine] {
        let prefix = opponent.rawValue
        let topics = topicLines(for: opponent)
        return (0..<100).map { index in
            let topic = topics[index % topics.count]
            let extra = endPhrases(for: opponent)[index % endPhrases(for: opponent).count]
            let text = "\(topic)\(extra)"
            let expression = expressionCycle[index % expressionCycle.count]
            return CharacterDialogueLine(
                id: "\(prefix)_\(String(format: "%03d", index + 1))",
                text: text,
                expressionID: expression
            )
        }
    }

    static func moveLine(for opponent: OpponentCharacter, move: Move, isPlayerTurn: Bool) -> CharacterDialogueLine {
        let from = AICoach.squareName(move.from)
        let to = AICoach.squareName(move.to)
        let text: String
        switch opponent {
        case .kouhai:
            text = "\(from)から\(to)ですね。えっと、次は落ち着いて受けます。"
        case .senpai:
            text = "\(from)から\(to)。その手、少しだけ読み直したくなります。"
        case .janitor:
            text = "\(from)から\(to)か。廊下の角みたいに、逃げ道を見ておくんだ。"
        }
        return CharacterDialogueLine(id: "\(opponent.rawValue)_move", text: text, expressionID: isPlayerTurn ? 2 : 13)
    }

    static func resultLine(for opponent: OpponentCharacter, didPlayerWin: Bool) -> CharacterDialogueLine {
        let text: String
        switch (opponent, didPlayerWin) {
        case (.kouhai, true):
            text = "負けました。でも、もう一局だけお願いします。次は少し粘ります。"
        case (.kouhai, false):
            text = "勝てました。いまのは、たまたまじゃないと信じたいです。"
        case (.senpai, true):
            text = "いい勝ち方でした。最後の詰め、ちゃんと見えていましたね。"
        case (.senpai, false):
            text = "今回は私の勝ちです。序盤の一手が、最後まで効いていました。"
        case (.janitor, true):
            text = "やるじゃないか。盤は掃除しても、負けは消えないな。"
        case (.janitor, false):
            text = "勝負は終わりだ。さて、黒板消しも片づけてくるか。"
        }
        return CharacterDialogueLine(id: "\(opponent.rawValue)_result", text: text, expressionID: didPlayerWin ? 10 : 5)
    }

    private static let expressionCycle = [1, 2, 3, 5, 9, 12, 13, 15, 17, 18, 21, 23, 26, 31]

    private static func topicLines(for opponent: OpponentCharacter) -> [String] {
        switch opponent {
        case .kouhai:
            return [
                "放課後の教室って、時計の音だけ大きく聞こえますね。",
                "ポーンを一歩出すだけでも、ちょっと勇気がいります。",
                "先輩の指し方、静かなのに圧があります。",
                "ナイトって変な動きなのに、助けに来ると頼もしいです。",
                "今日は購買のパン、まだ残ってるでしょうか。",
                "ビショップの斜め線、見落とすと本当に痛いです。",
                "負けても棋譜を見直すと、少しだけ強くなれます。",
                "窓の外が暗くなる前に、一局終わるといいですね。",
                "王様って、偉いのに逃げるのが仕事なんですね。",
                "クイーンが動くと、教室の空気まで変わります。"
            ]
        case .senpai:
            return [
                "静かな局面ほど、次の一手で性格が出ます。",
                "チェスは強い手より、悪くならない手を探す時間が長いです。",
                "放課後の光は、盤面の白マスを少しだけ優しくします。",
                "急がなくて大丈夫。持ち時間は心にもあります。",
                "ナイトの跳ね方は、たまに会話みたいで面白いです。",
                "弱い駒を守る手は、地味でも綺麗です。",
                "終盤は、言葉より一マスの差が大きいですね。",
                "今日の紅茶、少し渋いです。局面に似ています。",
                "攻める時ほど、王の逃げ道を見ておきましょう。",
                "いい手は、指した後に盤面が少し静かになります。"
            ]
        case .janitor:
            return [
                "この教室、夕方になると駒音がよく響くんだ。",
                "チェス盤も廊下も、隅っこを放っておくと後で困る。",
                "ポーンを雑に扱う人は、雑巾もしぼりが甘い。",
                "王手は大声じゃなくていい。逃げ道を消せば伝わる。",
                "若い頃はな、昼休みに毎日一局だけ指してた。",
                "ナイトは掃除用具入れみたいなもんだ。変な所から出てくる。",
                "勝ち急ぐと、床のワックスみたいに足をすくわれるぞ。",
                "いいか、取れる駒より取られる駒を先に見ろ。",
                "放課後の勝負は、チャイムが鳴ってからが本番だ。",
                "盤面は嘘をつかない。人間より正直だな。"
            ]
        }
    }

    private static func endPhrases(for opponent: OpponentCharacter) -> [String] {
        switch opponent {
        case .kouhai:
            return ["", " たぶん。", " まだ自信ないですけど。", " えへへ。", " ちょっとだけ。", " 次、見えてきました。"]
        case .senpai:
            return ["", " ふふ。", " 焦らずいきましょう。", " 覚えておくと便利です。", " ここ、大事です。", " 少し間を置きましょう。"]
        case .janitor:
            return ["", " 覚えときな。", " まあ、茶でも飲め。", " 急ぐな急ぐな。", " 盤をよく見ろ。", " そういう日もある。"]
        }
    }
}

extension FACSExpression {
    static func byID(_ id: Int) -> FACSExpression? {
        all.first { $0.id == id }
    }
}

