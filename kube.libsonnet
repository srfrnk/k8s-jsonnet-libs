/*
  This library contains general Kubernetes objects.
*/
{
  CRD(isClusterScoped=false, kind, singular, plural, group, shortNames=[], versions=[]):: (
    local version(v) =
      local setStatus = std.objectHas(v.schema.openAPIV3Schema.properties, 'status');
      v {
        schema+: {
          openAPIV3Schema+: {
            properties+: {
              [if setStatus then 'status' else null]+: {
                type: 'object',
                description: (if std.objectHas(v.schema.openAPIV3Schema.properties.status, 'description')
                              then v.schema.openAPIV3Schema.properties.status.description else 'Status of object'),
                properties+: {
                  conditions: {
                    type: 'array',
                    default: [],
                    description: 'List of conditions',
                    items: {
                      type: 'object',
                      description: 'Condition',
                      required: ['type', 'status'],
                      properties: {
                        type: {
                          type: 'string',
                          description: 'Type of condition',
                        },
                        status: {
                          type: 'string',
                          description: 'Status of the condition, one of **True**, **False**, **Unknown**',
                          enum: ['True', 'False', 'Unknown'],
                        },
                        reason: {
                          type: 'string',
                          description: "One-word CamelCase reason for the condition's last transition",
                        },
                        message: {
                          type: 'string',
                          description: 'Human-readable message indicating details about last transition',
                        },
                        lastHeartbeatTime: {
                          type: 'string',
                          description: 'Last time we got an update on a given condition',
                        },
                        lastTransitionTime: {
                          type: 'string',
                          description: 'Last time the condition transit from one status to another',
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        },
        [if setStatus then 'subresources' else null]+: {
          status: {},
        },
      };

    {
      apiVersion: 'apiextensions.k8s.io/v1',
      kind: 'CustomResourceDefinition',
      metadata: {
        name: plural + '.' + group,
      },
      spec: {
        group: group,
        scope: if isClusterScoped then 'Cluster' else 'Namespaced',
        versions: [version(v) for v in versions],
        names: {
          plural: plural,
          singular: singular,
          kind: kind,
          shortNames: shortNames,
        },
      },
    }
  ),
  Deployment(namespace, name, replicas, serviceAccountName=null, containers=[], volumes=[]):: ({
                                                                                                 apiVersion: 'apps/v1',
                                                                                                 kind: 'Deployment',
                                                                                                 metadata: {
                                                                                                   name: name,
                                                                                                   namespace: namespace,
                                                                                                 },
                                                                                                 spec: {
                                                                                                   replicas: replicas,
                                                                                                   selector: {
                                                                                                     matchLabels: {
                                                                                                       app: name,
                                                                                                     },
                                                                                                   },
                                                                                                   template: {
                                                                                                     metadata: {
                                                                                                       labels:
                                                                                                         {
                                                                                                           app: name,
                                                                                                         },
                                                                                                     },
                                                                                                     spec: {
                                                                                                       [if serviceAccountName != null then 'serviceAccountName' else null]: serviceAccountName,
                                                                                                       containers: containers,
                                                                                                       volumes: volumes,
                                                                                                       securityContext: {
                                                                                                         runAsNonRoot: true,
                                                                                                       },
                                                                                                     },
                                                                                                   },
                                                                                                 },
                                                                                               }),
  Container(name, image, imagePullPolicy):: ({
                                               name: name,
                                               image: image,
                                               livenessProbe: {
                                                 initialDelaySeconds: 10,
                                                 periodSeconds: 30,
                                                 timeoutSeconds: 5,
                                                 failureThreshold: 3,
                                                 successThreshold: 1,
                                               },
                                               readinessProbe: {
                                                 initialDelaySeconds: 10,
                                                 periodSeconds: 30,
                                                 timeoutSeconds: 5,
                                                 failureThreshold: 3,
                                                 successThreshold: 1,
                                               },
                                               imagePullPolicy: imagePullPolicy,
                                               securityContext: {
                                                 readOnlyRootFilesystem: true,
                                                 allowPrivilegeEscalation: false,
                                                 runAsNonRoot: true,
                                                 capabilities: {
                                                   drop: ['ALL'],
                                                 },
                                               },
                                             }),
  Service(namespace, name, labels=null, selector, ports, headless=false):: ({
                                                                              apiVersion: 'v1',
                                                                              kind: 'Service',
                                                                              metadata: {
                                                                                name: name,
                                                                                namespace: namespace,
                                                                                [if labels != null then 'labels' else null]: labels,
                                                                              },
                                                                              spec: {
                                                                                [if headless then 'clusterIP' else null]: 'None',
                                                                                selector: selector,
                                                                                ports: ports,
                                                                              },
                                                                            }),
  ServiceAccount(name, namespace):: ({
                                       apiVersion: 'v1',
                                       kind: 'ServiceAccount',
                                       metadata: {
                                         name: name,
                                         namespace: namespace,
                                       },
                                     }),
  Role(name, namespace, rules=[]):: ({
                                       apiVersion: 'rbac.authorization.k8s.io/v1',
                                       kind: 'Role',
                                       metadata: {
                                         name: name,
                                         namespace: namespace,
                                       },
                                       rules: rules,
                                     }),
  PolicyRule(apiGroups=[], resources=[], verbs=[], resourceNames=[], nonResourceURLs=[]):: ({
                                                                                              apiGroups: apiGroups,
                                                                                              resources: resources,
                                                                                              verbs: verbs,
                                                                                              resourceNames: resourceNames,
                                                                                              nonResourceURLs: nonResourceURLs,
                                                                                            }),

  RoleBinding(name, namespace, roleName, subjects=[]):: ({
                                                           apiVersion: 'rbac.authorization.k8s.io/v1',
                                                           kind: 'RoleBinding',
                                                           metadata: {
                                                             name: name,
                                                             namespace: namespace,
                                                           },
                                                           roleRef: {
                                                             apiGroup: 'rbac.authorization.k8s.io',
                                                             kind: 'Role',
                                                             name: roleName,
                                                           },
                                                           subjects: subjects,
                                                         }),
  Subject(apiGroup, kind, name, namespace):: ({
                                                apiGroup: apiGroup,
                                                kind: kind,
                                                namespace: namespace,
                                                name: name,
                                              }),
  ConfigMap(name, namespace, data):: ({
                                        apiVersion: 'v1',
                                        kind: 'ConfigMap',
                                        metadata: {
                                          name: name,
                                          namespace: namespace,
                                        },
                                        data: data,
                                      }),
}
