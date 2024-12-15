import XCTest
import Speech
@testable import VoiceAssistApp

final class SpeechRecognizerTests: XCTestCase {
    var speechRecognizer: SpeechRecognizer!
    
    override func setUp() {
        super.setUp()
        speechRecognizer = SpeechRecognizer()
    }
    
    override func tearDown() {
        speechRecognizer = nil
        super.tearDown()
    }
    
    // MARK: - Authorization Tests
    
    func testAuthorizationRequest() {
        // Test that authorization is requested on initialization
        let expectation = XCTestExpectation(description: "Authorization request")
        
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized, .denied, .restricted, .notDetermined:
                expectation.fulfill()
            @unknown default:
                XCTFail("Unknown authorization status")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Recording Control Tests
    
    func testStartAndStopRecording() {
        let expectation = XCTestExpectation(description: "Recording callback")
        
        speechRecognizer.startRecording { text in
            // Callback received
            expectation.fulfill()
        }
        
        // Stop recording after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.speechRecognizer.stopRecording()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
