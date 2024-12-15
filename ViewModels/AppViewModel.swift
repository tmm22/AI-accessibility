import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var outputText = ""
    @Published var isRecording = false
    @Published var isSpeaking = false
    @Published var selectedAIProvider: AIProvider = .openAI
    @Published var isProcessing = false
    @Published var errorMessage: String?
    
    private var openAIService: OpenAIService?
    private var anthropicService: AnthropicService?
    private var ttsService: TextToSpeechService?
    
    private var currentAIService: AIServiceProtocol? {
        switch selectedAIProvider {
        case .openAI:
            return openAIService
        case .anthropic:
            return anthropicService
        }
    }
    
    init() {
        setupServices()
    }
    
    private func setupServices() {
        if let openAIKey = UserDefaults.standard.string(forKey: "OpenAIKey") {
            openAIService = OpenAIService(apiKey: openAIKey)
        }
        
        if let anthropicKey = UserDefaults.standard.string(forKey: "AnthropicKey") {
            anthropicService = AnthropicService(apiKey: anthropicKey)
        }
        
        if let elevenLabsKey = UserDefaults.standard.string(forKey: "ElevenLabsKey"),
           let voiceID = UserDefaults.standard.string(forKey: "SelectedVoiceID") {
            ttsService = TextToSpeechService(apiKey: elevenLabsKey, voiceID: voiceID)
        }
    }
    
    func setAPIKey(for provider: AIProvider, key: String) {
        switch provider {
        case .openAI:
            UserDefaults.standard.set(key, forKey: "OpenAIKey")
            openAIService = OpenAIService(apiKey: key)
        case .anthropic:
            UserDefaults.standard.set(key, forKey: "AnthropicKey")
            anthropicService = AnthropicService(apiKey: key)
        }
    }
    
    func setElevenLabsKey(_ key: String, voiceID: String) {
        UserDefaults.standard.set(key, forKey: "ElevenLabsKey")
        UserDefaults.standard.set(voiceID, forKey: "SelectedVoiceID")
        ttsService = TextToSpeechService(apiKey: key, voiceID: voiceID)
    }
    
    @MainActor
    func correctGrammar() async {
        guard !inputText.isEmpty else { return }
        guard let aiService = currentAIService else {
            errorMessage = "Please set up API key for \(selectedAIProvider == .openAI ? "OpenAI" : "Anthropic")"
            return
        }
        
        isProcessing = true
        errorMessage = nil
        
        do {
            outputText = try await aiService.correctText(inputText)
        } catch {
            errorMessage = "Error correcting text: \(error.localizedDescription)"
        }
        
        isProcessing = false
    }
    
    @MainActor
    func toggleSpeech() async {
        guard let tts = ttsService else {
            errorMessage = "Please set up Eleven Labs API key and voice ID in settings"
            return
        }
        
        if tts.isPlaying {
            tts.stopSpeaking()
            isSpeaking = false
        } else {
            let textToSpeak = !outputText.isEmpty ? outputText : inputText
            guard !textToSpeak.isEmpty else { return }
            
            do {
                isSpeaking = true
                try await tts.speak(textToSpeak)
            } catch {
                errorMessage = "Error speaking text: \(error.localizedDescription)"
                isSpeaking = false
            }
        }
    }
}
