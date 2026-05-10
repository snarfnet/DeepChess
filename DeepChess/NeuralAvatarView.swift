import SceneKit
import SwiftUI

struct NeuralAvatarView: UIViewRepresentable {
    let board: [Piece?]
    let isThinking: Bool
    let isCheck: Bool
    let lastMove: Move?

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.allowsCameraControl = false
        view.autoenablesDefaultLighting = false
        view.scene = context.coordinator.makeScene()
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        context.coordinator.update(sceneView: view, board: board, isThinking: isThinking, isCheck: isCheck, lastMove: lastMove)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        private let boardRoot = SCNNode()
        private let avatarRoot = SCNNode()
        private var pieceNodes: [SCNNode] = []
        private var pulseNodes: [SCNNode] = []
        private var lastHighlightedMove: Move?

        func makeScene() -> SCNScene {
            let scene = SCNScene()
            scene.background.contents = UIColor.clear

            let camera = SCNCamera()
            camera.fieldOfView = 42
            let cameraNode = SCNNode()
            cameraNode.camera = camera
            cameraNode.position = SCNVector3(0, 7.3, 9.7)
            cameraNode.eulerAngles = SCNVector3(-0.66, 0, 0)
            scene.rootNode.addChildNode(cameraNode)

            let key = SCNLight()
            key.type = .omni
            key.intensity = 980
            key.color = UIColor(red: 0.47, green: 0.96, blue: 1.0, alpha: 1)
            let keyNode = SCNNode()
            keyNode.light = key
            keyNode.position = SCNVector3(-2.8, 5.2, 4.0)
            scene.rootNode.addChildNode(keyNode)

            let fill = SCNLight()
            fill.type = .directional
            fill.intensity = 410
            fill.color = UIColor(red: 1.0, green: 0.72, blue: 0.36, alpha: 1)
            let fillNode = SCNNode()
            fillNode.light = fill
            fillNode.eulerAngles = SCNVector3(-0.8, 0.4, 0)
            scene.rootNode.addChildNode(fillNode)

            boardRoot.eulerAngles = SCNVector3(-0.22, 0, 0)
            boardRoot.position = SCNVector3(0, -1.1, 0)
            scene.rootNode.addChildNode(boardRoot)
            scene.rootNode.addChildNode(avatarRoot)

            buildBoard()
            buildAvatar()
            buildPulseRings()
            return scene
        }

        func update(sceneView: SCNView, board: [Piece?], isThinking: Bool, isCheck: Bool, lastMove: Move?) {
            rebuildPieces(board)

            avatarRoot.childNodes.forEach { node in
                if node.name == "iris" {
                    node.geometry?.firstMaterial?.emission.contents = isThinking
                        ? UIColor(red: 0.33, green: 1.0, blue: 0.88, alpha: 1)
                        : UIColor(red: 1.0, green: 0.70, blue: 0.36, alpha: 1)
                }
            }

            let pulseOpacity: CGFloat = isThinking ? 0.92 : (isCheck ? 0.74 : 0.28)
            pulseNodes.enumerated().forEach { offset, node in
                node.opacity = pulseOpacity - CGFloat(offset) * 0.12
                if node.action(forKey: "pulse") == nil {
                    let scale = SCNAction.sequence([
                        SCNAction.scale(to: 1.15 + CGFloat(offset) * 0.08, duration: 1.1),
                        SCNAction.scale(to: 0.92, duration: 1.1)
                    ])
                    node.runAction(SCNAction.repeatForever(scale), forKey: "pulse")
                }
            }

            if let lastMove, lastMove != lastHighlightedMove {
                lastHighlightedMove = lastMove
                highlightLastMove(lastMove)
            }
        }

        private func buildBoard() {
            let base = SCNBox(width: 4.65, height: 0.12, length: 4.65, chamferRadius: 0.08)
            base.firstMaterial = material(diffuse: UIColor(red: 0.025, green: 0.035, blue: 0.043, alpha: 1), emission: nil, metalness: 0.4)
            let baseNode = SCNNode(geometry: base)
            boardRoot.addChildNode(baseNode)

            for row in 0..<8 {
                for col in 0..<8 {
                    let square = SCNBox(width: 0.5, height: 0.025, length: 0.5, chamferRadius: 0.015)
                    let light = (row + col) % 2 == 0
                    let color = light
                        ? UIColor(red: 0.72, green: 0.95, blue: 0.86, alpha: 1)
                        : UIColor(red: 0.08, green: 0.18, blue: 0.20, alpha: 1)
                    square.firstMaterial = material(diffuse: color, emission: light ? color.withAlphaComponent(0.12) : nil, metalness: light ? 0.05 : 0.35)
                    let node = SCNNode(geometry: square)
                    node.name = "sq-\(row)-\(col)"
                    node.position = boardPosition(row: row, col: col, y: 0.08)
                    boardRoot.addChildNode(node)
                }
            }
        }

