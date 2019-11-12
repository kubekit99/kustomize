# Feature Test for Issue 0821


This folder contains files describing how to address [Issue 0821](https://github.com/kubernetes-sigs/kustomize/issues/0821)

## Setup the workspace

First, define a place to work:

<!-- @makeWorkplace @test -->
```bash
DEMO_HOME=$(mktemp -d)
```

## Preparation

<!-- @makeDirectories @test -->
```bash
mkdir -p ${DEMO_HOME}/
```

### Preparation Step KustomizationFile0

<!-- @createKustomizationFile0 @test -->
```bash
cat <<'EOF' >${DEMO_HOME}/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ./resources.yaml
EOF
```


### Preparation Step Resource0

<!-- @createResource0 @test -->
```bash
cat <<'EOF' >${DEMO_HOME}/kubectlapplyordertransformer.yaml
apiVersion: builtin
kind: KindOrderTransformer
metadata:
  name: kubectlapplyordertransformer
kindorder:
- Namespace
- CustomResourceDefinition
- ServiceAccount
- ClusterRole
- RoleBinding
- ClusterRoleBinding
- ConfigMap
- Service
- Deployment
- CronJob
- ValidatingWebhookConfiguration
- APIService
- Job
- Certificate
- ClusterIssuer
- Issuer
EOF
```


### Preparation Step Resource1

<!-- @createResource1 @test -->
```bash
cat <<'EOF' >${DEMO_HOME}/kubectldeleteordertransformer.yaml
apiVersion: builtin
kind: KindOrderTransformer
metadata:
  name: kubectldeleteordertransformer
kindorder:
- Issuer
- ClusterIssuer
- Certificate
- Job
- APIService
- ValidatingWebhookConfiguration
- CronJob
- Deployment
- Service
- ConfigMap
- ClusterRoleBinding
- RoleBinding
- ClusterRole
- ServiceAccount
- CustomResourceDefinition
- Namespace
EOF
```


### Preparation Step Resource2

<!-- @createResource2 @test -->
```bash
cat <<'EOF' >${DEMO_HOME}/resources.yaml
apiVersion: v1
kind: Namespace
metadata:
  labels:
    app: cert-manager
    certmanager.k8s.io/disable-validation: "true"
    heritage: kustomize
  name: cert-manager
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: certificates.certmanager.k8s.io
spec:
  additionalPrinterColumns:
  - JSONPath: .status.conditions[?(@.type=="Ready")].status
    name: Ready
    type: string
  - JSONPath: .spec.secretName
    name: Secret
    type: string
  - JSONPath: .spec.issuerRef.name
    name: Issuer
    priority: 1
    type: string
  - JSONPath: .status.conditions[?(@.type=="Ready")].message
    name: Status
    priority: 1
    type: string
  - JSONPath: .metadata.creationTimestamp
    description: |-
      CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.

      Populated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    name: Age
    type: date
  group: certmanager.k8s.io
  names:
    kind: Certificate
    plural: certificates
    shortNames:
    - cert
    - certs
  scope: Namespaced
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: challenges.certmanager.k8s.io
spec:
  additionalPrinterColumns:
  - JSONPath: .status.state
    name: State
    type: string
  - JSONPath: .spec.dnsName
    name: Domain
    type: string
  - JSONPath: .status.reason
    name: Reason
    type: string
  - JSONPath: .metadata.creationTimestamp
    description: |-
      CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.

      Populated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    name: Age
    type: date
  group: certmanager.k8s.io
  names:
    kind: Challenge
    plural: challenges
  scope: Namespaced
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: clusterissuers.certmanager.k8s.io
spec:
  group: certmanager.k8s.io
  names:
    kind: ClusterIssuer
    plural: clusterissuers
  scope: Cluster
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: issuers.certmanager.k8s.io
spec:
  group: certmanager.k8s.io
  names:
    kind: Issuer
    plural: issuers
  scope: Namespaced
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: orders.certmanager.k8s.io
spec:
  additionalPrinterColumns:
  - JSONPath: .status.state
    name: State
    type: string
  - JSONPath: .spec.issuerRef.name
    name: Issuer
    priority: 1
    type: string
  - JSONPath: .status.reason
    name: Reason
    priority: 1
    type: string
  - JSONPath: .metadata.creationTimestamp
    description: |-
      CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.

      Populated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    name: Age
    type: date
  group: certmanager.k8s.io
  names:
    kind: Order
    plural: orders
  scope: Namespaced
  version: v1alpha1
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    release: cert-manager
  name: cert-manager-edit
rules:
- apiGroups:
  - certmanager.k8s.io
  resources:
  - certificates
  - issuers
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-view: "true"
    release: cert-manager
  name: cert-manager-view
rules:
- apiGroups:
  - certmanager.k8s.io
  resources:
  - certificates
  - issuers
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook:webhook-requester
rules:
- apiGroups:
  - admission.certmanager.k8s.io
  resources:
  - certificates
  - issuers
  - clusterissuers
  verbs:
  - create
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
rules:
- apiGroups:
  - ""
  resourceNames:
  - cert-manager-webhook-ca
  resources:
  - secrets
  verbs:
  - get
- apiGroups:
  - admissionregistration.k8s.io
  resourceNames:
  - cert-manager-webhook
  resources:
  - validatingwebhookconfigurations
  - mutatingwebhookconfigurations
  verbs:
  - get
  - update
- apiGroups:
  - apiregistration.k8s.io
  resourceNames:
  - v1beta1.admission.certmanager.k8s.io
  resources:
  - apiservices
  verbs:
  - get
  - update
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
rules:
- apiGroups:
  - certmanager.k8s.io
  resources:
  - certificates
  - issuers
  - clusterissuers
  - orders
  - challenges
  verbs:
  - '*'
- apiGroups:
  - ""
  resources:
  - configmaps
  - secrets
  - events
  - services
  - pods
  verbs:
  - '*'
- apiGroups:
  - extensions
  resources:
  - ingresses
  verbs:
  - '*'
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook:webhook-authentication-reader
  namespace: cert-manager
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: extension-apiserver-authentication-reader
subjects:
- apiGroup: ""
  kind: ServiceAccount
  name: cert-manager-webhook
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cert-manager-webhook-ca-sync
subjects:
- kind: ServiceAccount
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook:auth-delegator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- apiGroup: ""
  kind: ServiceAccount
  name: cert-manager-webhook
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cert-manager
subjects:
- kind: ServiceAccount
  name: cert-manager
  namespace: cert-manager
---
apiVersion: v1
data:
  config: |-
    {
        "apiServices": [
            {
                "name": "v1beta1.admission.certmanager.k8s.io",
                "secret": {
                    "name": "cert-manager-webhook-ca",
                    "namespace": "cert-manager",
                    "key": "tls.crt"
                }
            }
        ],
        "validatingWebhookConfigurations": [
            {
                "name": "cert-manager-webhook",
                "file": {
                    "path": "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
                }
            }
        ]
    }
kind: ConfigMap
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
spec:
  ports:
  - name: https
    port: 443
    targetPort: 6443
  selector:
    app: cert-manager
    heritage: kustomize
    release: cert-manager
  type: ClusterIP
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cert-manager
      heritage: kustomize
      release: cert-manager
  template:
    metadata:
      annotations: null
      labels:
        app: cert-manager
        heritage: kustomize
        release: cert-manager
    spec:
      containers:
      - args:
        - --v=12
        - --secure-port=6443
        - --tls-cert-file=/certs/tls.crt
        - --tls-private-key-file=/certs/tls.key
        - --disable-admission-plugins=NamespaceLifecycle,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,Initializers
        env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        image: quay.io/jetstack/cert-manager-webhook:v0.6.0
        imagePullPolicy: IfNotPresent
        name: webhook
        resources: {}
        volumeMounts:
        - mountPath: /certs
          name: certs
      serviceAccountName: cert-manager-webhook
      volumes:
      - name: certs
        secret:
          secretName: cert-manager-webhook-webhook-tls
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
  namespace: cert-manager
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cert-manager
      heritage: kustomize
      release: cert-manager
  template:
    metadata:
      annotations: null
      labels:
        app: cert-manager
        heritage: kustomize
        release: cert-manager
    spec:
      containers:
      - args:
        - --cluster-resource-namespace=$(POD_NAMESPACE)
        - --leader-election-namespace=$(POD_NAMESPACE)
        - --default-issuer-kind=ClusterIssuer
        - --default-issuer-name=letsencrypt
        env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        image: quay.io/jetstack/cert-manager-controller:v0.6.0
        imagePullPolicy: IfNotPresent
        name: cert-manager
        resources:
          requests:
            cpu: 10m
            memory: 32Mi
      serviceAccountName: cert-manager
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
spec:
  jobTemplate:
    metadata:
      labels:
        app: cert-manager
        heritage: kustomize
    spec:
      backoffLimit: 20
      template:
        metadata:
          labels:
            app: cert-manager
            heritage: kustomize
        spec:
          containers:
          - args:
            - -config=/config/config
            image: quay.io/munnerz/apiextensions-ca-helper:v0.1.0
            imagePullPolicy: IfNotPresent
            name: ca-helper
            resources:
              limits:
                cpu: 100m
                memory: 128Mi
              requests:
                cpu: 10m
                memory: 32Mi
            volumeMounts:
            - mountPath: /config
              name: config
          restartPolicy: OnFailure
          serviceAccountName: cert-manager-webhook-ca-sync
          volumes:
          - configMap:
              name: cert-manager-webhook-ca-sync
            name: config
  schedule: '@weekly'
---
apiVersion: admissionregistration.k8s.io/v1beta1
kind: ValidatingWebhookConfiguration
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
webhooks:
- clientConfig:
    service:
      name: kubernetes
      namespace: default
      path: /apis/admission.certmanager.k8s.io/v1beta1/certificates
  failurePolicy: Fail
  name: certificates.admission.certmanager.k8s.io
  namespaceSelector:
    matchExpressions:
    - key: certmanager.k8s.io/disable-validation
      operator: NotIn
      values:
      - "true"
    - key: name
      operator: NotIn
      values:
      - cert-manager
  rules:
  - apiGroups:
    - certmanager.k8s.io
    apiVersions:
    - v1alpha1
    operations:
    - CREATE
    - UPDATE
    resources:
    - certificates
- clientConfig:
    service:
      name: kubernetes
      namespace: default
      path: /apis/admission.certmanager.k8s.io/v1beta1/issuers
  failurePolicy: Fail
  name: issuers.admission.certmanager.k8s.io
  namespaceSelector:
    matchExpressions:
    - key: certmanager.k8s.io/disable-validation
      operator: NotIn
      values:
      - "true"
    - key: name
      operator: NotIn
      values:
      - cert-manager
  rules:
  - apiGroups:
    - certmanager.k8s.io
    apiVersions:
    - v1alpha1
    operations:
    - CREATE
    - UPDATE
    resources:
    - issuers
- clientConfig:
    service:
      name: kubernetes
      namespace: default
      path: /apis/admission.certmanager.k8s.io/v1beta1/clusterissuers
  failurePolicy: Fail
  name: clusterissuers.admission.certmanager.k8s.io
  namespaceSelector:
    matchExpressions:
    - key: certmanager.k8s.io/disable-validation
      operator: NotIn
      values:
      - "true"
    - key: name
      operator: NotIn
      values:
      - cert-manager
  rules:
  - apiGroups:
    - certmanager.k8s.io
    apiVersions:
    - v1alpha1
    operations:
    - CREATE
    - UPDATE
    resources:
    - clusterissuers
---
apiVersion: apiregistration.k8s.io/v1beta1
kind: APIService
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: v1beta1.admission.certmanager.k8s.io
spec:
  group: admission.certmanager.k8s.io
  groupPriorityMinimum: 1000
  service:
    name: cert-manager-webhook
    namespace: cert-manager
  version: v1beta1
  versionPriority: 15
---
apiVersion: batch/v1
kind: Job
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
spec:
  backoffLimit: 20
  template:
    metadata:
      labels:
        app: cert-manager
        heritage: kustomize
    spec:
      containers:
      - args:
        - -config=/config/config
        image: quay.io/munnerz/apiextensions-ca-helper:v0.1.0
        imagePullPolicy: IfNotPresent
        name: ca-helper
        resources:
          limits:
            cpu: 100m
            memory: 128Mi
          requests:
            cpu: 10m
            memory: 32Mi
        volumeMounts:
        - mountPath: /config
          name: config
      restartPolicy: OnFailure
      serviceAccountName: cert-manager-webhook-ca-sync
      volumes:
      - configMap:
          name: cert-manager-webhook-ca-sync
        name: config
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca
  namespace: cert-manager
spec:
  commonName: ca.webhook.cert-manager
  isCA: true
  issuerRef:
    name: cert-manager-webhook-selfsign
  secretName: cert-manager-webhook-ca
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-webhook-tls
  namespace: cert-manager
spec:
  dnsNames:
  - cert-manager-webhook
  - cert-manager-webhook.cert-manager
  - cert-manager-webhook.cert-manager.svc
  issuerRef:
    name: cert-manager-webhook-ca
  secretName: cert-manager-webhook-webhook-tls
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: selfsigning-issuer
  namespace: kube-system
spec:
  selfSigned: {}
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Issuer
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca
  namespace: cert-manager
spec:
  ca:
    secretName: cert-manager-webhook-ca
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Issuer
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-selfsign
  namespace: cert-manager
spec:
  selfsigned: {}
EOF
```

## Execution

<!-- @build @test -->
```bash
mkdir ${DEMO_HOME}/actual
kustomize build ${DEMO_HOME} -o ${DEMO_HOME}/actual/reorder.notspecified.yaml
kustomize build ${DEMO_HOME} --reorder=none -o ${DEMO_HOME}/actual/reorder.none.yaml
kustomize build ${DEMO_HOME} --reorder=legacy -o ${DEMO_HOME}/actual/reorder.legacy.yaml
kustomize build ${DEMO_HOME} --reorder=kubectlapply -o ${DEMO_HOME}/actual/reorder.kubectlapply.yaml
kustomize build ${DEMO_HOME} --reorder=kubectldelete -o ${DEMO_HOME}/actual/reorder.kubectldelete.yaml
```

## Verification

<!-- @createExpectedDir @test -->
```bash
mkdir ${DEMO_HOME}/expected
```


### Verification Step Expected0

<!-- @createExpected0 @test -->
```bash
cat <<'EOF' >${DEMO_HOME}/expected/reorder.kubectlapply.yaml
apiVersion: v1
kind: Namespace
metadata:
  labels:
    app: cert-manager
    certmanager.k8s.io/disable-validation: "true"
    heritage: kustomize
  name: cert-manager
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: certificates.certmanager.k8s.io
spec:
  additionalPrinterColumns:
  - JSONPath: .status.conditions[?(@.type=="Ready")].status
    name: Ready
    type: string
  - JSONPath: .spec.secretName
    name: Secret
    type: string
  - JSONPath: .spec.issuerRef.name
    name: Issuer
    priority: 1
    type: string
  - JSONPath: .status.conditions[?(@.type=="Ready")].message
    name: Status
    priority: 1
    type: string
  - JSONPath: .metadata.creationTimestamp
    description: |-
      CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.

      Populated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    name: Age
    type: date
  group: certmanager.k8s.io
  names:
    kind: Certificate
    plural: certificates
    shortNames:
    - cert
    - certs
  scope: Namespaced
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: challenges.certmanager.k8s.io
spec:
  additionalPrinterColumns:
  - JSONPath: .status.state
    name: State
    type: string
  - JSONPath: .spec.dnsName
    name: Domain
    type: string
  - JSONPath: .status.reason
    name: Reason
    type: string
  - JSONPath: .metadata.creationTimestamp
    description: |-
      CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.

      Populated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    name: Age
    type: date
  group: certmanager.k8s.io
  names:
    kind: Challenge
    plural: challenges
  scope: Namespaced
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: clusterissuers.certmanager.k8s.io
spec:
  group: certmanager.k8s.io
  names:
    kind: ClusterIssuer
    plural: clusterissuers
  scope: Cluster
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: issuers.certmanager.k8s.io
spec:
  group: certmanager.k8s.io
  names:
    kind: Issuer
    plural: issuers
  scope: Namespaced
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: orders.certmanager.k8s.io
spec:
  additionalPrinterColumns:
  - JSONPath: .status.state
    name: State
    type: string
  - JSONPath: .spec.issuerRef.name
    name: Issuer
    priority: 1
    type: string
  - JSONPath: .status.reason
    name: Reason
    priority: 1
    type: string
  - JSONPath: .metadata.creationTimestamp
    description: |-
      CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.

      Populated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    name: Age
    type: date
  group: certmanager.k8s.io
  names:
    kind: Order
    plural: orders
  scope: Namespaced
  version: v1alpha1
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
  namespace: cert-manager
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    release: cert-manager
  name: cert-manager-edit
rules:
- apiGroups:
  - certmanager.k8s.io
  resources:
  - certificates
  - issuers
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-view: "true"
    release: cert-manager
  name: cert-manager-view
rules:
- apiGroups:
  - certmanager.k8s.io
  resources:
  - certificates
  - issuers
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook:webhook-requester
rules:
- apiGroups:
  - admission.certmanager.k8s.io
  resources:
  - certificates
  - issuers
  - clusterissuers
  verbs:
  - create
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
rules:
- apiGroups:
  - certmanager.k8s.io
  resources:
  - certificates
  - issuers
  - clusterissuers
  - orders
  - challenges
  verbs:
  - '*'
- apiGroups:
  - ""
  resources:
  - configmaps
  - secrets
  - events
  - services
  - pods
  verbs:
  - '*'
- apiGroups:
  - extensions
  resources:
  - ingresses
  verbs:
  - '*'
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
rules:
- apiGroups:
  - ""
  resourceNames:
  - cert-manager-webhook-ca
  resources:
  - secrets
  verbs:
  - get
- apiGroups:
  - admissionregistration.k8s.io
  resourceNames:
  - cert-manager-webhook
  resources:
  - validatingwebhookconfigurations
  - mutatingwebhookconfigurations
  verbs:
  - get
  - update
- apiGroups:
  - apiregistration.k8s.io
  resourceNames:
  - v1beta1.admission.certmanager.k8s.io
  resources:
  - apiservices
  verbs:
  - get
  - update
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook:webhook-authentication-reader
  namespace: cert-manager
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: extension-apiserver-authentication-reader
subjects:
- apiGroup: ""
  kind: ServiceAccount
  name: cert-manager-webhook
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cert-manager
subjects:
- kind: ServiceAccount
  name: cert-manager
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cert-manager-webhook-ca-sync
subjects:
- kind: ServiceAccount
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook:auth-delegator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- apiGroup: ""
  kind: ServiceAccount
  name: cert-manager-webhook
  namespace: cert-manager
---
apiVersion: v1
data:
  config: |-
    {
        "apiServices": [
            {
                "name": "v1beta1.admission.certmanager.k8s.io",
                "secret": {
                    "name": "cert-manager-webhook-ca",
                    "namespace": "cert-manager",
                    "key": "tls.crt"
                }
            }
        ],
        "validatingWebhookConfigurations": [
            {
                "name": "cert-manager-webhook",
                "file": {
                    "path": "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
                }
            }
        ]
    }
kind: ConfigMap
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
spec:
  ports:
  - name: https
    port: 443
    targetPort: 6443
  selector:
    app: cert-manager
    heritage: kustomize
    release: cert-manager
  type: ClusterIP
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
  namespace: cert-manager
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cert-manager
      heritage: kustomize
      release: cert-manager
  template:
    metadata:
      annotations: null
      labels:
        app: cert-manager
        heritage: kustomize
        release: cert-manager
    spec:
      containers:
      - args:
        - --cluster-resource-namespace=$(POD_NAMESPACE)
        - --leader-election-namespace=$(POD_NAMESPACE)
        - --default-issuer-kind=ClusterIssuer
        - --default-issuer-name=letsencrypt
        env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        image: quay.io/jetstack/cert-manager-controller:v0.6.0
        imagePullPolicy: IfNotPresent
        name: cert-manager
        resources:
          requests:
            cpu: 10m
            memory: 32Mi
      serviceAccountName: cert-manager
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cert-manager
      heritage: kustomize
      release: cert-manager
  template:
    metadata:
      annotations: null
      labels:
        app: cert-manager
        heritage: kustomize
        release: cert-manager
    spec:
      containers:
      - args:
        - --v=12
        - --secure-port=6443
        - --tls-cert-file=/certs/tls.crt
        - --tls-private-key-file=/certs/tls.key
        - --disable-admission-plugins=NamespaceLifecycle,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,Initializers
        env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        image: quay.io/jetstack/cert-manager-webhook:v0.6.0
        imagePullPolicy: IfNotPresent
        name: webhook
        resources: {}
        volumeMounts:
        - mountPath: /certs
          name: certs
      serviceAccountName: cert-manager-webhook
      volumes:
      - name: certs
        secret:
          secretName: cert-manager-webhook-webhook-tls
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
spec:
  jobTemplate:
    metadata:
      labels:
        app: cert-manager
        heritage: kustomize
    spec:
      backoffLimit: 20
      template:
        metadata:
          labels:
            app: cert-manager
            heritage: kustomize
        spec:
          containers:
          - args:
            - -config=/config/config
            image: quay.io/munnerz/apiextensions-ca-helper:v0.1.0
            imagePullPolicy: IfNotPresent
            name: ca-helper
            resources:
              limits:
                cpu: 100m
                memory: 128Mi
              requests:
                cpu: 10m
                memory: 32Mi
            volumeMounts:
            - mountPath: /config
              name: config
          restartPolicy: OnFailure
          serviceAccountName: cert-manager-webhook-ca-sync
          volumes:
          - configMap:
              name: cert-manager-webhook-ca-sync
            name: config
  schedule: '@weekly'
---
apiVersion: admissionregistration.k8s.io/v1beta1
kind: ValidatingWebhookConfiguration
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
webhooks:
- clientConfig:
    service:
      name: kubernetes
      namespace: default
      path: /apis/admission.certmanager.k8s.io/v1beta1/certificates
  failurePolicy: Fail
  name: certificates.admission.certmanager.k8s.io
  namespaceSelector:
    matchExpressions:
    - key: certmanager.k8s.io/disable-validation
      operator: NotIn
      values:
      - "true"
    - key: name
      operator: NotIn
      values:
      - cert-manager
  rules:
  - apiGroups:
    - certmanager.k8s.io
    apiVersions:
    - v1alpha1
    operations:
    - CREATE
    - UPDATE
    resources:
    - certificates
- clientConfig:
    service:
      name: kubernetes
      namespace: default
      path: /apis/admission.certmanager.k8s.io/v1beta1/issuers
  failurePolicy: Fail
  name: issuers.admission.certmanager.k8s.io
  namespaceSelector:
    matchExpressions:
    - key: certmanager.k8s.io/disable-validation
      operator: NotIn
      values:
      - "true"
    - key: name
      operator: NotIn
      values:
      - cert-manager
  rules:
  - apiGroups:
    - certmanager.k8s.io
    apiVersions:
    - v1alpha1
    operations:
    - CREATE
    - UPDATE
    resources:
    - issuers
- clientConfig:
    service:
      name: kubernetes
      namespace: default
      path: /apis/admission.certmanager.k8s.io/v1beta1/clusterissuers
  failurePolicy: Fail
  name: clusterissuers.admission.certmanager.k8s.io
  namespaceSelector:
    matchExpressions:
    - key: certmanager.k8s.io/disable-validation
      operator: NotIn
      values:
      - "true"
    - key: name
      operator: NotIn
      values:
      - cert-manager
  rules:
  - apiGroups:
    - certmanager.k8s.io
    apiVersions:
    - v1alpha1
    operations:
    - CREATE
    - UPDATE
    resources:
    - clusterissuers
---
apiVersion: apiregistration.k8s.io/v1beta1
kind: APIService
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: v1beta1.admission.certmanager.k8s.io
spec:
  group: admission.certmanager.k8s.io
  groupPriorityMinimum: 1000
  service:
    name: cert-manager-webhook
    namespace: cert-manager
  version: v1beta1
  versionPriority: 15
---
apiVersion: batch/v1
kind: Job
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
spec:
  backoffLimit: 20
  template:
    metadata:
      labels:
        app: cert-manager
        heritage: kustomize
    spec:
      containers:
      - args:
        - -config=/config/config
        image: quay.io/munnerz/apiextensions-ca-helper:v0.1.0
        imagePullPolicy: IfNotPresent
        name: ca-helper
        resources:
          limits:
            cpu: 100m
            memory: 128Mi
          requests:
            cpu: 10m
            memory: 32Mi
        volumeMounts:
        - mountPath: /config
          name: config
      restartPolicy: OnFailure
      serviceAccountName: cert-manager-webhook-ca-sync
      volumes:
      - configMap:
          name: cert-manager-webhook-ca-sync
        name: config
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca
  namespace: cert-manager
spec:
  commonName: ca.webhook.cert-manager
  isCA: true
  issuerRef:
    name: cert-manager-webhook-selfsign
  secretName: cert-manager-webhook-ca
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-webhook-tls
  namespace: cert-manager
spec:
  dnsNames:
  - cert-manager-webhook
  - cert-manager-webhook.cert-manager
  - cert-manager-webhook.cert-manager.svc
  issuerRef:
    name: cert-manager-webhook-ca
  secretName: cert-manager-webhook-webhook-tls
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: selfsigning-issuer
  namespace: kube-system
spec:
  selfSigned: {}
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Issuer
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca
  namespace: cert-manager
spec:
  ca:
    secretName: cert-manager-webhook-ca
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Issuer
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-selfsign
  namespace: cert-manager
spec:
  selfsigned: {}
EOF
```


### Verification Step Expected1

<!-- @createExpected1 @test -->
```bash
cat <<'EOF' >${DEMO_HOME}/expected/reorder.kubectldelete.yaml
apiVersion: certmanager.k8s.io/v1alpha1
kind: Issuer
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca
  namespace: cert-manager
spec:
  ca:
    secretName: cert-manager-webhook-ca
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Issuer
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-selfsign
  namespace: cert-manager
spec:
  selfsigned: {}
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: selfsigning-issuer
  namespace: kube-system
spec:
  selfSigned: {}
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca
  namespace: cert-manager
spec:
  commonName: ca.webhook.cert-manager
  isCA: true
  issuerRef:
    name: cert-manager-webhook-selfsign
  secretName: cert-manager-webhook-ca
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-webhook-tls
  namespace: cert-manager
spec:
  dnsNames:
  - cert-manager-webhook
  - cert-manager-webhook.cert-manager
  - cert-manager-webhook.cert-manager.svc
  issuerRef:
    name: cert-manager-webhook-ca
  secretName: cert-manager-webhook-webhook-tls
---
apiVersion: batch/v1
kind: Job
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
spec:
  backoffLimit: 20
  template:
    metadata:
      labels:
        app: cert-manager
        heritage: kustomize
    spec:
      containers:
      - args:
        - -config=/config/config
        image: quay.io/munnerz/apiextensions-ca-helper:v0.1.0
        imagePullPolicy: IfNotPresent
        name: ca-helper
        resources:
          limits:
            cpu: 100m
            memory: 128Mi
          requests:
            cpu: 10m
            memory: 32Mi
        volumeMounts:
        - mountPath: /config
          name: config
      restartPolicy: OnFailure
      serviceAccountName: cert-manager-webhook-ca-sync
      volumes:
      - configMap:
          name: cert-manager-webhook-ca-sync
        name: config
---
apiVersion: apiregistration.k8s.io/v1beta1
kind: APIService
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: v1beta1.admission.certmanager.k8s.io
spec:
  group: admission.certmanager.k8s.io
  groupPriorityMinimum: 1000
  service:
    name: cert-manager-webhook
    namespace: cert-manager
  version: v1beta1
  versionPriority: 15
---
apiVersion: admissionregistration.k8s.io/v1beta1
kind: ValidatingWebhookConfiguration
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
webhooks:
- clientConfig:
    service:
      name: kubernetes
      namespace: default
      path: /apis/admission.certmanager.k8s.io/v1beta1/certificates
  failurePolicy: Fail
  name: certificates.admission.certmanager.k8s.io
  namespaceSelector:
    matchExpressions:
    - key: certmanager.k8s.io/disable-validation
      operator: NotIn
      values:
      - "true"
    - key: name
      operator: NotIn
      values:
      - cert-manager
  rules:
  - apiGroups:
    - certmanager.k8s.io
    apiVersions:
    - v1alpha1
    operations:
    - CREATE
    - UPDATE
    resources:
    - certificates
- clientConfig:
    service:
      name: kubernetes
      namespace: default
      path: /apis/admission.certmanager.k8s.io/v1beta1/issuers
  failurePolicy: Fail
  name: issuers.admission.certmanager.k8s.io
  namespaceSelector:
    matchExpressions:
    - key: certmanager.k8s.io/disable-validation
      operator: NotIn
      values:
      - "true"
    - key: name
      operator: NotIn
      values:
      - cert-manager
  rules:
  - apiGroups:
    - certmanager.k8s.io
    apiVersions:
    - v1alpha1
    operations:
    - CREATE
    - UPDATE
    resources:
    - issuers
- clientConfig:
    service:
      name: kubernetes
      namespace: default
      path: /apis/admission.certmanager.k8s.io/v1beta1/clusterissuers
  failurePolicy: Fail
  name: clusterissuers.admission.certmanager.k8s.io
  namespaceSelector:
    matchExpressions:
    - key: certmanager.k8s.io/disable-validation
      operator: NotIn
      values:
      - "true"
    - key: name
      operator: NotIn
      values:
      - cert-manager
  rules:
  - apiGroups:
    - certmanager.k8s.io
    apiVersions:
    - v1alpha1
    operations:
    - CREATE
    - UPDATE
    resources:
    - clusterissuers
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
spec:
  jobTemplate:
    metadata:
      labels:
        app: cert-manager
        heritage: kustomize
    spec:
      backoffLimit: 20
      template:
        metadata:
          labels:
            app: cert-manager
            heritage: kustomize
        spec:
          containers:
          - args:
            - -config=/config/config
            image: quay.io/munnerz/apiextensions-ca-helper:v0.1.0
            imagePullPolicy: IfNotPresent
            name: ca-helper
            resources:
              limits:
                cpu: 100m
                memory: 128Mi
              requests:
                cpu: 10m
                memory: 32Mi
            volumeMounts:
            - mountPath: /config
              name: config
          restartPolicy: OnFailure
          serviceAccountName: cert-manager-webhook-ca-sync
          volumes:
          - configMap:
              name: cert-manager-webhook-ca-sync
            name: config
  schedule: '@weekly'
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
  namespace: cert-manager
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cert-manager
      heritage: kustomize
      release: cert-manager
  template:
    metadata:
      annotations: null
      labels:
        app: cert-manager
        heritage: kustomize
        release: cert-manager
    spec:
      containers:
      - args:
        - --cluster-resource-namespace=$(POD_NAMESPACE)
        - --leader-election-namespace=$(POD_NAMESPACE)
        - --default-issuer-kind=ClusterIssuer
        - --default-issuer-name=letsencrypt
        env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        image: quay.io/jetstack/cert-manager-controller:v0.6.0
        imagePullPolicy: IfNotPresent
        name: cert-manager
        resources:
          requests:
            cpu: 10m
            memory: 32Mi
      serviceAccountName: cert-manager
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cert-manager
      heritage: kustomize
      release: cert-manager
  template:
    metadata:
      annotations: null
      labels:
        app: cert-manager
        heritage: kustomize
        release: cert-manager
    spec:
      containers:
      - args:
        - --v=12
        - --secure-port=6443
        - --tls-cert-file=/certs/tls.crt
        - --tls-private-key-file=/certs/tls.key
        - --disable-admission-plugins=NamespaceLifecycle,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,Initializers
        env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        image: quay.io/jetstack/cert-manager-webhook:v0.6.0
        imagePullPolicy: IfNotPresent
        name: webhook
        resources: {}
        volumeMounts:
        - mountPath: /certs
          name: certs
      serviceAccountName: cert-manager-webhook
      volumes:
      - name: certs
        secret:
          secretName: cert-manager-webhook-webhook-tls
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
spec:
  ports:
  - name: https
    port: 443
    targetPort: 6443
  selector:
    app: cert-manager
    heritage: kustomize
    release: cert-manager
  type: ClusterIP
---
apiVersion: v1
data:
  config: |-
    {
        "apiServices": [
            {
                "name": "v1beta1.admission.certmanager.k8s.io",
                "secret": {
                    "name": "cert-manager-webhook-ca",
                    "namespace": "cert-manager",
                    "key": "tls.crt"
                }
            }
        ],
        "validatingWebhookConfigurations": [
            {
                "name": "cert-manager-webhook",
                "file": {
                    "path": "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
                }
            }
        ]
    }
kind: ConfigMap
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cert-manager
subjects:
- kind: ServiceAccount
  name: cert-manager
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cert-manager-webhook-ca-sync
subjects:
- kind: ServiceAccount
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook:auth-delegator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- apiGroup: ""
  kind: ServiceAccount
  name: cert-manager-webhook
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook:webhook-authentication-reader
  namespace: cert-manager
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: extension-apiserver-authentication-reader
subjects:
- apiGroup: ""
  kind: ServiceAccount
  name: cert-manager-webhook
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    release: cert-manager
  name: cert-manager-edit
rules:
- apiGroups:
  - certmanager.k8s.io
  resources:
  - certificates
  - issuers
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-view: "true"
    release: cert-manager
  name: cert-manager-view
rules:
- apiGroups:
  - certmanager.k8s.io
  resources:
  - certificates
  - issuers
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook:webhook-requester
rules:
- apiGroups:
  - admission.certmanager.k8s.io
  resources:
  - certificates
  - issuers
  - clusterissuers
  verbs:
  - create
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
rules:
- apiGroups:
  - certmanager.k8s.io
  resources:
  - certificates
  - issuers
  - clusterissuers
  - orders
  - challenges
  verbs:
  - '*'
- apiGroups:
  - ""
  resources:
  - configmaps
  - secrets
  - events
  - services
  - pods
  verbs:
  - '*'
- apiGroups:
  - extensions
  resources:
  - ingresses
  verbs:
  - '*'
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
rules:
- apiGroups:
  - ""
  resourceNames:
  - cert-manager-webhook-ca
  resources:
  - secrets
  verbs:
  - get
- apiGroups:
  - admissionregistration.k8s.io
  resourceNames:
  - cert-manager-webhook
  resources:
  - validatingwebhookconfigurations
  - mutatingwebhookconfigurations
  verbs:
  - get
  - update
- apiGroups:
  - apiregistration.k8s.io
  resourceNames:
  - v1beta1.admission.certmanager.k8s.io
  resources:
  - apiservices
  verbs:
  - get
  - update
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
  namespace: cert-manager
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: certificates.certmanager.k8s.io
spec:
  additionalPrinterColumns:
  - JSONPath: .status.conditions[?(@.type=="Ready")].status
    name: Ready
    type: string
  - JSONPath: .spec.secretName
    name: Secret
    type: string
  - JSONPath: .spec.issuerRef.name
    name: Issuer
    priority: 1
    type: string
  - JSONPath: .status.conditions[?(@.type=="Ready")].message
    name: Status
    priority: 1
    type: string
  - JSONPath: .metadata.creationTimestamp
    description: |-
      CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.

      Populated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    name: Age
    type: date
  group: certmanager.k8s.io
  names:
    kind: Certificate
    plural: certificates
    shortNames:
    - cert
    - certs
  scope: Namespaced
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: challenges.certmanager.k8s.io
spec:
  additionalPrinterColumns:
  - JSONPath: .status.state
    name: State
    type: string
  - JSONPath: .spec.dnsName
    name: Domain
    type: string
  - JSONPath: .status.reason
    name: Reason
    type: string
  - JSONPath: .metadata.creationTimestamp
    description: |-
      CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.

      Populated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    name: Age
    type: date
  group: certmanager.k8s.io
  names:
    kind: Challenge
    plural: challenges
  scope: Namespaced
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: clusterissuers.certmanager.k8s.io
spec:
  group: certmanager.k8s.io
  names:
    kind: ClusterIssuer
    plural: clusterissuers
  scope: Cluster
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: issuers.certmanager.k8s.io
spec:
  group: certmanager.k8s.io
  names:
    kind: Issuer
    plural: issuers
  scope: Namespaced
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: orders.certmanager.k8s.io
spec:
  additionalPrinterColumns:
  - JSONPath: .status.state
    name: State
    type: string
  - JSONPath: .spec.issuerRef.name
    name: Issuer
    priority: 1
    type: string
  - JSONPath: .status.reason
    name: Reason
    priority: 1
    type: string
  - JSONPath: .metadata.creationTimestamp
    description: |-
      CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.

      Populated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    name: Age
    type: date
  group: certmanager.k8s.io
  names:
    kind: Order
    plural: orders
  scope: Namespaced
  version: v1alpha1
---
apiVersion: v1
kind: Namespace
metadata:
  labels:
    app: cert-manager
    certmanager.k8s.io/disable-validation: "true"
    heritage: kustomize
  name: cert-manager
EOF
```


### Verification Step Expected2

<!-- @createExpected2 @test -->
```bash
cat <<'EOF' >${DEMO_HOME}/expected/reorder.legacy.yaml
apiVersion: v1
kind: Namespace
metadata:
  labels:
    app: cert-manager
    certmanager.k8s.io/disable-validation: "true"
    heritage: kustomize
  name: cert-manager
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: certificates.certmanager.k8s.io
spec:
  additionalPrinterColumns:
  - JSONPath: .status.conditions[?(@.type=="Ready")].status
    name: Ready
    type: string
  - JSONPath: .spec.secretName
    name: Secret
    type: string
  - JSONPath: .spec.issuerRef.name
    name: Issuer
    priority: 1
    type: string
  - JSONPath: .status.conditions[?(@.type=="Ready")].message
    name: Status
    priority: 1
    type: string
  - JSONPath: .metadata.creationTimestamp
    description: |-
      CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.

      Populated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    name: Age
    type: date
  group: certmanager.k8s.io
  names:
    kind: Certificate
    plural: certificates
    shortNames:
    - cert
    - certs
  scope: Namespaced
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: challenges.certmanager.k8s.io
spec:
  additionalPrinterColumns:
  - JSONPath: .status.state
    name: State
    type: string
  - JSONPath: .spec.dnsName
    name: Domain
    type: string
  - JSONPath: .status.reason
    name: Reason
    type: string
  - JSONPath: .metadata.creationTimestamp
    description: |-
      CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.

      Populated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    name: Age
    type: date
  group: certmanager.k8s.io
  names:
    kind: Challenge
    plural: challenges
  scope: Namespaced
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: clusterissuers.certmanager.k8s.io
spec:
  group: certmanager.k8s.io
  names:
    kind: ClusterIssuer
    plural: clusterissuers
  scope: Cluster
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: issuers.certmanager.k8s.io
spec:
  group: certmanager.k8s.io
  names:
    kind: Issuer
    plural: issuers
  scope: Namespaced
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: orders.certmanager.k8s.io
spec:
  additionalPrinterColumns:
  - JSONPath: .status.state
    name: State
    type: string
  - JSONPath: .spec.issuerRef.name
    name: Issuer
    priority: 1
    type: string
  - JSONPath: .status.reason
    name: Reason
    priority: 1
    type: string
  - JSONPath: .metadata.creationTimestamp
    description: |-
      CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.

      Populated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    name: Age
    type: date
  group: certmanager.k8s.io
  names:
    kind: Order
    plural: orders
  scope: Namespaced
  version: v1alpha1
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
  namespace: cert-manager
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    release: cert-manager
  name: cert-manager-edit
rules:
- apiGroups:
  - certmanager.k8s.io
  resources:
  - certificates
  - issuers
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-view: "true"
    release: cert-manager
  name: cert-manager-view
rules:
- apiGroups:
  - certmanager.k8s.io
  resources:
  - certificates
  - issuers
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook:webhook-requester
rules:
- apiGroups:
  - admission.certmanager.k8s.io
  resources:
  - certificates
  - issuers
  - clusterissuers
  verbs:
  - create
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
rules:
- apiGroups:
  - certmanager.k8s.io
  resources:
  - certificates
  - issuers
  - clusterissuers
  - orders
  - challenges
  verbs:
  - '*'
- apiGroups:
  - ""
  resources:
  - configmaps
  - secrets
  - events
  - services
  - pods
  verbs:
  - '*'
- apiGroups:
  - extensions
  resources:
  - ingresses
  verbs:
  - '*'
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
rules:
- apiGroups:
  - ""
  resourceNames:
  - cert-manager-webhook-ca
  resources:
  - secrets
  verbs:
  - get
- apiGroups:
  - admissionregistration.k8s.io
  resourceNames:
  - cert-manager-webhook
  resources:
  - validatingwebhookconfigurations
  - mutatingwebhookconfigurations
  verbs:
  - get
  - update
- apiGroups:
  - apiregistration.k8s.io
  resourceNames:
  - v1beta1.admission.certmanager.k8s.io
  resources:
  - apiservices
  verbs:
  - get
  - update
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook:webhook-authentication-reader
  namespace: cert-manager
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: extension-apiserver-authentication-reader
subjects:
- apiGroup: ""
  kind: ServiceAccount
  name: cert-manager-webhook
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cert-manager
subjects:
- kind: ServiceAccount
  name: cert-manager
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cert-manager-webhook-ca-sync
subjects:
- kind: ServiceAccount
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook:auth-delegator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- apiGroup: ""
  kind: ServiceAccount
  name: cert-manager-webhook
  namespace: cert-manager
---
apiVersion: v1
data:
  config: |-
    {
        "apiServices": [
            {
                "name": "v1beta1.admission.certmanager.k8s.io",
                "secret": {
                    "name": "cert-manager-webhook-ca",
                    "namespace": "cert-manager",
                    "key": "tls.crt"
                }
            }
        ],
        "validatingWebhookConfigurations": [
            {
                "name": "cert-manager-webhook",
                "file": {
                    "path": "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
                }
            }
        ]
    }
kind: ConfigMap
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
spec:
  ports:
  - name: https
    port: 443
    targetPort: 6443
  selector:
    app: cert-manager
    heritage: kustomize
    release: cert-manager
  type: ClusterIP
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
  namespace: cert-manager
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cert-manager
      heritage: kustomize
      release: cert-manager
  template:
    metadata:
      annotations: null
      labels:
        app: cert-manager
        heritage: kustomize
        release: cert-manager
    spec:
      containers:
      - args:
        - --cluster-resource-namespace=$(POD_NAMESPACE)
        - --leader-election-namespace=$(POD_NAMESPACE)
        - --default-issuer-kind=ClusterIssuer
        - --default-issuer-name=letsencrypt
        env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        image: quay.io/jetstack/cert-manager-controller:v0.6.0
        imagePullPolicy: IfNotPresent
        name: cert-manager
        resources:
          requests:
            cpu: 10m
            memory: 32Mi
      serviceAccountName: cert-manager
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cert-manager
      heritage: kustomize
      release: cert-manager
  template:
    metadata:
      annotations: null
      labels:
        app: cert-manager
        heritage: kustomize
        release: cert-manager
    spec:
      containers:
      - args:
        - --v=12
        - --secure-port=6443
        - --tls-cert-file=/certs/tls.crt
        - --tls-private-key-file=/certs/tls.key
        - --disable-admission-plugins=NamespaceLifecycle,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,Initializers
        env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        image: quay.io/jetstack/cert-manager-webhook:v0.6.0
        imagePullPolicy: IfNotPresent
        name: webhook
        resources: {}
        volumeMounts:
        - mountPath: /certs
          name: certs
      serviceAccountName: cert-manager-webhook
      volumes:
      - name: certs
        secret:
          secretName: cert-manager-webhook-webhook-tls
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
spec:
  jobTemplate:
    metadata:
      labels:
        app: cert-manager
        heritage: kustomize
    spec:
      backoffLimit: 20
      template:
        metadata:
          labels:
            app: cert-manager
            heritage: kustomize
        spec:
          containers:
          - args:
            - -config=/config/config
            image: quay.io/munnerz/apiextensions-ca-helper:v0.1.0
            imagePullPolicy: IfNotPresent
            name: ca-helper
            resources:
              limits:
                cpu: 100m
                memory: 128Mi
              requests:
                cpu: 10m
                memory: 32Mi
            volumeMounts:
            - mountPath: /config
              name: config
          restartPolicy: OnFailure
          serviceAccountName: cert-manager-webhook-ca-sync
          volumes:
          - configMap:
              name: cert-manager-webhook-ca-sync
            name: config
  schedule: '@weekly'
---
apiVersion: apiregistration.k8s.io/v1beta1
kind: APIService
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: v1beta1.admission.certmanager.k8s.io
spec:
  group: admission.certmanager.k8s.io
  groupPriorityMinimum: 1000
  service:
    name: cert-manager-webhook
    namespace: cert-manager
  version: v1beta1
  versionPriority: 15
---
apiVersion: batch/v1
kind: Job
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
spec:
  backoffLimit: 20
  template:
    metadata:
      labels:
        app: cert-manager
        heritage: kustomize
    spec:
      containers:
      - args:
        - -config=/config/config
        image: quay.io/munnerz/apiextensions-ca-helper:v0.1.0
        imagePullPolicy: IfNotPresent
        name: ca-helper
        resources:
          limits:
            cpu: 100m
            memory: 128Mi
          requests:
            cpu: 10m
            memory: 32Mi
        volumeMounts:
        - mountPath: /config
          name: config
      restartPolicy: OnFailure
      serviceAccountName: cert-manager-webhook-ca-sync
      volumes:
      - configMap:
          name: cert-manager-webhook-ca-sync
        name: config
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca
  namespace: cert-manager
spec:
  commonName: ca.webhook.cert-manager
  isCA: true
  issuerRef:
    name: cert-manager-webhook-selfsign
  secretName: cert-manager-webhook-ca
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-webhook-tls
  namespace: cert-manager
spec:
  dnsNames:
  - cert-manager-webhook
  - cert-manager-webhook.cert-manager
  - cert-manager-webhook.cert-manager.svc
  issuerRef:
    name: cert-manager-webhook-ca
  secretName: cert-manager-webhook-webhook-tls
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: selfsigning-issuer
  namespace: kube-system
spec:
  selfSigned: {}
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Issuer
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca
  namespace: cert-manager
spec:
  ca:
    secretName: cert-manager-webhook-ca
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Issuer
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-selfsign
  namespace: cert-manager
spec:
  selfsigned: {}
---
apiVersion: admissionregistration.k8s.io/v1beta1
kind: ValidatingWebhookConfiguration
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
webhooks:
- clientConfig:
    service:
      name: kubernetes
      namespace: default
      path: /apis/admission.certmanager.k8s.io/v1beta1/certificates
  failurePolicy: Fail
  name: certificates.admission.certmanager.k8s.io
  namespaceSelector:
    matchExpressions:
    - key: certmanager.k8s.io/disable-validation
      operator: NotIn
      values:
      - "true"
    - key: name
      operator: NotIn
      values:
      - cert-manager
  rules:
  - apiGroups:
    - certmanager.k8s.io
    apiVersions:
    - v1alpha1
    operations:
    - CREATE
    - UPDATE
    resources:
    - certificates
- clientConfig:
    service:
      name: kubernetes
      namespace: default
      path: /apis/admission.certmanager.k8s.io/v1beta1/issuers
  failurePolicy: Fail
  name: issuers.admission.certmanager.k8s.io
  namespaceSelector:
    matchExpressions:
    - key: certmanager.k8s.io/disable-validation
      operator: NotIn
      values:
      - "true"
    - key: name
      operator: NotIn
      values:
      - cert-manager
  rules:
  - apiGroups:
    - certmanager.k8s.io
    apiVersions:
    - v1alpha1
    operations:
    - CREATE
    - UPDATE
    resources:
    - issuers
- clientConfig:
    service:
      name: kubernetes
      namespace: default
      path: /apis/admission.certmanager.k8s.io/v1beta1/clusterissuers
  failurePolicy: Fail
  name: clusterissuers.admission.certmanager.k8s.io
  namespaceSelector:
    matchExpressions:
    - key: certmanager.k8s.io/disable-validation
      operator: NotIn
      values:
      - "true"
    - key: name
      operator: NotIn
      values:
      - cert-manager
  rules:
  - apiGroups:
    - certmanager.k8s.io
    apiVersions:
    - v1alpha1
    operations:
    - CREATE
    - UPDATE
    resources:
    - clusterissuers
EOF
```


### Verification Step Expected3

<!-- @createExpected3 @test -->
```bash
cat <<'EOF' >${DEMO_HOME}/expected/reorder.none.yaml
apiVersion: v1
kind: Namespace
metadata:
  labels:
    app: cert-manager
    certmanager.k8s.io/disable-validation: "true"
    heritage: kustomize
  name: cert-manager
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: certificates.certmanager.k8s.io
spec:
  additionalPrinterColumns:
  - JSONPath: .status.conditions[?(@.type=="Ready")].status
    name: Ready
    type: string
  - JSONPath: .spec.secretName
    name: Secret
    type: string
  - JSONPath: .spec.issuerRef.name
    name: Issuer
    priority: 1
    type: string
  - JSONPath: .status.conditions[?(@.type=="Ready")].message
    name: Status
    priority: 1
    type: string
  - JSONPath: .metadata.creationTimestamp
    description: |-
      CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.

      Populated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    name: Age
    type: date
  group: certmanager.k8s.io
  names:
    kind: Certificate
    plural: certificates
    shortNames:
    - cert
    - certs
  scope: Namespaced
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: challenges.certmanager.k8s.io
spec:
  additionalPrinterColumns:
  - JSONPath: .status.state
    name: State
    type: string
  - JSONPath: .spec.dnsName
    name: Domain
    type: string
  - JSONPath: .status.reason
    name: Reason
    type: string
  - JSONPath: .metadata.creationTimestamp
    description: |-
      CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.

      Populated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    name: Age
    type: date
  group: certmanager.k8s.io
  names:
    kind: Challenge
    plural: challenges
  scope: Namespaced
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: clusterissuers.certmanager.k8s.io
spec:
  group: certmanager.k8s.io
  names:
    kind: ClusterIssuer
    plural: clusterissuers
  scope: Cluster
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: issuers.certmanager.k8s.io
spec:
  group: certmanager.k8s.io
  names:
    kind: Issuer
    plural: issuers
  scope: Namespaced
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: orders.certmanager.k8s.io
spec:
  additionalPrinterColumns:
  - JSONPath: .status.state
    name: State
    type: string
  - JSONPath: .spec.issuerRef.name
    name: Issuer
    priority: 1
    type: string
  - JSONPath: .status.reason
    name: Reason
    priority: 1
    type: string
  - JSONPath: .metadata.creationTimestamp
    description: |-
      CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.

      Populated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    name: Age
    type: date
  group: certmanager.k8s.io
  names:
    kind: Order
    plural: orders
  scope: Namespaced
  version: v1alpha1
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    release: cert-manager
  name: cert-manager-edit
rules:
- apiGroups:
  - certmanager.k8s.io
  resources:
  - certificates
  - issuers
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-view: "true"
    release: cert-manager
  name: cert-manager-view
rules:
- apiGroups:
  - certmanager.k8s.io
  resources:
  - certificates
  - issuers
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook:webhook-requester
rules:
- apiGroups:
  - admission.certmanager.k8s.io
  resources:
  - certificates
  - issuers
  - clusterissuers
  verbs:
  - create
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
rules:
- apiGroups:
  - ""
  resourceNames:
  - cert-manager-webhook-ca
  resources:
  - secrets
  verbs:
  - get
- apiGroups:
  - admissionregistration.k8s.io
  resourceNames:
  - cert-manager-webhook
  resources:
  - validatingwebhookconfigurations
  - mutatingwebhookconfigurations
  verbs:
  - get
  - update
- apiGroups:
  - apiregistration.k8s.io
  resourceNames:
  - v1beta1.admission.certmanager.k8s.io
  resources:
  - apiservices
  verbs:
  - get
  - update
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
rules:
- apiGroups:
  - certmanager.k8s.io
  resources:
  - certificates
  - issuers
  - clusterissuers
  - orders
  - challenges
  verbs:
  - '*'
- apiGroups:
  - ""
  resources:
  - configmaps
  - secrets
  - events
  - services
  - pods
  verbs:
  - '*'
- apiGroups:
  - extensions
  resources:
  - ingresses
  verbs:
  - '*'
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook:webhook-authentication-reader
  namespace: cert-manager
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: extension-apiserver-authentication-reader
subjects:
- apiGroup: ""
  kind: ServiceAccount
  name: cert-manager-webhook
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cert-manager-webhook-ca-sync
subjects:
- kind: ServiceAccount
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook:auth-delegator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- apiGroup: ""
  kind: ServiceAccount
  name: cert-manager-webhook
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cert-manager
subjects:
- kind: ServiceAccount
  name: cert-manager
  namespace: cert-manager
---
apiVersion: v1
data:
  config: |-
    {
        "apiServices": [
            {
                "name": "v1beta1.admission.certmanager.k8s.io",
                "secret": {
                    "name": "cert-manager-webhook-ca",
                    "namespace": "cert-manager",
                    "key": "tls.crt"
                }
            }
        ],
        "validatingWebhookConfigurations": [
            {
                "name": "cert-manager-webhook",
                "file": {
                    "path": "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
                }
            }
        ]
    }
kind: ConfigMap
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
spec:
  ports:
  - name: https
    port: 443
    targetPort: 6443
  selector:
    app: cert-manager
    heritage: kustomize
    release: cert-manager
  type: ClusterIP
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cert-manager
      heritage: kustomize
      release: cert-manager
  template:
    metadata:
      annotations: null
      labels:
        app: cert-manager
        heritage: kustomize
        release: cert-manager
    spec:
      containers:
      - args:
        - --v=12
        - --secure-port=6443
        - --tls-cert-file=/certs/tls.crt
        - --tls-private-key-file=/certs/tls.key
        - --disable-admission-plugins=NamespaceLifecycle,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,Initializers
        env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        image: quay.io/jetstack/cert-manager-webhook:v0.6.0
        imagePullPolicy: IfNotPresent
        name: webhook
        resources: {}
        volumeMounts:
        - mountPath: /certs
          name: certs
      serviceAccountName: cert-manager-webhook
      volumes:
      - name: certs
        secret:
          secretName: cert-manager-webhook-webhook-tls
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
  namespace: cert-manager
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cert-manager
      heritage: kustomize
      release: cert-manager
  template:
    metadata:
      annotations: null
      labels:
        app: cert-manager
        heritage: kustomize
        release: cert-manager
    spec:
      containers:
      - args:
        - --cluster-resource-namespace=$(POD_NAMESPACE)
        - --leader-election-namespace=$(POD_NAMESPACE)
        - --default-issuer-kind=ClusterIssuer
        - --default-issuer-name=letsencrypt
        env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        image: quay.io/jetstack/cert-manager-controller:v0.6.0
        imagePullPolicy: IfNotPresent
        name: cert-manager
        resources:
          requests:
            cpu: 10m
            memory: 32Mi
      serviceAccountName: cert-manager
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
spec:
  jobTemplate:
    metadata:
      labels:
        app: cert-manager
        heritage: kustomize
    spec:
      backoffLimit: 20
      template:
        metadata:
          labels:
            app: cert-manager
            heritage: kustomize
        spec:
          containers:
          - args:
            - -config=/config/config
            image: quay.io/munnerz/apiextensions-ca-helper:v0.1.0
            imagePullPolicy: IfNotPresent
            name: ca-helper
            resources:
              limits:
                cpu: 100m
                memory: 128Mi
              requests:
                cpu: 10m
                memory: 32Mi
            volumeMounts:
            - mountPath: /config
              name: config
          restartPolicy: OnFailure
          serviceAccountName: cert-manager-webhook-ca-sync
          volumes:
          - configMap:
              name: cert-manager-webhook-ca-sync
            name: config
  schedule: '@weekly'
---
apiVersion: admissionregistration.k8s.io/v1beta1
kind: ValidatingWebhookConfiguration
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
webhooks:
- clientConfig:
    service:
      name: kubernetes
      namespace: default
      path: /apis/admission.certmanager.k8s.io/v1beta1/certificates
  failurePolicy: Fail
  name: certificates.admission.certmanager.k8s.io
  namespaceSelector:
    matchExpressions:
    - key: certmanager.k8s.io/disable-validation
      operator: NotIn
      values:
      - "true"
    - key: name
      operator: NotIn
      values:
      - cert-manager
  rules:
  - apiGroups:
    - certmanager.k8s.io
    apiVersions:
    - v1alpha1
    operations:
    - CREATE
    - UPDATE
    resources:
    - certificates
- clientConfig:
    service:
      name: kubernetes
      namespace: default
      path: /apis/admission.certmanager.k8s.io/v1beta1/issuers
  failurePolicy: Fail
  name: issuers.admission.certmanager.k8s.io
  namespaceSelector:
    matchExpressions:
    - key: certmanager.k8s.io/disable-validation
      operator: NotIn
      values:
      - "true"
    - key: name
      operator: NotIn
      values:
      - cert-manager
  rules:
  - apiGroups:
    - certmanager.k8s.io
    apiVersions:
    - v1alpha1
    operations:
    - CREATE
    - UPDATE
    resources:
    - issuers
- clientConfig:
    service:
      name: kubernetes
      namespace: default
      path: /apis/admission.certmanager.k8s.io/v1beta1/clusterissuers
  failurePolicy: Fail
  name: clusterissuers.admission.certmanager.k8s.io
  namespaceSelector:
    matchExpressions:
    - key: certmanager.k8s.io/disable-validation
      operator: NotIn
      values:
      - "true"
    - key: name
      operator: NotIn
      values:
      - cert-manager
  rules:
  - apiGroups:
    - certmanager.k8s.io
    apiVersions:
    - v1alpha1
    operations:
    - CREATE
    - UPDATE
    resources:
    - clusterissuers
---
apiVersion: apiregistration.k8s.io/v1beta1
kind: APIService
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: v1beta1.admission.certmanager.k8s.io
spec:
  group: admission.certmanager.k8s.io
  groupPriorityMinimum: 1000
  service:
    name: cert-manager-webhook
    namespace: cert-manager
  version: v1beta1
  versionPriority: 15
---
apiVersion: batch/v1
kind: Job
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
spec:
  backoffLimit: 20
  template:
    metadata:
      labels:
        app: cert-manager
        heritage: kustomize
    spec:
      containers:
      - args:
        - -config=/config/config
        image: quay.io/munnerz/apiextensions-ca-helper:v0.1.0
        imagePullPolicy: IfNotPresent
        name: ca-helper
        resources:
          limits:
            cpu: 100m
            memory: 128Mi
          requests:
            cpu: 10m
            memory: 32Mi
        volumeMounts:
        - mountPath: /config
          name: config
      restartPolicy: OnFailure
      serviceAccountName: cert-manager-webhook-ca-sync
      volumes:
      - configMap:
          name: cert-manager-webhook-ca-sync
        name: config
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca
  namespace: cert-manager
spec:
  commonName: ca.webhook.cert-manager
  isCA: true
  issuerRef:
    name: cert-manager-webhook-selfsign
  secretName: cert-manager-webhook-ca
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-webhook-tls
  namespace: cert-manager
spec:
  dnsNames:
  - cert-manager-webhook
  - cert-manager-webhook.cert-manager
  - cert-manager-webhook.cert-manager.svc
  issuerRef:
    name: cert-manager-webhook-ca
  secretName: cert-manager-webhook-webhook-tls
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: selfsigning-issuer
  namespace: kube-system
spec:
  selfSigned: {}
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Issuer
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca
  namespace: cert-manager
spec:
  ca:
    secretName: cert-manager-webhook-ca
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Issuer
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-selfsign
  namespace: cert-manager
spec:
  selfsigned: {}
EOF
```


### Verification Step Expected4

<!-- @createExpected4 @test -->
```bash
cat <<'EOF' >${DEMO_HOME}/expected/reorder.notspecified.yaml
apiVersion: v1
kind: Namespace
metadata:
  labels:
    app: cert-manager
    certmanager.k8s.io/disable-validation: "true"
    heritage: kustomize
  name: cert-manager
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: certificates.certmanager.k8s.io
spec:
  additionalPrinterColumns:
  - JSONPath: .status.conditions[?(@.type=="Ready")].status
    name: Ready
    type: string
  - JSONPath: .spec.secretName
    name: Secret
    type: string
  - JSONPath: .spec.issuerRef.name
    name: Issuer
    priority: 1
    type: string
  - JSONPath: .status.conditions[?(@.type=="Ready")].message
    name: Status
    priority: 1
    type: string
  - JSONPath: .metadata.creationTimestamp
    description: |-
      CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.

      Populated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    name: Age
    type: date
  group: certmanager.k8s.io
  names:
    kind: Certificate
    plural: certificates
    shortNames:
    - cert
    - certs
  scope: Namespaced
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: challenges.certmanager.k8s.io
spec:
  additionalPrinterColumns:
  - JSONPath: .status.state
    name: State
    type: string
  - JSONPath: .spec.dnsName
    name: Domain
    type: string
  - JSONPath: .status.reason
    name: Reason
    type: string
  - JSONPath: .metadata.creationTimestamp
    description: |-
      CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.

      Populated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    name: Age
    type: date
  group: certmanager.k8s.io
  names:
    kind: Challenge
    plural: challenges
  scope: Namespaced
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: clusterissuers.certmanager.k8s.io
spec:
  group: certmanager.k8s.io
  names:
    kind: ClusterIssuer
    plural: clusterissuers
  scope: Cluster
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: issuers.certmanager.k8s.io
spec:
  group: certmanager.k8s.io
  names:
    kind: Issuer
    plural: issuers
  scope: Namespaced
  version: v1alpha1
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  labels:
    app: cert-manager
    heritage: kustomize
  name: orders.certmanager.k8s.io
spec:
  additionalPrinterColumns:
  - JSONPath: .status.state
    name: State
    type: string
  - JSONPath: .spec.issuerRef.name
    name: Issuer
    priority: 1
    type: string
  - JSONPath: .status.reason
    name: Reason
    priority: 1
    type: string
  - JSONPath: .metadata.creationTimestamp
    description: |-
      CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.

      Populated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    name: Age
    type: date
  group: certmanager.k8s.io
  names:
    kind: Order
    plural: orders
  scope: Namespaced
  version: v1alpha1
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
  namespace: cert-manager
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    release: cert-manager
  name: cert-manager-edit
rules:
- apiGroups:
  - certmanager.k8s.io
  resources:
  - certificates
  - issuers
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-view: "true"
    release: cert-manager
  name: cert-manager-view
rules:
- apiGroups:
  - certmanager.k8s.io
  resources:
  - certificates
  - issuers
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook:webhook-requester
rules:
- apiGroups:
  - admission.certmanager.k8s.io
  resources:
  - certificates
  - issuers
  - clusterissuers
  verbs:
  - create
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
rules:
- apiGroups:
  - certmanager.k8s.io
  resources:
  - certificates
  - issuers
  - clusterissuers
  - orders
  - challenges
  verbs:
  - '*'
- apiGroups:
  - ""
  resources:
  - configmaps
  - secrets
  - events
  - services
  - pods
  verbs:
  - '*'
- apiGroups:
  - extensions
  resources:
  - ingresses
  verbs:
  - '*'
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
rules:
- apiGroups:
  - ""
  resourceNames:
  - cert-manager-webhook-ca
  resources:
  - secrets
  verbs:
  - get
- apiGroups:
  - admissionregistration.k8s.io
  resourceNames:
  - cert-manager-webhook
  resources:
  - validatingwebhookconfigurations
  - mutatingwebhookconfigurations
  verbs:
  - get
  - update
- apiGroups:
  - apiregistration.k8s.io
  resourceNames:
  - v1beta1.admission.certmanager.k8s.io
  resources:
  - apiservices
  verbs:
  - get
  - update
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook:webhook-authentication-reader
  namespace: cert-manager
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: extension-apiserver-authentication-reader
subjects:
- apiGroup: ""
  kind: ServiceAccount
  name: cert-manager-webhook
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cert-manager
subjects:
- kind: ServiceAccount
  name: cert-manager
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cert-manager-webhook-ca-sync
subjects:
- kind: ServiceAccount
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook:auth-delegator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- apiGroup: ""
  kind: ServiceAccount
  name: cert-manager-webhook
  namespace: cert-manager
---
apiVersion: v1
data:
  config: |-
    {
        "apiServices": [
            {
                "name": "v1beta1.admission.certmanager.k8s.io",
                "secret": {
                    "name": "cert-manager-webhook-ca",
                    "namespace": "cert-manager",
                    "key": "tls.crt"
                }
            }
        ],
        "validatingWebhookConfigurations": [
            {
                "name": "cert-manager-webhook",
                "file": {
                    "path": "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
                }
            }
        ]
    }
kind: ConfigMap
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
spec:
  ports:
  - name: https
    port: 443
    targetPort: 6443
  selector:
    app: cert-manager
    heritage: kustomize
    release: cert-manager
  type: ClusterIP
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  labels:
    app: cert-manager
    chart: cert-manager-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager
  namespace: cert-manager
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cert-manager
      heritage: kustomize
      release: cert-manager
  template:
    metadata:
      annotations: null
      labels:
        app: cert-manager
        heritage: kustomize
        release: cert-manager
    spec:
      containers:
      - args:
        - --cluster-resource-namespace=$(POD_NAMESPACE)
        - --leader-election-namespace=$(POD_NAMESPACE)
        - --default-issuer-kind=ClusterIssuer
        - --default-issuer-name=letsencrypt
        env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        image: quay.io/jetstack/cert-manager-controller:v0.6.0
        imagePullPolicy: IfNotPresent
        name: cert-manager
        resources:
          requests:
            cpu: 10m
            memory: 32Mi
      serviceAccountName: cert-manager
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cert-manager
      heritage: kustomize
      release: cert-manager
  template:
    metadata:
      annotations: null
      labels:
        app: cert-manager
        heritage: kustomize
        release: cert-manager
    spec:
      containers:
      - args:
        - --v=12
        - --secure-port=6443
        - --tls-cert-file=/certs/tls.crt
        - --tls-private-key-file=/certs/tls.key
        - --disable-admission-plugins=NamespaceLifecycle,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,Initializers
        env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        image: quay.io/jetstack/cert-manager-webhook:v0.6.0
        imagePullPolicy: IfNotPresent
        name: webhook
        resources: {}
        volumeMounts:
        - mountPath: /certs
          name: certs
      serviceAccountName: cert-manager-webhook
      volumes:
      - name: certs
        secret:
          secretName: cert-manager-webhook-webhook-tls
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
spec:
  jobTemplate:
    metadata:
      labels:
        app: cert-manager
        heritage: kustomize
    spec:
      backoffLimit: 20
      template:
        metadata:
          labels:
            app: cert-manager
            heritage: kustomize
        spec:
          containers:
          - args:
            - -config=/config/config
            image: quay.io/munnerz/apiextensions-ca-helper:v0.1.0
            imagePullPolicy: IfNotPresent
            name: ca-helper
            resources:
              limits:
                cpu: 100m
                memory: 128Mi
              requests:
                cpu: 10m
                memory: 32Mi
            volumeMounts:
            - mountPath: /config
              name: config
          restartPolicy: OnFailure
          serviceAccountName: cert-manager-webhook-ca-sync
          volumes:
          - configMap:
              name: cert-manager-webhook-ca-sync
            name: config
  schedule: '@weekly'
---
apiVersion: apiregistration.k8s.io/v1beta1
kind: APIService
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: v1beta1.admission.certmanager.k8s.io
spec:
  group: admission.certmanager.k8s.io
  groupPriorityMinimum: 1000
  service:
    name: cert-manager-webhook
    namespace: cert-manager
  version: v1beta1
  versionPriority: 15
---
apiVersion: batch/v1
kind: Job
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca-sync
  namespace: cert-manager
spec:
  backoffLimit: 20
  template:
    metadata:
      labels:
        app: cert-manager
        heritage: kustomize
    spec:
      containers:
      - args:
        - -config=/config/config
        image: quay.io/munnerz/apiextensions-ca-helper:v0.1.0
        imagePullPolicy: IfNotPresent
        name: ca-helper
        resources:
          limits:
            cpu: 100m
            memory: 128Mi
          requests:
            cpu: 10m
            memory: 32Mi
        volumeMounts:
        - mountPath: /config
          name: config
      restartPolicy: OnFailure
      serviceAccountName: cert-manager-webhook-ca-sync
      volumes:
      - configMap:
          name: cert-manager-webhook-ca-sync
        name: config
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca
  namespace: cert-manager
spec:
  commonName: ca.webhook.cert-manager
  isCA: true
  issuerRef:
    name: cert-manager-webhook-selfsign
  secretName: cert-manager-webhook-ca
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-webhook-tls
  namespace: cert-manager
spec:
  dnsNames:
  - cert-manager-webhook
  - cert-manager-webhook.cert-manager
  - cert-manager-webhook.cert-manager.svc
  issuerRef:
    name: cert-manager-webhook-ca
  secretName: cert-manager-webhook-webhook-tls
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: selfsigning-issuer
  namespace: kube-system
spec:
  selfSigned: {}
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Issuer
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-ca
  namespace: cert-manager
spec:
  ca:
    secretName: cert-manager-webhook-ca
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Issuer
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook-selfsign
  namespace: cert-manager
spec:
  selfsigned: {}
---
apiVersion: admissionregistration.k8s.io/v1beta1
kind: ValidatingWebhookConfiguration
metadata:
  labels:
    app: cert-manager
    chart: webhook-v0.6.0
    heritage: kustomize
    release: cert-manager
  name: cert-manager-webhook
  namespace: cert-manager
webhooks:
- clientConfig:
    service:
      name: kubernetes
      namespace: default
      path: /apis/admission.certmanager.k8s.io/v1beta1/certificates
  failurePolicy: Fail
  name: certificates.admission.certmanager.k8s.io
  namespaceSelector:
    matchExpressions:
    - key: certmanager.k8s.io/disable-validation
      operator: NotIn
      values:
      - "true"
    - key: name
      operator: NotIn
      values:
      - cert-manager
  rules:
  - apiGroups:
    - certmanager.k8s.io
    apiVersions:
    - v1alpha1
    operations:
    - CREATE
    - UPDATE
    resources:
    - certificates
- clientConfig:
    service:
      name: kubernetes
      namespace: default
      path: /apis/admission.certmanager.k8s.io/v1beta1/issuers
  failurePolicy: Fail
  name: issuers.admission.certmanager.k8s.io
  namespaceSelector:
    matchExpressions:
    - key: certmanager.k8s.io/disable-validation
      operator: NotIn
      values:
      - "true"
    - key: name
      operator: NotIn
      values:
      - cert-manager
  rules:
  - apiGroups:
    - certmanager.k8s.io
    apiVersions:
    - v1alpha1
    operations:
    - CREATE
    - UPDATE
    resources:
    - issuers
- clientConfig:
    service:
      name: kubernetes
      namespace: default
      path: /apis/admission.certmanager.k8s.io/v1beta1/clusterissuers
  failurePolicy: Fail
  name: clusterissuers.admission.certmanager.k8s.io
  namespaceSelector:
    matchExpressions:
    - key: certmanager.k8s.io/disable-validation
      operator: NotIn
      values:
      - "true"
    - key: name
      operator: NotIn
      values:
      - cert-manager
  rules:
  - apiGroups:
    - certmanager.k8s.io
    apiVersions:
    - v1alpha1
    operations:
    - CREATE
    - UPDATE
    resources:
    - clusterissuers
EOF
```


<!-- @compareActualToExpected @test -->
```bash
test 0 == \
$(diff -r $DEMO_HOME/actual $DEMO_HOME/expected | wc -l); \
echo $?
```

