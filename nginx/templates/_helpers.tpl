{{- /* Chart name  */ -}}
{{- define "nginx-app.name" -}}
{{ .Chart.Name }}
{{- end -}}

{{- /* Full name used as prefix */ -}}
{{- define "nginx-app.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end -}}

{{- /* Labels  */ -}}

{{- define "nginx-app.labels" -}}
app.kubernetes.io/name: {{ include "nginx-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
env: {{ .Values.environment }}
{{- end -}}

{{- define "nginx-app.selector" -}}
app.kubernetes.io/name: {{ include "nginx-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}