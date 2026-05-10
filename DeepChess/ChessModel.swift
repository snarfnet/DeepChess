import Foundation

enum PieceColor: Equatable, Hashable {
    case white, black
    var opposite: PieceColor { self == .white ? .black : .white }
}

enum PieceType: Equatable, Hashable {
    case pawn, knight, bishop, rook, queen, king
}

struct Piece: Equatable, Hashable {
    let color: PieceColor
    let type: PieceType

    var symbol: String {
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

    var value: Int {
        switch type {
        case .pawn: return 100
        case .knight: return 320
        case .bishop: return 330
        case .rook: return 500
        case .queen: return 900
        case .king: return 20000
        }
    }
}

struct Move: Equatable, Hashable {
    let from: Int
    let to: Int
    var promotion: PieceType? = nil
}

struct UndoInfo {
    let move: Move
    let capturedPiece: Piece?
    let capturedSquare: Int
    let prevCastling: [Bool]
    let prevEnPassant: Int?
    let prevHalfMove: Int
    let prevLastMove: Move?
}

enum GameResult: Equatable {
    case playing, checkmate, stalemate
}

@MainActor
class ChessGame: ObservableObject {
    @Published var board: [Piece?] = Array(repeating: nil, count: 64)
    @Published var turn: PieceColor = .white
    @Published var selectedSquare: Int? = nil
    @Published var highlightedMoves: [Move] = []
    @Published var isCheck: Bool = false
    @Published var result: GameResult = .playing
    @Published var isThinking: Bool = false
    @Published var lastMove: Move? = nil
    @Published var promotionPending: Move? = nil
    @Published var capturedWhite: [Piece] = []
    @Published var capturedBlack: [Piece] = []

    var castling: [Bool] = [true, true, true, true] // WK, WQ, BK, BQ
    var enPassantTarget: Int? = nil
    var halfMoveClock: Int = 0
    var undoStack: [UndoInfo] = []
    var playerColor: PieceColor = .white
    var difficulty: Int = 3

    init() { setupBoard() }

    func row(_ sq: Int) -> Int { sq / 8 }
    func col(_ sq: Int) -> Int { sq % 8 }
    func sq(_ r: Int, _ c: Int) -> Int { r * 8 + c }
    func valid(_ r: Int, _ c: Int) -> Bool { r >= 0 && r < 8 && c >= 0 && c < 8 }

    func setupBoard() {
        board = Array(repeating: nil, count: 64)
        let back: [PieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]
        for c in 0..<8 {
            board[sq(0, c)] = Piece(color: .white, type: back[c])
            board[sq(1, c)] = Piece(color: .white, type: .pawn)
            board[sq(6, c)] = Piece(color: .black, type: .pawn)
            board[sq(7, c)] = Piece(color: .black, type: back[c])
        }
        turn = .white
        castling = [true, true, true, true]
        enPassantTarget = nil
        halfMoveClock = 0
        undoStack = []
        selectedSquare = nil
        highlightedMoves = []
        isCheck = false
        result = .playing
        lastMove = nil
        promotionPending = nil
        capturedWhite = []
        capturedBlack = []
    }

    func newGame(asColor: PieceColor = .white, depth: Int = 3) {
        playerColor = asColor
        difficulty = depth
        setupBoard()
        if playerColor == .black {
            cpuMove()
        }
    }

    // MARK: - Tap handling

    func tapSquare(_ index: Int) {
        guard result == .playing, turn == playerColor, promotionPending == nil else { return }

        if let sel = selectedSquare {
            if let move = highlightedMoves.first(where: { $0.to == index }) {
                // Check promotion
                if board[sel]?.type == .pawn {
                    let promoRow = playerColor == .white ? 7 : 0
                    if row(index) == promoRow {
                        promotionPending = move
                        selectedSquare = nil
                        highlightedMoves = []
                        return
                    }
                }
                applyPlayerMove(move)
            } else {
                selectPiece(at: index)
            }
        } else {
            selectPiece(at: index)
        }
    }

    func selectPromotion(_ type: PieceType) {
        guard var move = promotionPending else { return }
        move = Move(from: move.from, to: move.to, promotion: type)
        promotionPending = nil
        applyPlayerMove(move)
    }

