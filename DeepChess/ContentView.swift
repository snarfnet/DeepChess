import SwiftUI

private let lightSquare = Color(red: 0.94, green: 0.85, blue: 0.71)
private let darkSquare = Color(red: 0.71, green: 0.53, blue: 0.39)
private let highlightColor = Color.green.opacity(0.4)
private let lastMoveColor = Color.yellow.opacity(0.3)
private let checkColor = Color.red.opacity(0.5)
private let topAdUnitID = "ca-app-pub-3940256099942544/2934735716"
private let bottomAdUnitID = "ca-app-pub-3940256099942544/2934735716"

struct ContentView: View {
    @StateObject private var game = ChessGame()
    @State private var showNewGame = false
    @State private var selectedDepth = 3

    var body: some View {
        VStack(spacing: 0) {
            AdBannerView(adUnitID: topAdUnitID).frame(height: 50)

            // Status bar
            statusBar

            // Captured pieces (opponent)
            capturedRow(pieces: game.playerColor == .white ? game.capturedBlack : game.capturedWhite)

            // Board
            GeometryReader { geo in
                let size = min(geo.size.width, geo.size.height)
                let sqSize = size / 8
                boardView(sqSize: sqSize)
                    .frame(width: size, height: size)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // Captured pieces (player)
            capturedRow(pieces: game.playerColor == .white ? game.capturedWhite : game.capturedBlack)

            // Controls
            controlsBar

            AdBannerView(adUnitID: bottomAdUnitID).frame(height: 50)
        }
        .background(Color(red: 0.18, green: 0.16, blue: 0.14))
        .overlay { promotionOverlay }
        .overlay { gameOverOverlay }
        .sheet(isPresented: $showNewGame) { newGameSheet }
    }

    // MARK: - Board

    private func boardView(sqSize: CGFloat) -> some View {
        VStack(spacing: 0) {
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
    }

    private func squareView(index: Int, row: Int, col: Int, size: CGFloat) -> some View {
        let isLight = (row + col) % 2 == 0
        let isSelected = game.selectedSquare == index
        let isHighlighted = game.highlightedMoves.contains(where: { $0.to == index })
        let isLastMove = game.lastMove?.from == index || game.lastMove?.to == index
        let isKingCheck = game.isCheck && game.board[index] == Piece(color: game.turn, type: .king)

        return ZStack {
            Rectangle()
                .fill(isLight ? lightSquare : darkSquare)

            if isLastMove {
                Rectangle().fill(lastMoveColor)
            }
            if isKingCheck {
                Rectangle().fill(checkColor)
            }
            if isSelected {
                Rectangle().fill(Color.blue.opacity(0.35))
            }
            if isHighlighted {
                if game.board[index] != nil {
                    // Capture indicator
                    Circle()
                        .strokeBorder(highlightColor, lineWidth: 3)
                        .padding(2)
                } else {
                    Circle()
                        .fill(highlightColor)
                        .frame(width: size * 0.3, height: size * 0.3)
                }
            }

            if let piece = game.board[index] {
                Text(piece.symbol)
                    .font(.system(size: size * 0.7))
                    .minimumScaleFactor(0.5)
            }

            // File/rank labels
            if col == 0 {
                Text("\(row + 1)")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(isLight ? darkSquare : lightSquare)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(1)
            }
            if row == 0 {
                Text(String(Character(UnicodeScalar(97 + col)!)))
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(isLight ? darkSquare : lightSquare)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(1)
            }
        }
        .frame(width: size, height: size)
        .onTapGesture { game.tapSquare(index) }
    }

    // MARK: - Status

    private var statusBar: some View {
        HStack {
            Circle()
                .fill(game.turn == .white ? .white : .black)
                .frame(width: 14, height: 14)
                .overlay(Circle().stroke(.gray, lineWidth: 1))

            if game.isThinking {
                ProgressView()
                    .scaleEffect(0.7)
                    .tint(.white)
                Text("考え中...")
                    .foregroundColor(.white)
                    .font(.system(size: 14))
            } else if game.isCheck {
                Text("チェック!")
                    .foregroundColor(.red)
                    .font(.system(size: 14, weight: .bold))
            } else {
                Text(game.turn == game.playerColor ? "あなたの番" : "CPUの番")
                    .foregroundColor(.white)
                    .font(.system(size: 14))
            }

            Spacer()

            Text("Lv.\(game.difficulty)")
                .foregroundColor(.gray)
                .font(.system(size: 13))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    private func capturedRow(pieces: [Piece]) -> some View {
        HStack(spacing: 1) {
            ForEach(Array(pieces.enumerated()), id: \.offset) { _, piece in
                Text(piece.symbol)
                    .font(.system(size: 16))
            }
            Spacer()
        }
        .frame(height: 22)
        .padding(.horizontal, 8)
    }

    private var controlsBar: some View {
        HStack(spacing: 20) {
            Button {
                showNewGame = true
            } label: {
                Label("新しい対局", systemImage: "plus.circle")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.7))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Promotion

    @ViewBuilder
    private var promotionOverlay: some View {
        if game.promotionPending != nil {
            ZStack {
                Color.black.opacity(0.5).ignoresSafeArea()
                VStack(spacing: 12) {
                    Text("プロモーション")
                        .font(.headline)
                        .foregroundColor(.white)
                    HStack(spacing: 16) {
                        let color = game.playerColor
                        ForEach([PieceType.queen, .rook, .bishop, .knight], id: \.self) { type in
                            Button {
                                game.selectPromotion(type)
                            } label: {
                                Text(Piece(color: color, type: type).symbol)
                                    .font(.system(size: 44))
                                    .frame(width: 60, height: 60)
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding(24)
                .background(Color(red: 0.25, green: 0.22, blue: 0.2))
                .cornerRadius(16)
            }
        }
    }

    // MARK: - Game Over

    @ViewBuilder
    private var gameOverOverlay: some View {
        if game.result != .playing {
            ZStack {
                Color.black.opacity(0.6).ignoresSafeArea()
                VStack(spacing: 16) {
                    Text(gameOverText)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(gameOverSubtext)
                        .font(.body)
                        .foregroundColor(.gray)

                    Button {
                        game.newGame(asColor: game.playerColor, depth: game.difficulty)
                    } label: {
                        Text("もう一度")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(30)
                .background(Color(red: 0.2, green: 0.18, blue: 0.16))
                .cornerRadius(20)
            }
        }
    }

    private var gameOverText: String {
        switch game.result {
        case .checkmate:
            return game.turn == game.playerColor ? "負けました" : "勝ちました!"
        case .stalemate:
            return "引き分け"
        case .playing:
            return ""
        }
    }

    private var gameOverSubtext: String {
        switch game.result {
        case .checkmate: return "チェックメイト"
        case .stalemate: return "ステイルメイト"
        case .playing: return ""
        }
    }

    // MARK: - New Game Sheet

    private var newGameSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("難易度")
                    .font(.headline)
                Picker("難易度", selection: $selectedDepth) {
                    Text("初心者").tag(2)
                    Text("中級").tag(3)
                    Text("上級").tag(4)
                    Text("最強").tag(5)
                }
                .pickerStyle(.segmented)

                HStack(spacing: 20) {
                    Button {
                        showNewGame = false
                        game.newGame(asColor: .white, depth: selectedDepth)
                    } label: {
                        VStack {
                            Text("♔").font(.system(size: 44))
                            Text("白 (先手)")
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    .foregroundColor(.black)

                    Button {
                        showNewGame = false
                        game.newGame(asColor: .black, depth: selectedDepth)
                    } label: {
                        VStack {
                            Text("♚").font(.system(size: 44))
                            Text("黒 (後手)")
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(12)
                    }
                    .foregroundColor(.white)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("新しい対局")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { showNewGame = false }
                }
            }
        }
    }
}
