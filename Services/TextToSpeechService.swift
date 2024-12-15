import Foundation
import AVFoundation

enum TTSError: Error {
    case invalidAPIKey
    case invalidVoiceID
    case networkError(Error)
    case audioPlaybackError(Error)
    case invalidResponse
}

class TextToSpeechService: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    private let apiKey: String
    private let voiceID: String
    
    @Published var isPlaying = false
    @Published var error: String?
    
    init(apiKey: String, voiceID: String) {
        self.apiKey = apiKey
        self.voiceID = voiceID
    }
    
    func speak(_ text: String) async throws {
        guard !apiKey.isEmpty else {
            throw TTSError.invalidAPIKey
        }
        
        guard !voiceID.isEmpty else {
            throw TTSError.invalidVoiceID
        }
        
        let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(voiceID)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        
        let payload: [String: Any] = [
            "text": text,
            "model_id": "eleven_monolingual_v1",
            "voice_settings": [
                "stability": 0.5,
                "similarity_boost": 0.75
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw TTSError.invalidResponse
            }
            
            try await playAudio(data)
        } catch {
            throw TTSError.networkError(error)
        }
    }
    
    func stopSpeaking() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    private func playAudio(_ data: Data) async throws {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            
            guard let player = audioPlayer else {
                throw TTSError.audioPlaybackError(NSError(domain: "", code: -1))
            }
            
            await MainActor.run {
                isPlaying = true
            }
            
            player.play()
        } catch {
            throw TTSError.audioPlaybackError(error)
        }
    }
}

extension TextToSpeechService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async {
            self.error = error?.localizedDescription
            self.isPlaying = false
        }
    }
}
