import Foundation

// Piece-Square Tables (from white's perspective, index 0=a1)
private let pawnPST: [Int] = [
     0,  0,  0,  0,  0,  0,  0,  0,
     5, 10, 10,-20,-20, 10, 10,  5,
     5, -5,-10,  0,  0,-10, -5,  5,
     0,  0,  0, 20, 20,  0,  0,  0,
     5,  5, 10, 25, 25, 10,  5,  5,
    10, 10, 20, 30, 30, 20, 10, 10,
    50, 50, 50, 50, 50, 50, 50, 50,
     0,  0,  0,  0,  0,  0,  0,  0
]

private let knightPST: [Int] = [
    -50,-40,-30,-30,-30,-30,-40,-50,
    -40,-20,  0,  5,  5,  0,-20,-40,
    -30,  5, 10, 15, 15, 10,  5,-30,
    -30,  0, 15, 20, 20, 15,  0,-30,
    -30,  5, 15, 20, 20, 15,  5,-30,
    -30,  0, 10, 15, 15, 10,  0,-30,
    -40,-20,  0,  0,  0,  0,-20,-40,
    -50,-40,-30,-30,-30,-30,-40,-50
]

private let bishopPST: [Int] = [
    -20,-10,-10,-10,-10,-10,-10,-20,
    -10,  5,  0,  0,  0,  0,  5,-10,
    -10, 10, 10, 10, 10, 10, 10,-10,
    -10,  0, 10, 10, 10, 10,  0,-10,
    -10,  5,  5, 10, 10,  5,  5,-10,
    -10,  0,  5, 10, 10,  5,  0,-10,
    -10,  0,  0,  0,  0,  0,  0,-10,
    -20,-10,-10,-10,-10,-10,-10,-20
]

private let rookPST: [Int] = [
     0,  0,  0,  5,  5,  0,  0,  0,
    -5,  0,  0,  0,  0,  0,  0, -5,
    -5,  0,  0,  0,  0,  0,  0, -5,
    -5,  0,  0,  0,  0,  0,  0, -5,
    -5,  0,  0,  0,  0,  0,  0, -5,
    -5,  0,  0,  0,  0,  0,  0, -5,
     5, 10, 10, 10, 10, 10, 10,  5,
     0,  0,  0,  0,  0,  0,  0,  0
]

private let queenPST: [Int] = [
    -20,-10,-10, -5, -5,-10,-10,-20,
    -10,  0,  5,  0,  0,  0,  0,-10,
    -10,  5,  5,  5,  5,  5,  0,-10,
      0,  0,  5,  5,  5,  5,  0, -5,
     -5,  0,  5,  5,  5,  5,  0, -5,
    -10,  0,  5,  5,  5,  5,  0,-10,
    -10,  0,  0,  0,  0,  0,  0,-10,
    -20,-10,-10, -5, -5,-10,-10,-20
]

private let kingMiddlePST: [Int] = [
     20, 30, 10,  0,  0, 10, 30, 20,
     20, 20,  0,  0,  0,  0, 20, 20,
    -10,-20,-20,-20,-20,-20,-20,-10,
    -20,-30,-30,-40,-40,-30,-30,-20,
    -30,-40,-40,-50,-50,-40,-40,-30,
    -30,-40,-40,-50,-50,-40,-40,-30,
    -30,-40,-40,-50,-50,-40,-40,-30,
    -30,-40,-40,-50,-50,-40,-40,-30
]

class ChessEngine {
    private var board: [Piece?] = []
    private var turn: PieceColor = .white
    private var castling: [Bool] = []
    private var enPassantTarget: Int? = nil
    private var halfMoveClock: Int = 0
    private var undoStack: [UndoInfo] = []
    private var nodesSearched: Int = 0

    func findBestMove(
        board: [Piece?], turn: PieceColor,
        castling: [Bool], enPassant: Int?,
        halfMove: Int, undoStack: [UndoInfo],
        depth: Int
    ) -> Move? {
        self.board = board
        self.turn = turn
        self.castling = castling
        self.enPassantTarget = enPassant
        self.halfMoveClock = halfMove
        self.undoStack = undoStack
        self.nodesSearched = 0

        let moves = generateLegalMoves(for: turn)
        if moves.isEmpty { return nil }

        var bestMove = moves[0]
        var bestScore = Int.min

        let sorted = orderMoves(moves)
        for move in sorted {
            performMove(move)
            let score = -alphaBeta(depth: depth - 1, alpha: Int.min + 1, beta: Int.max - 1, color: turn.opposite)
            undoMove()

            if score > bestScore {
                bestScore = score
                bestMove = move
            }
        }
        return bestMove
    }

