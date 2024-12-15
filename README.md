# VoiceAssist

A native macOS application designed to help people with disabilities communicate effectively through speech recognition and text-to-speech capabilities.

## Features

- Speech-to-text using native macOS speech recognition
- Text-to-speech using Eleven Labs API
- AI-powered grammar and punctuation correction (choice between OpenAI and Anthropic)
- Accessible user interface designed for ease of use
- Multiple voice options for text-to-speech
- Real-time speech recognition
- Error handling and user feedback
- Comprehensive test suite

## Requirements

- macOS 12.0 or later
- Xcode 14.0 or later
- API Keys:
  - Eleven Labs API key (for text-to-speech)
  - OpenAI API key (for grammar correction)
  - Anthropic API key (alternative for grammar correction)

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/tmm22/AI-accessibility.git
   cd AI-accessibility
   ```

2. Copy the configuration template:
   ```bash
   cp Config.example.swift Config.swift
   ```

3. Add your API keys to `Config.swift`

4. Open the project in Xcode:
   ```bash
   open VoiceAssistApp.xcodeproj
   ```

5. Build and run the project

## Testing

The project includes a comprehensive test suite covering:
- Core functionality
- UI interactions
- API integrations
- Accessibility features

To run the tests:
1. Open the project in Xcode
2. Press ⌘U or navigate to Product > Test

## Project Structure

```
VoiceAssistApp/
├── Views/
│   ├── ContentView.swift       # Main app interface
│   └── SettingsView.swift      # Settings management
├── Services/
│   ├── AIService.swift         # Grammar correction services
│   ├── SpeechRecognizer.swift  # Speech recognition
│   └── TextToSpeechService.swift # Text-to-speech
├── ViewModels/
│   └── AppViewModel.swift      # App state management
└── Tests/                      # Test suite
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Eleven Labs](https://elevenlabs.io/) for text-to-speech capabilities
- [OpenAI](https://openai.com/) and [Anthropic](https://www.anthropic.com/) for AI-powered text correction
