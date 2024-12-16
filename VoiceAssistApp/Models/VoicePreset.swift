import Foundation

struct VoicePreset: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let settings: TextToSpeechService.VoiceSettings
    let category: Category
    let tags: [String]
    
    enum Category: String, Codable, CaseIterable, Identifiable {
        case conversation = "Conversation"
        case narrative = "Narrative"
        case professional = "Professional"
        case accessibility = "Accessibility"
        case custom = "Custom"
        
        var id: String { rawValue }
    }
    
    static let defaultPresets: [VoicePreset] = [
        // Conversation Presets
        VoicePreset(
            id: "casual-chat",
            name: "Casual Chat",
            description: "Natural, relaxed voice for everyday conversations",
            settings: .init(stability: 0.7, similarityBoost: 0.8),
            category: .conversation,
            tags: ["casual", "friendly", "natural"]
        ),
        VoicePreset(
            id: "clear-speech",
            name: "Clear Speech",
            description: "Highly articulate voice for clear communication",
            settings: .init(stability: 0.9, similarityBoost: 0.7),
            category: .conversation,
            tags: ["clear", "articulate", "precise"]
        ),
        
        // Narrative Presets
        VoicePreset(
            id: "storytelling",
            name: "Storytelling",
            description: "Engaging voice for narrative content",
            settings: .init(stability: 0.8, similarityBoost: 0.9),
            category: .narrative,
            tags: ["expressive", "dynamic", "engaging"]
        ),
        VoicePreset(
            id: "audiobook",
            name: "Audiobook",
            description: "Professional voice for audiobook narration",
            settings: .init(stability: 0.85, similarityBoost: 0.8),
            category: .narrative,
            tags: ["professional", "consistent", "clear"]
        ),
        
        // Professional Presets
        VoicePreset(
            id: "business",
            name: "Business",
            description: "Professional voice for business communications",
            settings: .init(stability: 0.95, similarityBoost: 0.7),
            category: .professional,
            tags: ["formal", "professional", "business"]
        ),
        VoicePreset(
            id: "presentation",
            name: "Presentation",
            description: "Confident voice for presentations and speeches",
            settings: .init(stability: 0.9, similarityBoost: 0.8),
            category: .professional,
            tags: ["confident", "authoritative", "clear"]
        ),
        
        // Accessibility Presets
        VoicePreset(
            id: "screen-reader",
            name: "Screen Reader",
            description: "Clear and consistent voice for screen reading",
            settings: .init(stability: 1.0, similarityBoost: 0.6),
            category: .accessibility,
            tags: ["clear", "consistent", "accessible"]
        ),
        VoicePreset(
            id: "learning-support",
            name: "Learning Support",
            description: "Patient voice for educational content",
            settings: .init(stability: 0.9, similarityBoost: 0.7),
            category: .accessibility,
            tags: ["patient", "clear", "educational"]
        )
    ]
}