    private func selectPiece(at index: Int) {
        guard let piece = board[index], piece.color == turn else {
            selectedSquare = nil
            highlightedMoves = []
            return
        }
        selectedSquare = index
        highlightedMoves = generateLegalMoves(for: turn).filter { $0.from == index }
    }

    private func applyPlayerMove(_ move: Move) {
        performMove(move)
        selectedSquare = nil
        highlightedMoves = []
        updateState()
        if result == .playing {
            cpuMove()
        }
    }

    func cpuMove() {
        isThinking = true
        let boardCopy = board
        let turnCopy = turn
        let castCopy = castling
        let epCopy = enPassantTarget
        let hmCopy = halfMoveClock
        let undoCopy = undoStack
        let diff = difficulty

        Task.detached { [weak self] in
            guard let self else { return }
            let engine = ChessEngine()
            let bestMove = engine.findBestMove(
                board: boardCopy, turn: turnCopy,
                castling: castCopy, enPassant: epCopy,
                halfMove: hmCopy, undoStack: undoCopy,
                depth: diff
            )
            await MainActor.run {
                self.isThinking = false
                if let move = bestMove {
                    self.performMove(move)
                    self.updateState()
                }
            }
        }
    }

    // MARK: - State

    func updateState() {
        let legal = generateLegalMoves(for: turn)
        isCheck = isInCheck(turn)
        if legal.isEmpty {
            result = isCheck ? .checkmate : .stalemate
        }
    }

    // MARK: - Move Generation

    func generateLegalMoves(for color: PieceColor) -> [Move] {
        generatePseudoLegalMoves(for: color).filter { move in
            performMove(move)
            let legal = !isInCheck(color)
            undoMove()
            return legal
        }
    }

    func generatePseudoLegalMoves(for color: PieceColor) -> [Move] {
        var moves: [Move] = []
        for i in 0..<64 {
            guard let p = board[i], p.color == color else { continue }
            switch p.type {
            case .pawn:   moves += pawnMoves(i, color)
            case .knight: moves += knightMoves(i, color)
            case .bishop: moves += slidingMoves(i, color, [(-1,-1),(-1,1),(1,-1),(1,1)])
            case .rook:   moves += slidingMoves(i, color, [(-1,0),(1,0),(0,-1),(0,1)])
            case .queen:  moves += slidingMoves(i, color, [(-1,-1),(-1,1),(1,-1),(1,1),(-1,0),(1,0),(0,-1),(0,1)])
            case .king:   moves += kingMoves(i, color)
            }
        }
        return moves
    }

    private func pawnMoves(_ s: Int, _ color: PieceColor) -> [Move] {
        var moves: [Move] = []
        let r = row(s), c = col(s)
        let dir = color == .white ? 1 : -1
        let startRow = color == .white ? 1 : 6
        let promoRow = color == .white ? 7 : 0
        let fwd = r + dir

        guard valid(fwd, c) else { return moves }

        // Push
        if board[sq(fwd, c)] == nil {
            if fwd == promoRow {
                for pt in [PieceType.queen, .rook, .bishop, .knight] {
                    moves.append(Move(from: s, to: sq(fwd, c), promotion: pt))
                }
            } else {
                moves.append(Move(from: s, to: sq(fwd, c)))
                // Double push
                let fwd2 = r + dir * 2
                if r == startRow && valid(fwd2, c) && board[sq(fwd2, c)] == nil {
                    moves.append(Move(from: s, to: sq(fwd2, c)))
                }
            }
        }

        // Captures
        for dc in [-1, 1] {
            let nc = c + dc
            guard valid(fwd, nc) else { continue }
            let target = sq(fwd, nc)
            let hasEnemy = board[target] != nil && board[target]!.color != color
            let isEP = target == enPassantTarget

            if hasEnemy || isEP {
                if fwd == promoRow {
                    for pt in [PieceType.queen, .rook, .bishop, .knight] {
                        moves.append(Move(from: s, to: target, promotion: pt))
                    }
                } else {
                    moves.append(Move(from: s, to: target))
                }
            }
        }
        return moves
    }

