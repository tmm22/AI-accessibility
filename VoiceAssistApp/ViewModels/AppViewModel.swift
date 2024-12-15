import Foundation
import SwiftUI

@MainActor
class AppViewModel: ObservableObject {
    private let ttsService: TextToSpeechService
    private let aiService: AIService
    
    @Published var inputText = ""
    @Published var outputText = ""
    @Published var isProcessing = false
    @Published var error: Error?
    
    @Published var availableVoices: [TextToSpeechService.Voice] = []
    @Published var selectedVoice: TextToSpeechService.Voice?
    @Published var isGeneratingSpeech = false
    
    @Published var voiceStability: Double = 0.75
    @Published var voiceSimilarityBoost: Double = 0.75
    @Published var voicePresets: [VoicePreset] = []
    
    @AppStorage("selectedVoiceId") private var selectedVoiceId: String?
    @AppStorage("voiceStability") private var storedVoiceStability: Double = 0.75
    @AppStorage("voiceSimilarityBoost") private var storedVoiceSimilarityBoost: Double = 0.75
    @AppStorage("customPresets") private var storedCustomPresets: Data = Data()
    
    init(ttsService: TextToSpeechService, aiService: AIService) {
        self.ttsService = ttsService
        self.aiService = aiService
        
        // Load stored voice settings
        self.voiceStability = storedVoiceStability
        self.voiceSimilarityBoost = storedVoiceSimilarityBoost
        
        // Load presets
        loadPresets()
        
        Task {
            await loadVoices()
        }
    }
    
    private func loadPresets() {
        // Load default presets
        voicePresets = VoicePreset.defaultPresets
        
        // Load custom presets
        if !storedCustomPresets.isEmpty {
            do {
                let decoder = JSONDecoder()
                let customPresets = try decoder.decode([VoicePreset].self, from: storedCustomPresets)
                voicePresets.append(contentsOf: customPresets)
            } catch {
                print("Error loading custom presets: \(error)")
            }
        }
    }
    
    func saveVoicePreset(_ preset: VoicePreset) {
        // Only store custom presets
        if preset.category == .custom {
            var customPresets = voicePresets.filter { $0.category == .custom }
            customPresets.append(preset)
            
            do {
                let encoder = JSONEncoder()
                storedCustomPresets = try encoder.encode(customPresets)
            } catch {
                print("Error saving custom preset: \(error)")
            }
        }
        
        // Add to current presets
        voicePresets.append(preset)
    }
    
    func deleteVoicePreset(_ preset: VoicePreset) {
        // Only allow deleting custom presets
        guard preset.category == .custom else { return }
        
        voicePresets.removeAll { $0.id == preset.id }
        
        // Update stored presets
        let customPresets = voicePresets.filter { $0.category == .custom }
        do {
            let encoder = JSONEncoder()
            storedCustomPresets = try encoder.encode(customPresets)
        } catch {
            print("Error updating stored presets: \(error)")
        }
    }
    
    func loadVoices() async {
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
    
    func correctGrammar() async {
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            outputText = try await aiService.correctGrammar(inputText)
        } catch {
            self.error = error
        }
    }
    
    func speakText(_ text: String) async {
        guard let voice = selectedVoice else { return }
        isGeneratingSpeech = true
        defer { isGeneratingSpeech = false }
        
        do {
            let settings = TextToSpeechService.VoiceSettings(
                stability: voiceStability,
                similarityBoost: voiceSimilarityBoost
            )
            
            let audioData = try await ttsService.generateSpeech(
                text: text,
                voiceId: voice.id,
                settings: settings
            )
            try ttsService.playAudio(audioData)
        } catch {
            self.error = error
        }
    }
    
    func stopSpeaking() {
        ttsService.stopAudio()
    }
    
    func updateVoiceSettings(stability: Double, similarityBoost: Double) {
        voiceStability = stability
        voiceSimilarityBoost = similarityBoost
        
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
