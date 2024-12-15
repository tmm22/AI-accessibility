import Foundation

struct VoicePreset: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let settings: TextToSpeechService.VoiceSettings
    let category: Category
    let tags: [String]
    
    enum Category: String, Codable, CaseIterable {
        case conversation = "Conversation"
        case narrative = "Narrative"
        case professional = "Professional"
        case accessibility = "Accessibility"
        case custom = "Custom"
    }
    
    static let defaultPresets: [VoicePreset] = [
        // Conversation Presets
        VoicePreset(
            id: "casual-chat",
            name: "Casual Chat",
            description: "Natural, relaxed tone for everyday conversations",
            settings: .init(stability: 0.65, similarityBoost: 0.75),
            category: .conversation,
            tags: ["casual", "friendly", "natural"]
        ),
        VoicePreset(
            id: "clear-speech",
            name: "Clear Speech",
            description: "Highly articulate for better understanding",
            settings: .init(stability: 0.85, similarityBoost: 0.80),
            category: .conversation,
            tags: ["clear", "articulate", "precise"]
        ),
        
        // Narrative Presets
        VoicePreset(
            id: "storytelling",
            name: "Storytelling",
            description: "Expressive and dynamic for engaging narratives",
            settings: .init(stability: 0.55, similarityBoost: 0.70),
            category: .narrative,
            tags: ["expressive", "dynamic", "engaging"]
        ),
        VoicePreset(
            id: "audiobook",
            name: "Audiobook",
            description: "Consistent and clear for long-form content",
            settings: .init(stability: 0.80, similarityBoost: 0.85),
            category: .narrative,
            tags: ["consistent", "professional", "clear"]
        ),
        
        // Professional Presets
        VoicePreset(
            id: "business",
            name: "Business",
            description: "Professional and authoritative tone",
            settings: .init(stability: 0.90, similarityBoost: 0.80),
            category: .professional,
            tags: ["professional", "formal", "business"]
        ),
        VoicePreset(
            id: "presentation",
            name: "Presentation",
            description: "Engaging yet professional for presentations",
            settings: .init(stability: 0.75, similarityBoost: 0.85),
            category: .professional,
            tags: ["presentation", "engaging", "formal"]
        ),
        
        // Accessibility Presets
        VoicePreset(
            id: "screen-reader",
            name: "Screen Reader",
            description: "Maximum clarity and consistency for accessibility",
            settings: .init(stability: 0.95, similarityBoost: 0.90),
            category: .accessibility,
            tags: ["accessibility", "clear", "consistent"]
        ),
        VoicePreset(
            id: "learning-support",
            name: "Learning Support",
            description: "Clear and patient tone for educational content",
            settings: .init(stability: 0.85, similarityBoost: 0.85),
            category: .accessibility,
            tags: ["education", "clear", "patient"]
        )
    ]
}
