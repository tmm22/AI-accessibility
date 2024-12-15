import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var openAIKey: String = UserDefaults.standard.string(forKey: "OpenAIKey") ?? ""
    @State private var anthropicKey: String = UserDefaults.standard.string(forKey: "AnthropicKey") ?? ""
    @State private var elevenLabsKey: String = UserDefaults.standard.string(forKey: "ElevenLabsKey") ?? ""
    @State private var selectedVoiceID: String = UserDefaults.standard.string(forKey: "SelectedVoiceID") ?? ""
    @Environment(\.dismiss) private var dismiss
    
    private let commonVoices = [
        ("Rachel", "21m00Tcm4TlvDq8ikWAM"),
        ("Domi", "AZnzlk1XvdvUeBnXmlld"),
        ("Bella", "EXAVITQu4vr4xnSDxMaL"),
        ("Antoni", "ErXwobaYiN019PkySvjV"),
        ("Elli", "MF3mGyEYCl7XYWbV9V6O"),
        ("Josh", "TxGEqnHWrfWFTfGW9XjX"),
        ("Arnold", "VR6AewLTigWG4xSOukaG"),
        ("Adam", "pNInz6obpgDQGcFmaJgB"),
        ("Sam", "yoZ06aMxZJJ28mfd3POQ")
    ]
    
    var body: some View {
        Form {
            Section("AI Services") {
                VStack(alignment: .leading) {
                    Text("OpenAI")
                        .font(.headline)
                    SecureField("API Key", text: $openAIKey)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: openAIKey) { newValue in
                            viewModel.setAPIKey(for: .openAI, key: newValue)
                        }
                }
                
                VStack(alignment: .leading) {
                    Text("Anthropic")
                        .font(.headline)
                    SecureField("API Key", text: $anthropicKey)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: anthropicKey) { newValue in
                            viewModel.setAPIKey(for: .anthropic, key: newValue)
                        }
                }
            }
            
            Section("Text-to-Speech") {
                VStack(alignment: .leading) {
                    Text("Eleven Labs")
                        .font(.headline)
                    SecureField("API Key", text: $elevenLabsKey)
                        .textFieldStyle(.roundedBorder)
                    
                    Text("Voice")
                        .font(.headline)
                        .padding(.top, 8)
                    Picker("Voice", selection: $selectedVoiceID) {
                        Text("Select a voice").tag("")
                        ForEach(commonVoices, id: \.1) { voice in
                            Text(voice.0).tag(voice.1)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .onChange(of: elevenLabsKey) { _ in
                    updateTTSSettings()
                }
                .onChange(of: selectedVoiceID) { _ in
                    updateTTSSettings()
                }
            }
            
            Button("Done") {
                dismiss()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .frame(width: 400, height: 500)
    }
    
    private func updateTTSSettings() {
        viewModel.setElevenLabsKey(elevenLabsKey, voiceID: selectedVoiceID)
    }
}
