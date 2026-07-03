{{- /*chezmoi:modify-template*/ -}}
{{- $current := .chezmoi.stdin -}}
{{- $marker := "<!-- chezmoi:end -->" -}}

{{- printf "%s\n" "@AGENTS.md" -}}
{{- printf "%s\n" $marker -}}

{{- /*Extract and append only the plugin modifications */ -}}
{{- if contains $marker $current -}}
{{- /* Split the file by the marker and grab everything after it*/ -}}
{{- $splitContent := splitList $marker $current -}}
{{- printf "%s" (index $splitContent 1 | trim) -}}
{{- end -}}
