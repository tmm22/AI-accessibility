import XCTest
@testable import VoiceAssistApp

final class TextToSpeechServiceTests: XCTestCase {
    var ttsService: TextToSpeechService!
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        ttsService = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitializationWithEmptyAPIKey() {
        ttsService = TextToSpeechService(apiKey: "", voiceID: "test_voice_id")
        
        Task {
            do {
                try await ttsService.speak("Test text")
                XCTFail("Should throw an error for empty API key")
            } catch TTSError.invalidAPIKey {
                // Expected error
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testInitializationWithEmptyVoiceID() {
        ttsService = TextToSpeechService(apiKey: "test_key", voiceID: "")
        
        Task {
            do {
                try await ttsService.speak("Test text")
                XCTFail("Should throw an error for empty voice ID")
            } catch TTSError.invalidVoiceID {
                // Expected error
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    // MARK: - Speech Control Tests
    
    func testStopSpeaking() {
        ttsService = TextToSpeechService(apiKey: "test_key", voiceID: "test_voice_id")
        ttsService.stopSpeaking()
        XCTAssertFalse(ttsService.isPlaying)
    }
}
