import SwiftUI

@MainActor
class AppViewModel: ObservableObject {
    private var ttsService: TextToSpeechService
    private var aiService: AIService
    
    @Published var inputText = ""
    @Published var outputText = ""
    @Published var isProcessing = false
    @Published var isGeneratingSpeech = false
    @Published var error: Error?
    
    @Published var selectedVoice: TextToSpeechService.Voice?
    @Published var voiceSettings = TextToSpeechService.VoiceSettings(stability: 0.75, similarityBoost: 0.75)
    @Published var availableVoices: [TextToSpeechService.Voice] = []
    @Published var voicePresets: [VoicePreset] = []
    
    @AppStorage("ElevenLabsAPIKey") var elevenLabsApiKey: String = ""
    @AppStorage("OpenAIAPIKey") var openAIApiKey: String = ""
    @AppStorage("selectedVoiceId") private var selectedVoiceId: String?
    @AppStorage("voiceStability") private var storedVoiceStability: Double = 0.75
    @AppStorage("voiceSimilarityBoost") private var storedVoiceSimilarityBoost: Double = 0.75
    @AppStorage("customPresets") private var storedCustomPresets: Data = Data()
    
    init() {
        self.ttsService = TextToSpeechService(apiKey: "")
        self.aiService = AIService(apiKey: "")
        
        // Load stored voice settings
        self.voiceSettings.stability = storedVoiceStability
        self.voiceSettings.similarityBoost = storedVoiceSimilarityBoost
        
        loadAPIKeys()
        
        Task {
            await loadVoices()
            loadPresets()
        }
    }
    
    func saveAPIKeys() {
        ttsService = TextToSpeechService(apiKey: elevenLabsApiKey)
        aiService = AIService(apiKey: openAIApiKey)
        
        Task {
            await loadVoices()
        }
    }
    
    private func loadAPIKeys() {
        if !elevenLabsApiKey.isEmpty {
            ttsService = TextToSpeechService(apiKey: elevenLabsApiKey)
        }
        
        if !openAIApiKey.isEmpty {
            aiService = AIService(apiKey: openAIApiKey)
        }
    }
    
    func correctGrammar() async {
        guard !inputText.isEmpty else { return }
        
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            outputText = try await aiService.correctGrammar(inputText)
        } catch {
            self.error = error
        }
    }
    
    func speakText(_ text: String) async {
        guard !text.isEmpty, let voice = selectedVoice else { return }
        
        isGeneratingSpeech = true
        defer { isGeneratingSpeech = false }
        
        do {
            try await ttsService.generateSpeech(text: text, voiceId: voice.id, settings: voiceSettings)
        } catch {
            self.error = error
        }
    }
    
    func applyPreset(_ preset: VoicePreset) {
        voiceSettings = preset.settings
    }
    
    func savePreset(name: String, description: String, category: VoicePreset.Category, tags: [String]) {
        let preset = VoicePreset(
            id: UUID().uuidString,
            name: name,
            description: description,
            settings: voiceSettings,
            category: category,
            tags: tags
        )
        
        voicePresets.append(preset)
        savePresets()
    }
    
    private func loadVoices() async {
        do {
            availableVoices = try await ttsService.fetchVoices()
            if let voiceId = selectedVoiceId {
                selectedVoice = availableVoices.first { $0.id == voiceId }
            } else {
                selectedVoice = availableVoices.first
                selectedVoiceId = selectedVoice?.id
            }
        } catch {
            self.error = error
        }
    }
    
    private func loadPresets() {
        if let data = storedCustomPresets.isEmpty ? UserDefaults.standard.data(forKey: "VoicePresets") : storedCustomPresets,
           let presets = try? JSONDecoder().decode([VoicePreset].self, from: data) {
            voicePresets = presets
        } else {
            voicePresets = VoicePreset.defaultPresets
        }
    }
    
    private func savePresets() {
        if let data = try? JSONEncoder().encode(voicePresets) {
            storedCustomPresets = data
            UserDefaults.standard.set(data, forKey: "VoicePresets")
        }
    }
    
    func stopSpeaking() {
        ttsService.stopAudio()
    }
    
    func updateVoiceSettings(stability: Double, similarityBoost: Double) {
        voiceSettings.stability = stability
        voiceSettings.similarityBoost = similarityBoost
        
        // Store settings
        storedVoiceStability = stability
        storedVoiceSimilarityBoost = similarityBoost
    }
    
    func previewVoiceSettings(stability: Double, similarityBoost: Double) {
        guard let voice = selectedVoice else { return }
        
        Task {
            do {
                let settings = TextToSpeechService.VoiceSettings(
                    stability: stability,
                    similarityBoost: similarityBoost
                )
                
                try await ttsService.previewVoiceSettings(
                    voiceId: voice.id,
                    settings: settings
                )
            } catch {
                self.error = error
            }
        }
    }
}
