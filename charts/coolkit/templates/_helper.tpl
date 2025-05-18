{{ define "coolkit.deployment-name" -}}
{{ .Release.Name }}
{{- end }}

{{ define "coolkit.service-name" -}}
{{ .Release.Name }}
{{- end }}

{{ define "coolkit.image" -}}
{{ if and .repository .tag .hash -}}
{{ .repository }}:{{ .tag }}@{{ .hash }}
{{ else -}}
{{ if and .repository .tag -}}
{{ .repository }}:{{ .tag }}
{{ else -}}
{{ .repository }}:latest
{{ end -}}
{{ end -}}
{{- end }}

{{ define "coolkit.match-labels" }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{ end }}

{{ define "coolkit.labels" }}
{{ include "coolkit.match-labels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Chart.Version | quote }}
{{ end }}

{{ define "coolkit.probe" -}}
{{ $key := .key -}}
{{ $values := .Values -}}
{{ $probeTpl := get .Values.probes $key -}}
{{ with $probeTpl -}}
{{ $key }}Probe: {{ . | toYaml | nindent 2 }}
{{ end -}}
{{ end -}}

{{ define "coolkit.serviceaccount-name" -}}
{{ .Release.Name }}
{{- end }}