    private func knightMoves(_ s: Int, _ color: PieceColor) -> [Move] {
        var moves: [Move] = []
        let r = row(s), c = col(s)
        for (dr, dc) in [(-2,-1),(-2,1),(-1,-2),(-1,2),(1,-2),(1,2),(2,-1),(2,1)] {
            let nr = r + dr, nc = c + dc
            guard valid(nr, nc) else { continue }
            let t = sq(nr, nc)
            if board[t]?.color != color { moves.append(Move(from: s, to: t)) }
        }
        return moves
    }

    private func slidingMoves(_ s: Int, _ color: PieceColor, _ dirs: [(Int,Int)]) -> [Move] {
        var moves: [Move] = []
        let r = row(s), c = col(s)
        for (dr, dc) in dirs {
            var nr = r + dr, nc = c + dc
            while valid(nr, nc) {
                let t = sq(nr, nc)
                if let p = board[t] {
                    if p.color != color { moves.append(Move(from: s, to: t)) }
                    break
                }
                moves.append(Move(from: s, to: t))
                nr += dr; nc += dc
            }
        }
        return moves
    }

    private func kingMoves(_ s: Int, _ color: PieceColor) -> [Move] {
        var moves: [Move] = []
        let r = row(s), c = col(s)
        for dr in -1...1 {
            for dc in -1...1 {
                if dr == 0 && dc == 0 { continue }
                let nr = r + dr, nc = c + dc
                guard valid(nr, nc) else { continue }
                let t = sq(nr, nc)
                if board[t]?.color != color { moves.append(Move(from: s, to: t)) }
            }
        }

        // Castling
        let home = color == .white ? 0 : 7
        let ki = color == .white ? 0 : 2
        let qi = color == .white ? 1 : 3
        let opp = color.opposite

        if r == home && c == 4 {
            if castling[ki],
               board[sq(home, 5)] == nil, board[sq(home, 6)] == nil,
               !isSquareAttacked(sq(home, 4), by: opp),
               !isSquareAttacked(sq(home, 5), by: opp),
               !isSquareAttacked(sq(home, 6), by: opp) {
                moves.append(Move(from: s, to: sq(home, 6)))
            }
            if castling[qi],
               board[sq(home, 3)] == nil, board[sq(home, 2)] == nil, board[sq(home, 1)] == nil,
               !isSquareAttacked(sq(home, 4), by: opp),
               !isSquareAttacked(sq(home, 3), by: opp),
               !isSquareAttacked(sq(home, 2), by: opp) {
                moves.append(Move(from: s, to: sq(home, 2)))
            }
        }
        return moves
    }

    // MARK: - Attack Detection

    func isSquareAttacked(_ s: Int, by color: PieceColor) -> Bool {
        let r = row(s), c = col(s)

        // Knight
        for (dr, dc) in [(-2,-1),(-2,1),(-1,-2),(-1,2),(1,-2),(1,2),(2,-1),(2,1)] {
            let nr = r + dr, nc = c + dc
            if valid(nr, nc) && board[sq(nr, nc)] == Piece(color: color, type: .knight) { return true }
        }

        // Pawn
        let pDir = color == .white ? -1 : 1
        for dc in [-1, 1] {
            let pr = r + pDir, pc = c + dc
            if valid(pr, pc) && board[sq(pr, pc)] == Piece(color: color, type: .pawn) { return true }
        }

        // King
        for dr in -1...1 {
            for dc in -1...1 {
                if dr == 0 && dc == 0 { continue }
                let nr = r + dr, nc = c + dc
                if valid(nr, nc) && board[sq(nr, nc)] == Piece(color: color, type: .king) { return true }
            }
        }

        // Diagonal (bishop/queen)
        for (dr, dc) in [(-1,-1),(-1,1),(1,-1),(1,1)] {
            var nr = r + dr, nc = c + dc
            while valid(nr, nc) {
                if let p = board[sq(nr, nc)] {
                    if p.color == color && (p.type == .bishop || p.type == .queen) { return true }
                    break
                }
                nr += dr; nc += dc
            }
        }

        // Straight (rook/queen)
        for (dr, dc) in [(-1,0),(1,0),(0,-1),(0,1)] {
            var nr = r + dr, nc = c + dc
            while valid(nr, nc) {
                if let p = board[sq(nr, nc)] {
                    if p.color == color && (p.type == .rook || p.type == .queen) { return true }
                    break
                }
                nr += dr; nc += dc
            }
        }

        return false
    }

