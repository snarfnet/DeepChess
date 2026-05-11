import SwiftUI

// MARK: - ChessPieceView

struct ChessPieceView: View {
    let pieceType: PieceType
    let isWhite: Bool
    let size: CGFloat

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.black.opacity(0.28))
                .frame(width: size * 0.60, height: size * 0.12)
                .offset(y: size * 0.38)
                .blur(radius: size * 0.04)

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

// MARK: - Wood Shading Helpers

private func woodFill(isWhite: Bool, size: CGFloat) -> GraphicsContext.Shading {
    if isWhite {
        return .linearGradient(
            Gradient(colors: [
                Color(red: 0.95, green: 0.82, blue: 0.58),
                Color(red: 0.88, green: 0.72, blue: 0.48),
                Color(red: 0.78, green: 0.60, blue: 0.34),
                Color(red: 0.85, green: 0.70, blue: 0.44),
            ]),
            startPoint: CGPoint(x: size * 0.1, y: 0),
            endPoint: CGPoint(x: size * 0.9, y: size)
        )
    } else {
        return .linearGradient(
            Gradient(colors: [
                Color(red: 0.38, green: 0.22, blue: 0.12),
                Color(red: 0.28, green: 0.15, blue: 0.08),
                Color(red: 0.18, green: 0.10, blue: 0.05),
                Color(red: 0.24, green: 0.14, blue: 0.07),
            ]),
            startPoint: CGPoint(x: size * 0.1, y: 0),
            endPoint: CGPoint(x: size * 0.9, y: size)
        )
    }
}

private func woodHighlight(isWhite: Bool, size: CGFloat) -> GraphicsContext.Shading {
    if isWhite {
        return .linearGradient(
            Gradient(colors: [
                Color(red: 1.00, green: 0.95, blue: 0.80).opacity(0.70),
                Color(red: 1.00, green: 0.90, blue: 0.68).opacity(0.25),
                Color.clear,
            ]),
            startPoint: CGPoint(x: size * 0.15, y: 0),
            endPoint: CGPoint(x: size * 0.6, y: size * 0.6)
        )
    } else {
        return .linearGradient(
            Gradient(colors: [
                Color(red: 0.60, green: 0.40, blue: 0.25).opacity(0.55),
                Color(red: 0.45, green: 0.28, blue: 0.16).opacity(0.20),
                Color.clear,
            ]),
            startPoint: CGPoint(x: size * 0.15, y: 0),
            endPoint: CGPoint(x: size * 0.6, y: size * 0.6)
        )
    }
}

private func woodEdge(isWhite: Bool) -> Color {
    isWhite
        ? Color(red: 0.52, green: 0.36, blue: 0.16).opacity(0.85)
        : Color(red: 0.10, green: 0.06, blue: 0.02).opacity(0.92)
}

private func woodRimLight(isWhite: Bool, size: CGFloat) -> GraphicsContext.Shading {
    if isWhite {
        return .linearGradient(
            Gradient(colors: [
                Color(red: 1.00, green: 0.92, blue: 0.72).opacity(0.50),
                Color.clear,
            ]),
            startPoint: CGPoint(x: 0, y: size * 0.2),
            endPoint: CGPoint(x: size * 0.3, y: size * 0.5)
        )
    } else {
        return .linearGradient(
            Gradient(colors: [
                Color(red: 0.55, green: 0.35, blue: 0.22).opacity(0.40),
                Color.clear,
            ]),
            startPoint: CGPoint(x: 0, y: size * 0.2),
            endPoint: CGPoint(x: size * 0.3, y: size * 0.5)
        )
    }
}

private func drawWoodGrain(ctx: inout GraphicsContext, size: CGFloat, isWhite: Bool) {
    let grainColor: Color = isWhite
        ? Color(red: 0.62, green: 0.46, blue: 0.24).opacity(0.12)
        : Color(red: 0.08, green: 0.04, blue: 0.01).opacity(0.20)

    for i in stride(from: CGFloat(0.18), through: 0.82, by: 0.08) {
        var grain = Path()
        let y = size * i
        grain.move(to: CGPoint(x: size * 0.22, y: y))
        grain.addQuadCurve(
            to: CGPoint(x: size * 0.78, y: y + size * 0.02),
            control: CGPoint(x: size * 0.50, y: y - size * 0.025)
        )
        ctx.stroke(grain, with: .color(grainColor), lineWidth: size * 0.008)
    }
}

