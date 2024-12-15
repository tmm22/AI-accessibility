import SwiftUI
import Speech

struct ContentView: View {
    @StateObject private var viewModel = AppViewModel()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("VoiceAssist")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gear")
                }
            }
            .padding()
            
            TextEditor(text: $viewModel.inputText)
                .font(.body)
                .frame(height: 150)
                .border(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            HStack {
                Picker("AI Provider", selection: $viewModel.selectedAIProvider) {
                    Text("OpenAI").tag(AIProvider.openAI)
                    Text("Anthropic").tag(AIProvider.anthropic)
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    viewModel.isRecording.toggle()
                    if viewModel.isRecording {
                        speechRecognizer.startRecording { text in
                            viewModel.inputText += text + " "
                        }
                    } else {
                        speechRecognizer.stopRecording()
                    }
                }) {
                    Label(viewModel.isRecording ? "Stop Recording" : "Start Recording", 
                          systemImage: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: {
                    Task {
                        await viewModel.correctGrammar()
                    }
                }) {
                    Label("Correct Grammar", systemImage: "wand.and.stars")
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isProcessing)
                
                Button(action: {
                    Task {
                        await viewModel.toggleSpeech()
                    }
                }) {
                    Label(viewModel.isSpeaking ? "Stop Speaking" : "Speak Text", 
                          systemImage: viewModel.isSpeaking ? "stop.circle.fill" : "speaker.wave.2.fill")
                }
                .buttonStyle(.bordered)
            }
            
            if viewModel.isProcessing {
                ProgressView()
                    .progressViewStyle(.circular)
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            if !viewModel.outputText.isEmpty {
                Text("Corrected Text:")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                
                TextEditor(text: .constant(viewModel.outputText))
                    .font(.body)
                    .frame(height: 150)
                    .border(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
        .frame(minWidth: 600, minHeight: 400)
        .sheet(isPresented: $showingSettings) {
            SettingsView(viewModel: viewModel)
        }
    }
}
