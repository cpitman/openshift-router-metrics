# OpenShift Router Metrics

OpenShift by default uses HAProxy to reverse proxy and load balance 
traffic coming from outside of OpenShift going to one or more pods 
deployed in OpenShift. HAproxy exposes a statistics web page on port 1936, which
a user can login to if they know the HAProxy admin password. Once logged in, a
user can see data for all routes exposed by OpenShift.

The stats page provides lots of useful data:

* What pods the router is currently exposing
* If any pods are failing router health checks
* If any or all pods are returning error codes
* Latency for requests
* Etc

openshift-router-metrics is an application that exposes HAProxy metrics and
integrates with OpenShift for authentication. Users do not need to know the
HAProxy admin password, and can use their own credentials for accessing
OpenShift. Once logged in, users can only see information on routes that they
have access to in OpenShift.

In other words, a cluster administrator can see information for all routes,
while a normal user can see data for routes they have access to.

The app also exposes a tenant-aware csv data endpoint, just add `?csv` to the
end of the url.

## Deployment

Prerequisites:

1. This application communicates with HAProxy to get statistics, which requires 
   port 1936/TCP to be open on all infrastructure nodes. This is good practice
   anyways, since this is the port that should be used for health checking the
   routers.

Most of the installation is automated via a OpenShift Template. Download the
template
[openshift-router-metrics.yaml](https://raw.githubusercontent.com/cpitman/openshift-router-metrics/master/openshift-router-metrics.yaml],
and then create the template by running `oc create -n openshift -f
openshift-router-metrics.yml`. Then, using the web ui, choose a project and then
click "Add to Project". Select the "openshift-router-metrics" template. The most
important parameters that you need to provide are:

1. The public hostname that this app should be exposed on. This is needed to
   properly setup OAuth SSO, and should not include a scheme (ie
   "router-metrics.paas.example.com")
2. The public master url for accessing the OpenShift Web UI, again needed for
   OAuth SSO (ie "https://paas-console.example.com:8443")
3. Disable TLS Certificate verification if you are using a self signed
   certificate for the public master url

*After running the template* instructions will be displayed on the screen for
running two more commands to provide the app access to the routers and OAuth
SSO. Both commands must be executed before the app will properly function.
