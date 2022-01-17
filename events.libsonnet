/*
  This library contains Kubernetes event objects.
*/
{
  ObjectReference(apiVersion,
                  kind,
                  name,
                  namespace,
                  uid,
                  resourceVersion=null):: ({
                                             apiVersion: apiVersion,
                                             kind: kind,
                                             name: name,
                                             namespace: namespace,
                                             uid: uid,
                                             [if resourceVersion != null then 'resourceVersion' else null]: resourceVersion,
                                           }),
  Event(name,
        namespace,
        eventTime,
        reportingController,
        reportingInstance,
        action,
        reason,
        type,
        note,
        regarding, /* ObjectReference */
        count=null):: ({
                         apiVersion: 'events.k8s.io/v1',
                         kind: 'Event',
                         metadata: {
                           name: name,
                           namespace: namespace,
                         },
                         eventTime: eventTime,  //'2021-12-30T09:37:20.886561Z'
                         reportingController: reportingController,
                         reportingInstance: reportingInstance,
                         action: action,
                         reason: reason,
                         type: type,
                         note: note,
                         regarding: regarding,
                         [if count != null then 'series' else null]: {
                           count: count,
                           lastObservedTime: eventTime,
                         },
                       }),
  SimpleEvent(eventName,
              name,
              namespace,
              apiVersion,
              kind,
              uid,
              resourceVersion,
              action,
              reason,
              type,
              note,
              controller,
              eventTime,
              count=null):: (self.Event(name=eventName,
                                        namespace=namespace,
                                        eventTime=eventTime,
                                        reportingController=controller,
                                        reportingInstance=name,
                                        action=action,
                                        reason=reason,
                                        type=type,
                                        note=note,
                                        regarding=self.ObjectReference(
                                          apiVersion=apiVersion,
                                          kind=kind,
                                          name=name,
                                          namespace=namespace,
                                          uid=uid,
                                          resourceVersion=resourceVersion,
                                        ),
                                        count=count)),
}
