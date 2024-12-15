# Accessibility in VoiceAssist

Learn about VoiceAssist's accessibility features and best practices.

## Overview

VoiceAssist is built with accessibility as a core principle, not an afterthought. Our app follows Apple's accessibility guidelines and includes features to support users with various needs.

## VoiceOver Support

### Navigation

All UI elements are properly labeled for VoiceOver:

```swift
Button("Start Recording") {
    // Action
}
.accessibilityLabel("Start voice recording")
.accessibilityHint("Double tap to start recording your voice")
```

### Custom Actions

VoiceOver users can perform common actions through custom rotors:

- Recording control
- Grammar correction
- Text-to-speech playback

## Keyboard Support

### Shortcuts

VoiceAssist supports keyboard shortcuts for all major functions:

- ⌘R: Start/Stop Recording
- ⌘G: Correct Grammar
- ⌘P: Play/Pause Speech
- ⌘,: Open Settings

### Focus Management

The app maintains a logical tab order and clear focus indicators:

```swift
TextField("Enter text", text: $inputText)
    .focusable()
    .focused($focusedField, equals: .input)
```

## Visual Accessibility

### Color and Contrast

- Support for system dark mode
- High contrast mode compatibility
- No color-only information

### Text Size

- Dynamic Type support
- Scalable UI elements
- Maintains readability at all sizes

## Motor Accessibility

### Touch Targets

- Large, easy-to-hit buttons
- Adequate spacing between controls
- Support for alternative input methods

### Reduced Motion

Respects system reduced motion settings:

```swift
if !UIAccessibility.isReduceMotionEnabled {
    // Animate
} else {
    // Skip animation
}
```

## Testing Accessibility

### Automated Tests

```swift
func testAccessibility() {
    XCTAssertTrue(button.isAccessibilityElement)
    XCTAssertEqual(button.accessibilityLabel, "Start Recording")
    XCTAssertEqual(button.accessibilityTraits, .button)
}
```

### Manual Testing

Regular testing with:
- VoiceOver
- Switch Control
- Voice Control
- Various text sizes
