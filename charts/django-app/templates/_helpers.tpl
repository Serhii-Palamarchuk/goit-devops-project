{{/*
Application base name
*/}}
{{- define "django-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Full application name
*/}}
{{- define "django-app.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "django-app.name" . -}}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "django-app.labels" -}}
app.kubernetes.io/name: {{ include "django-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "django-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "django-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
ConfigMap name
*/}}
{{- define "django-app.configMapName" -}}
{{ include "django-app.fullname" . }}-config
{{- end -}}
