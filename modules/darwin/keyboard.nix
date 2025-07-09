_:
{
  system.activationScripts.postActivation.text =
    let
      leftOption = "30064771298";
      leftCommand = "30064771299";
      rightOption = "30064771302";
      rightCommand = "30064771303";
      keyboardId = "14-13330-0";
    in
    ''
      # Customise modifier keys
      echo "customise modifier keys..." >&2
      defaults -currentHost write -g com.apple.keyboard.modifiermapping.${keyboardId} -array \
      '<dict>
          <key>HIDKeyboardModifierMappingDst</key>
          <integer>${leftOption}</integer>
          <key>HIDKeyboardModifierMappingSrc</key>
          <integer>${leftCommand}</integer>
      </dict>' \
      '<dict>
          <key>HIDKeyboardModifierMappingDst</key>
          <integer>${leftCommand}</integer>
          <key>HIDKeyboardModifierMappingSrc</key>
          <integer>${leftOption}</integer>
      </dict>' \
      '<dict>
          <key>HIDKeyboardModifierMappingDst</key>
          <integer>${rightOption}</integer>
          <key>HIDKeyboardModifierMappingSrc</key>
          <integer>${rightCommand}</integer>
      </dict>' \
      '<dict>
          <key>HIDKeyboardModifierMappingDst</key>
          <integer>${rightCommand}</integer>
          <key>HIDKeyboardModifierMappingSrc</key>
          <integer>${rightOption}</integer>
      </dict>'
    '';
}
