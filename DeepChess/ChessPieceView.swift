import SwiftUI

// MARK: - ChessPieceView

struct ChessPieceView: View {
    let pieceType: PieceType
    let isWhite: Bool
    let size: CGFloat

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.black.opacity(0.22))
                .frame(width: size * 0.62, height: size * 0.10)
                .offset(y: size * 0.38)
                .blur(radius: size * 0.03)

            pieceShape
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private var pieceShape: some View {
        switch pieceType {
        case .king:   KingShape(isWhite: isWhite, size: size)
        case .queen:  QueenShape(isWhite: isWhite, size: size)
        case .rook:   RookShape(isWhite: isWhite, size: size)
        case .bishop: BishopShape(isWhite: isWhite, size: size)
        case .knight: KnightShape(isWhite: isWhite, size: size)
        case .pawn:   PawnShape(isWhite: isWhite, size: size)
        }
    }
}

// MARK: - Shading Helpers

private func mainShading(isWhite: Bool, size: CGFloat) -> GraphicsContext.Shading {
    if isWhite {
        return .linearGradient(
            Gradient(colors: [
                Color(red: 1.00, green: 0.98, blue: 0.92),
                Color(red: 0.94, green: 0.90, blue: 0.78),
                Color(red: 0.82, green: 0.76, blue: 0.60),
            ]),
            startPoint: CGPoint(x: 0, y: 0),
            endPoint: CGPoint(x: size, y: size)
        )
    } else {
        return .linearGradient(
            Gradient(colors: [
                Color(red: 0.30, green: 0.32, blue: 0.38),
                Color(red: 0.12, green: 0.13, blue: 0.17),
                Color(red: 0.06, green: 0.07, blue: 0.10),
            ]),
            startPoint: CGPoint(x: 0, y: 0),
            endPoint: CGPoint(x: size, y: size)
        )
    }
}

private func highlightShading(isWhite: Bool, size: CGFloat) -> GraphicsContext.Shading {
    if isWhite {
        return .linearGradient(
            Gradient(colors: [
                Color(red: 1.00, green: 0.97, blue: 0.86).opacity(0.90),
                Color.clear,
            ]),
            startPoint: CGPoint(x: 0, y: 0),
            endPoint: CGPoint(x: size * 0.5, y: size * 0.5)
        )
    } else {
        return .linearGradient(
            Gradient(colors: [
                Color(red: 0.55, green: 0.65, blue: 0.80).opacity(0.45),
                Color.clear,
            ]),
            startPoint: CGPoint(x: 0, y: 0),
            endPoint: CGPoint(x: size * 0.5, y: size * 0.5)
        )
    }
}

private func strokeColor(isWhite: Bool) -> Color {
    isWhite
        ? Color(red: 0.55, green: 0.48, blue: 0.28).opacity(0.75)
        : Color(red: 0.05, green: 0.06, blue: 0.10).opacity(0.90)
}

// MARK: - King

private struct KingShape: View {
    let isWhite: Bool
    let size: CGFloat

