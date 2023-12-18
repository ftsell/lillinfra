# Monitoring

The monitoring solution is based on [icinga2](https://icinga.com/) ([docs](https://icinga.com/docs/icinga-2/latest/doc/01-about/)).
Icinga periodically executes configured checks against my infrastructure, notifies me about outages and aggregates some performance data.

## Configuration

The configuration is done via the [`icinga_node` role](./ansible/roles/icinga_node) which is applied for each node that should be part of the icinga cluster.
Most nodes don't have much configuration of their own and instead receive relevant parts of the config (i.e. which checks to execute when) from the cluster leader.
This cluster leader is the *monitoring* server (`monitoring.srv.ftsell.de`).
It also has the same `icinga_node` role but with more components enabled and more configuration done.

Concrete configuration is located in the *monitoring* servers host_vars ([link](./ansible/inventory/host_vars/monitoring/main.yml)).
To apply zone reconfiguration, run this command:
```shell
ansible-playbook playbooks/setup.yml -l monitoring -t icinga_node
```

### Icinga Basics

The way icinga is configured is via a set of *objects* ([object types docs](https://icinga.com/docs/icinga-2/latest/doc/09-object-types/)).
Each object describes something in the infrastructure while the *Host* and *Service* objects are arguably the most important ones because they describe what icinga should monitor and how to do that.

*Hosts* are generally meant to describe a Server but I also use them to model a Load-Balancer.
Basically anything can be a host as long as it provides some services.

*Services* are things which a user might use or which describe detailed aspects about the infrastructure.
For example, a website could be a service but *available disk space* could also be one.
Services are always associated with one *Host* object.

### About Zones, Endpoints and Hosts

Icinga supports distributed monitoring ([docs](https://icinga.com/docs/icinga-2/latest/doc/06-distributed-monitoring/)) through the concept of *Zones* and *Endpoints*.

*Zones* describe an availability zone or area of the icinga cluster from which service and host checks are executed.
Zones can also be configured to be in a hierarchy.
If *zone a* is the parent of *zone b*, then *b* will accept configuration updates and commands from *a* while reporting statuses back to it.
If a zone has no parent, it is either a root zone or a *global* zone which is made available to all nodes regardless of where in the zone hierarchy they are placed.

*Endpoints* are always part of a zone and tell icinga how to communicate with icinga nodes in that zone to synchronize its configuration and schedule check execution.

In my setup, the zone hierarchy is like this:

- Each node that is part of the icinga cluster has its own zone with that node being the only endpoint in that zone.
- The monitoring servers zone is configured as the root zone and all others are direct parents of it.
- There is one *global-templates* zone for object templates and service apply rules.

Putting the that into a picture results in the following example zone diagram:

```text
                          ┌──────────────────────────────────────┐
                          │ Zone: monitoring server (root)       │
                          │ Endpoints: monitoring server         │
                          │                                      │
                          │ Hosts:                               │
                          │   - monitoring server                │
                          │   - K8S Main IP                      │
                          │   - K8S Mail IP                      │
                          │ Services:                            │
                          │   - services regarding above hosts   │
                          │   - icinga cluster services          │
                          └──────────────────┬───────────────────┘
                                             │
                                             │
                    ┌────────────────────────┴───────────────────────┐
                    │                                                │
┌───────────────────┴──────────────────┐         ┌───────────────────┴────────────────┐
│ Zone: vpn server                     │         │ Zone: main server                  │
│ Endpoints: vpn server                │         │ Endpoints: main server             │
│                                      │         │                                    │
│ Hosts:                               │         │ Hosts:                             │
│   - vpn server                       │         │   - main server                    │
│   - vpn clients                      │         │ Services:                          │
│ Services:                            │         │   - services regarding above host  │
│   - services regarding above hosts   │         └────────────────────────────────────┘
└──────────────────────────────────────┘
```
