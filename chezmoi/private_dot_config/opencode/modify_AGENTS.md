{{- /*chezmoi:modify-template*/ -}}
{{- $current := .chezmoi.stdin -}}
{{- $marker := "<!-- CHEZMOI_END -->" -}}

{{- printf "%s\n" (includeTemplate "AGENTS.md") -}}
{{- printf "%s\n" $marker -}}

{{- /*Extract and append only the plugin modifications*/ -}}
{{- if contains $marker $current -}}
{{- /*Split the file by the marker and grab everything after it*/ -}}
{{- $splitContent := splitList $marker $current -}}
{{- printf "%s" (index $splitContent 1 | trim) -}}
{{- end -}}
