module sigs.k8s.io/kustomize/plugin/builtin/kindordertransformer

go 1.13

require (
	github.com/pkg/errors v0.8.1
	sigs.k8s.io/kustomize/api v0.2.0
	sigs.k8s.io/yaml v1.1.0
)

replace sigs.k8s.io/kustomize/api => ../../../api
