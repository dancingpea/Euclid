import AVFoundation

/// Programmatic sound generation using AVAudioEngine. No audio files needed.
final class SoundManager {
    static let shared = SoundManager()

    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let sampleRate: Double = 44100
    private let audioFormat: AVAudioFormat

    private init() {
        // Use a single consistent format everywhere: mono, 44100 Hz
        audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: audioFormat)

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            try audioEngine.start()
        } catch {
            print("SoundManager: Failed to start: \(error)")
        }
    }

    /// Play a short tone at the given frequency and duration.
    func playTone(frequency: Double, duration: Double = 0.15, volume: Float = 0.3) {
        guard audioEngine.isRunning else { return }

        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount

        guard let data = buffer.floatChannelData?[0] else { return }
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let envelope = Float(max(0, 1.0 - t / duration))
            data[i] = volume * envelope * Float(sin(2.0 * .pi * frequency * t))
        }

        if !playerNode.isPlaying {
            playerNode.play()
        }
        playerNode.scheduleBuffer(buffer, completionHandler: nil)
    }

    func correctSound() {
        playTone(frequency: 880, duration: 0.12, volume: 0.25)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            self.playTone(frequency: 1320, duration: 0.15, volume: 0.2)
        }
    }

    func wrongSound() {
        playTone(frequency: 280, duration: 0.25, volume: 0.25)
    }

    func buttonSound() {
        playTone(frequency: 600, duration: 0.05, volume: 0.15)
    }

    func countdownTickSound() {
        playTone(frequency: 440, duration: 0.04, volume: 0.1)
    }

    func gameStartSound() {
        playTone(frequency: 523, duration: 0.1, volume: 0.2)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.playTone(frequency: 659, duration: 0.1, volume: 0.2)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.playTone(frequency: 784, duration: 0.15, volume: 0.25)
        }
    }

    func gameEndSound() {
        playTone(frequency: 784, duration: 0.15, volume: 0.2)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.playTone(frequency: 523, duration: 0.3, volume: 0.2)
        }
    }
}