    func findKing(_ color: PieceColor) -> Int {
        for i in 0..<64 where board[i] == Piece(color: color, type: .king) { return i }
        return 0
    }

    func isInCheck(_ color: PieceColor) -> Bool {
        isSquareAttacked(findKing(color), by: color.opposite)
    }

    // MARK: - Make / Undo Move

    func performMove(_ move: Move) {
        guard let piece = board[move.from] else { return }
        let r = row(move.from), c = col(move.from)
        let tr = row(move.to), tc = col(move.to)

        var capturedPiece = board[move.to]
        var capturedSq = move.to

        // En passant capture
        let isEP = piece.type == .pawn && move.to == enPassantTarget
        if isEP {
            capturedSq = sq(r, tc)
            capturedPiece = board[capturedSq]
        }

        undoStack.append(UndoInfo(
            move: move, capturedPiece: capturedPiece, capturedSquare: capturedSq,
            prevCastling: castling, prevEnPassant: enPassantTarget, prevHalfMove: halfMoveClock,
            prevLastMove: lastMove
        ))

        if isEP { board[capturedSq] = nil }

        // Track captures
        if let cap = capturedPiece {
            if cap.color == .white { capturedWhite.append(cap) }
            else { capturedBlack.append(cap) }
        }

        // Castling - move rook
        let home = piece.color == .white ? 0 : 7
        if piece.type == .king && abs(tc - c) == 2 {
            if tc == 6 { // Kingside
                board[sq(home, 5)] = board[sq(home, 7)]
                board[sq(home, 7)] = nil
            } else if tc == 2 { // Queenside
                board[sq(home, 3)] = board[sq(home, 0)]
                board[sq(home, 0)] = nil
            }
        }

        // Move piece
        board[move.to] = move.promotion != nil ? Piece(color: piece.color, type: move.promotion!) : piece
        board[move.from] = nil

        // Update en passant target
        if piece.type == .pawn && abs(tr - r) == 2 {
            enPassantTarget = sq((r + tr) / 2, c)
        } else {
            enPassantTarget = nil
        }

        // Update castling rights
        if piece.type == .king {
            if piece.color == .white { castling[0] = false; castling[1] = false }
            else { castling[2] = false; castling[3] = false }
        }
        if piece.type == .rook {
            if move.from == sq(0, 7) { castling[0] = false }
            if move.from == sq(0, 0) { castling[1] = false }
            if move.from == sq(7, 7) { castling[2] = false }
            if move.from == sq(7, 0) { castling[3] = false }
        }
        if move.to == sq(0, 7) { castling[0] = false }
        if move.to == sq(0, 0) { castling[1] = false }
        if move.to == sq(7, 7) { castling[2] = false }
        if move.to == sq(7, 0) { castling[3] = false }

        // Half move clock
        if piece.type == .pawn || capturedPiece != nil { halfMoveClock = 0 }
        else { halfMoveClock += 1 }

        lastMove = move
        turn = turn.opposite
    }

    func undoMove() {
        guard let info = undoStack.popLast() else { return }
        let move = info.move
        let piece = board[move.to]!
        let originalPiece = move.promotion != nil ? Piece(color: piece.color, type: .pawn) : piece

        // Undo castling rook
        let home = piece.color == .white ? 0 : 7
        if (piece.type == .king || move.promotion == nil && originalPiece.type == .king) && abs(col(move.to) - col(move.from)) == 2 {
            if col(move.to) == 6 {
                board[sq(home, 7)] = board[sq(home, 5)]
                board[sq(home, 5)] = nil
            } else if col(move.to) == 2 {
                board[sq(home, 0)] = board[sq(home, 3)]
                board[sq(home, 3)] = nil
            }
        }

        board[move.from] = originalPiece
        board[move.to] = nil

        // Restore capture
        if let cap = info.capturedPiece {
            board[info.capturedSquare] = cap
            if cap.color == .white { capturedWhite.removeLast() }
            else { capturedBlack.removeLast() }
        }

        castling = info.prevCastling
        enPassantTarget = info.prevEnPassant
        halfMoveClock = info.prevHalfMove
        lastMove = info.prevLastMove
        turn = turn.opposite
    }
}
