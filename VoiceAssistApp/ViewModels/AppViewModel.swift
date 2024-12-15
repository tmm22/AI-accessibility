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
    
    @AppStorage("selectedVoiceId") private var selectedVoiceId: String?
    @AppStorage("voiceStability") private var storedVoiceStability: Double = 0.75
    @AppStorage("voiceSimilarityBoost") private var storedVoiceSimilarityBoost: Double = 0.75
    
    init(ttsService: TextToSpeechService, aiService: AIService) {
        self.ttsService = ttsService
        self.aiService = aiService
        
        // Load stored voice settings
        self.voiceStability = storedVoiceStability
        self.voiceSimilarityBoost = storedVoiceSimilarityBoost
        
        Task {
            await loadVoices()
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
