import SwiftUI

struct APISettingsView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    SecureField("ElevenLabs API Key", text: $viewModel.elevenLabsApiKey)
                        .textFieldStyle(.roundedBorder)
                    Text("Get your API key from [ElevenLabs Dashboard](https://elevenlabs.io/)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Label("ElevenLabs", systemImage: "waveform")
                } footer: {
                    Text("Required for text-to-speech functionality")
                }
                
                Section {
                    SecureField("OpenAI API Key", text: $viewModel.openAIApiKey)
                        .textFieldStyle(.roundedBorder)
                    Text("Get your API key from [OpenAI Dashboard](https://platform.openai.com/)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Label("OpenAI", systemImage: "sparkles")
                } footer: {
                    Text("Required for grammar correction functionality")
                }
                
                Section {
                    SecureField("Anthropic API Key", text: $viewModel.anthropicApiKey)
                        .textFieldStyle(.roundedBorder)
                    Text("Get your API key from [Anthropic Console](https://console.anthropic.com/)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Label("Anthropic", systemImage: "brain")
                } footer: {
                    Text("Required for advanced AI functionality")
                }
            }
            .navigationTitle("API Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        viewModel.saveAPIKeys()
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 400, minHeight: 400)
    }
}
