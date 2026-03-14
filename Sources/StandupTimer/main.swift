import AppKit
import UserNotifications

// MARK: - Configuration

struct Config: Codable {
    var intervalMinutes: Int = 60
}

// MARK: - Fun Messages

enum Theme: String, CaseIterable {
    case standup, water, backPain, productMgmt, vibeCoding
    case startup, football, party, fintech, cats
}

struct FunMessage {
    let text: String
    let theme: Theme
}

let funMessages: [FunMessage] = [
    // Stand up
    FunMessage(text: "Your spine filed a complaint with HR.", theme: .standup),
    FunMessage(text: "Standing up: the original standing desk.", theme: .standup),
    FunMessage(text: "Your future self called. They said stand up.", theme: .standup),
    FunMessage(text: "Sitting is the new smoking. Time to quit.", theme: .standup),
    // Water
    FunMessage(text: "Your cells are sending thirst traps. Drink water.", theme: .water),
    FunMessage(text: "Hydration check! Your kidneys will thank you.", theme: .water),
    FunMessage(text: "Water break. Your body is 60% water, not 60% coffee.", theme: .water),
    // Back pain
    FunMessage(text: "Your L4-L5 vertebrae are drafting a resignation letter.", theme: .backPain),
    FunMessage(text: "Your lower back called. It wants a divorce.", theme: .backPain),
    FunMessage(text: "Ergonomics tip: you can't fix posture by ignoring it.", theme: .backPain),
    FunMessage(text: "Your chiropractor's kids need braces. Stretch.", theme: .backPain),
    // Product management
    FunMessage(text: "Stand up. This is not in the backlog — it's a P0.", theme: .productMgmt),
    FunMessage(text: "User story: As a human, I want to stand so I don't break.", theme: .productMgmt),
    FunMessage(text: "Sprint retro: sitting too long was the blocker.", theme: .productMgmt),
    FunMessage(text: "Acceptance criteria: must stand. Status: not accepted.", theme: .productMgmt),
    // Vibe coding
    FunMessage(text: "The vibes are off when your posture is off. Stand up.", theme: .vibeCoding),
    FunMessage(text: "You can't vibe code with a stiff neck. Stretch.", theme: .vibeCoding),
    FunMessage(text: "Even Claude takes breaks between tokens.", theme: .vibeCoding),
    FunMessage(text: "git commit -m 'stood up, touched grass'", theme: .vibeCoding),
    // Startup
    FunMessage(text: "Pivot from sitting to standing. No board approval needed.", theme: .startup),
    FunMessage(text: "Disrupt your chair. Stand up.", theme: .startup),
    FunMessage(text: "Your health has negative burn rate. Stand up to fundraise.", theme: .startup),
    FunMessage(text: "Move fast and fix things. Starting with your posture.", theme: .startup),
    // Football
    FunMessage(text: "Halftime! Get off the bench. Do some stretches.", theme: .football),
    FunMessage(text: "Fourth quarter. Time to make a play — stand up.", theme: .football),
    FunMessage(text: "Unnecessary roughness — on your own spine. Flag on the play.", theme: .football),
    FunMessage(text: "The ref calls a timeout. Stand and stretch.", theme: .football),
    // Party
    FunMessage(text: "DJ Spine says: everybody get up!", theme: .party),
    FunMessage(text: "The floor is lava! Get off your chair!", theme: .party),
    FunMessage(text: "Stand up if you're having a good time. Or even if you're not.", theme: .party),
    // Fintech
    FunMessage(text: "Your health balance is overdrawn. Deposit one standup.", theme: .fintech),
    FunMessage(text: "ROI on standing: infinite. Cost: zero. Just do it.", theme: .fintech),
    FunMessage(text: "Your wellness portfolio is underperforming. Diversify with stretches.", theme: .fintech),
    FunMessage(text: "Transaction pending: 1x standup. Approve?", theme: .fintech),
    // Cats
    FunMessage(text: "Even your cat stretches more than you. Get up.", theme: .cats),
    FunMessage(text: "Be more cat. Stretch, yawn, knock something off the desk.", theme: .cats),
    FunMessage(text: "Cats nap 16 hours a day but still stretch. Your move.", theme: .cats),
    FunMessage(text: "Channel your inner cat: arch your back, then walk away.", theme: .cats),
]

// MARK: - Illustration Generator

final class IllustrationGenerator {
    let iconsDir: URL

    init(dataDir: URL) {
        iconsDir = dataDir.appendingPathComponent("icons")
    }

