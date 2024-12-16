import SwiftUI

@main
struct VoiceAssistApp: App {
    @StateObject private var viewModel: AppViewModel
    
    init() {
        let ttsService = TextToSpeechService(apiKey: ProcessInfo.processInfo.environment["ELEVEN_LABS_API_KEY"] ?? "")
        let aiService = AIService(apiKey: ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "")
        _viewModel = StateObject(wrappedValue: AppViewModel(ttsService: ttsService, aiService: aiService))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .frame(minWidth: 800, minHeight: 600)
                .background(Color(.windowBackgroundColor))
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