        private func buildAvatar() {
            avatarRoot.position = SCNVector3(0, 1.05, -1.95)

            let torso = SCNCapsule(capRadius: 0.42, height: 1.38)
            torso.firstMaterial = material(
                diffuse: UIColor(red: 0.08, green: 0.10, blue: 0.12, alpha: 1),
                emission: UIColor(red: 0.05, green: 0.32, blue: 0.30, alpha: 1),
                metalness: 0.18
            )
            let torsoNode = SCNNode(geometry: torso)
            torsoNode.position = SCNVector3(0, 0.18, 0)
            avatarRoot.addChildNode(torsoNode)

            let head = SCNSphere(radius: 0.42)
            head.segmentCount = 48
            head.firstMaterial = material(
                diffuse: UIColor(red: 0.96, green: 0.78, blue: 0.66, alpha: 1),
                emission: UIColor(red: 0.10, green: 0.05, blue: 0.03, alpha: 1),
                metalness: 0.0
            )
            let headNode = SCNNode(geometry: head)
            headNode.position = SCNVector3(0, 1.07, 0)
            avatarRoot.addChildNode(headNode)

            let hair = SCNSphere(radius: 0.455)
            hair.segmentCount = 48
            hair.firstMaterial = material(
                diffuse: UIColor(red: 0.02, green: 0.025, blue: 0.035, alpha: 1),
                emission: UIColor(red: 0.0, green: 0.12, blue: 0.16, alpha: 1),
                metalness: 0.2
            )
            let hairNode = SCNNode(geometry: hair)
            hairNode.scale = SCNVector3(1.03, 0.72, 1.02)
            hairNode.position = SCNVector3(0, 1.24, -0.03)
            avatarRoot.addChildNode(hairNode)

            for side in [-1.0, 1.0] {
                let lock = SCNCapsule(capRadius: 0.075, height: 0.72)
                lock.firstMaterial = material(
                    diffuse: UIColor(red: 0.015, green: 0.02, blue: 0.03, alpha: 1),
                    emission: UIColor(red: 0.0, green: 0.12, blue: 0.18, alpha: 1),
                    metalness: 0.18
                )
                let lockNode = SCNNode(geometry: lock)
                lockNode.position = SCNVector3(Float(side) * 0.34, 0.86, 0.03)
                lockNode.eulerAngles = SCNVector3(0.18, 0, Float(side) * 0.22)
                avatarRoot.addChildNode(lockNode)
            }

            let collar = SCNTorus(ringRadius: 0.36, pipeRadius: 0.018)
            collar.firstMaterial = material(
                diffuse: UIColor(red: 1.0, green: 0.70, blue: 0.36, alpha: 1),
                emission: UIColor(red: 0.80, green: 0.36, blue: 0.08, alpha: 1),
                metalness: 0.1
            )
            let collarNode = SCNNode(geometry: collar)
            collarNode.position = SCNVector3(0, 0.74, 0.06)
            collarNode.eulerAngles = SCNVector3(1.42, 0, 0)
            avatarRoot.addChildNode(collarNode)

            for x in [-0.17, 0.17] {
                let eye = SCNSphere(radius: 0.045)
                eye.firstMaterial = material(
                    diffuse: UIColor.white,
                    emission: UIColor(red: 0.3, green: 0.95, blue: 0.86, alpha: 1),
                    metalness: 0.0
                )
                let eyeNode = SCNNode(geometry: eye)
                eyeNode.name = "iris"
                eyeNode.position = SCNVector3(Float(x), 1.09, 0.38)
                avatarRoot.addChildNode(eyeNode)
            }

            let halo = SCNTorus(ringRadius: 0.58, pipeRadius: 0.012)
            halo.firstMaterial = material(
                diffuse: UIColor(red: 0.44, green: 0.95, blue: 1.0, alpha: 1),
                emission: UIColor(red: 0.30, green: 0.85, blue: 1.0, alpha: 1),
                metalness: 0.1
            )
            let haloNode = SCNNode(geometry: halo)
            haloNode.position = SCNVector3(0, 1.62, -0.08)
            haloNode.eulerAngles = SCNVector3(1.2, 0, 0)
            avatarRoot.addChildNode(haloNode)
            haloNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 0, z: .pi * 2, duration: 8)))
            avatarRoot.runAction(SCNAction.repeatForever(SCNAction.sequence([
                SCNAction.moveBy(x: 0, y: 0.035, z: 0, duration: 1.6),
                SCNAction.moveBy(x: 0, y: -0.035, z: 0, duration: 1.6)
            ])))

            for side in [-1.0, 1.0] {
                let arm = SCNCapsule(capRadius: 0.055, height: 0.98)
                arm.firstMaterial = material(diffuse: UIColor(red: 0.10, green: 0.14, blue: 0.15, alpha: 1), emission: UIColor(red: 0.02, green: 0.25, blue: 0.24, alpha: 1), metalness: 0.25)
                let armNode = SCNNode(geometry: arm)
                armNode.position = SCNVector3(Float(side) * 0.48, 0.35, 0.25)
                armNode.eulerAngles = SCNVector3(0.72, 0, Float(side) * 0.32)
                avatarRoot.addChildNode(armNode)
            }
        }

        private func buildPulseRings() {
            for index in 0..<3 {
                let torus = SCNTorus(ringRadius: 0.72 + CGFloat(index) * 0.18, pipeRadius: 0.008)
                torus.firstMaterial = material(diffuse: UIColor(red: 0.33, green: 0.9, blue: 0.82, alpha: 1), emission: UIColor(red: 0.16, green: 0.75, blue: 0.72, alpha: 1), metalness: 0.0)
                let node = SCNNode(geometry: torus)
                node.position = SCNVector3(0, 0.82, 0.06)
                node.eulerAngles = SCNVector3(1.35, 0.0, Float(index) * 0.45)
                avatarRoot.addChildNode(node)
                pulseNodes.append(node)
            }
        }

        private func rebuildPieces(_ board: [Piece?]) {
            pieceNodes.forEach { $0.removeFromParentNode() }
            pieceNodes = []
            for index in 0..<64 {
                guard let piece = board[index] else { continue }
                let node = makePieceNode(piece)
                node.position = boardPosition(row: index / 8, col: index % 8, y: 0.28)
                boardRoot.addChildNode(node)
                pieceNodes.append(node)
            }
        }

        private func makePieceNode(_ piece: Piece) -> SCNNode {
            let color = piece.color == .white
                ? UIColor(red: 0.95, green: 0.86, blue: 0.67, alpha: 1)
                : UIColor(red: 0.06, green: 0.08, blue: 0.10, alpha: 1)
            let emission = piece.color == .white
                ? UIColor(red: 0.25, green: 0.16, blue: 0.04, alpha: 1)
                : UIColor(red: 0.02, green: 0.27, blue: 0.30, alpha: 1)

            let root = SCNNode()
            let base = SCNCylinder(radius: 0.14, height: 0.08)
            base.firstMaterial = material(diffuse: color, emission: emission, metalness: 0.25)
            let baseNode = SCNNode(geometry: base)
            root.addChildNode(baseNode)

            let body: SCNGeometry
            switch piece.type {
            case .pawn:
                body = SCNSphere(radius: 0.13)
            case .knight:
                body = SCNCapsule(capRadius: 0.08, height: 0.34)
            case .bishop:
                body = SCNCone(topRadius: 0.04, bottomRadius: 0.13, height: 0.34)
            case .rook:
                body = SCNBox(width: 0.22, height: 0.26, length: 0.22, chamferRadius: 0.035)
            case .queen:
                body = SCNCone(topRadius: 0.10, bottomRadius: 0.17, height: 0.42)
            case .king:
                body = SCNCapsule(capRadius: 0.11, height: 0.43)
            }
            body.firstMaterial = material(diffuse: color, emission: emission, metalness: 0.25)
            let bodyNode = SCNNode(geometry: body)
            bodyNode.position = SCNVector3(0, 0.16, 0)
            root.addChildNode(bodyNode)
            return root
        }

        private func highlightLastMove(_ move: Move) {
            for name in ["sq-\(move.from / 8)-\(move.from % 8)", "sq-\(move.to / 8)-\(move.to % 8)"] {
                guard let node = boardRoot.childNode(withName: name, recursively: false) else { continue }
                node.removeAction(forKey: "flash")
                node.runAction(SCNAction.sequence([
                    SCNAction.scale(to: 1.12, duration: 0.18),
                    SCNAction.scale(to: 1.0, duration: 0.32)
                ]), forKey: "flash")
            }
        }

        private func boardPosition(row: Int, col: Int, y: CGFloat) -> SCNVector3 {
            SCNVector3(Float(CGFloat(col) * 0.53 - 1.855), Float(y), Float(CGFloat(row) * 0.53 - 1.855))
        }

        private func material(diffuse: UIColor, emission: UIColor?, metalness: CGFloat) -> SCNMaterial {
            let material = SCNMaterial()
            material.diffuse.contents = diffuse
            material.emission.contents = emission ?? UIColor.black
            material.metalness.contents = metalness
            material.roughness.contents = 0.38
            return material
        }
    }
}
