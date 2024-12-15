import XCTest
@testable import VoiceAssistApp

final class UITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }
    
    // MARK: - ContentView Tests
    
    func testMainUIElements() {
        // Verify all main UI elements are present
        XCTAssertTrue(app.textViews["inputTextEditor"].exists)
        XCTAssertTrue(app.buttons["Start Recording"].exists)
        XCTAssertTrue(app.buttons["Correct Grammar"].exists)
        XCTAssertTrue(app.buttons["Speak Text"].exists)
    }
    
    func testSettingsButton() {
        // Test settings button opens settings view
        let settingsButton = app.buttons["settingsButton"]
        XCTAssertTrue(settingsButton.exists)
        
        settingsButton.tap()
        
        // Verify settings view is presented
        let settingsTitle = app.staticTexts["AI Services"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 2))
    }
    
    func testAIProviderSelection() {
        // Test AI provider picker
        let picker = app.segmentedControls["aiProviderPicker"]
        XCTAssertTrue(picker.exists)
        
        // Test switching between providers
        picker.buttons["Anthropic"].tap()
        XCTAssertEqual(picker.selectedSegmentIndex, 1)
        
        picker.buttons["OpenAI"].tap()
        XCTAssertEqual(picker.selectedSegmentIndex, 0)
    }
    
    // MARK: - SettingsView Tests
    
    func testSettingsViewFields() {
        // Open settings
        app.buttons["settingsButton"].tap()
        
        // Verify all API key fields exist
        XCTAssertTrue(app.secureTextFields["OpenAI API Key"].exists)
        XCTAssertTrue(app.secureTextFields["Anthropic API Key"].exists)
        XCTAssertTrue(app.secureTextFields["Eleven Labs API Key"].exists)
        
        // Verify voice picker exists
        XCTAssertTrue(app.pickers["voicePicker"].exists)
        
        // Test closing settings
        app.buttons["Done"].tap()
        XCTAssertFalse(app.staticTexts["AI Services"].exists)
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabels() {
        // Test that all important elements have accessibility labels
        XCTAssertTrue(app.buttons["Start Recording"].hasValidAccessibilityLabel)
        XCTAssertTrue(app.buttons["Correct Grammar"].hasValidAccessibilityLabel)
        XCTAssertTrue(app.buttons["Speak Text"].hasValidAccessibilityLabel)
        XCTAssertTrue(app.textViews["inputTextEditor"].hasValidAccessibilityLabel)
    }
}

extension XCUIElement {
    var hasValidAccessibilityLabel: Bool {
        return (value(forKey: "accessibilityLabel") as? String)?.isEmpty == false
    }
}
