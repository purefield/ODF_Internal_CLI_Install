Developed from <https://access.redhat.com/articles/5683981>


# Label nodes

Labeling the storage nodes allows us to create an LSO LocalVolumeSet
only for storage nodes

*You will need to change the node names to match your cluster.*

oc label node openshift-worker-3.testme.libvirt2.smh
cluster.ocs.openshift.io/openshift-storage=\'\'\
oc label node openshift-worker-4.testme.libvirt2.smh
cluster.ocs.openshift.io/openshift-storage=\'\'\
oc label node openshift-worker-5.testme.libvirt2.smh
cluster.ocs.openshift.io/openshift-storage=\'\'

# Taint Nodes and Label as Infra (optional)

*You will need to change the node names to match your cluster.*

1.  oc label node openshift-worker-3.testme.libvirt2.smh
    > node-role.kubernetes.io/infra=\"\"\
    > oc label node openshift-worker-4.testme.libvirt2.smh
    > node-role.kubernetes.io/infra=\"\"\
    > oc label node openshift-worker-5.testme.libvirt2.smh
    > node-role.kubernetes.io/infra=\"\"

2.  oc adm taint node openshift-worker-3.testme.libvirt2.smh
    > node.ocs.openshift.io/storage=\"true\":NoSchedule\
    > oc adm taint node openshift-worker-4.testme.libvirt2.smh
    > node.ocs.openshift.io/storage=\"true\":NoSchedule\
    > oc adm taint node openshift-worker-5.testme.libvirt2.smh
    > node.ocs.openshift.io/storage=\"true\":NoSchedule

# LSO

1.  Create openshift-local-storage namespace\
    > oc create -f ODF-CLI/lso-namespace.yaml

2.  Create openshift-local-storage-cliinstall oporatorgroup\
    > oc create -f ODF-CLI/lso-opgroup.yaml

3.  Create LSO subscription\
    > oc create -f ODF-CLI/lso-sub.yaml

4.  Wait for subscription to finish installing\
    > CSVname=\`oc get ClusterServiceVersion -n openshift-local-storage
    > \|grep -v NAME\| cut -d\' \' -f1\`\
    > while \[ \"\`oc get ClusterServiceVersion \$CSVname -n
    > openshift-local-storage -o
    > jsonpath=\'{.status.phase}{\"\\n\"}\'\`\" != \"Succeeded\" \] ; do
    > echo -n \".\" && sleep 10 ; done\
    > echo

5.  Create localvolumeset\
    > oc create -f ODF-CLI/lso-localvolset.yaml

# ODF

1.  Create the openshift-storage namespace\
    > oc create -f ODF-CLI/odf-namespace.yaml

2.  Create the openshift-storage-operatorgroup for the Operator\
    > oc create -f ODF-CLI/odf-operatorgroup.yaml

3.  Subscribe to the odf-operator\
    > oc create -f ODF-CLI/odf-sub.yaml

4.  Enable console plugin

oc patch console.operator cluster -n openshift-storage \--type json -p
\'\[{\"op\": \"add\", \"path\": \"/spec/plugins\", \"value\":
\[\"odf-console\"\]}\]\'

5.  Wait for subscription to finish installing\
    > CSVname=\`oc get ClusterServiceVersion -n openshift-storage \|grep
    > -v NAME\| cut -d\' \' -f1\`\
    > while \[ \"\`oc get ClusterServiceVersion \$CSVname -n
    > openshift-storage -o jsonpath=\'{.status.phase}{\"\\n\"}\'\`\" !=
    > \"Succeeded\" \] ; do echo -n \".\" && sleep 10 ; done\
    > echo

6.  Create Storage System and Storage cluster\
    > oc create -f ODF-CLI/odf-storagesystem.yaml

7.  Wait for storage cluster to be ready\
    > while \[ \"\`oc get StorageCluster ocs-storagecluster -n
    > openshift-storage -o jsonpath=\'{.status.phase}{\"\\n\"}\'\`\" !=
    > \"Succeeded\" \] ; do echo -n \".\" && sleep 10 ; done\
    > echo

8.  Set default storage class (optional if you already have a default
    > storage class set)

oc patch storageclass ocs-storagecluster-ceph-rbd -p \'{\"metadata\":
{\"annotations\": {\"storageclass.kubernetes.io/is-default-class\":
\"true\"}}}\'

9.  Verify
