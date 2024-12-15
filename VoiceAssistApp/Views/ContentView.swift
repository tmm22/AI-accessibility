import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextEditor(text: $viewModel.inputText)
                    .frame(height: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                
                HStack {
                    Button(action: {
                        Task {
                            await viewModel.correctGrammar()
                        }
                    }) {
                        Label("Correct Grammar", systemImage: "checkmark.circle")
                    }
                    .disabled(viewModel.inputText.isEmpty || viewModel.isProcessing)
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await viewModel.speakText(viewModel.outputText.isEmpty ? viewModel.inputText : viewModel.outputText)
                        }
                    }) {
                        Label("Speak", systemImage: "speaker.wave.2")
                    }
                    .disabled(viewModel.inputText.isEmpty || viewModel.isGeneratingSpeech)
                }
                
                if !viewModel.outputText.isEmpty {
                    TextEditor(text: .constant(viewModel.outputText))
                        .frame(height: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("VoiceAssist")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingSettings = true }) {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                VoiceSettingsView(viewModel: viewModel)
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "")
            }
        }
    }
}
