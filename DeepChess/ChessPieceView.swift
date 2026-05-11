import SwiftUI

// MARK: - ChessPieceView

struct ChessPieceView: View {
    let pieceType: PieceType
    let isWhite: Bool
    let size: CGFloat

    var body: some View {
        Image(imageName)
            .resizable()
            .interpolation(.high)
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
    }

    private var imageName: String {
        let color = isWhite ? "white" : "black"
        let piece: String
        switch pieceType {
        case .king:   piece = "king"
        case .queen:  piece = "queen"
        case .rook:   piece = "rook"
        case .bishop: piece = "bishop"
        case .knight: piece = "knight"
        case .pawn:   piece = "pawn"
        }
        return "\(color)_\(piece)"
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 4) {
        HStack(spacing: 0) {
            ForEach([PieceType.king, .queen, .rook, .bishop, .knight, .pawn], id: \.self) { t in
                ChessPieceView(pieceType: t, isWhite: true, size: 56)
                    .background(Color(red: 0.96, green: 0.91, blue: 0.78))
            }
        }
        HStack(spacing: 0) {
            ForEach([PieceType.king, .queen, .rook, .bishop, .knight, .pawn], id: \.self) { t in
                ChessPieceView(pieceType: t, isWhite: false, size: 56)
                    .background(Color(red: 0.53, green: 0.68, blue: 0.73).opacity(0.62))
            }
        }
    }
}
