import SwiftUI

private let topAdUnitID = "ca-app-pub-9404799280370656/3426466078"
private let bottomAdUnitID = "ca-app-pub-9404799280370656/3426466078"

private let paper = Color(red: 0.96, green: 0.91, blue: 0.78)
private let paperLight = Color(red: 1.00, green: 0.97, blue: 0.84)
private let pencil = Color(red: 0.25, green: 0.30, blue: 0.33)
private let bluePencil = Color(red: 0.53, green: 0.68, blue: 0.73)
private let yellowTape = Color(red: 0.93, green: 0.84, blue: 0.42)
private let deskBrown = Color(red: 0.63, green: 0.48, blue: 0.32)
private let rainyBlue = Color(red: 0.38, green: 0.55, blue: 0.68)
private let redPencil = Color(red: 0.78, green: 0.32, blue: 0.24)

@MainActor
struct ContentView: View {
    @StateObject private var game = ChessGame()
    @State private var showNewGame = false
    @State private var selectedOpponent: OpponentCharacter = .senpai
    @State private var showCoach = true
    @State private var expressionOverride: FACSExpression?
    @State private var didStartDefaultOpponent = false

    private var expression: FACSExpression {
        expressionOverride ?? FACSExpression.current(for: game)
    }

    var body: some View {
        ZStack {
            posterBackground
            VStack(spacing: 0) {
                AdBannerView(adUnitID: topAdUnitID)
                    .frame(height: 50)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        header
                        opponentPoster
                        boardSection
                        expressionStrip
                        if showCoach { coachCard }
                        controlsBar
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 18)
                }

                AdBannerView(adUnitID: bottomAdUnitID)
                    .frame(height: 50)
            }
        }
        .overlay { promotionOverlay }
        .overlay { gameOverOverlay }
        .sheet(isPresented: $showNewGame) { newGameSheet }
        .onAppear {
            if !didStartDefaultOpponent {
                didStartDefaultOpponent = true
                game.newGame(asColor: .white, depth: selectedOpponent.depth)
            }
        }
    }

    private var posterBackground: some View {
        ZStack {
            paper.ignoresSafeArea()
            GeometryReader { geo in
                Path { path in
                    let step: CGFloat = 22
                    for y in stride(from: 0, through: geo.size.height, by: step) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geo.size.width, y: y + CGFloat.random(in: -2...2)))
                    }
                }
                .stroke(pencil.opacity(0.055), lineWidth: 0.7)

                Path { path in
                    for x in stride(from: -60, through: geo.size.width + 60, by: 42) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x + 26, y: geo.size.height))
                    }
                }
                .stroke(rainyBlue.opacity(0.08), lineWidth: 1)
            }
            .ignoresSafeArea()
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("DeepChess")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(pencil)
                Text("放課後チェス部")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(rainyBlue)
            }

            Spacer()

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    showCoach.toggle()
                }
            } label: {
                Image(systemName: showCoach ? "note.text" : "note")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(pencil)
                    .frame(width: 44, height: 44)
                    .background(paperLight, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(pencil.opacity(0.45), lineWidth: 1.5))
            }
            .accessibilityLabel(showCoach ? "AIコーチを隠す" : "AIコーチを表示")
        }
    }

    private var opponentPoster: some View {
        ZStack(alignment: .bottomLeading) {
            Image(selectedOpponent.assetName(for: expression))
                .resizable()
                .scaledToFill()
                .frame(height: 226)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [.clear, paper.opacity(0.10), paper.opacity(0.60)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(pencil.opacity(0.48), lineWidth: 2))

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 7) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 9, height: 9)
                Text(statusText)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(pencil)
                }
                Text(expression.name)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(pencil)
                Text("\(selectedOpponent.role)・\(selectedOpponent.strength)  \(selectedOpponent.name)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(rainyBlue)
                Text("\(expression.code)  \(expression.note)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(pencil.opacity(0.72))
            }
            .padding(13)
            .background(paperLight.opacity(0.88), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(pencil.opacity(0.28), lineWidth: 1.2))
            .padding(12)
        }
        .overlay(alignment: .topLeading) { tape(width: 96).offset(x: 18, y: -7) }
        .overlay(alignment: .topTrailing) { tape(width: 96).offset(x: -18, y: -7) }
    }

    private var boardSection: some View {
        VStack(spacing: 10) {
            capturedRow(title: "相手", pieces: game.playerColor == .white ? game.capturedBlack : game.capturedWhite, trailing: false)

            GeometryReader { geo in
                let size = min(geo.size.width, 430)
                boardView(size: size)
                    .frame(width: size, height: size)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: min(UIScreen.main.bounds.width - 32, 430))

            capturedRow(title: "あなた", pieces: game.playerColor == .white ? game.capturedWhite : game.capturedBlack, trailing: true)
        }
        .padding(12)
        .background(paperLight.opacity(0.82), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(pencil.opacity(0.34), lineWidth: 2))
    }

    private func boardView(size: CGFloat) -> some View {
        let sqSize = size / 8
        return VStack(spacing: 0) {
            ForEach((0..<8).reversed(), id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { col in
                        let displayRow = game.playerColor == .white ? row : 7 - row
                        let displayCol = game.playerColor == .white ? col : 7 - col
                        let index = displayRow * 8 + displayCol
                        squareView(index: index, row: displayRow, col: displayCol, size: sqSize)
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(pencil.opacity(0.70), lineWidth: 2))
        .shadow(color: deskBrown.opacity(0.20), radius: 12, x: 0, y: 8)
    }

    private func squareView(index: Int, row: Int, col: Int, size: CGFloat) -> some View {
        let isLight = (row + col) % 2 == 0
        let isSelected = game.selectedSquare == index
        let isHighlighted = game.highlightedMoves.contains(where: { $0.to == index })
        let isLastMove = game.lastMove?.from == index || game.lastMove?.to == index
        let isKingCheck = game.isCheck && game.board[index] == Piece(color: game.turn, type: .king)

        return ZStack {
            Rectangle()
                .fill(isLight ? paperLight : rainyBlue.opacity(0.62))

            if isLastMove { Rectangle().fill(yellowTape.opacity(0.48)) }
            if isKingCheck { Rectangle().fill(redPencil.opacity(0.36)) }
            if isSelected { Rectangle().strokeBorder(redPencil, lineWidth: 3) }

            if isHighlighted {
                if game.board[index] != nil {
                    Circle()
                        .strokeBorder(redPencil.opacity(0.85), lineWidth: 3)
                        .padding(size * 0.10)
                } else {
                    Circle()
                        .fill(bluePencil.opacity(0.75))
                        .frame(width: size * 0.24, height: size * 0.24)
                }
            }

            if let piece = game.board[index] {
                ChessPieceView(
                    pieceType: piece.type,
                    isWhite: piece.color == .white,
                    size: size
                )
            }

            coordinateLabels(row: row, col: col, isLight: isLight)
        }
        .frame(width: size, height: size)
        .contentShape(Rectangle())
        .onTapGesture {
            expressionOverride = nil
            game.tapSquare(index)
        }
    }

    private func coordinateLabels(row: Int, col: Int, isLight: Bool) -> some View {
        ZStack {
            if col == 0 {
                Text("\(row + 1)")
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .foregroundStyle(pencil.opacity(isLight ? 0.62 : 0.82))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(3)
            }
            if row == 0 {
                Text(String(Character(UnicodeScalar(97 + col)!)))
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .foregroundStyle(pencil.opacity(isLight ? 0.62 : 0.82))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(3)
            }
        }
    }

    private var expressionStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(selectedOpponent.role)の表情")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(pencil)
                Spacer()
                Button("自動") { expressionOverride = nil }
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(rainyBlue)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    ForEach(FACSExpression.all) { item in
                        Button {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                                expressionOverride = item
                            }
                        } label: {
                            Text("\(item.id)")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle((expressionOverride ?? expression).id == item.id ? paperLight : pencil)
                                .frame(width: 32, height: 30)
                                .background((expressionOverride ?? expression).id == item.id ? pencil : paperLight, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 7).stroke(pencil.opacity(0.32), lineWidth: 1))
                        }
                        .accessibilityLabel(item.name)
                    }
                }
            }
        }
        .padding(12)
        .background(paperLight.opacity(0.75), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(pencil.opacity(0.24), lineWidth: 1.5))
    }

    private var coachCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("AI")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(pencil)
                .frame(width: 42, height: 42)
                .background(yellowTape.opacity(0.80), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text("メガネのAIコーチ")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(pencil)
                Text(AICoach.insight(for: game))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(pencil.opacity(0.78))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(paperLight.opacity(0.88), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(pencil.opacity(0.34), lineWidth: 1.5))
        .overlay(alignment: .topLeading) { tape(width: 74).offset(x: 18, y: -7) }
    }

    private var controlsBar: some View {
        HStack(spacing: 10) {
            Button {
                showNewGame = true
            } label: {
                Label("新しい対局", systemImage: "plus")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(pencil)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(bluePencil.opacity(0.58), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(pencil.opacity(0.46), lineWidth: 1.5))
            }

            Button {
                expressionOverride = nil
                game.newGame(asColor: game.playerColor, depth: selectedOpponent.depth)
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(pencil)
                    .frame(width: 50, height: 46)
                    .background(paperLight, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(pencil.opacity(0.42), lineWidth: 1.5))
            }
            .accessibilityLabel("同じ設定でリスタート")
        }
    }

    private func capturedRow(title: String, pieces: [Piece], trailing: Bool) -> some View {
        HStack(spacing: 8) {
            if trailing { Spacer(minLength: 0) }
            Text(title)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(pencil.opacity(0.60))
            HStack(spacing: -2) {
                ForEach(Array(pieces.enumerated()), id: \.offset) { _, piece in
                    Text(piece.displaySymbol)
                        .font(.system(size: 18, design: .serif))
                        .foregroundStyle(piece.color == .white ? deskBrown.opacity(0.75) : pencil)
                }
            }
            if !trailing { Spacer(minLength: 0) }
        }
        .frame(height: 24)
    }

    private var statusColor: Color {
        if game.isThinking { return rainyBlue }
        if game.isCheck { return redPencil }
        if game.result != .playing { return yellowTape }
        return game.turn == game.playerColor ? deskBrown : pencil
    }

    private var statusText: String {
        if game.isThinking { return "考え中" }
        if game.isCheck { return "王手" }
        if game.result != .playing { return "対局終了" }
        return game.turn == game.playerColor ? "あなたの番" : "相手の番"
    }

    private func tape(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(yellowTape.opacity(0.58))
            .frame(width: width, height: 18)
    }

    @ViewBuilder
    private var promotionOverlay: some View {
        if game.promotionPending != nil {
            ZStack {
                Color.black.opacity(0.35).ignoresSafeArea()
                VStack(spacing: 16) {
                    Text("昇格する駒")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(pencil)
                    HStack(spacing: 12) {
                        ForEach([PieceType.queen, .rook, .bishop, .knight], id: \.self) { type in
                            Button {
                                game.selectPromotion(type)
                            } label: {
                                Text(Piece(color: game.playerColor, type: type).displaySymbol)
                                    .font(.system(size: 42, design: .serif))
                                    .frame(width: 66, height: 66)
                                    .foregroundStyle(pencil)
                                    .background(paperLight, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(pencil.opacity(0.38), lineWidth: 1.5))
                            }
                        }
                    }
                }
                .padding(24)
                .background(paper, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(pencil.opacity(0.38), lineWidth: 2))
                .padding(18)
            }
        }
    }

    @ViewBuilder
    private var gameOverOverlay: some View {
        if game.result != .playing {
            ZStack {
                Color.black.opacity(0.38).ignoresSafeArea()
                VStack(spacing: 14) {
                    Image(selectedOpponent.assetName(for: expression))
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    Text(gameOverText)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(pencil)
                    Text(gameOverSubtext)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(pencil.opacity(0.72))
                        .multilineTextAlignment(.center)

                    Button {
                        expressionOverride = nil
                        game.newGame(asColor: game.playerColor, depth: selectedOpponent.depth)
                    } label: {
                        Text("もう一局")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(pencil)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(bluePencil.opacity(0.56), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .padding(.top, 6)
                }
                .padding(22)
                .background(paper, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(pencil.opacity(0.38), lineWidth: 2))
                .padding(20)
            }
        }
    }

    private var gameOverText: String {
        switch game.result {
        case .checkmate:
            return game.turn == game.playerColor ? "負けました" : "勝ちました"
        case .stalemate:
            return "引き分け"
        case .playing:
            return ""
        }
    }

    private var gameOverSubtext: String {
        switch game.result {
        case .checkmate:
            return game.turn == game.playerColor ? "相手に詰まされました。" : "きれいにチェックメイトです。"
        case .stalemate:
            return "合法手がなく、王手ではありません。"
        case .playing:
            return ""
        }
    }

    private var newGameSheet: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 22) {
                Text("対戦相手")
                    .font(.system(size: 17, weight: .black, design: .rounded))

                VStack(spacing: 10) {
                    ForEach(OpponentCharacter.allCases) { opponent in
                        opponentButton(opponent)
                    }
                }

                Text("あなたの色")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .padding(.top, 8)

                HStack(spacing: 12) {
                    colorButton(color: .white, title: "白", subtitle: "先手")
                    colorButton(color: .black, title: "黒", subtitle: "後手")
                }

                Spacer()
            }
            .padding(20)
            .background(paper)
            .navigationTitle("新しい対局")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { showNewGame = false }
                }
            }
        }
    }

    private func opponentButton(_ opponent: OpponentCharacter) -> some View {
        Button {
            selectedOpponent = opponent
            expressionOverride = nil
        } label: {
            HStack(spacing: 12) {
                Image(opponent.assetName(for: FACSExpression.all[0]))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 72, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(pencil.opacity(0.28), lineWidth: 1))

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(opponent.role)  \(opponent.name)")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                    Text("\(opponent.strength) / \(opponent.intro)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(pencil.opacity(0.70))
                        .lineLimit(2)
                }

                Spacer()

                if selectedOpponent == opponent {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(rainyBlue)
                }
            }
            .padding(10)
            .foregroundStyle(pencil)
            .background(selectedOpponent == opponent ? bluePencil.opacity(0.25) : paperLight, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(pencil.opacity(selectedOpponent == opponent ? 0.58 : 0.28), lineWidth: 1.5))
        }
    }

    private func colorButton(color: PieceColor, title: String, subtitle: String) -> some View {
        Button {
            showNewGame = false
            expressionOverride = nil
            game.newGame(asColor: color, depth: selectedOpponent.depth)
        } label: {
            VStack(spacing: 8) {
                Text(Piece(color: color, type: .queen).displaySymbol)
                    .font(.system(size: 48, design: .serif))
                Text(title)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(pencil.opacity(0.70))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .foregroundStyle(pencil)
            .background(color == .white ? paperLight : rainyBlue.opacity(0.45), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(pencil.opacity(0.36), lineWidth: 1.5))
        }
    }
}

private extension Piece {
    var displaySymbol: String {
        switch (color, type) {
        case (.white, .king): return "♔"
        case (.white, .queen): return "♕"
        case (.white, .rook): return "♖"
        case (.white, .bishop): return "♗"
        case (.white, .knight): return "♘"
        case (.white, .pawn): return "♙"
        case (.black, .king): return "♚"
        case (.black, .queen): return "♛"
        case (.black, .rook): return "♜"
        case (.black, .bishop): return "♝"
        case (.black, .knight): return "♞"
        case (.black, .pawn): return "♟"
        }
    }
}
