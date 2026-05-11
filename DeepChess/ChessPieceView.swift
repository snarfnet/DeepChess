import SwiftUI

// MARK: - ChessPieceView

struct ChessPieceView: View {
    let pieceType: PieceType
    let isWhite: Bool
    let size: CGFloat

    var body: some View {
        ZStack {
            // Drop shadow ellipse beneath piece
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

// MARK: - Gradient Helpers

private func whiteGradient(start: UnitPoint = .topLeading, end: UnitPoint = .bottomTrailing) -> LinearGradient {
    LinearGradient(
        colors: [
            Color(red: 1.00, green: 0.98, blue: 0.92),
            Color(red: 0.94, green: 0.90, blue: 0.78),
            Color(red: 0.82, green: 0.76, blue: 0.60),
        ],
        startPoint: start,
        endPoint: end
    )
}

private func whiteHighlight() -> LinearGradient {
    LinearGradient(
        colors: [
            Color(red: 1.00, green: 0.97, blue: 0.86).opacity(0.90),
            Color.clear,
        ],
        startPoint: .topLeading,
        endPoint: .center
    )
}

private func blackGradient(start: UnitPoint = .topLeading, end: UnitPoint = .bottomTrailing) -> LinearGradient {
    LinearGradient(
        colors: [
            Color(red: 0.30, green: 0.32, blue: 0.38),
            Color(red: 0.12, green: 0.13, blue: 0.17),
            Color(red: 0.06, green: 0.07, blue: 0.10),
        ],
        startPoint: start,
        endPoint: end
    )
}

private func blackHighlight() -> LinearGradient {
    LinearGradient(
        colors: [
            Color(red: 0.55, green: 0.65, blue: 0.80).opacity(0.45),
            Color.clear,
        ],
        startPoint: .topLeading,
        endPoint: .center
    )
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
            // Base
            var base = Path()
            base.addRoundedRect(
                in: CGRect(x: s*0.15, y: s*0.74, width: s*0.70, height: s*0.10),
                cornerSize: CGSize(width: s*0.04, height: s*0.04)
            )
            // Neck
            var neck = Path()
            neck.move(to: CGPoint(x: s*0.32, y: s*0.74))
            neck.addLine(to: CGPoint(x: s*0.28, y: s*0.62))
            neck.addLine(to: CGPoint(x: s*0.72, y: s*0.62))
            neck.addLine(to: CGPoint(x: s*0.68, y: s*0.74))
            neck.closeSubpath()
            // Crown body
            var crown = Path()
            crown.move(to: CGPoint(x: s*0.28, y: s*0.62))
            crown.addLine(to: CGPoint(x: s*0.22, y: s*0.40))
            // Left battlement notch
            crown.addLine(to: CGPoint(x: s*0.22, y: s*0.35))
            crown.addLine(to: CGPoint(x: s*0.28, y: s*0.35))
            crown.addLine(to: CGPoint(x: s*0.28, y: s*0.30))
            // Inner notch
            crown.addLine(to: CGPoint(x: s*0.35, y: s*0.30))
            crown.addLine(to: CGPoint(x: s*0.35, y: s*0.35))
            // Center stem base
            crown.addLine(to: CGPoint(x: s*0.44, y: s*0.35))
            // Cross vertical
            crown.addLine(to: CGPoint(x: s*0.44, y: s*0.20))
            // Cross left arm
            crown.addLine(to: CGPoint(x: s*0.38, y: s*0.20))
            crown.addLine(to: CGPoint(x: s*0.38, y: s*0.27))
            crown.addLine(to: CGPoint(x: s*0.44, y: s*0.27))
            // Cross top
            crown.addLine(to: CGPoint(x: s*0.44, y: s*0.12))
            crown.addLine(to: CGPoint(x: s*0.56, y: s*0.12))
            crown.addLine(to: CGPoint(x: s*0.56, y: s*0.27))
            // Cross right arm
            crown.addLine(to: CGPoint(x: s*0.62, y: s*0.27))
            crown.addLine(to: CGPoint(x: s*0.62, y: s*0.20))
            crown.addLine(to: CGPoint(x: s*0.56, y: s*0.20))
            crown.addLine(to: CGPoint(x: s*0.56, y: s*0.35))
            // Right battlement
            crown.addLine(to: CGPoint(x: s*0.65, y: s*0.35))
            crown.addLine(to: CGPoint(x: s*0.65, y: s*0.30))
            crown.addLine(to: CGPoint(x: s*0.72, y: s*0.30))
            crown.addLine(to: CGPoint(x: s*0.72, y: s*0.35))
            crown.addLine(to: CGPoint(x: s*0.78, y: s*0.35))
            crown.addLine(to: CGPoint(x: s*0.78, y: s*0.40))
            crown.addLine(to: CGPoint(x: s*0.72, y: s*0.62))
            crown.closeSubpath()

            let fill = isWhite ? AnyShapeStyle(whiteGradient()) : AnyShapeStyle(blackGradient())
            ctx.fill(base, with: fill)
            ctx.fill(neck, with: fill)
            ctx.fill(crown, with: fill)
            ctx.stroke(base, with: .color(strokeColor(isWhite: isWhite)), lineWidth: s*0.018)
            ctx.stroke(neck, with: .color(strokeColor(isWhite: isWhite)), lineWidth: s*0.018)
            ctx.stroke(crown, with: .color(strokeColor(isWhite: isWhite)), lineWidth: s*0.018)

            let hilite = isWhite ? AnyShapeStyle(whiteHighlight()) : AnyShapeStyle(blackHighlight())
            ctx.fill(crown, with: hilite)
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

            // Queen crown body with 5 orb-tipped spikes
            var crown = Path()
            crown.move(to: CGPoint(x: s*0.27, y: s*0.63))
            crown.addLine(to: CGPoint(x: s*0.20, y: s*0.44))
            crown.addLine(to: CGPoint(x: s*0.20, y: s*0.38))

            // Spike 1 (far left)
            crown.addLine(to: CGPoint(x: s*0.22, y: s*0.30))
            crown.addQuadCurve(to: CGPoint(x: s*0.28, y: s*0.24), control: CGPoint(x: s*0.18, y: s*0.22))
            crown.addQuadCurve(to: CGPoint(x: s*0.30, y: s*0.30), control: CGPoint(x: s*0.34, y: s*0.22))
            crown.addLine(to: CGPoint(x: s*0.32, y: s*0.38))

            // Spike 2 (center-left)
            crown.addLine(to: CGPoint(x: s*0.34, y: s*0.30))
            crown.addQuadCurve(to: CGPoint(x: s*0.40, y: s*0.22), control: CGPoint(x: s*0.30, y: s*0.16))
            crown.addQuadCurve(to: CGPoint(x: s*0.44, y: s*0.30), control: CGPoint(x: s*0.48, y: s*0.16))
            crown.addLine(to: CGPoint(x: s*0.44, y: s*0.36))

            // Spike 3 (center / tallest)
            crown.addLine(to: CGPoint(x: s*0.46, y: s*0.26))
            crown.addQuadCurve(to: CGPoint(x: s*0.50, y: s*0.14), control: CGPoint(x: s*0.40, y: s*0.11))
            crown.addQuadCurve(to: CGPoint(x: s*0.56, y: s*0.26), control: CGPoint(x: s*0.62, y: s*0.11))
            crown.addLine(to: CGPoint(x: s*0.56, y: s*0.36))

            // Spike 4 (center-right)
            crown.addLine(to: CGPoint(x: s*0.58, y: s*0.30))
            crown.addQuadCurve(to: CGPoint(x: s*0.62, y: s*0.22), control: CGPoint(x: s*0.54, y: s*0.16))
            crown.addQuadCurve(to: CGPoint(x: s*0.68, y: s*0.30), control: CGPoint(x: s*0.72, y: s*0.16))
            crown.addLine(to: CGPoint(x: s*0.70, y: s*0.38))

            // Spike 5 (far right)
            crown.addLine(to: CGPoint(x: s*0.72, y: s*0.30))
            crown.addQuadCurve(to: CGPoint(x: s*0.76, y: s*0.24), control: CGPoint(x: s*0.68, y: s*0.18))
            crown.addQuadCurve(to: CGPoint(x: s*0.80, y: s*0.30), control: CGPoint(x: s*0.84, y: s*0.18))
            crown.addLine(to: CGPoint(x: s*0.80, y: s*0.38))
            crown.addLine(to: CGPoint(x: s*0.80, y: s*0.44))
            crown.addLine(to: CGPoint(x: s*0.73, y: s*0.63))
            crown.closeSubpath()

            let fill = isWhite ? AnyShapeStyle(whiteGradient()) : AnyShapeStyle(blackGradient())
            ctx.fill(base, with: fill)
            ctx.fill(neck, with: fill)
            ctx.fill(crown, with: fill)
            ctx.stroke(base, with: .color(strokeColor(isWhite: isWhite)), lineWidth: s*0.018)
            ctx.stroke(neck, with: .color(strokeColor(isWhite: isWhite)), lineWidth: s*0.018)
            ctx.stroke(crown, with: .color(strokeColor(isWhite: isWhite)), lineWidth: s*0.018)

            let hilite = isWhite ? AnyShapeStyle(whiteHighlight()) : AnyShapeStyle(blackHighlight())
            ctx.fill(crown, with: hilite)

            // Orb dots on spike tips
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
                ctx.stroke(dot, with: .color(strokeColor(isWhite: isWhite)), lineWidth: s*0.016)
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

            // Tower body (trapezoid)
            var tower = Path()
            tower.move(to: CGPoint(x: s*0.22, y: s*0.74))
            tower.addLine(to: CGPoint(x: s*0.20, y: s*0.42))
            tower.addLine(to: CGPoint(x: s*0.80, y: s*0.42))
            tower.addLine(to: CGPoint(x: s*0.78, y: s*0.74))
            tower.closeSubpath()

            // Battlements (3 merlons with 2 gaps)
            var battlements = Path()
            // Left merlon
            battlements.addRect(CGRect(x: s*0.20, y: s*0.30, width: s*0.17, height: s*0.13))
            // Center merlon
            battlements.addRect(CGRect(x: s*0.415, y: s*0.30, width: s*0.17, height: s*0.13))
            // Right merlon
            battlements.addRect(CGRect(x: s*0.63, y: s*0.30, width: s*0.17, height: s*0.13))
            // Battlement base platform
            battlements.addRect(CGRect(x: s*0.20, y: s*0.41, width: s*0.60, height: s*0.04))

            let fill = isWhite ? AnyShapeStyle(whiteGradient()) : AnyShapeStyle(blackGradient())
            ctx.fill(base, with: fill)
            ctx.fill(tower, with: fill)
            ctx.fill(battlements, with: fill)
            ctx.stroke(base, with: .color(strokeColor(isWhite: isWhite)), lineWidth: s*0.018)
            ctx.stroke(tower, with: .color(strokeColor(isWhite: isWhite)), lineWidth: s*0.018)
            ctx.stroke(battlements, with: .color(strokeColor(isWhite: isWhite)), lineWidth: s*0.018)

            let hilite = isWhite ? AnyShapeStyle(whiteHighlight()) : AnyShapeStyle(blackHighlight())
            ctx.fill(tower, with: hilite)

            // Interior window slit
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

            // Neck collar
            var collar = Path()
            collar.addRoundedRect(
                in: CGRect(x: s*0.28, y: s*0.65, width: s*0.44, height: s*0.10),
                cornerSize: CGSize(width: s*0.05, height: s*0.05)
            )

            // Miter body — tall pointed hat shape
            var miter = Path()
            miter.move(to: CGPoint(x: s*0.28, y: s*0.65))
            miter.addQuadCurve(to: CGPoint(x: s*0.32, y: s*0.44), control: CGPoint(x: s*0.20, y: s*0.56))
            miter.addLine(to: CGPoint(x: s*0.38, y: s*0.36))
            miter.addQuadCurve(to: CGPoint(x: s*0.50, y: s*0.12), control: CGPoint(x: s*0.36, y: s*0.24))
            miter.addQuadCurve(to: CGPoint(x: s*0.62, y: s*0.36), control: CGPoint(x: s*0.64, y: s*0.24))
            miter.addLine(to: CGPoint(x: s*0.68, y: s*0.44))
            miter.addQuadCurve(to: CGPoint(x: s*0.72, y: s*0.65), control: CGPoint(x: s*0.80, y: s*0.56))
            miter.closeSubpath()

            // Finial orb at top
            let orbR = s * 0.042
            var orb = Path()
            orb.addEllipse(in: CGRect(x: s*0.50 - orbR, y: s*0.09, width: orbR*2, height: orbR*2))

            let fill = isWhite ? AnyShapeStyle(whiteGradient()) : AnyShapeStyle(blackGradient())
            ctx.fill(base, with: fill)
            ctx.fill(collar, with: fill)
            ctx.fill(miter, with: fill)
            ctx.fill(orb, with: fill)
            ctx.stroke(base, with: .color(strokeColor(isWhite: isWhite)), lineWidth: s*0.018)
            ctx.stroke(collar, with: .color(strokeColor(isWhite: isWhite)), lineWidth: s*0.018)
            ctx.stroke(miter, with: .color(strokeColor(isWhite: isWhite)), lineWidth: s*0.018)
            ctx.stroke(orb, with: .color(strokeColor(isWhite: isWhite)), lineWidth: s*0.018)

            let hilite = isWhite ? AnyShapeStyle(whiteHighlight()) : AnyShapeStyle(blackHighlight())
            ctx.fill(miter, with: hilite)

            // Diagonal slit
            var slit = Path()
            slit.move(to: CGPoint(x: s*0.40, y: s*0.50))
            slit.addLine(to: CGPoint(x: s*0.60, y: s*0.50))
            ctx.stroke(slit, with: .color(strokeColor(isWhite: isWhite).opacity(0.55)), lineWidth: s*0.020)
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

            // Neck / body block
            var body = Path()
            body.move(to: CGPoint(x: s*0.28, y: s*0.74))
            body.addLine(to: CGPoint(x: s*0.26, y: s*0.58))
            body.addLine(to: CGPoint(x: s*0.30, y: s*0.50))
            body.addLine(to: CGPoint(x: s*0.70, y: s*0.50))
            body.addLine(to: CGPoint(x: s*0.72, y: s*0.74))
            body.closeSubpath()

            // Horse head silhouette
            var head = Path()
            // Chest / jaw base
            head.move(to: CGPoint(x: s*0.30, y: s*0.50))
            head.addLine(to: CGPoint(x: s*0.26, y: s*0.44))
            // Jaw curve
            head.addQuadCurve(to: CGPoint(x: s*0.30, y: s*0.36), control: CGPoint(x: s*0.20, y: s*0.40))
            // Muzzle
            head.addLine(to: CGPoint(x: s*0.38, y: s*0.30))
            head.addQuadCurve(to: CGPoint(x: s*0.50, y: s*0.26), control: CGPoint(x: s*0.38, y: s*0.22))
            // Nostril bump
            head.addQuadCurve(to: CGPoint(x: s*0.52, y: s*0.24), control: CGPoint(x: s*0.52, y: s*0.27))
            // Bridge of nose up to forehead
            head.addLine(to: CGPoint(x: s*0.50, y: s*0.20))
            head.addQuadCurve(to: CGPoint(x: s*0.56, y: s*0.15), control: CGPoint(x: s*0.48, y: s*0.14))
            // Ear
            head.addLine(to: CGPoint(x: s*0.60, y: s*0.11))
            head.addLine(to: CGPoint(x: s*0.66, y: s*0.15))
            // Poll / back of head
            head.addQuadCurve(to: CGPoint(x: s*0.70, y: s*0.24), control: CGPoint(x: s*0.74, y: s*0.17))
            // Crest / neck back
            head.addQuadCurve(to: CGPoint(x: s*0.68, y: s*0.38), control: CGPoint(x: s*0.76, y: s*0.30))
            head.addLine(to: CGPoint(x: s*0.70, y: s*0.50))
            head.closeSubpath()

            let fill = isWhite ? AnyShapeStyle(whiteGradient()) : AnyShapeStyle(blackGradient())
            ctx.fill(base, with: fill)
            ctx.fill(body, with: fill)
            ctx.fill(head, with: fill)
            ctx.stroke(base, with: .color(strokeColor(isWhite: isWhite)), lineWidth: s*0.018)
            ctx.stroke(body, with: .color(strokeColor(isWhite: isWhite)), lineWidth: s*0.018)
            ctx.stroke(head, with: .color(strokeColor(isWhite: isWhite)), lineWidth: s*0.020)

            let hilite = isWhite ? AnyShapeStyle(whiteHighlight()) : AnyShapeStyle(blackHighlight())
            ctx.fill(head, with: hilite)

            // Eye
            let eyeR = s * 0.025
            var eye = Path()
            eye.addEllipse(in: CGRect(x: s*0.48 - eyeR, y: s*0.245 - eyeR, width: eyeR*2, height: eyeR*2))
            let eyeColor: Color = isWhite
                ? Color(red: 0.22, green: 0.18, blue: 0.10)
                : Color(red: 0.70, green: 0.75, blue: 0.85)
            ctx.fill(eye, with: .color(eyeColor))

            // Mane line detail
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

            // Tapered body stem
            var stem = Path()
            stem.move(to: CGPoint(x: s*0.30, y: s*0.74))
            stem.addLine(to: CGPoint(x: s*0.33, y: s*0.62))
            stem.addLine(to: CGPoint(x: s*0.38, y: s*0.56))
            // Widen to collar
            stem.addLine(to: CGPoint(x: s*0.62, y: s*0.56))
            stem.addLine(to: CGPoint(x: s*0.67, y: s*0.62))
            stem.addLine(to: CGPoint(x: s*0.70, y: s*0.74))
            stem.closeSubpath()

            // Round head — circle approximated with bezier
            let headCX = s * 0.50
            let headCY = s * 0.42
            let headR  = s * 0.155
            var headPath = Path()
            headPath.addEllipse(in: CGRect(
                x: headCX - headR, y: headCY - headR,
                width: headR * 2, height: headR * 2
            ))

            let fill = isWhite ? AnyShapeStyle(whiteGradient()) : AnyShapeStyle(blackGradient())
            ctx.fill(base, with: fill)
            ctx.fill(stem, with: fill)
            ctx.fill(headPath, with: fill)
            ctx.stroke(base, with: .color(strokeColor(isWhite: isWhite)), lineWidth: s*0.018)
            ctx.stroke(stem, with: .color(strokeColor(isWhite: isWhite)), lineWidth: s*0.018)
            ctx.stroke(headPath, with: .color(strokeColor(isWhite: isWhite)), lineWidth: s*0.020)

            // Highlight on head
            let hilite = isWhite ? AnyShapeStyle(whiteHighlight()) : AnyShapeStyle(blackHighlight())
            ctx.fill(headPath, with: hilite)
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
