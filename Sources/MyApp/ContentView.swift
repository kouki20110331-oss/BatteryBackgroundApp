import SwiftUI
import AVKit
import AVFoundation

struct ContentView: View {

    @StateObject private var batteryMonitor = BatteryMonitor()

    var body: some View {
        ZStack {
            NormalView(batteryLevel: batteryMonitor.batteryLevel)
                .opacity(batteryMonitor.isCharging ? 0 : 1)

            ChargingView()
                .opacity(batteryMonitor.isCharging ? 1 : 0)
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 1.2), value: batteryMonitor.isCharging)
    }
}

// MARK: - Video Player
struct LoopingVideoPlayer: UIViewRepresentable {

    let videoName: String
    let videoExtension: String

    class Coordinator {
        var player: AVPlayer?
        var playerLayer: AVPlayerLayer?
        var observer: Any?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black

        guard let url = Bundle.main.url(
            forResource: videoName,
            withExtension: videoExtension
        ) else {
            print("⚠️ Video not found: \(videoName).\(videoExtension)")
            return view
        }

        let player = AVPlayer(url: url)
        player.isMuted = true

        let observer = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)

        context.coordinator.player = player
        context.coordinator.playerLayer = playerLayer
        context.coordinator.observer = observer

        player.play()
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.playerLayer?.frame = uiView.bounds
            if context.coordinator.player?.timeControlStatus == .paused {
                context.coordinator.player?.play()
            }
        }
    }
}

// MARK: - Clock
struct ClockView: View {

    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 8) {
            Text(timeString)
                .font(.system(size: 80, weight: .thin, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 8)

            Text(dateString)
                .font(.system(size: 20, weight: .light))
                .foregroundColor(.white.opacity(0.85))
                .shadow(color: .black.opacity(0.5), radius: 4)
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }

    private var timeString: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: currentTime)
    }

    private var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        f.locale = Locale(identifier: "en_US")
        return f.string(from: currentTime)
    }
}

// MARK: - Charging View
struct ChargingView: View {

    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            LoopingVideoPlayer(
                videoName: "ssstik.io_1781227610211",
                videoExtension: "mp4"
            )
            .ignoresSafeArea()

            VStack {
                Spacer().frame(height: 60)
                ClockView()
                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 28, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(pulseScale)
                        .shadow(color: .yellow.opacity(0.8), radius: 10)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                                pulseScale = 1.2
                            }
                        }

                    Text("Charging")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.white.opacity(0.7))
                        .tracking(2)
                }
                .padding(.bottom, 60)
            }
        }
    }
}

// MARK: - Normal View
struct NormalView: View {

    let batteryLevel: Float

    var body: some View {
        ZStack {
            LoopingVideoPlayer(
                videoName: "ssstik.io_1781358025043",
                videoExtension: "MP4"
            )
            .ignoresSafeArea()

            VStack {
                Spacer().frame(height: 60)
                ClockView()
                Spacer()

                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: batteryIconName)
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(batteryColor)

                        Text("\(Int(batteryLevel * 100))%")
                            .font(.system(size: 24, weight: .light, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                    }

                    Text("Swipe up to unlock")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(1)
                }
                .padding(.bottom, 60)
            }
        }
    }

    private var batteryIconName: String {
        switch batteryLevel {
        case 0..<0.25: return "battery.0percent"
        case 0..<0.50: return "battery.25percent"
        case 0..<0.75: return "battery.50percent"
        case 0..<1.0: return "battery.75percent"
        default: return "battery.100percent"
        }
    }

    private var batteryColor: Color {
        switch batteryLevel {
        case 0..<0.20: return .red
        case 0..<0.50: return .yellow
        default: return .green
        }
    }
}

// MARK: - Battery Monitor
@MainActor
class BatteryMonitor: ObservableObject {

    @Published var isCharging: Bool = false
    @Published var batteryLevel: Float = 1.0

    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        updateState()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryStateChanged),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryLevelChanged),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )
    }

    @objc private func batteryStateChanged() {
        updateState()
    }

    @objc private func batteryLevelChanged() {
        updateState()
    }

    private func updateState() {
        let state = UIDevice.current.batteryState
        isCharging = (state == .charging || state == .full)
        batteryLevel = max(UIDevice.current.batteryLevel, 0)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}