    private func alphaBeta(depth: Int, alpha: Int, beta: Int, color: PieceColor) -> Int {
        nodesSearched += 1

        if depth == 0 { return quiesce(alpha: alpha, beta: beta, color: color) }

        let moves = generateLegalMoves(for: color)
        if moves.isEmpty {
            return isInCheck(color) ? (-20000 + (10 - depth)) : 0
        }

        var a = alpha
        let sorted = orderMoves(moves)
        for move in sorted {
            performMove(move)
            let score = -alphaBeta(depth: depth - 1, alpha: -beta, beta: -a, color: color.opposite)
            undoMove()

            if score >= beta { return beta }
            if score > a { a = score }
        }
        return a
    }

    private func quiesce(alpha: Int, beta: Int, color: PieceColor) -> Int {
        let standPat = evaluate(for: color)
        if standPat >= beta { return beta }
        var a = max(alpha, standPat)

        let captures = generatePseudoLegalMoves(for: color).filter { board[$0.to] != nil }
        for move in captures {
            performMove(move)
            guard !isInCheck(color) else { undoMove(); continue }
            let score = -quiesce(alpha: -beta, beta: -a, color: color.opposite)
            undoMove()

            if score >= beta { return beta }
            if score > a { a = score }
        }
        return a
    }

    private func orderMoves(_ moves: [Move]) -> [Move] {
        moves.sorted { m1, m2 in
            let s1 = moveScore(m1)
            let s2 = moveScore(m2)
            return s1 > s2
        }
    }

    private func moveScore(_ move: Move) -> Int {
        var score = 0
        if let captured = board[move.to] {
            score += captured.value * 10 - (board[move.from]?.value ?? 0)
        }
        if move.promotion == .queen { score += 800 }
        return score
    }

    // MARK: - Evaluation

    private func evaluate(for color: PieceColor) -> Int {
        var score = 0
        for i in 0..<64 {
            guard let p = board[i] else { continue }
            let mult = p.color == color ? 1 : -1
            score += mult * p.value
            score += mult * positionalBonus(piece: p, square: i)
        }
        return score
    }

    private func positionalBonus(piece: Piece, square: Int) -> Int {
        let idx = piece.color == .white ? square : (56 + (square % 8) - (square / 8) * 8)
        // Mirror for black: row 0 becomes row 7
        let mirrorIdx = piece.color == .white ? square : ((7 - square / 8) * 8 + square % 8)

        switch piece.type {
        case .pawn:   return pawnPST[mirrorIdx]
        case .knight: return knightPST[mirrorIdx]
        case .bishop: return bishopPST[mirrorIdx]
        case .rook:   return rookPST[mirrorIdx]
        case .queen:  return queenPST[mirrorIdx]
        case .king:   return kingMiddlePST[mirrorIdx]
        }
    }

    // MARK: - Move Generation (duplicated for engine thread safety)

    private func row(_ sq: Int) -> Int { sq / 8 }
    private func col(_ sq: Int) -> Int { sq % 8 }
    private func sq(_ r: Int, _ c: Int) -> Int { r * 8 + c }
    private func valid(_ r: Int, _ c: Int) -> Bool { r >= 0 && r < 8 && c >= 0 && c < 8 }

    private func findKing(_ color: PieceColor) -> Int {
        for i in 0..<64 where board[i] == Piece(color: color, type: .king) { return i }
        return 0
    }

