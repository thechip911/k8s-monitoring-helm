{{/* Returns an alloy-formatted array of destination targets given the name */}}
{{/* Inputs: destinations (array of destination definition), names ([]string), type (string) ecosystem (string) */}}
{{- define "destinations.alloy.targets" -}}
{{- range $destination := .destinations }}
  {{- if (has $destination.name $.names ) }}
    {{- if eq (include (printf "destinations.%s.supports_%s" $destination.type $.type) $destination) "true" }}
{{ include (printf "destinations.%s.alloy.%s.%s.target" $destination.type $.ecosystem $.type) $destination | trim }},
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}

{{/* Adds the Alloy components for destinations */}}
{{/* Inputs: . (root object) */}}
{{- define "destinations.alloy.config" }}
{{- range $destination := .Values.destinations }}
{{- $defaultValues := (printf "destinations/%s-values.yaml" $destination.type) | $.Files.Get | fromYaml }}
{{- $destinationWithDefaults := mergeOverwrite $defaultValues $destination }}
// Destination: {{ $destination.name }} ({{ $destination.type }})
{{- include (printf "destinations.%s.alloy" $destination.type) (deepCopy $ | merge (dict "destination" $destinationWithDefaults)) | indent 0 }}

{{- if eq (include "secrets.usesKubernetesSecret" $destinationWithDefaults) "true" }}
  {{- include "secret.alloy" (deepCopy $ | merge (dict "object" $destinationWithDefaults)) | nindent 0 }}
{{- end }}
{{- end }}
{{- end }}
