import SwiftUI

struct VoiceSettingsView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingSavePreset = false
    @State private var showingAPISettings = false
    @State private var searchText = ""
    
    var filteredPresets: [VoicePreset] {
        if searchText.isEmpty {
            return viewModel.voicePresets
        }
        return viewModel.voicePresets.filter { preset in
            preset.name.localizedCaseInsensitiveContains(searchText) ||
            preset.description.localizedCaseInsensitiveContains(searchText) ||
            preset.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Picker("Voice", selection: $viewModel.selectedVoice) {
                        ForEach(viewModel.availableVoices, id: \.id) { voice in
                            Text(voice.name).tag(voice)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                } header: {
                    Label("Voice Selection", systemImage: "person.wave.2")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Stability")
                            Spacer()
                            Text(String(format: "%.2f", viewModel.voiceSettings.stability))
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $viewModel.voiceSettings.stability, in: 0...1)
                            .tint(.accentColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Similarity Boost")
                            Spacer()
                            Text(String(format: "%.2f", viewModel.voiceSettings.similarityBoost))
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $viewModel.voiceSettings.similarityBoost, in: 0...1)
                            .tint(.accentColor)
                    }
                } header: {
                    Label("Voice Parameters", systemImage: "slider.horizontal.3")
                } footer: {
                    Text("Adjust stability for consistent output and similarity boost for voice matching accuracy.")
                }
                
                Section {
                    SearchBar(text: $searchText)
                    
                    ForEach(filteredPresets) { preset in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(preset.name)
                                .font(.headline)
                            Text(preset.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            HStack {
                                ForEach(preset.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.accentColor.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.applyPreset(preset)
                        }
                    }
                } header: {
                    Label("Voice Presets", systemImage: "square.stack.3d.up")
                }
            }
            .listStyle(.inset)
            .navigationTitle("Voice Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Preset") {
                        showingSavePreset = true
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAPISettings = true }) {
                        Label("API Settings", systemImage: "key")
                    }
                }
            }
        }
        .sheet(isPresented: $showingSavePreset) {
            SavePresetView(viewModel: viewModel, isPresented: $showingSavePreset)
        }
        .sheet(isPresented: $showingAPISettings) {
            APISettingsView(viewModel: viewModel)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search presets...", text: $text)
                .textFieldStyle(.plain)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color(.textBackgroundColor))
        .cornerRadius(8)
    }
}

struct SavePresetView: View {
    @ObservedObject var viewModel: AppViewModel
    @Binding var isPresented: Bool
    @State private var name = ""
    @State private var description = ""
    @State private var category = VoicePreset.Category.conversation
    @State private var tags = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                    Picker("Category", selection: $category) {
                        ForEach(VoicePreset.Category.allCases) { category in
                            Text(category.rawValue.capitalized).tag(category)
                        }
                    }
                    TextField("Tags (comma separated)", text: $tags)
                } header: {
                    Text("Preset Details")
                } footer: {
                    Text("Enter details for your custom voice preset")
                }
            }
            .navigationTitle("Save Preset")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let tagArray = tags.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
                        viewModel.savePreset(name: name, description: description, category: category, tags: tagArray)
                        isPresented = false
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
