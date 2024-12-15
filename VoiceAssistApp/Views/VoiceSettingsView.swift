import SwiftUI

struct VoiceSettingsView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var stability: Double = 0.75
    @State private var similarityBoost: Double = 0.75
    @State private var selectedPreset: VoicePreset?
    @State private var showingSavePreset = false
    @State private var newPresetName = ""
    @State private var newPresetDescription = ""
    @State private var selectedCategory = VoicePreset.Category.custom
    @State private var searchText = ""
    
    private var filteredPresets: [VoicePreset] {
        let presets = viewModel.voicePresets
        if searchText.isEmpty {
            return presets
        }
        return presets.filter { preset in
            preset.name.localizedCaseInsensitiveContains(searchText) ||
            preset.description.localizedCaseInsensitiveContains(searchText) ||
            preset.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private var presetsByCategory: [VoicePreset.Category: [VoicePreset]] {
        Dictionary(grouping: filteredPresets) { $0.category }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Voice Selection")) {
                Picker("Voice", selection: $viewModel.selectedVoice) {
                    ForEach(viewModel.availableVoices, id: \.id) { voice in
                        Text(voice.name).tag(voice)
                    }
                }
            }
            
            Section(header: Text("Presets")) {
                SearchBar(text: $searchText)
                
                ForEach(VoicePreset.Category.allCases, id: \.self) { category in
                    if let presets = presetsByCategory[category] {
                        DisclosureGroup(category.rawValue) {
                            ForEach(presets) { preset in
                                VStack(alignment: .leading) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(preset.name)
                                                .font(.headline)
                                            Text(preset.description)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        if preset == selectedPreset {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectPreset(preset)
                                    }
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(preset.tags, id: \.self) { tag in
                                                Text(tag)
                                                    .font(.caption)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.secondary.opacity(0.2))
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
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
                            selectedPreset = nil
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
                            selectedPreset = nil
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
            
            Section(header: Text("Actions")) {
                Button("Preview Settings") {
                    viewModel.previewVoiceSettings(
                        stability: stability,
                        similarityBoost: similarityBoost
                    )
                }
                .disabled(viewModel.isGeneratingSpeech)
                
                Button("Save as Preset") {
                    showingSavePreset = true
                }
            }
        }
        .sheet(isPresented: $showingSavePreset) {
            SavePresetView(
                isPresented: $showingSavePreset,
                name: $newPresetName,
                description: $newPresetDescription,
                category: $selectedCategory,
                onSave: saveNewPreset
            )
        }
        .padding()
        .onAppear {
            stability = viewModel.voiceStability
            similarityBoost = viewModel.voiceSimilarityBoost
        }
    }
    
    private func selectPreset(_ preset: VoicePreset) {
        selectedPreset = preset
        stability = preset.settings.stability
        similarityBoost = preset.settings.similarityBoost
        viewModel.updateVoiceSettings(
            stability: preset.settings.stability,
            similarityBoost: preset.settings.similarityBoost
        )
    }
    
    private func saveNewPreset() {
        let newPreset = VoicePreset(
            id: UUID().uuidString,
            name: newPresetName,
            description: newPresetDescription,
            settings: .init(
                stability: stability,
                similarityBoost: similarityBoost
            ),
            category: selectedCategory,
            tags: []
        )
        
        viewModel.saveVoicePreset(newPreset)
        showingSavePreset = false
        newPresetName = ""
        newPresetDescription = ""
        selectedCategory = .custom
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search presets...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct SavePresetView: View {
    @Binding var isPresented: Bool
    @Binding var name: String
    @Binding var description: String
    @Binding var category: VoicePreset.Category
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Preset Details")) {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                    Picker("Category", selection: $category) {
                        ForEach(VoicePreset.Category.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Save Preset")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    onSave()
                }
                .disabled(name.isEmpty)
            )
        }
    }
}
