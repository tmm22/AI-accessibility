import SwiftUI

@main
struct VoiceAssistApp: App {
    @StateObject private var viewModel = AppViewModel()
    @State private var isShowingSettings = false
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .frame(minWidth: 800, minHeight: 600)
                .background(Color(.windowBackgroundColor))
                .sheet(isPresented: $isShowingSettings) {
                    APISettingsView(viewModel: viewModel)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Settings") {
                    isShowingSettings = true
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}
