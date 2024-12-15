import Foundation
@testable import VoiceAssistApp

// MARK: - Mock Services

class MockAIService: AIServiceProtocol {
    var shouldSucceed = true
    var correctedText = "Corrected test text"
    
    func correctText(_ text: String) async throws -> String {
        if shouldSucceed {
            return correctedText
        } else {
            throw NSError(domain: "MockAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
    }
}

class MockTextToSpeechService: TextToSpeechService {
    var shouldSucceed = true
    
    override func speak(_ text: String) async throws {
        if !shouldSucceed {
            throw TTSError.networkError(NSError(domain: "MockTTS", code: -1))
        }
        await MainActor.run {
            isPlaying = true
        }
    }
}

// MARK: - Test Data

enum TestData {
    static let sampleText = "This is a test sentence."
    static let sampleCorrectedText = "This is a corrected test sentence."
    static let mockOpenAIKey = "mock_openai_key"
    static let mockAnthropicKey = "mock_anthropic_key"
    static let mockElevenLabsKey = "mock_elevenlabs_key"
    static let mockVoiceID = "mock_voice_id"
}

// MARK: - Test Extensions

extension UserDefaults {
    static var test: UserDefaults {
        let defaults = UserDefaults(suiteName: #file)!
        defaults.removePersistentDomain(forName: #file)
        return defaults
    }
}