    func generateAllIfNeeded() {
        try? FileManager.default.createDirectory(at: iconsDir, withIntermediateDirectories: true)
        for theme in Theme.allCases {
            let path = iconPath(for: theme)
            if !FileManager.default.fileExists(atPath: path.path) {
                generateIcon(for: theme, at: path)
            }
        }
    }

    func iconPath(for theme: Theme) -> URL {
        iconsDir.appendingPathComponent("\(theme.rawValue).png")
    }

    private func generateIcon(for theme: Theme, at url: URL) {
        let size = 128
        let cs = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: nil, width: size, height: size,
            bitsPerComponent: 8, bytesPerRow: 0, space: cs,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return }

        let s = CGFloat(size)
        let bg = backgroundColor(for: theme)
        let fg = foregroundColor(for: theme)

        // Background circle
        ctx.setFillColor(bg)
        ctx.fillEllipse(in: CGRect(x: 4, y: 4, width: s - 8, height: s - 8))

        // Theme-specific drawing
        ctx.setFillColor(fg)
        ctx.setStrokeColor(fg)
        ctx.setLineWidth(3)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)

        switch theme {
        case .standup:   drawPerson(ctx: ctx, s: s)
        case .water:     drawWaterGlass(ctx: ctx, s: s)
        case .backPain:  drawSpine(ctx: ctx, s: s)
        case .productMgmt: drawClipboard(ctx: ctx, s: s)
        case .vibeCoding:  drawLaptop(ctx: ctx, s: s)
        case .startup:   drawRocket(ctx: ctx, s: s)
        case .football:  drawFootball(ctx: ctx, s: s)
        case .party:     drawMusicNote(ctx: ctx, s: s)
        case .fintech:   drawChart(ctx: ctx, s: s)
        case .cats:      drawCat(ctx: ctx, s: s)
        }

        guard let image = ctx.makeImage() else { return }
        let rep = NSBitmapImageRep(cgImage: image)
        guard let data = rep.representation(using: .png, properties: [:]) else { return }
        try? data.write(to: url)
    }

    private func backgroundColor(for theme: Theme) -> CGColor {
        switch theme {
        case .standup:     return CGColor(red: 0.75, green: 0.90, blue: 0.75, alpha: 1) // mint
        case .water:       return CGColor(red: 0.73, green: 0.88, blue: 1.0, alpha: 1)  // sky blue
        case .backPain:    return CGColor(red: 1.0, green: 0.60, blue: 0.63, alpha: 1)   // coral
        case .productMgmt: return CGColor(red: 0.90, green: 0.90, blue: 0.98, alpha: 1)  // lavender
        case .vibeCoding:  return CGColor(red: 0.80, green: 0.95, blue: 0.80, alpha: 1)  // light mint
        case .startup:     return CGColor(red: 1.0, green: 0.85, blue: 0.73, alpha: 1)   // peach
        case .football:    return CGColor(red: 0.68, green: 0.85, blue: 0.65, alpha: 1)  // grass green
        case .party:       return CGColor(red: 1.0, green: 0.80, blue: 0.90, alpha: 1)   // pink
        case .fintech:     return CGColor(red: 0.75, green: 0.90, blue: 0.85, alpha: 1)  // teal
        case .cats:        return CGColor(red: 1.0, green: 0.90, blue: 0.75, alpha: 1)   // warm peach
        }
    }

    private func foregroundColor(for theme: Theme) -> CGColor {
        switch theme {
        case .standup:     return CGColor(red: 0.15, green: 0.45, blue: 0.15, alpha: 1)
        case .water:       return CGColor(red: 0.10, green: 0.35, blue: 0.65, alpha: 1)
        case .backPain:    return CGColor(red: 0.60, green: 0.10, blue: 0.15, alpha: 1)
        case .productMgmt: return CGColor(red: 0.30, green: 0.30, blue: 0.60, alpha: 1)
        case .vibeCoding:  return CGColor(red: 0.15, green: 0.50, blue: 0.25, alpha: 1)
        case .startup:     return CGColor(red: 0.65, green: 0.30, blue: 0.10, alpha: 1)
        case .football:    return CGColor(red: 0.20, green: 0.45, blue: 0.15, alpha: 1)
        case .party:       return CGColor(red: 0.60, green: 0.15, blue: 0.35, alpha: 1)
        case .fintech:     return CGColor(red: 0.10, green: 0.45, blue: 0.40, alpha: 1)
        case .cats:        return CGColor(red: 0.55, green: 0.30, blue: 0.10, alpha: 1)
        }
    }

    // MARK: - Drawing Functions

    private func drawPerson(ctx: CGContext, s: CGFloat) {
        // Head
        ctx.fillEllipse(in: CGRect(x: s*0.42, y: s*0.62, width: s*0.16, height: s*0.16))
        // Body
        ctx.move(to: CGPoint(x: s*0.50, y: s*0.62))
        ctx.addLine(to: CGPoint(x: s*0.50, y: s*0.35))
        ctx.strokePath()
        // Arms up (stretching)
        ctx.move(to: CGPoint(x: s*0.50, y: s*0.55))
        ctx.addLine(to: CGPoint(x: s*0.35, y: s*0.68))
        ctx.move(to: CGPoint(x: s*0.50, y: s*0.55))
        ctx.addLine(to: CGPoint(x: s*0.65, y: s*0.68))
        ctx.strokePath()
        // Legs
        ctx.move(to: CGPoint(x: s*0.50, y: s*0.35))
        ctx.addLine(to: CGPoint(x: s*0.38, y: s*0.20))
        ctx.move(to: CGPoint(x: s*0.50, y: s*0.35))
        ctx.addLine(to: CGPoint(x: s*0.62, y: s*0.20))
        ctx.strokePath()
    }

    private func drawWaterGlass(ctx: CGContext, s: CGFloat) {
        // Glass outline
        ctx.move(to: CGPoint(x: s*0.35, y: s*0.72))
        ctx.addLine(to: CGPoint(x: s*0.38, y: s*0.28))
        ctx.addLine(to: CGPoint(x: s*0.62, y: s*0.28))
        ctx.addLine(to: CGPoint(x: s*0.65, y: s*0.72))
        ctx.closePath()
        ctx.strokePath()
        // Water level
        ctx.setAlpha(0.4)
        ctx.move(to: CGPoint(x: s*0.37, y: s*0.55))
        ctx.addLine(to: CGPoint(x: s*0.39, y: s*0.28))
        ctx.addLine(to: CGPoint(x: s*0.61, y: s*0.28))
        ctx.addLine(to: CGPoint(x: s*0.63, y: s*0.55))
        ctx.closePath()
        ctx.fillPath()
        ctx.setAlpha(1.0)
        // Bubbles
        ctx.fillEllipse(in: CGRect(x: s*0.45, y: s*0.35, width: s*0.05, height: s*0.05))
        ctx.fillEllipse(in: CGRect(x: s*0.52, y: s*0.42, width: s*0.04, height: s*0.04))
    }

    private func drawSpine(ctx: CGContext, s: CGFloat) {
        // Vertebrae as small rounded rects
        let cx = s * 0.50
        let vertebrae: [(CGFloat, CGFloat)] = [
            (0.70, 0.10), (0.65, 0.12), (0.60, 0.13),
            (0.55, 0.13), (0.50, 0.12), (0.45, 0.12),
            (0.40, 0.11), (0.35, 0.10)
        ]
        for (yFrac, wFrac) in vertebrae {
            let w = s * wFrac
            let h = s * 0.04
            let rect = CGRect(x: cx - w/2, y: s * yFrac, width: w, height: h)
            let path = CGPath(roundedRect: rect, cornerWidth: 3, cornerHeight: 3, transform: nil)
            ctx.addPath(path)
            ctx.fillPath()
        }
    }

    private func drawClipboard(ctx: CGContext, s: CGFloat) {
        // Board
        let board = CGRect(x: s*0.30, y: s*0.22, width: s*0.40, height: s*0.50)
        let boardPath = CGPath(roundedRect: board, cornerWidth: 6, cornerHeight: 6, transform: nil)
        ctx.addPath(boardPath)
        ctx.strokePath()
        // Clip
        let clip = CGRect(x: s*0.42, y: s*0.68, width: s*0.16, height: s*0.10)
        let clipPath = CGPath(roundedRect: clip, cornerWidth: 3, cornerHeight: 3, transform: nil)
        ctx.addPath(clipPath)
        ctx.fillPath()
        // Lines
        for i in 0..<3 {
            let y = s * (0.55 - CGFloat(i) * 0.10)
            ctx.move(to: CGPoint(x: s*0.38, y: y))
            ctx.addLine(to: CGPoint(x: s*0.62, y: y))
        }
        ctx.strokePath()
        // Checkmark on first line
        ctx.move(to: CGPoint(x: s*0.36, y: s*0.54))
        ctx.addLine(to: CGPoint(x: s*0.39, y: s*0.51))
        ctx.addLine(to: CGPoint(x: s*0.44, y: s*0.57))
        ctx.strokePath()
    }

    private func drawLaptop(ctx: CGContext, s: CGFloat) {
        // Screen
        let screen = CGRect(x: s*0.28, y: s*0.42, width: s*0.44, height: s*0.30)
        let screenPath = CGPath(roundedRect: screen, cornerWidth: 5, cornerHeight: 5, transform: nil)
        ctx.addPath(screenPath)
        ctx.strokePath()
        // Base/keyboard
        ctx.move(to: CGPoint(x: s*0.22, y: s*0.38))
        ctx.addLine(to: CGPoint(x: s*0.78, y: s*0.38))
        ctx.addLine(to: CGPoint(x: s*0.75, y: s*0.42))
        ctx.addLine(to: CGPoint(x: s*0.25, y: s*0.42))
        ctx.closePath()
        ctx.strokePath()
        // Code lines on screen
        ctx.setLineWidth(2)
        ctx.move(to: CGPoint(x: s*0.34, y: s*0.60))
        ctx.addLine(to: CGPoint(x: s*0.50, y: s*0.60))
        ctx.move(to: CGPoint(x: s*0.34, y: s*0.54))
        ctx.addLine(to: CGPoint(x: s*0.58, y: s*0.54))
        ctx.move(to: CGPoint(x: s*0.38, y: s*0.48))
        ctx.addLine(to: CGPoint(x: s*0.54, y: s*0.48))
        ctx.strokePath()
        ctx.setLineWidth(3)
    }

    private func drawRocket(ctx: CGContext, s: CGFloat) {
        // Body
        ctx.move(to: CGPoint(x: s*0.50, y: s*0.78))
        ctx.addCurve(
            to: CGPoint(x: s*0.50, y: s*0.25),
            control1: CGPoint(x: s*0.62, y: s*0.70),
            control2: CGPoint(x: s*0.58, y: s*0.40)
        )
        ctx.addCurve(
            to: CGPoint(x: s*0.50, y: s*0.78),
            control1: CGPoint(x: s*0.42, y: s*0.40),
            control2: CGPoint(x: s*0.38, y: s*0.70)
        )
        ctx.strokePath()
        // Window
        ctx.fillEllipse(in: CGRect(x: s*0.45, y: s*0.52, width: s*0.10, height: s*0.10))
        // Fins
        ctx.move(to: CGPoint(x: s*0.42, y: s*0.35))
        ctx.addLine(to: CGPoint(x: s*0.30, y: s*0.25))
        ctx.addLine(to: CGPoint(x: s*0.42, y: s*0.42))
        ctx.move(to: CGPoint(x: s*0.58, y: s*0.35))
        ctx.addLine(to: CGPoint(x: s*0.70, y: s*0.25))
        ctx.addLine(to: CGPoint(x: s*0.58, y: s*0.42))
        ctx.strokePath()
    }

    private func drawFootball(ctx: CGContext, s: CGFloat) {
        // Football shape (ellipse, rotated feel)
        let cx = s * 0.50
        let cy = s * 0.50
        ctx.saveGState()
        ctx.translateBy(x: cx, y: cy)
        let path = CGMutablePath()
        path.addEllipse(in: CGRect(x: -s*0.22, y: -s*0.14, width: s*0.44, height: s*0.28))
        ctx.addPath(path)
        ctx.strokePath()
        // Laces
        ctx.move(to: CGPoint(x: 0, y: -s*0.14))
        ctx.addLine(to: CGPoint(x: 0, y: s*0.14))
        ctx.strokePath()
        // Cross laces
        for i in -1...1 {
            let y = CGFloat(i) * s * 0.06
            ctx.move(to: CGPoint(x: -s*0.05, y: y))
            ctx.addLine(to: CGPoint(x: s*0.05, y: y))
        }
        ctx.strokePath()
        ctx.restoreGState()
    }

    private func drawMusicNote(ctx: CGContext, s: CGFloat) {
        // Note head
        ctx.fillEllipse(in: CGRect(x: s*0.35, y: s*0.28, width: s*0.14, height: s*0.10))
        ctx.fillEllipse(in: CGRect(x: s*0.55, y: s*0.32, width: s*0.14, height: s*0.10))
        // Stems
        ctx.setLineWidth(3)
        ctx.move(to: CGPoint(x: s*0.49, y: s*0.33))
        ctx.addLine(to: CGPoint(x: s*0.49, y: s*0.72))
        ctx.move(to: CGPoint(x: s*0.69, y: s*0.37))
        ctx.addLine(to: CGPoint(x: s*0.69, y: s*0.72))
        ctx.strokePath()
        // Beam
        ctx.setLineWidth(4)
        ctx.move(to: CGPoint(x: s*0.49, y: s*0.72))
        ctx.addLine(to: CGPoint(x: s*0.69, y: s*0.72))
        ctx.move(to: CGPoint(x: s*0.49, y: s*0.66))
        ctx.addLine(to: CGPoint(x: s*0.69, y: s*0.66))
        ctx.strokePath()
        ctx.setLineWidth(3)
    }

    private func drawChart(ctx: CGContext, s: CGFloat) {
        // Axes
        ctx.move(to: CGPoint(x: s*0.25, y: s*0.72))
        ctx.addLine(to: CGPoint(x: s*0.25, y: s*0.28))
        ctx.move(to: CGPoint(x: s*0.25, y: s*0.28))
        ctx.addLine(to: CGPoint(x: s*0.75, y: s*0.28))
        ctx.strokePath()
        // Bars going up
        let bars: [(CGFloat, CGFloat)] = [(0.32, 0.20), (0.44, 0.30), (0.56, 0.25), (0.68, 0.40)]
        for (x, h) in bars {
            let rect = CGRect(x: s*x, y: s*0.28, width: s*0.08, height: s*h)
            ctx.fill(rect)
        }
        // Arrow going up
        ctx.setLineWidth(2)
        ctx.move(to: CGPoint(x: s*0.30, y: s*0.38))
        ctx.addLine(to: CGPoint(x: s*0.70, y: s*0.65))
        ctx.strokePath()
        ctx.setLineWidth(3)
    }

    private func drawCat(ctx: CGContext, s: CGFloat) {
        // Body (oval)
        ctx.strokeEllipse(in: CGRect(x: s*0.30, y: s*0.28, width: s*0.35, height: s*0.25))
        // Head
        ctx.fillEllipse(in: CGRect(x: s*0.55, y: s*0.45, width: s*0.18, height: s*0.16))
        // Ears (triangles)
        ctx.move(to: CGPoint(x: s*0.58, y: s*0.61))
        ctx.addLine(to: CGPoint(x: s*0.55, y: s*0.70))
        ctx.addLine(to: CGPoint(x: s*0.62, y: s*0.64))
        ctx.fillPath()
        ctx.move(to: CGPoint(x: s*0.68, y: s*0.61))
        ctx.addLine(to: CGPoint(x: s*0.73, y: s*0.70))
        ctx.addLine(to: CGPoint(x: s*0.66, y: s*0.64))
        ctx.fillPath()
        // Eyes (small dots) - use background color for contrast
        ctx.setFillColor(backgroundColor(for: .cats))
        ctx.fillEllipse(in: CGRect(x: s*0.60, y: s*0.52, width: s*0.04, height: s*0.04))
        ctx.fillEllipse(in: CGRect(x: s*0.66, y: s*0.52, width: s*0.04, height: s*0.04))
        ctx.setFillColor(foregroundColor(for: .cats))
        // Tail (curve)
        ctx.move(to: CGPoint(x: s*0.30, y: s*0.38))
        ctx.addCurve(
            to: CGPoint(x: s*0.22, y: s*0.60),
            control1: CGPoint(x: s*0.20, y: s*0.35),
            control2: CGPoint(x: s*0.18, y: s*0.55)
        )
        ctx.strokePath()
    }
}

