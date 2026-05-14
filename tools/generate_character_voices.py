import argparse
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "DeepChess" / "Resources" / "Voices"
MANIFEST = ROOT / "tools" / "voice_lines.json"

CHARACTERS = {
    "kouhai": {
        "voice": "sage",
        "instructions": (
            "Act as 日向あかり, a shy first-year after-school chess club member. "
            "Use a young, soft Japanese voice. Speak quietly, a little nervous, with small smiles and natural pauses. "
            "Do not sound like a narrator. Keep it conversational, as if sitting across the chessboard."
        ),
        "topics": [
            "放課後の教室って、時計の音だけ大きく聞こえますね。",
            "ポーンを一歩出すだけでも、ちょっと勇気がいります。",
            "先輩の指し方、静かなのに圧があります。",
            "ナイトって変な動きなのに、助けに来ると頼もしいです。",
            "今日は購買のパン、まだ残ってるでしょうか。",
            "ビショップの斜め線、見落とすと本当に痛いです。",
            "負けても棋譜を見直すと、少しだけ強くなれます。",
            "窓の外が暗くなる前に、一局終わるといいですね。",
            "王様って、偉いのに逃げるのが仕事なんですね。",
            "クイーンが動くと、教室の空気まで変わります。",
        ],
        "tails": ["", " たぶん。", " まだ自信ないですけど。", " えへへ。", " ちょっとだけ。", " 次、見えてきました。"],
        "style": "小声で、少し照れながら、間を多めに。"
    },
    "senpai": {
        "voice": "coral",
        "instructions": (
            "Act as 成瀬澪, a calm senior in an after-school chess club. "
            "Use a composed, intelligent Japanese voice. Speak slowly, gently, with a faint smile and quiet confidence. "
            "Do not overact. She should feel like a real club senior talking during a game."
        ),
        "topics": [
            "静かな局面ほど、次の一手で性格が出ます。",
            "チェスは強い手より、悪くならない手を探す時間が長いです。",
            "放課後の光は、盤面の白マスを少しだけ優しくします。",
            "急がなくて大丈夫。持ち時間は心にもあります。",
            "ナイトの跳ね方は、たまに会話みたいで面白いです。",
            "弱い駒を守る手は、地味でも綺麗です。",
            "終盤は、言葉より一マスの差が大きいですね。",
            "今日の紅茶、少し渋いです。局面に似ています。",
            "攻める時ほど、王の逃げ道を見ておきましょう。",
            "いい手は、指した後に盤面が少し静かになります。",
        ],
        "tails": ["", " ふふ。", " 焦らずいきましょう。", " 覚えておくと便利です。", " ここ、大事です。", " 少し間を置きましょう。"],
        "style": "落ち着いた先輩らしく、静かに、少し笑いながら。"
    },
    "janitor": {
        "voice": "ash",
        "instructions": (
            "Act as the mysterious school janitor who is unexpectedly strong at chess. "
            "Use a low, warm Japanese voice. Speak casually, slightly rough around the edges, but kind. "
            "Add natural pauses like an older person giving advice while cleaning the classroom."
        ),
        "topics": [
            "この教室、夕方になると駒音がよく響くんだ。",
            "チェス盤も廊下も、隅っこを放っておくと後で困る。",
            "ポーンを雑に扱う人は、雑巾もしぼりが甘い。",
            "王手は大声じゃなくていい。逃げ道を消せば伝わる。",
            "若い頃はな、昼休みに毎日一局だけ指してた。",
            "ナイトは掃除用具入れみたいなもんだ。変な所から出てくる。",
            "勝ち急ぐと、床のワックスみたいに足をすくわれるぞ。",
            "いいか、取れる駒より取られる駒を先に見ろ。",
            "放課後の勝負は、チャイムが鳴ってからが本番だ。",
            "盤面は嘘をつかない。人間より正直だな。",
        ],
        "tails": ["", " 覚えときな。", " まあ、茶でも飲め。", " 急ぐな急ぐな。", " 盤をよく見ろ。", " そういう日もある。"],
        "style": "低めの声で、少しぶっきらぼうに、でも優しく。"
    },
}


def build_lines():
    lines = []
    for character, spec in CHARACTERS.items():
        for i in range(100):
            text = spec["topics"][i % len(spec["topics"])] + spec["tails"][i % len(spec["tails"])]
            lines.append({
                "id": f"{character}_{i + 1:03d}",
                "character": character,
                "voice": spec["voice"],
                "instructions": spec["instructions"],
                "text": f'{spec["style"]}\n「{text}」',
            })
    return lines


def write_manifest(lines):
    MANIFEST.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST.write_text(json.dumps(lines, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"wrote {MANIFEST}")


def generate(lines, character=None, limit=None):
    if not os.environ.get("OPENAI_API_KEY"):
        print("OPENAI_API_KEY is not set. Manifest only.")
        return

    from openai import OpenAI

    client = OpenAI()
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    selected = [
        line for line in lines
        if character is None or line["character"] == character
    ]
    if limit is not None:
        selected = selected[:limit]

    for line in selected:
        out = OUT_DIR / f'{line["id"]}.mp3'
        if out.exists():
            print(f"skip {out.name}")
            continue
        print(f"generate {out.name}")
        params = {
            "model": "gpt-4o-mini-tts",
            "voice": line["voice"],
            "input": line["text"],
            "instructions": line["instructions"],
            "response_format": "mp3",
        }
        with client.audio.speech.with_streaming_response.create(**params) as response:
            response.stream_to_file(out)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate Houkago Chess Club character MP3 voices.")
    parser.add_argument("--character", choices=sorted(CHARACTERS.keys()))
    parser.add_argument("--limit", type=int, help="Generate only the first N lines for checking voices.")
    args = parser.parse_args()

    lines = build_lines()
    write_manifest(lines)
    generate(lines, character=args.character, limit=args.limit)
