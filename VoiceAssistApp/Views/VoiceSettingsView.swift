import SwiftUI

struct VoiceSettingsView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var stability: Double = 0.75
    @State private var similarityBoost: Double = 0.75
    
    var body: some View {
        Form {
            Section(header: Text("Voice Selection")) {
                Picker("Voice", selection: $viewModel.selectedVoice) {
                    ForEach(viewModel.availableVoices, id: \.id) { voice in
                        Text(voice.name).tag(voice)
                    }
                }
            }
            
            Section(header: Text("Voice Parameters")) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Stability")
                        Spacer()
                        Text(String(format: "%.2f", stability))
                    }
                    Slider(value: $stability, in: 0...1) { editing in
                        if !editing {
                            viewModel.updateVoiceSettings(stability: stability, similarityBoost: similarityBoost)
                        }
                    }
                    .onChange(of: stability) { newValue in
                        viewModel.previewVoiceSettings(stability: newValue, similarityBoost: similarityBoost)
                    }
                    
                    Text("Controls consistency in voice generation")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Similarity Boost")
                        Spacer()
                        Text(String(format: "%.2f", similarityBoost))
                    }
                    Slider(value: $similarityBoost, in: 0...1) { editing in
                        if !editing {
                            viewModel.updateVoiceSettings(stability: stability, similarityBoost: similarityBoost)
                        }
                    }
                    .onChange(of: similarityBoost) { newValue in
                        viewModel.previewVoiceSettings(stability: stability, similarityBoost: newValue)
                    }
                    
                    Text("Controls similarity to the original voice")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Preview")) {
                Button("Preview Settings") {
                    viewModel.previewVoiceSettings(
                        stability: stability,
                        similarityBoost: similarityBoost
                    )
                }
                .disabled(viewModel.isGeneratingSpeech)
            }
        }
        .padding()
        .onAppear {
            stability = viewModel.voiceStability
            similarityBoost = viewModel.voiceSimilarityBoost
        }
    }
}