// MARK: - App Delegate

final class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var coarseTimer: Timer?
    var countdownTimer: Timer?
    var snoozeTimer: Timer?
    var targetDate = Date()
    var config = Config()
    var isOverdue = false
    var recentMessageIndices: [Int] = []
    var isLogging = false
    var illustrationGen: IllustrationGenerator!

    lazy var dataDir: URL = {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("StandupTimer")
        try? FileManager.default.createDirectory(
            at: dir, withIntermediateDirectories: true,
            attributes: [.posixPermissions: 0o700]
        )
        return dir
    }()

    // MARK: - App Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        config = loadConfig()
        illustrationGen = IllustrationGenerator(dataDir: dataDir)
        illustrationGen.generateAllIfNeeded()

        setupStatusItem()
        registerNotificationCategory()
        requestNotificationPermission()
        observeSleepWake()
        resetTimer()
    }

    // MARK: - Status Item Setup

    private lazy var catIcon: NSImage = loadCatIcon()

    private func setupStatusItem() {
        guard let button = statusItem.button else { return }
        button.image = catIcon
        button.imagePosition = .imageOnly
        button.target = self
        button.action = #selector(handleClick(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    /// Show the cat icon (normal state)
    private func showCatIcon() {
        statusItem.button?.image = catIcon
        statusItem.button?.imagePosition = .imageOnly
        statusItem.button?.title = ""
    }

    /// Show cat icon + text side by side (countdown / overdue states)
    private func showText(_ text: String) {
        statusItem.button?.image = catIcon
        statusItem.button?.imagePosition = .imageLeft
        statusItem.button?.title = text
    }

    /// Load the custom cat icon from the app bundle's Resources.
    /// Falls back to a simple "▲" text icon if the file is missing.
    /// Template images auto-adapt to light/dark menu bar.
    private func loadCatIcon() -> NSImage {
        let size = NSSize(width: 18, height: 18)

        // Try loading from bundle Resources
        if let bundlePath = Bundle.main.path(forResource: "cat-icon", ofType: "png"),
           let original = NSImage(contentsOfFile: bundlePath) {
            // Resize to 18×18 pt (the PNG is 36×36 px for @2x retina)
            let resized = NSImage(size: size)
            resized.addRepresentation(NSBitmapImageRep(
                bitmapDataPlanes: nil,
                pixelsWide: 36, pixelsHigh: 36,
                bitsPerSample: 8, samplesPerPixel: 4,
                hasAlpha: true, isPlanar: false,
                colorSpaceName: .deviceRGB,
                bytesPerRow: 0, bitsPerPixel: 0
            )!)
            resized.lockFocus()
            original.draw(in: NSRect(origin: .zero, size: size),
                          from: NSRect(origin: .zero, size: original.size),
                          operation: .copy, fraction: 1.0)
            resized.unlockFocus()
            resized.size = size
            resized.isTemplate = true
            return resized
        }

        // Fallback: try loading from the executable's sibling ../Resources/
        let execURL = URL(fileURLWithPath: CommandLine.arguments[0])
        let resourceURL = execURL
            .deletingLastPathComponent()           // MacOS/
            .deletingLastPathComponent()           // Contents/
            .appendingPathComponent("Resources")
            .appendingPathComponent("cat-icon.png")
        if let original = NSImage(contentsOf: resourceURL) {
            let resized = NSImage(size: size)
            resized.lockFocus()
            original.draw(in: NSRect(origin: .zero, size: size),
                          from: NSRect(origin: .zero, size: original.size),
                          operation: .copy, fraction: 1.0)
            resized.unlockFocus()
            resized.isTemplate = true
            return resized
        }

        // Last-resort fallback: draw a simple triangle
        let fallback = NSImage(size: size, flipped: false) { rect in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            let s = rect.size.width
            ctx.setFillColor(NSColor.black.cgColor)
            ctx.move(to: CGPoint(x: s * 0.5, y: s * 0.85))
            ctx.addLine(to: CGPoint(x: s * 0.15, y: s * 0.2))
            ctx.addLine(to: CGPoint(x: s * 0.85, y: s * 0.2))
            ctx.closePath()
            ctx.fillPath()
            return true
        }
        fallback.isTemplate = true
        return fallback
    }

    // MARK: - Click Handling

    @objc private func handleClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            showMenu()
        } else {
            logStandupIfNeeded()
        }
    }

    private func showMenu() {
        let menu = NSMenu()

        // Last standup info
        let lastInfo = NSMenuItem(title: lastStandupDescription(), action: nil, keyEquivalent: "")
        lastInfo.isEnabled = false
        menu.addItem(lastInfo)

        menu.addItem(.separator())

        menu.addItem(NSMenuItem(title: "Set Interval...", action: #selector(showIntervalDialog), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "View Log...", action: #selector(openLog), keyEquivalent: ""))

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    // MARK: - Timer Management

    func resetTimer() {
        coarseTimer?.invalidate()
        countdownTimer?.invalidate()
        snoozeTimer?.invalidate()
        isOverdue = false

        targetDate = Date().addingTimeInterval(TimeInterval(config.intervalMinutes * 60))
        showCatIcon()
        startCoarseTimer()
    }

    private func startCoarseTimer() {
        checkCountdown() // immediate check for short intervals
        coarseTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.checkCountdown()
        }
    }

    private func checkCountdown() {
        let remaining = targetDate.timeIntervalSinceNow
        if remaining <= 60 {
            coarseTimer?.invalidate()
            coarseTimer = nil
            switchToCountdownMode()
        }
    }

    private func switchToCountdownMode() {
        updateCountdownDisplay()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateCountdownDisplay()
        }
    }

    private func updateCountdownDisplay() {
        let remaining = Int(targetDate.timeIntervalSinceNow)
        if remaining > 60 {
            // Shouldn't be in countdown mode yet — switch back to coarse
            countdownTimer?.invalidate()
            countdownTimer = nil
            startCoarseTimer()
        } else if remaining > 0 {
            showText(String(format: "0:%02d", remaining))
        } else if !isOverdue {
            countdownTimer?.invalidate()
            countdownTimer = nil
            switchToOverdueMode()
        }
    }

    private func switchToOverdueMode() {
        isOverdue = true
        showText("--:--")
        sendFunNotification()
        startSnoozeTimer()
    }

    private func startSnoozeTimer() {
        snoozeTimer?.invalidate()
        snoozeTimer = Timer.scheduledTimer(withTimeInterval: 5 * 60, repeats: true) { [weak self] _ in
            self?.sendFunNotification()
        }
    }

    // MARK: - Notifications

    private func registerNotificationCategory() {
        let doneAction = UNNotificationAction(
            identifier: "DONE_ACTION",
            title: "Done! ✓",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: "STANDUP_CATEGORY",
            actions: [doneAction],
            intentIdentifiers: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
        UNUserNotificationCenter.current().delegate = self
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { granted, error in
            if !granted {
                fputs("Notification permission denied — use menu bar click to log standups\n", stderr)
            }
            if let error = error {
                fputs("Notification error: \(error.localizedDescription)\n", stderr)
            }
        }
    }

    private let funTitles = [
        "Time to stand up! 🧍",
        "Stretch break! 🐱",
        "Up up up! 🚀",
        "Hey you! Stand! 👆",
        "Stretch o'clock! ⏰",
        "Rise and shine! ☀️",
        "Standup time! 🎯",
        "Move it! 💪",
    ]

    private func sendFunNotification() {
        let message = pickRandomMessage()
        let content = UNMutableNotificationContent()
        content.title = funTitles.randomElement() ?? "Time to stand up! 🧍"
        content.body = message.text
        content.sound = nil
        content.categoryIdentifier = "STANDUP_CATEGORY"

        // Attach themed illustration
        // Use a stable temp path per theme (avoids accumulating UUID-named files)
        let iconURL = illustrationGen.iconPath(for: message.theme)
        if FileManager.default.fileExists(atPath: iconURL.path) {
            let tmpDir = FileManager.default.temporaryDirectory
                .appendingPathComponent("StandupTimer")
            try? FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
            let tmpFile = tmpDir.appendingPathComponent("\(message.theme.rawValue).png")
            // Remove stale copy if it exists, then copy fresh
            try? FileManager.default.removeItem(at: tmpFile)
            try? FileManager.default.copyItem(at: iconURL, to: tmpFile)
            if let attachment = try? UNNotificationAttachment(
                identifier: message.theme.rawValue,
                url: tmpFile,
                options: nil
            ) {
                content.attachments = [attachment]
            }
        }

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func pickRandomMessage() -> FunMessage {
        // Build a list of indices we haven't used recently
        let available = (0..<funMessages.count).filter { !recentMessageIndices.contains($0) }
        let index: Int
        if available.isEmpty {
            // All used recently — clear history and pick any
            recentMessageIndices.removeAll()
            index = Int.random(in: 0..<funMessages.count)
        } else {
            index = available.randomElement()!
        }
        recentMessageIndices.append(index)
        // Keep history to half the total so we cycle through all messages
        if recentMessageIndices.count > funMessages.count / 2 {
            recentMessageIndices.removeFirst()
        }
        return funMessages[index]
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.actionIdentifier == "DONE_ACTION"
            || response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            DispatchQueue.main.async { [weak self] in
                self?.logStandupIfNeeded()
            }
        }
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list])
    }

    // MARK: - Sleep/Wake

    private func observeSleepWake() {
        let ws = NSWorkspace.shared.notificationCenter
        ws.addObserver(self, selector: #selector(handleSleep), name: NSWorkspace.willSleepNotification, object: nil)
        ws.addObserver(self, selector: #selector(handleWake), name: NSWorkspace.didWakeNotification, object: nil)
    }

    @objc private func handleSleep() {
        coarseTimer?.invalidate()
        countdownTimer?.invalidate()
        snoozeTimer?.invalidate()
        coarseTimer = nil
        countdownTimer = nil
        snoozeTimer = nil
    }

    @objc private func handleWake() {
        resetTimer()
    }

    // MARK: - Logging

    /// Guard against double-invocation (e.g. user taps notification + clicks menu bar)
    func logStandupIfNeeded() {
        guard !isLogging else { return }
        isLogging = true
        logStandup()
        // Reset the guard after a short delay to allow future logs
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isLogging = false
        }
    }

    private func logStandup() {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let timestamp = formatter.string(from: Date())
        let line = timestamp + "\n"

        let logFile = dataDir.appendingPathComponent("standups.csv")
        guard let lineData = line.data(using: .utf8) else { return }
        if let handle = try? FileHandle(forWritingTo: logFile) {
            handle.seekToEndOfFile()
            handle.write(lineData)
            try? handle.close()
        } else {
            try? lineData.write(to: logFile, options: .atomic)
        }

        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        resetTimer()
    }

    private func lastStandupDescription() -> String {
        let logFile = dataDir.appendingPathComponent("standups.csv")
        guard let handle = try? FileHandle(forReadingFrom: logFile) else {
            return "No standups logged yet"
        }
        defer { try? handle.close() }

        // Read only the last 128 bytes (enough for one ISO 8601 timestamp line)
        let fileSize = handle.seekToEndOfFile()
        guard fileSize > 0 else { return "No standups logged yet" }
        let readOffset = fileSize > 128 ? fileSize - 128 : 0
        handle.seek(toFileOffset: readOffset)
        guard let tail = String(data: handle.readDataToEndOfFile(), encoding: .utf8) else {
            return "No standups logged yet"
        }

        let lines = tail.components(separatedBy: "\n").filter { !$0.isEmpty }
        guard let last = lines.last else { return "No standups logged yet" }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        guard let date = formatter.date(from: last) else { return "Last standup: \(last)" }

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "h:mm a"
        return "Last standup: \(displayFormatter.string(from: date))"
    }

    // MARK: - Settings

    @objc private func showIntervalDialog() {
        let alert = NSAlert()
        alert.messageText = "Standup Interval"
        alert.informativeText = "Minutes between standup reminders:"
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 100, height: 24))
        input.stringValue = "\(config.intervalMinutes)"
        alert.accessoryView = input

        if #available(macOS 14.0, *) {
            NSApp.activate()
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let value = Int(input.stringValue), value > 0, value <= 1440 {
                config.intervalMinutes = value
                saveConfig(config)
                resetTimer()
            }
        }
    }

    @objc private func openLog() {
        let logFile = dataDir.appendingPathComponent("standups.csv")
        if !FileManager.default.fileExists(atPath: logFile.path) {
            try? "".write(to: logFile, atomically: true, encoding: .utf8)
        }
        NSWorkspace.shared.open(logFile)
    }

    // MARK: - Config Persistence

    private func loadConfig() -> Config {
        let configFile = dataDir.appendingPathComponent("config.json")
        guard let data = try? Data(contentsOf: configFile),
              var config = try? JSONDecoder().decode(Config.self, from: data) else {
            let defaultConfig = Config()
            saveConfig(defaultConfig)
            return defaultConfig
        }
        // Clamp to safe range to prevent integer overflow in intervalMinutes * 60
        config.intervalMinutes = max(1, min(config.intervalMinutes, 1440))
        return config
    }

    private func saveConfig(_ config: Config) {
        let configFile = dataDir.appendingPathComponent("config.json")
        if let data = try? JSONEncoder().encode(config) {
            try? data.write(to: configFile, options: .atomic)
        }
    }
}

// MARK: - Duplicate Instance Check

let dominated = NSRunningApplication.runningApplications(withBundleIdentifier: "com.local.StandupTimer")
if dominated.count > 1 {
    fputs("StandupTimer is already running\n", stderr)
    exit(0)
}

// MARK: - Entry Point

let app = NSApplication.shared
app.setActivationPolicy(.accessory) // hide from Dock even when running outside .app bundle
let delegate = AppDelegate()
app.delegate = delegate
app.run()
