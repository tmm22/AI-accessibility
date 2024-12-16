import SwiftUI

@main
struct VoiceAssistApp: App {
    @StateObject private var viewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .frame(minWidth: 800, minHeight: 600)
                .background(Color(.windowBackgroundColor))
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Settings") {
                    NSApp.sendAction(#selector(NSPopover.performClose(_:)), to: nil, from: nil)
                    let settingsWindow = NSWindow(
                        contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
                        styleMask: [.titled, .closable],
                        backing: .buffered,
                        defer: false
                    )
                    settingsWindow.title = "Settings"
                    settingsWindow.contentView = NSHostingView(
                        rootView: APISettingsView(viewModel: viewModel)
                            .frame(width: 400, height: 300)
                    )
                    settingsWindow.center()
                    settingsWindow.makeKeyAndOrderFront(nil)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}