    var body: some View {
        let s = size
        Canvas { ctx, _ in
            var base = Path()
            base.addRoundedRect(
                in: CGRect(x: s*0.15, y: s*0.74, width: s*0.70, height: s*0.10),
                cornerSize: CGSize(width: s*0.04, height: s*0.04)
            )
            var neck = Path()
            neck.move(to: CGPoint(x: s*0.32, y: s*0.74))
            neck.addLine(to: CGPoint(x: s*0.28, y: s*0.62))
            neck.addLine(to: CGPoint(x: s*0.72, y: s*0.62))
            neck.addLine(to: CGPoint(x: s*0.68, y: s*0.74))
            neck.closeSubpath()
            var crown = Path()
            crown.move(to: CGPoint(x: s*0.28, y: s*0.62))
            crown.addLine(to: CGPoint(x: s*0.22, y: s*0.40))
            crown.addLine(to: CGPoint(x: s*0.22, y: s*0.35))
            crown.addLine(to: CGPoint(x: s*0.28, y: s*0.35))
            crown.addLine(to: CGPoint(x: s*0.28, y: s*0.30))
            crown.addLine(to: CGPoint(x: s*0.35, y: s*0.30))
            crown.addLine(to: CGPoint(x: s*0.35, y: s*0.35))
            crown.addLine(to: CGPoint(x: s*0.44, y: s*0.35))
            crown.addLine(to: CGPoint(x: s*0.44, y: s*0.20))
            crown.addLine(to: CGPoint(x: s*0.38, y: s*0.20))
            crown.addLine(to: CGPoint(x: s*0.38, y: s*0.27))
            crown.addLine(to: CGPoint(x: s*0.44, y: s*0.27))
            crown.addLine(to: CGPoint(x: s*0.44, y: s*0.12))
            crown.addLine(to: CGPoint(x: s*0.56, y: s*0.12))
            crown.addLine(to: CGPoint(x: s*0.56, y: s*0.27))
            crown.addLine(to: CGPoint(x: s*0.62, y: s*0.27))
            crown.addLine(to: CGPoint(x: s*0.62, y: s*0.20))
            crown.addLine(to: CGPoint(x: s*0.56, y: s*0.20))
            crown.addLine(to: CGPoint(x: s*0.56, y: s*0.35))
            crown.addLine(to: CGPoint(x: s*0.65, y: s*0.35))
            crown.addLine(to: CGPoint(x: s*0.65, y: s*0.30))
            crown.addLine(to: CGPoint(x: s*0.72, y: s*0.30))
            crown.addLine(to: CGPoint(x: s*0.72, y: s*0.35))
            crown.addLine(to: CGPoint(x: s*0.78, y: s*0.35))
            crown.addLine(to: CGPoint(x: s*0.78, y: s*0.40))
            crown.addLine(to: CGPoint(x: s*0.72, y: s*0.62))
            crown.closeSubpath()

            let fill = mainShading(isWhite: isWhite, size: s)
            let stroke: GraphicsContext.Shading = .color(strokeColor(isWhite: isWhite))
            ctx.fill(base, with: fill)
            ctx.fill(neck, with: fill)
            ctx.fill(crown, with: fill)
            ctx.stroke(base, with: stroke, lineWidth: s*0.018)
            ctx.stroke(neck, with: stroke, lineWidth: s*0.018)
            ctx.stroke(crown, with: stroke, lineWidth: s*0.018)
            ctx.fill(crown, with: highlightShading(isWhite: isWhite, size: s))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Queen

private struct QueenShape: View {
    let isWhite: Bool
    let size: CGFloat

    var body: some View {
        let s = size
        Canvas { ctx, _ in
            var base = Path()
            base.addRoundedRect(
                in: CGRect(x: s*0.14, y: s*0.74, width: s*0.72, height: s*0.10),
                cornerSize: CGSize(width: s*0.04, height: s*0.04)
            )
            var neck = Path()
            neck.move(to: CGPoint(x: s*0.31, y: s*0.74))
            neck.addLine(to: CGPoint(x: s*0.27, y: s*0.63))
            neck.addLine(to: CGPoint(x: s*0.73, y: s*0.63))
            neck.addLine(to: CGPoint(x: s*0.69, y: s*0.74))
            neck.closeSubpath()

            var crown = Path()
            crown.move(to: CGPoint(x: s*0.27, y: s*0.63))
            crown.addLine(to: CGPoint(x: s*0.20, y: s*0.44))
            crown.addLine(to: CGPoint(x: s*0.20, y: s*0.38))
            crown.addLine(to: CGPoint(x: s*0.22, y: s*0.30))
            crown.addQuadCurve(to: CGPoint(x: s*0.28, y: s*0.24), control: CGPoint(x: s*0.18, y: s*0.22))
            crown.addQuadCurve(to: CGPoint(x: s*0.30, y: s*0.30), control: CGPoint(x: s*0.34, y: s*0.22))
            crown.addLine(to: CGPoint(x: s*0.32, y: s*0.38))
            crown.addLine(to: CGPoint(x: s*0.34, y: s*0.30))
            crown.addQuadCurve(to: CGPoint(x: s*0.40, y: s*0.22), control: CGPoint(x: s*0.30, y: s*0.16))
            crown.addQuadCurve(to: CGPoint(x: s*0.44, y: s*0.30), control: CGPoint(x: s*0.48, y: s*0.16))
            crown.addLine(to: CGPoint(x: s*0.44, y: s*0.36))
            crown.addLine(to: CGPoint(x: s*0.46, y: s*0.26))
            crown.addQuadCurve(to: CGPoint(x: s*0.50, y: s*0.14), control: CGPoint(x: s*0.40, y: s*0.11))
            crown.addQuadCurve(to: CGPoint(x: s*0.56, y: s*0.26), control: CGPoint(x: s*0.62, y: s*0.11))
            crown.addLine(to: CGPoint(x: s*0.56, y: s*0.36))
            crown.addLine(to: CGPoint(x: s*0.58, y: s*0.30))
            crown.addQuadCurve(to: CGPoint(x: s*0.62, y: s*0.22), control: CGPoint(x: s*0.54, y: s*0.16))
            crown.addQuadCurve(to: CGPoint(x: s*0.68, y: s*0.30), control: CGPoint(x: s*0.72, y: s*0.16))
            crown.addLine(to: CGPoint(x: s*0.70, y: s*0.38))
            crown.addLine(to: CGPoint(x: s*0.72, y: s*0.30))
            crown.addQuadCurve(to: CGPoint(x: s*0.76, y: s*0.24), control: CGPoint(x: s*0.68, y: s*0.18))
            crown.addQuadCurve(to: CGPoint(x: s*0.80, y: s*0.30), control: CGPoint(x: s*0.84, y: s*0.18))
            crown.addLine(to: CGPoint(x: s*0.80, y: s*0.38))
            crown.addLine(to: CGPoint(x: s*0.80, y: s*0.44))
            crown.addLine(to: CGPoint(x: s*0.73, y: s*0.63))
            crown.closeSubpath()

            let fill = mainShading(isWhite: isWhite, size: s)
            let stroke: GraphicsContext.Shading = .color(strokeColor(isWhite: isWhite))
            ctx.fill(base, with: fill)
            ctx.fill(neck, with: fill)
            ctx.fill(crown, with: fill)
            ctx.stroke(base, with: stroke, lineWidth: s*0.018)
            ctx.stroke(neck, with: stroke, lineWidth: s*0.018)
            ctx.stroke(crown, with: stroke, lineWidth: s*0.018)
            ctx.fill(crown, with: highlightShading(isWhite: isWhite, size: s))

            let orbs: [CGPoint] = [
                CGPoint(x: s*0.25, y: s*0.24),
                CGPoint(x: s*0.40, y: s*0.20),
                CGPoint(x: s*0.50, y: s*0.12),
                CGPoint(x: s*0.62, y: s*0.20),
                CGPoint(x: s*0.77, y: s*0.24),
            ]
            let r = s * 0.035
            for orb in orbs {
                var dot = Path()
                dot.addEllipse(in: CGRect(x: orb.x - r, y: orb.y - r, width: r*2, height: r*2))
                ctx.fill(dot, with: fill)
                ctx.stroke(dot, with: stroke, lineWidth: s*0.016)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Rook

private struct RookShape: View {
    let isWhite: Bool
    let size: CGFloat

    var body: some View {
        let s = size
        Canvas { ctx, _ in
            var base = Path()
            base.addRoundedRect(
                in: CGRect(x: s*0.15, y: s*0.74, width: s*0.70, height: s*0.10),
                cornerSize: CGSize(width: s*0.04, height: s*0.04)
            )
            var tower = Path()
            tower.move(to: CGPoint(x: s*0.22, y: s*0.74))
            tower.addLine(to: CGPoint(x: s*0.20, y: s*0.42))
            tower.addLine(to: CGPoint(x: s*0.80, y: s*0.42))
            tower.addLine(to: CGPoint(x: s*0.78, y: s*0.74))
            tower.closeSubpath()

            var battlements = Path()
            battlements.addRect(CGRect(x: s*0.20, y: s*0.30, width: s*0.17, height: s*0.13))
            battlements.addRect(CGRect(x: s*0.415, y: s*0.30, width: s*0.17, height: s*0.13))
            battlements.addRect(CGRect(x: s*0.63, y: s*0.30, width: s*0.17, height: s*0.13))
            battlements.addRect(CGRect(x: s*0.20, y: s*0.41, width: s*0.60, height: s*0.04))

            let fill = mainShading(isWhite: isWhite, size: s)
            let stroke: GraphicsContext.Shading = .color(strokeColor(isWhite: isWhite))
            ctx.fill(base, with: fill)
            ctx.fill(tower, with: fill)
            ctx.fill(battlements, with: fill)
            ctx.stroke(base, with: stroke, lineWidth: s*0.018)
            ctx.stroke(tower, with: stroke, lineWidth: s*0.018)
            ctx.stroke(battlements, with: stroke, lineWidth: s*0.018)
            ctx.fill(tower, with: highlightShading(isWhite: isWhite, size: s))

            var slit = Path()
            slit.addRoundedRect(
                in: CGRect(x: s*0.44, y: s*0.51, width: s*0.12, height: s*0.15),
                cornerSize: CGSize(width: s*0.03, height: s*0.04)
            )
            let slitColor: Color = isWhite
                ? Color(red: 0.50, green: 0.40, blue: 0.20).opacity(0.35)
                : Color(red: 0.04, green: 0.04, blue: 0.06).opacity(0.70)
            ctx.fill(slit, with: .color(slitColor))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Bishop

private struct BishopShape: View {
    let isWhite: Bool
    let size: CGFloat

    var body: some View {
        let s = size
        Canvas { ctx, _ in
            var base = Path()
            base.addRoundedRect(
                in: CGRect(x: s*0.16, y: s*0.74, width: s*0.68, height: s*0.10),
                cornerSize: CGSize(width: s*0.04, height: s*0.04)
            )
            var collar = Path()
            collar.addRoundedRect(
                in: CGRect(x: s*0.28, y: s*0.65, width: s*0.44, height: s*0.10),
                cornerSize: CGSize(width: s*0.05, height: s*0.05)
            )
            var miter = Path()
            miter.move(to: CGPoint(x: s*0.28, y: s*0.65))
            miter.addQuadCurve(to: CGPoint(x: s*0.32, y: s*0.44), control: CGPoint(x: s*0.20, y: s*0.56))
            miter.addLine(to: CGPoint(x: s*0.38, y: s*0.36))
            miter.addQuadCurve(to: CGPoint(x: s*0.50, y: s*0.12), control: CGPoint(x: s*0.36, y: s*0.24))
            miter.addQuadCurve(to: CGPoint(x: s*0.62, y: s*0.36), control: CGPoint(x: s*0.64, y: s*0.24))
            miter.addLine(to: CGPoint(x: s*0.68, y: s*0.44))
            miter.addQuadCurve(to: CGPoint(x: s*0.72, y: s*0.65), control: CGPoint(x: s*0.80, y: s*0.56))
            miter.closeSubpath()

            let orbR = s * 0.042
            var orb = Path()
            orb.addEllipse(in: CGRect(x: s*0.50 - orbR, y: s*0.09, width: orbR*2, height: orbR*2))

            let fill = mainShading(isWhite: isWhite, size: s)
            let stroke: GraphicsContext.Shading = .color(strokeColor(isWhite: isWhite))
            ctx.fill(base, with: fill)
            ctx.fill(collar, with: fill)
            ctx.fill(miter, with: fill)
            ctx.fill(orb, with: fill)
            ctx.stroke(base, with: stroke, lineWidth: s*0.018)
            ctx.stroke(collar, with: stroke, lineWidth: s*0.018)
            ctx.stroke(miter, with: stroke, lineWidth: s*0.018)
            ctx.stroke(orb, with: stroke, lineWidth: s*0.018)
            ctx.fill(miter, with: highlightShading(isWhite: isWhite, size: s))

            var slitPath = Path()
            slitPath.move(to: CGPoint(x: s*0.40, y: s*0.50))
            slitPath.addLine(to: CGPoint(x: s*0.60, y: s*0.50))
            ctx.stroke(slitPath, with: .color(strokeColor(isWhite: isWhite).opacity(0.55)), lineWidth: s*0.020)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Knight

private struct KnightShape: View {
    let isWhite: Bool
    let size: CGFloat

    var body: some View {
        let s = size
        Canvas { ctx, _ in
            var base = Path()
            base.addRoundedRect(
                in: CGRect(x: s*0.14, y: s*0.74, width: s*0.72, height: s*0.10),
                cornerSize: CGSize(width: s*0.04, height: s*0.04)
            )
            var bodyPath = Path()
            bodyPath.move(to: CGPoint(x: s*0.28, y: s*0.74))
            bodyPath.addLine(to: CGPoint(x: s*0.26, y: s*0.58))
            bodyPath.addLine(to: CGPoint(x: s*0.30, y: s*0.50))
            bodyPath.addLine(to: CGPoint(x: s*0.70, y: s*0.50))
            bodyPath.addLine(to: CGPoint(x: s*0.72, y: s*0.74))
            bodyPath.closeSubpath()

            var head = Path()
            head.move(to: CGPoint(x: s*0.30, y: s*0.50))
            head.addLine(to: CGPoint(x: s*0.26, y: s*0.44))
            head.addQuadCurve(to: CGPoint(x: s*0.30, y: s*0.36), control: CGPoint(x: s*0.20, y: s*0.40))
            head.addLine(to: CGPoint(x: s*0.38, y: s*0.30))
            head.addQuadCurve(to: CGPoint(x: s*0.50, y: s*0.26), control: CGPoint(x: s*0.38, y: s*0.22))
            head.addQuadCurve(to: CGPoint(x: s*0.52, y: s*0.24), control: CGPoint(x: s*0.52, y: s*0.27))
            head.addLine(to: CGPoint(x: s*0.50, y: s*0.20))
            head.addQuadCurve(to: CGPoint(x: s*0.56, y: s*0.15), control: CGPoint(x: s*0.48, y: s*0.14))
            head.addLine(to: CGPoint(x: s*0.60, y: s*0.11))
            head.addLine(to: CGPoint(x: s*0.66, y: s*0.15))
            head.addQuadCurve(to: CGPoint(x: s*0.70, y: s*0.24), control: CGPoint(x: s*0.74, y: s*0.17))
            head.addQuadCurve(to: CGPoint(x: s*0.68, y: s*0.38), control: CGPoint(x: s*0.76, y: s*0.30))
            head.addLine(to: CGPoint(x: s*0.70, y: s*0.50))
            head.closeSubpath()

            let fill = mainShading(isWhite: isWhite, size: s)
            let stroke: GraphicsContext.Shading = .color(strokeColor(isWhite: isWhite))
            ctx.fill(base, with: fill)
            ctx.fill(bodyPath, with: fill)
            ctx.fill(head, with: fill)
            ctx.stroke(base, with: stroke, lineWidth: s*0.018)
            ctx.stroke(bodyPath, with: stroke, lineWidth: s*0.018)
            ctx.stroke(head, with: stroke, lineWidth: s*0.020)
            ctx.fill(head, with: highlightShading(isWhite: isWhite, size: s))

            let eyeR = s * 0.025
            var eye = Path()
            eye.addEllipse(in: CGRect(x: s*0.48 - eyeR, y: s*0.245 - eyeR, width: eyeR*2, height: eyeR*2))
            let eyeColor: Color = isWhite
                ? Color(red: 0.22, green: 0.18, blue: 0.10)
                : Color(red: 0.70, green: 0.75, blue: 0.85)
            ctx.fill(eye, with: .color(eyeColor))

            var mane = Path()
            mane.move(to: CGPoint(x: s*0.56, y: s*0.15))
            mane.addQuadCurve(to: CGPoint(x: s*0.64, y: s*0.32), control: CGPoint(x: s*0.70, y: s*0.22))
            let maneColor: Color = isWhite
                ? Color(red: 0.55, green: 0.45, blue: 0.22).opacity(0.40)
                : Color(red: 0.40, green: 0.50, blue: 0.65).opacity(0.40)
            ctx.stroke(mane, with: .color(maneColor), lineWidth: s*0.018)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Pawn

private struct PawnShape: View {
    let isWhite: Bool
    let size: CGFloat

    var body: some View {
        let s = size
        Canvas { ctx, _ in
            var base = Path()
            base.addRoundedRect(
                in: CGRect(x: s*0.18, y: s*0.74, width: s*0.64, height: s*0.10),
                cornerSize: CGSize(width: s*0.04, height: s*0.04)
            )
            var stem = Path()
            stem.move(to: CGPoint(x: s*0.30, y: s*0.74))
            stem.addLine(to: CGPoint(x: s*0.33, y: s*0.62))
            stem.addLine(to: CGPoint(x: s*0.38, y: s*0.56))
            stem.addLine(to: CGPoint(x: s*0.62, y: s*0.56))
            stem.addLine(to: CGPoint(x: s*0.67, y: s*0.62))
            stem.addLine(to: CGPoint(x: s*0.70, y: s*0.74))
            stem.closeSubpath()

            let headCX = s * 0.50
            let headCY = s * 0.42
            let headR  = s * 0.155
            var headPath = Path()
            headPath.addEllipse(in: CGRect(
                x: headCX - headR, y: headCY - headR,
                width: headR * 2, height: headR * 2
            ))

            let fill = mainShading(isWhite: isWhite, size: s)
            let stroke: GraphicsContext.Shading = .color(strokeColor(isWhite: isWhite))
            ctx.fill(base, with: fill)
            ctx.fill(stem, with: fill)
            ctx.fill(headPath, with: fill)
            ctx.stroke(base, with: stroke, lineWidth: s*0.018)
            ctx.stroke(stem, with: stroke, lineWidth: s*0.018)
            ctx.stroke(headPath, with: stroke, lineWidth: s*0.020)
            ctx.fill(headPath, with: highlightShading(isWhite: isWhite, size: s))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
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