private func drawBase(ctx: inout GraphicsContext, s: CGFloat, isWhite: Bool) {
    var base = Path()
    base.addRoundedRect(
        in: CGRect(x: s*0.13, y: s*0.74, width: s*0.74, height: s*0.12),
        cornerSize: CGSize(width: s*0.05, height: s*0.05)
    )
    ctx.fill(base, with: woodFill(isWhite: isWhite, size: s))
    ctx.stroke(base, with: .color(woodEdge(isWhite: isWhite)), lineWidth: s*0.022)
    ctx.fill(base, with: woodHighlight(isWhite: isWhite, size: s))
}

// MARK: - King

private struct KingShape: View {
    let isWhite: Bool
    let size: CGFloat

    var body: some View {
        let s = size
        Canvas { ctx, _ in
            drawBase(ctx: &ctx, s: s, isWhite: isWhite)

            var neck = Path()
            neck.move(to: CGPoint(x: s*0.30, y: s*0.74))
            neck.addLine(to: CGPoint(x: s*0.26, y: s*0.58))
            neck.addQuadCurve(to: CGPoint(x: s*0.74, y: s*0.58), control: CGPoint(x: s*0.50, y: s*0.54))
            neck.addLine(to: CGPoint(x: s*0.70, y: s*0.74))
            neck.closeSubpath()

            var crown = Path()
            crown.move(to: CGPoint(x: s*0.26, y: s*0.58))
            crown.addQuadCurve(to: CGPoint(x: s*0.22, y: s*0.38), control: CGPoint(x: s*0.18, y: s*0.50))
            crown.addLine(to: CGPoint(x: s*0.20, y: s*0.30))
            crown.addQuadCurve(to: CGPoint(x: s*0.30, y: s*0.28), control: CGPoint(x: s*0.22, y: s*0.24))
            crown.addLine(to: CGPoint(x: s*0.34, y: s*0.32))
            crown.addLine(to: CGPoint(x: s*0.38, y: s*0.28))
            crown.addQuadCurve(to: CGPoint(x: s*0.44, y: s*0.16), control: CGPoint(x: s*0.36, y: s*0.20))
            // Cross
            crown.addLine(to: CGPoint(x: s*0.44, y: s*0.10))
            crown.addLine(to: CGPoint(x: s*0.40, y: s*0.10))
            crown.addLine(to: CGPoint(x: s*0.40, y: s*0.06))
            crown.addLine(to: CGPoint(x: s*0.60, y: s*0.06))
            crown.addLine(to: CGPoint(x: s*0.60, y: s*0.10))
            crown.addLine(to: CGPoint(x: s*0.56, y: s*0.10))
            crown.addLine(to: CGPoint(x: s*0.56, y: s*0.16))
            crown.addQuadCurve(to: CGPoint(x: s*0.62, y: s*0.28), control: CGPoint(x: s*0.64, y: s*0.20))
            crown.addLine(to: CGPoint(x: s*0.66, y: s*0.32))
            crown.addLine(to: CGPoint(x: s*0.70, y: s*0.28))
            crown.addQuadCurve(to: CGPoint(x: s*0.80, y: s*0.30), control: CGPoint(x: s*0.78, y: s*0.24))
            crown.addLine(to: CGPoint(x: s*0.78, y: s*0.38))
            crown.addQuadCurve(to: CGPoint(x: s*0.74, y: s*0.58), control: CGPoint(x: s*0.82, y: s*0.50))
            crown.closeSubpath()

            let fill = woodFill(isWhite: isWhite, size: s)
            let edge: GraphicsContext.Shading = .color(woodEdge(isWhite: isWhite))
            ctx.fill(neck, with: fill)
            ctx.fill(crown, with: fill)
            drawWoodGrain(ctx: &ctx, size: s, isWhite: isWhite)
            ctx.stroke(neck, with: edge, lineWidth: s*0.022)
            ctx.stroke(crown, with: edge, lineWidth: s*0.022)
            ctx.fill(crown, with: woodHighlight(isWhite: isWhite, size: s))
            ctx.fill(neck, with: woodRimLight(isWhite: isWhite, size: s))

            // Band detail
            var band = Path()
            band.move(to: CGPoint(x: s*0.28, y: s*0.56))
            band.addQuadCurve(to: CGPoint(x: s*0.72, y: s*0.56), control: CGPoint(x: s*0.50, y: s*0.52))
            ctx.stroke(band, with: edge, lineWidth: s*0.016)
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
            drawBase(ctx: &ctx, s: s, isWhite: isWhite)

            var neck = Path()
            neck.move(to: CGPoint(x: s*0.29, y: s*0.74))
            neck.addLine(to: CGPoint(x: s*0.26, y: s*0.60))
            neck.addQuadCurve(to: CGPoint(x: s*0.74, y: s*0.60), control: CGPoint(x: s*0.50, y: s*0.56))
            neck.addLine(to: CGPoint(x: s*0.71, y: s*0.74))
            neck.closeSubpath()

            var crown = Path()
            crown.move(to: CGPoint(x: s*0.26, y: s*0.60))
            crown.addQuadCurve(to: CGPoint(x: s*0.20, y: s*0.40), control: CGPoint(x: s*0.16, y: s*0.52))
            // 5 points
            crown.addQuadCurve(to: CGPoint(x: s*0.24, y: s*0.20), control: CGPoint(x: s*0.14, y: s*0.26))
            crown.addQuadCurve(to: CGPoint(x: s*0.30, y: s*0.32), control: CGPoint(x: s*0.32, y: s*0.22))
            crown.addQuadCurve(to: CGPoint(x: s*0.38, y: s*0.16), control: CGPoint(x: s*0.28, y: s*0.18))
            crown.addQuadCurve(to: CGPoint(x: s*0.44, y: s*0.28), control: CGPoint(x: s*0.46, y: s*0.14))
            crown.addQuadCurve(to: CGPoint(x: s*0.50, y: s*0.08), control: CGPoint(x: s*0.40, y: s*0.10))
            crown.addQuadCurve(to: CGPoint(x: s*0.56, y: s*0.28), control: CGPoint(x: s*0.60, y: s*0.10))
            crown.addQuadCurve(to: CGPoint(x: s*0.62, y: s*0.16), control: CGPoint(x: s*0.54, y: s*0.14))
            crown.addQuadCurve(to: CGPoint(x: s*0.70, y: s*0.32), control: CGPoint(x: s*0.72, y: s*0.18))
            crown.addQuadCurve(to: CGPoint(x: s*0.76, y: s*0.20), control: CGPoint(x: s*0.68, y: s*0.22))
            crown.addQuadCurve(to: CGPoint(x: s*0.80, y: s*0.40), control: CGPoint(x: s*0.86, y: s*0.26))
            crown.addQuadCurve(to: CGPoint(x: s*0.74, y: s*0.60), control: CGPoint(x: s*0.84, y: s*0.52))
            crown.closeSubpath()

            let fill = woodFill(isWhite: isWhite, size: s)
            let edge: GraphicsContext.Shading = .color(woodEdge(isWhite: isWhite))
            ctx.fill(neck, with: fill)
            ctx.fill(crown, with: fill)
            drawWoodGrain(ctx: &ctx, size: s, isWhite: isWhite)
            ctx.stroke(neck, with: edge, lineWidth: s*0.022)
            ctx.stroke(crown, with: edge, lineWidth: s*0.022)
            ctx.fill(crown, with: woodHighlight(isWhite: isWhite, size: s))

            // Orbs on tips
            let orbs: [CGPoint] = [
                CGPoint(x: s*0.24, y: s*0.19),
                CGPoint(x: s*0.38, y: s*0.14),
                CGPoint(x: s*0.50, y: s*0.07),
                CGPoint(x: s*0.62, y: s*0.14),
                CGPoint(x: s*0.76, y: s*0.19),
            ]
            let r = s * 0.038
            for orb in orbs {
                var dot = Path()
                dot.addEllipse(in: CGRect(x: orb.x - r, y: orb.y - r, width: r*2, height: r*2))
                ctx.fill(dot, with: fill)
                ctx.stroke(dot, with: edge, lineWidth: s*0.018)
            }

            var band = Path()
            band.move(to: CGPoint(x: s*0.28, y: s*0.58))
            band.addQuadCurve(to: CGPoint(x: s*0.72, y: s*0.58), control: CGPoint(x: s*0.50, y: s*0.54))
            ctx.stroke(band, with: edge, lineWidth: s*0.016)
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
            drawBase(ctx: &ctx, s: s, isWhite: isWhite)

            var tower = Path()
            tower.move(to: CGPoint(x: s*0.22, y: s*0.74))
            tower.addLine(to: CGPoint(x: s*0.20, y: s*0.42))
            tower.addLine(to: CGPoint(x: s*0.80, y: s*0.42))
            tower.addLine(to: CGPoint(x: s*0.78, y: s*0.74))
            tower.closeSubpath()

            var battlements = Path()
            battlements.addRoundedRect(in: CGRect(x: s*0.18, y: s*0.28, width: s*0.18, height: s*0.15), cornerSize: CGSize(width: s*0.02, height: s*0.02))
            battlements.addRoundedRect(in: CGRect(x: s*0.41, y: s*0.28, width: s*0.18, height: s*0.15), cornerSize: CGSize(width: s*0.02, height: s*0.02))
            battlements.addRoundedRect(in: CGRect(x: s*0.64, y: s*0.28, width: s*0.18, height: s*0.15), cornerSize: CGSize(width: s*0.02, height: s*0.02))
            battlements.addRoundedRect(in: CGRect(x: s*0.18, y: s*0.40, width: s*0.64, height: s*0.05), cornerSize: CGSize(width: s*0.02, height: s*0.02))

            let fill = woodFill(isWhite: isWhite, size: s)
            let edge: GraphicsContext.Shading = .color(woodEdge(isWhite: isWhite))
            ctx.fill(tower, with: fill)
            ctx.fill(battlements, with: fill)
            drawWoodGrain(ctx: &ctx, size: s, isWhite: isWhite)
            ctx.stroke(tower, with: edge, lineWidth: s*0.022)
            ctx.stroke(battlements, with: edge, lineWidth: s*0.022)
            ctx.fill(tower, with: woodHighlight(isWhite: isWhite, size: s))
            ctx.fill(battlements, with: woodRimLight(isWhite: isWhite, size: s))

            // Window
            var window = Path()
            window.move(to: CGPoint(x: s*0.42, y: s*0.50))
            window.addQuadCurve(to: CGPoint(x: s*0.58, y: s*0.50), control: CGPoint(x: s*0.50, y: s*0.46))
            window.addLine(to: CGPoint(x: s*0.58, y: s*0.64))
            window.addLine(to: CGPoint(x: s*0.42, y: s*0.64))
            window.closeSubpath()
            let windowColor: Color = isWhite
                ? Color(red: 0.44, green: 0.30, blue: 0.14).opacity(0.40)
                : Color(red: 0.04, green: 0.02, blue: 0.01).opacity(0.65)
            ctx.fill(window, with: .color(windowColor))
            ctx.stroke(window, with: edge, lineWidth: s*0.012)
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
            drawBase(ctx: &ctx, s: s, isWhite: isWhite)

            var collar = Path()
            collar.addRoundedRect(
                in: CGRect(x: s*0.26, y: s*0.64, width: s*0.48, height: s*0.11),
                cornerSize: CGSize(width: s*0.05, height: s*0.05)
            )

            var miter = Path()
            miter.move(to: CGPoint(x: s*0.26, y: s*0.64))
            miter.addQuadCurve(to: CGPoint(x: s*0.30, y: s*0.44), control: CGPoint(x: s*0.18, y: s*0.56))
            miter.addQuadCurve(to: CGPoint(x: s*0.50, y: s*0.10), control: CGPoint(x: s*0.32, y: s*0.22))
            miter.addQuadCurve(to: CGPoint(x: s*0.70, y: s*0.44), control: CGPoint(x: s*0.68, y: s*0.22))
            miter.addQuadCurve(to: CGPoint(x: s*0.74, y: s*0.64), control: CGPoint(x: s*0.82, y: s*0.56))
            miter.closeSubpath()

            let orbR = s * 0.048
            var orb = Path()
            orb.addEllipse(in: CGRect(x: s*0.50 - orbR, y: s*0.06, width: orbR*2, height: orbR*2))

            let fill = woodFill(isWhite: isWhite, size: s)
            let edge: GraphicsContext.Shading = .color(woodEdge(isWhite: isWhite))
            ctx.fill(collar, with: fill)
            ctx.fill(miter, with: fill)
            ctx.fill(orb, with: fill)
            drawWoodGrain(ctx: &ctx, size: s, isWhite: isWhite)
            ctx.stroke(collar, with: edge, lineWidth: s*0.022)
            ctx.stroke(miter, with: edge, lineWidth: s*0.022)
            ctx.stroke(orb, with: edge, lineWidth: s*0.020)
            ctx.fill(miter, with: woodHighlight(isWhite: isWhite, size: s))

            // Diagonal slit
            var slit = Path()
            slit.move(to: CGPoint(x: s*0.38, y: s*0.48))
            slit.addLine(to: CGPoint(x: s*0.52, y: s*0.30))
            ctx.stroke(slit, with: .color(woodEdge(isWhite: isWhite).opacity(0.60)), lineWidth: s*0.024)
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
            drawBase(ctx: &ctx, s: s, isWhite: isWhite)

            var bodyPath = Path()
            bodyPath.move(to: CGPoint(x: s*0.26, y: s*0.74))
            bodyPath.addLine(to: CGPoint(x: s*0.24, y: s*0.56))
            bodyPath.addQuadCurve(to: CGPoint(x: s*0.30, y: s*0.48), control: CGPoint(x: s*0.24, y: s*0.50))
            bodyPath.addLine(to: CGPoint(x: s*0.72, y: s*0.48))
            bodyPath.addQuadCurve(to: CGPoint(x: s*0.74, y: s*0.56), control: CGPoint(x: s*0.76, y: s*0.50))
            bodyPath.addLine(to: CGPoint(x: s*0.74, y: s*0.74))
            bodyPath.closeSubpath()

            var head = Path()
            head.move(to: CGPoint(x: s*0.30, y: s*0.48))
            head.addQuadCurve(to: CGPoint(x: s*0.24, y: s*0.40), control: CGPoint(x: s*0.22, y: s*0.46))
            head.addQuadCurve(to: CGPoint(x: s*0.28, y: s*0.32), control: CGPoint(x: s*0.16, y: s*0.38))
            head.addLine(to: CGPoint(x: s*0.36, y: s*0.26))
            head.addQuadCurve(to: CGPoint(x: s*0.42, y: s*0.22), control: CGPoint(x: s*0.34, y: s*0.20))
            // Ears
            head.addLine(to: CGPoint(x: s*0.48, y: s*0.16))
            head.addLine(to: CGPoint(x: s*0.54, y: s*0.10))
            head.addLine(to: CGPoint(x: s*0.60, y: s*0.08))
            head.addLine(to: CGPoint(x: s*0.66, y: s*0.12))
            head.addLine(to: CGPoint(x: s*0.68, y: s*0.18))
            head.addQuadCurve(to: CGPoint(x: s*0.72, y: s*0.26), control: CGPoint(x: s*0.76, y: s*0.18))
            head.addQuadCurve(to: CGPoint(x: s*0.70, y: s*0.38), control: CGPoint(x: s*0.78, y: s*0.32))
            head.addQuadCurve(to: CGPoint(x: s*0.72, y: s*0.48), control: CGPoint(x: s*0.76, y: s*0.42))
            head.closeSubpath()

            let fill = woodFill(isWhite: isWhite, size: s)
            let edge: GraphicsContext.Shading = .color(woodEdge(isWhite: isWhite))
            ctx.fill(bodyPath, with: fill)
            ctx.fill(head, with: fill)
            drawWoodGrain(ctx: &ctx, size: s, isWhite: isWhite)
            ctx.stroke(bodyPath, with: edge, lineWidth: s*0.022)
            ctx.stroke(head, with: edge, lineWidth: s*0.024)
            ctx.fill(head, with: woodHighlight(isWhite: isWhite, size: s))
            ctx.fill(bodyPath, with: woodRimLight(isWhite: isWhite, size: s))

            // Eye
            let eyeR = s * 0.028
            var eye = Path()
            eye.addEllipse(in: CGRect(x: s*0.46 - eyeR, y: s*0.24 - eyeR, width: eyeR*2, height: eyeR*2))
            let eyeColor: Color = isWhite
                ? Color(red: 0.18, green: 0.12, blue: 0.06)
                : Color(red: 0.70, green: 0.55, blue: 0.38)
            ctx.fill(eye, with: .color(eyeColor))

            // Nostril
            let nR = s * 0.016
            var nostril = Path()
            nostril.addEllipse(in: CGRect(x: s*0.30 - nR, y: s*0.34 - nR, width: nR*2, height: nR*2))
            ctx.fill(nostril, with: .color(eyeColor.opacity(0.60)))

            // Mane lines
            var mane = Path()
            mane.move(to: CGPoint(x: s*0.56, y: s*0.12))
            mane.addQuadCurve(to: CGPoint(x: s*0.66, y: s*0.30), control: CGPoint(x: s*0.72, y: s*0.20))
            let maneColor: Color = isWhite
                ? Color(red: 0.50, green: 0.34, blue: 0.14).opacity(0.40)
                : Color(red: 0.50, green: 0.35, blue: 0.22).opacity(0.45)
            ctx.stroke(mane, with: .color(maneColor), lineWidth: s*0.022)

            var mane2 = Path()
            mane2.move(to: CGPoint(x: s*0.52, y: s*0.14))
            mane2.addQuadCurve(to: CGPoint(x: s*0.62, y: s*0.34), control: CGPoint(x: s*0.68, y: s*0.24))
            ctx.stroke(mane2, with: .color(maneColor.opacity(0.60)), lineWidth: s*0.014)
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
            drawBase(ctx: &ctx, s: s, isWhite: isWhite)

            var stem = Path()
            stem.move(to: CGPoint(x: s*0.28, y: s*0.74))
            stem.addQuadCurve(to: CGPoint(x: s*0.32, y: s*0.60), control: CGPoint(x: s*0.28, y: s*0.66))
            stem.addLine(to: CGPoint(x: s*0.36, y: s*0.54))
            stem.addLine(to: CGPoint(x: s*0.64, y: s*0.54))
            stem.addLine(to: CGPoint(x: s*0.68, y: s*0.60))
            stem.addQuadCurve(to: CGPoint(x: s*0.72, y: s*0.74), control: CGPoint(x: s*0.72, y: s*0.66))
            stem.closeSubpath()

            let headCX = s * 0.50
            let headCY = s * 0.38
            let headR = s * 0.17
            var headPath = Path()
            headPath.addEllipse(in: CGRect(
                x: headCX - headR, y: headCY - headR,
                width: headR * 2, height: headR * 2
            ))

            let fill = woodFill(isWhite: isWhite, size: s)
            let edge: GraphicsContext.Shading = .color(woodEdge(isWhite: isWhite))
            ctx.fill(stem, with: fill)
            ctx.fill(headPath, with: fill)
            drawWoodGrain(ctx: &ctx, size: s, isWhite: isWhite)
            ctx.stroke(stem, with: edge, lineWidth: s*0.022)
            ctx.stroke(headPath, with: edge, lineWidth: s*0.024)
            ctx.fill(headPath, with: woodHighlight(isWhite: isWhite, size: s))
            ctx.fill(stem, with: woodRimLight(isWhite: isWhite, size: s))
        }
        .frame(width: size, height: size)
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
