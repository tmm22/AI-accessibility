import XCTest
@testable import VoiceAssistApp

final class AppViewModelTests: XCTestCase {
    var viewModel: AppViewModel!
    let userDefaults = UserDefaults.standard
    
    override func setUp() {
        super.setUp()
        // Clear any existing keys before each test
        userDefaults.removeObject(forKey: "OpenAIKey")
        userDefaults.removeObject(forKey: "AnthropicKey")
        userDefaults.removeObject(forKey: "ElevenLabsKey")
        userDefaults.removeObject(forKey: "SelectedVoiceID")
        
        viewModel = AppViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertEqual(viewModel.inputText, "")
        XCTAssertEqual(viewModel.outputText, "")
        XCTAssertFalse(viewModel.isRecording)
        XCTAssertFalse(viewModel.isSpeaking)
        XCTAssertEqual(viewModel.selectedAIProvider, .openAI)
        XCTAssertFalse(viewModel.isProcessing)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - API Key Management Tests
    
    func testSetOpenAIKey() {
        let testKey = "test_openai_key"
        viewModel.setAPIKey(for: .openAI, key: testKey)
        
        XCTAssertEqual(userDefaults.string(forKey: "OpenAIKey"), testKey)
    }
    
    func testSetAnthropicKey() {
        let testKey = "test_anthropic_key"
        viewModel.setAPIKey(for: .anthropic, key: testKey)
        
        XCTAssertEqual(userDefaults.string(forKey: "AnthropicKey"), testKey)
    }
    
    func testSetElevenLabsKey() {
        let testKey = "test_elevenlabs_key"
        let testVoiceID = "test_voice_id"
        viewModel.setElevenLabsKey(testKey, voiceID: testVoiceID)
        
        XCTAssertEqual(userDefaults.string(forKey: "ElevenLabsKey"), testKey)
        XCTAssertEqual(userDefaults.string(forKey: "SelectedVoiceID"), testVoiceID)
    }
    
    // MARK: - Grammar Correction Tests
    
    func testGrammarCorrectionWithoutAPIKey() async {
        await viewModel.correctGrammar()
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("Please set up API key") ?? false)
    }
    
    func testGrammarCorrectionWithEmptyInput() async {
        viewModel.inputText = ""
        await viewModel.correctGrammar()
        XCTAssertEqual(viewModel.outputText, "")
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - Text-to-Speech Tests
    
    func testToggleSpeechWithoutAPIKey() async {
        await viewModel.toggleSpeech()
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("Please set up Eleven Labs API key") ?? false)
    }
    
    func testToggleSpeechWithEmptyText() async {
        viewModel.inputText = ""
        viewModel.outputText = ""
        await viewModel.toggleSpeech()
        XCTAssertFalse(viewModel.isSpeaking)
    }
}
