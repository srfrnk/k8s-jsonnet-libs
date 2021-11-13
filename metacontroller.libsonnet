/*
  This library contains Metacontroller objects.
  See https://github.com/metacontroller/metacontroller for details.
*/
{
  DecoratorController(name, resources, attachments=[], syncHook, finalize=null, customize=null, resyncPeriodSeconds=null):: ({
                                                                                                                               apiVersion: 'metacontroller.k8s.io/v1alpha1',
                                                                                                                               kind: 'DecoratorController',
                                                                                                                               metadata: {
                                                                                                                                 name: name,
                                                                                                                               },
                                                                                                                               spec:
                                                                                                                                 {
                                                                                                                                   resources: resources,
                                                                                                                                   attachments: attachments,
                                                                                                                                   hooks:
                                                                                                                                     {
                                                                                                                                       sync: syncHook,
                                                                                                                                       [if finalize != null then 'finalize' else null]: finalize,
                                                                                                                                       [if customize != null then 'customize' else null]: customize,
                                                                                                                                     },
                                                                                                                                   [if resyncPeriodSeconds != null then 'resyncPeriodSeconds' else null]: resyncPeriodSeconds,
                                                                                                                                 },
                                                                                                                             }),
}
