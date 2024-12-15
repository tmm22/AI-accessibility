import Foundation
import AVFoundation

class TextToSpeechService: ObservableObject {
    private let apiKey: String
    private var audioPlayer: AVAudioPlayer?
    private let baseURL = "https://api.elevenlabs.io/v1"
    
    @Published var isGenerating = false
    @Published var error: Error?
    
    struct Voice: Identifiable, Codable {
        let id: String
        let name: String
        let previewURL: String?
        
        enum CodingKeys: String, CodingKey {
            case id, name
            case previewURL = "preview_url"
        }
    }
    
    struct VoiceSettings {
        var stability: Double
        var similarityBoost: Double
        
        static let `default` = VoiceSettings(stability: 0.75, similarityBoost: 0.75)
    }
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func fetchVoices() async throws -> [Voice] {
        guard let url = URL(string: "\(baseURL)/voices") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "xi-api-key")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode([Voice].self, from: data)
        return response
    }
    
    func generateSpeech(
        text: String,
        voiceId: String,
        settings: VoiceSettings = .default
    ) async throws -> Data {
        guard let url = URL(string: "\(baseURL)/text-to-speech/\(voiceId)") else {
            throw URLError(.badURL)
        }
        
        let parameters: [String: Any] = [
            "text": text,
            "voice_settings": [
                "stability": settings.stability,
                "similarity_boost": settings.similarityBoost
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "xi-api-key")
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return data
    }
    
    func playAudio(_ data: Data) throws {
        audioPlayer?.stop()
        audioPlayer = try AVAudioPlayer(data: data)
        audioPlayer?.play()
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    func previewVoiceSettings(
        text: String = "This is a preview of the voice settings.",
        voiceId: String,
        settings: VoiceSettings
    ) async throws {
        isGenerating = true
        defer { isGenerating = false }
        
        do {
            let audioData = try await generateSpeech(
                text: text,
                voiceId: voiceId,
                settings: settings
            )
            try playAudio(audioData)
        } catch {
            self.error = error
            throw error
        }
    }
}
