import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Input Section
                GroupBox(label: Label("Input Text", systemImage: "text.bubble")) {
                    TextEditor(text: $viewModel.inputText)
                        .frame(minHeight: 120, maxHeight: .infinity)
                        .font(.body)
                        .padding(8)
                        .background(Color(.textBackgroundColor))
                        .cornerRadius(8)
                }
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button(action: {
                        Task {
                            await viewModel.correctGrammar()
                        }
                    }) {
                        Label("Correct Grammar", systemImage: "checkmark.circle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.inputText.isEmpty || viewModel.isProcessing)
                    
                    Button(action: {
                        Task {
                            await viewModel.speakText(viewModel.outputText.isEmpty ? viewModel.inputText : viewModel.outputText)
                        }
                    }) {
                        Label("Speak", systemImage: "speaker.wave.2")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.inputText.isEmpty || viewModel.isGeneratingSpeech)
                }
                .padding(.vertical, 8)
                
                // Output Section
                if !viewModel.outputText.isEmpty {
                    GroupBox(label: Label("Corrected Text", systemImage: "text.quote")) {
                        TextEditor(text: .constant(viewModel.outputText))
                            .frame(minHeight: 120, maxHeight: .infinity)
                            .font(.body)
                            .padding(8)
                            .background(Color(.textBackgroundColor))
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .frame(minWidth: 600, minHeight: 400)
            .navigationTitle("VoiceAssist")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingSettings = true }) {
                        Label("Voice Settings", systemImage: "slider.horizontal.3")
                            .labelStyle(.titleAndIcon)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                VoiceSettingsView(viewModel: viewModel)
                    .frame(minWidth: 500, minHeight: 600)
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
