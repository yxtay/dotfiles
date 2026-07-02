{{- /* chezmoi:modify-template */ -}}
{{- $currentContent := .chezmoi.stdin -}}
{{- $marker := "<!-- CHEZMOI_END -->" -}}

{{- printf "%s\n" "@AGENTS.md\n" -}}
{{- printf "%s\n" $marker -}}

{{- /* Extract and append only the plugin modifications */ -}}
{{- if contains $marker $currentContent -}}
{{- /* Split the file by the marker and grab everything after it */ -}}
{{- $splitContent := splitList $marker $currentContent -}}
{{- printf "%s" (index $splitContent 1 | trim) -}}
{{- end -}}