    private func isSquareAttacked(_ s: Int, by color: PieceColor) -> Bool {
        let r = row(s), c = col(s)
        for (dr, dc) in [(-2,-1),(-2,1),(-1,-2),(-1,2),(1,-2),(1,2),(2,-1),(2,1)] {
            let nr = r + dr, nc = c + dc
            if valid(nr, nc) && board[sq(nr, nc)] == Piece(color: color, type: .knight) { return true }
        }
        let pDir = color == .white ? -1 : 1
        for dc in [-1, 1] {
            let pr = r + pDir, pc = c + dc
            if valid(pr, pc) && board[sq(pr, pc)] == Piece(color: color, type: .pawn) { return true }
        }
        for dr in -1...1 {
            for dc in -1...1 {
                if dr == 0 && dc == 0 { continue }
                let nr = r + dr, nc = c + dc
                if valid(nr, nc) && board[sq(nr, nc)] == Piece(color: color, type: .king) { return true }
            }
        }
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

    private func isInCheck(_ color: PieceColor) -> Bool {
        isSquareAttacked(findKing(color), by: color.opposite)
    }

    private func generateLegalMoves(for color: PieceColor) -> [Move] {
        generatePseudoLegalMoves(for: color).filter { move in
            performMove(move)
            let legal = !isInCheck(color)
            undoMove()
            return legal
        }
    }

    private func generatePseudoLegalMoves(for color: PieceColor) -> [Move] {
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
        if board[sq(fwd, c)] == nil {
            if fwd == promoRow {
                for pt in [PieceType.queen, .rook, .bishop, .knight] { moves.append(Move(from: s, to: sq(fwd, c), promotion: pt)) }
            } else {
                moves.append(Move(from: s, to: sq(fwd, c)))
                let fwd2 = r + dir * 2
                if r == startRow && valid(fwd2, c) && board[sq(fwd2, c)] == nil { moves.append(Move(from: s, to: sq(fwd2, c))) }
            }
        }
        for dc in [-1, 1] {
            let nc = c + dc
            guard valid(fwd, nc) else { continue }
            let t = sq(fwd, nc)
            if (board[t] != nil && board[t]!.color != color) || t == enPassantTarget {
                if fwd == promoRow {
                    for pt in [PieceType.queen, .rook, .bishop, .knight] { moves.append(Move(from: s, to: t, promotion: pt)) }
                } else { moves.append(Move(from: s, to: t)) }
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
                if let p = board[t] { if p.color != color { moves.append(Move(from: s, to: t)) }; break }
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
        let home = color == .white ? 0 : 7
        let ki = color == .white ? 0 : 2
        let qi = color == .white ? 1 : 3
        let opp = color.opposite
        if r == home && c == 4 {
            if castling[ki], board[sq(home,5)] == nil, board[sq(home,6)] == nil,
               !isSquareAttacked(sq(home,4), by: opp), !isSquareAttacked(sq(home,5), by: opp), !isSquareAttacked(sq(home,6), by: opp) {
                moves.append(Move(from: s, to: sq(home, 6)))
            }
            if castling[qi], board[sq(home,3)] == nil, board[sq(home,2)] == nil, board[sq(home,1)] == nil,
               !isSquareAttacked(sq(home,4), by: opp), !isSquareAttacked(sq(home,3), by: opp), !isSquareAttacked(sq(home,2), by: opp) {
                moves.append(Move(from: s, to: sq(home, 2)))
            }
        }
        return moves
    }

    // MARK: - Make / Undo

    private func performMove(_ move: Move) {
        guard let piece = board[move.from] else { return }
        let r = row(move.from), tc = col(move.to)
        var capturedPiece = board[move.to]
        var capturedSq = move.to

        let isEP = piece.type == .pawn && move.to == enPassantTarget
        if isEP { capturedSq = sq(r, tc); capturedPiece = board[capturedSq] }

        undoStack.append(UndoInfo(move: move, capturedPiece: capturedPiece, capturedSquare: capturedSq,
                                  prevCastling: castling, prevEnPassant: enPassantTarget, prevHalfMove: halfMoveClock,
                                  prevLastMove: nil))

        if isEP { board[capturedSq] = nil }

        let home = piece.color == .white ? 0 : 7
        if piece.type == .king && abs(tc - col(move.from)) == 2 {
            if tc == 6 { board[sq(home,5)] = board[sq(home,7)]; board[sq(home,7)] = nil }
            else if tc == 2 { board[sq(home,3)] = board[sq(home,0)]; board[sq(home,0)] = nil }
        }

        board[move.to] = move.promotion != nil ? Piece(color: piece.color, type: move.promotion!) : piece
        board[move.from] = nil

        if piece.type == .pawn && abs(row(move.to) - r) == 2 { enPassantTarget = sq((r + row(move.to)) / 2, col(move.from)) }
        else { enPassantTarget = nil }

        if piece.type == .king {
            if piece.color == .white { castling[0] = false; castling[1] = false }
            else { castling[2] = false; castling[3] = false }
        }
        if piece.type == .rook {
            if move.from == sq(0,7) { castling[0] = false }
            if move.from == sq(0,0) { castling[1] = false }
            if move.from == sq(7,7) { castling[2] = false }
            if move.from == sq(7,0) { castling[3] = false }
        }
        if move.to == sq(0,7) { castling[0] = false }
        if move.to == sq(0,0) { castling[1] = false }
        if move.to == sq(7,7) { castling[2] = false }
        if move.to == sq(7,0) { castling[3] = false }

        if piece.type == .pawn || capturedPiece != nil { halfMoveClock = 0 } else { halfMoveClock += 1 }
        turn = turn.opposite
    }

    private func undoMove() {
        guard let info = undoStack.popLast() else { return }
        let move = info.move
        let piece = board[move.to]!
        let original = move.promotion != nil ? Piece(color: piece.color, type: .pawn) : piece

        let home = piece.color == .white ? 0 : 7
        if original.type == .king && abs(col(move.to) - col(move.from)) == 2 {
            if col(move.to) == 6 { board[sq(home,7)] = board[sq(home,5)]; board[sq(home,5)] = nil }
            else if col(move.to) == 2 { board[sq(home,0)] = board[sq(home,3)]; board[sq(home,3)] = nil }
        }

        board[move.from] = original
        board[move.to] = nil
        if let cap = info.capturedPiece { board[info.capturedSquare] = cap }

        castling = info.prevCastling
        enPassantTarget = info.prevEnPassant
        halfMoveClock = info.prevHalfMove
        turn = turn.opposite
    }
}
