/*
  This library contains grafana-dashboard-operator objects.
  See https://github.com/srfrnk/grafana-dashboard-operator for details.
*/
{
  GrafanaDashboard(namespace, name, dashboard=null, dashboards=null, grafonnet=null):: (
    {
      apiVersion: 'grafana.operators/v1',
      kind: 'GrafanaDashboard',
      metadata: {
        name: name,
        namespace: namespace,
      },
      spec: {
        [if dashboard != null then 'dashboard' else null]: dashboard,
        [if dashboards != null then 'dashboards' else null]: dashboards,
        [if grafonnet != null then 'grafonnet' else null]: grafonnet,
      },
    }
  ),
}
