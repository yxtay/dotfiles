_: {
  system.activationScripts.extraActivation.text =
    let
      leftOptionId = "30064771298";
      leftCommandId = "30064771299";
      rightOptionId = "30064771302";
      rightCommandId = "30064771303";
      keyboardId = "14-13330-0";
    in
    ''
      # Customise modifier keys
      echo "customise modifier keys..." >&2
      defaults -currentHost write -g com.apple.keyboard.modifiermapping.${keyboardId} -array \
      '<dict>
          <key>HIDKeyboardModifierMappingDst</key>
          <integer>${leftOptionId}</integer>
          <key>HIDKeyboardModifierMappingSrc</key>
          <integer>${leftCommandId}</integer>
      </dict>' \
      '<dict>
          <key>HIDKeyboardModifierMappingDst</key>
          <integer>${leftCommandId}</integer>
          <key>HIDKeyboardModifierMappingSrc</key>
          <integer>${leftOptionId}</integer>
      </dict>' \
      '<dict>
          <key>HIDKeyboardModifierMappingDst</key>
          <integer>${rightOptionId}</integer>
          <key>HIDKeyboardModifierMappingSrc</key>
          <integer>${rightCommandId}</integer>
      </dict>' \
      '<dict>
          <key>HIDKeyboardModifierMappingDst</key>
          <integer>${rightCommandId}</integer>
          <key>HIDKeyboardModifierMappingSrc</key>
          <integer>${rightOptionId}</integer>
      </dict>'
    '';
}
