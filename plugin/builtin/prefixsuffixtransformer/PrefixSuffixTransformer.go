// Copyright 2019 The Kubernetes Authors.
// SPDX-License-Identifier: Apache-2.0

//go:generate pluginator
package main

import (
	"errors"
	"fmt"

	"sigs.k8s.io/kustomize/api/transform"
	"sigs.k8s.io/kustomize/api/types"

	"sigs.k8s.io/kustomize/api/resid"
	"sigs.k8s.io/kustomize/api/resmap"
	"sigs.k8s.io/yaml"
)

// Add the given prefix and suffix to the field.
type plugin struct {
	Prefix     string            `json:"prefix,omitempty" yaml:"prefix,omitempty"`
	Suffix     string            `json:"suffix,omitempty" yaml:"suffix,omitempty"`
	FieldSpecs []types.FieldSpec `json:"fieldSpecs,omitempty" yaml:"fieldSpecs,omitempty"`
}

//noinspection GoUnusedGlobalVariable
var KustomizePlugin plugin

func (p *plugin) Config(
	h *resmap.PluginHelpers, c []byte) (err error) {
	p.Prefix = ""
	p.Suffix = ""
	p.FieldSpecs = nil
	err = yaml.Unmarshal(c, p)
	if err != nil {
		return
	}
	if p.FieldSpecs == nil {
		return errors.New("fieldSpecs is not expected to be nil")
	}
	return
}

func (p *plugin) Transform(m resmap.ResMap) error {

	// Even if both the Prefix and Suffix are empty we want
	// to proceed with the transformation. This allows to add contextual
	// information to the resources (AddNamePrefix and AddNameSuffix).

	for _, r := range m.Resources() {
		id := r.OrgId()
		applicableFs := p.applicableFieldSpecs(id)

		// current default configuration contains
		// only one entry: "metadata/name" with no GVK
		for _, path := range applicableFs {

			if smellsLikeANameChange(&path) {
				// "metadata/name" is the only field.
				// this will add a prefix and a suffix
				// to the resource even if those are
				// empty
				r.AddNamePrefix(p.Prefix)
				r.AddNameSuffix(p.Suffix)
			}

			// the addPrefixSuffix method will not
			// change the name if both the prefix and suffix
			// are empty.
			err := transform.MutateField(
				r.Map(),
				path.PathSlice(),
				path.CreateIfNotPresent,
				p.addPrefixSuffix)
			if err != nil {
				return err
			}
		}
	}
	return nil
}

func smellsLikeANameChange(fs *types.FieldSpec) bool {
	return fs.Path == "metadata/name"
}

func (p *plugin) applicableFieldSpecs(id resid.ResId) types.FieldSpecs {
	res := types.NewFieldSpecsFromSlice(p.FieldSpecs)
	res = res.ApplicableFieldSpecs(id.Gvk)
	return res
}

func (p *plugin) addPrefixSuffix(
	in interface{}) (interface{}, error) {
	s, ok := in.(string)
	if !ok {
		return nil, fmt.Errorf("%#v is expected to be %T", in, s)
	}
	return fmt.Sprintf("%s%s%s", p.Prefix, s, p.Suffix), nil
}
