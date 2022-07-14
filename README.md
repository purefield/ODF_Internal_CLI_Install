[]{#ODFInternalModeCLIinstallStepbyStep.xhtml}

[ODF Internal Mode CLI install Step-by-Step]{.c17}

[Last installed OCP 4.10.20, LSO 4.10, ODF 4.10.4]{.c9}

Developed from [
[https://access.redhat.com/articles/5683981](https://www.google.com/url?q=https://access.redhat.com/articles/5683981&sa=D&source=editors&ust=1657813058482739&usg=AOvVaw1zTO7ym5AMuTRQHv0Tj03s){.c5}
]{.c11} [ ]{.c4}

[]{.c4}

[ [Files:
internal](https://www.google.com/url?q=https://drive.google.com/drive/folders/1_8gDjpR1mhrPHN5Rg0ZuakBUNrtKbXOc&sa=D&source=editors&ust=1657813058483529&usg=AOvVaw3dWKseXr_JW6XFhnSPxzM7){.c5}
]{.c11 .c14} [ ]{.c4}

# [Label nodes]{.c8} {#ODFInternalModeCLIinstallStepbyStep.xhtml#h.80ujf2c7npt7 .c0}

[Labeling the storage nodes allows us to create an LSO LocalVolumeSet
only for storage nodes]{.c4}

[You will need to change the node names to match your cluster.]{.c15}

[]{.c4}

[ oc label node openshift-worker-3.testme.libvirt2.smh
cluster.ocs.openshift.io/openshift-storage=\'\'\
oc label node openshift-worker-4.testme.libvirt2.smh
cluster.ocs.openshift.io/openshift-storage=\'\'\
oc label node openshift-worker-5.testme.libvirt2.smh
cluster.ocs.openshift.io/openshift-storage=\'\' ]{.c13}

# [Taint Nodes and Label as Infra (optional)]{.c8} {#ODFInternalModeCLIinstallStepbyStep.xhtml#h.rbn0y35f37qk .c0}

[You will need to change the node names to match your cluster.]{.c15}

[]{.c4}

1.  [ oc label node openshift-worker-3.testme.libvirt2.smh
    node-role.kubernetes.io/infra=\"\"\
    oc label node openshift-worker-4.testme.libvirt2.smh
    node-role.kubernetes.io/infra=\"\"\
    oc label node openshift-worker-5.testme.libvirt2.smh
    node-role.kubernetes.io/infra=\"\" ]{.c13}
2.  [ oc adm taint node openshift-worker-3.testme.libvirt2.smh
    node.ocs.openshift.io/storage=\"true\":NoSchedule\
    oc adm taint node openshift-worker-4.testme.libvirt2.smh
    node.ocs.openshift.io/storage=\"true\":NoSchedule\
    oc adm taint node openshift-worker-5.testme.libvirt2.smh
    node.ocs.openshift.io/storage=\"true\":NoSchedule ]{.c13}

# [LSO]{.c8} {#ODFInternalModeCLIinstallStepbyStep.xhtml#h.us2ftrzacwhi .c0}

1.   Create openshift-local-storage namespace\
    [oc create -f ODF-CLI/lso-namespace.yaml]{.c1}
2.   Create openshift-local-storage-cliinstall oporatorgroup\
    [oc create -f ODF-CLI/lso-opgroup.yaml]{.c1}
3.   Create LSO subscription\
    [oc create -f ODF-CLI/lso-sub.yaml]{.c1}
4.  [ Wait for subscription to finish installing\
    CSVname=\`oc get ClusterServiceVersion -n openshift-local-storage
    \|grep -v NAME\| cut -d\' \' -f1\`\
    while \[ \"\`oc get ClusterServiceVersion \$CSVname -n
    openshift-local-storage -o jsonpath=\'{.status.phase}{\"\\n\"}\'\`\"
    != \"Succeeded\" \] ; do echo -n \".\" && sleep 10 ; done\
    echo ]{.c4}
5.   Create localvolumeset\
    [ oc create -f ODF-CLI/lso-localvolset.yaml\
    ]{.c1}

# [ODF]{.c8} {#ODFInternalModeCLIinstallStepbyStep.xhtml#h.8wvoyi5qlaks .c0}

1.   Create the openshift-storage namespace\
    [oc create -f ODF-CLI/odf-namespace.yaml]{.c1}
2.   Create the openshift-storage-operatorgroup for the Operator\
    [oc create -f ODF-CLI/odf-operatorgroup.yaml]{.c1}
3.   Subscribe to the odf-operator\
    [oc create -f ODF-CLI/odf-sub.yaml]{.c1}
4.  [Enable console plugin]{.c4}

[]{.c4}

[oc patch console.operator cluster -n openshift-storage \--type json -p
\'\[{\"op\": \"add\", \"path\": \"/spec/plugins\", \"value\":
\[\"odf-console\"\]}\]\']{.c1}

[]{.c4}

5.  [ Wait for subscription to finish installing\
    CSVname=\`oc get ClusterServiceVersion -n openshift-storage \|grep
    -v NAME\| cut -d\' \' -f1\`\
    while \[ \"\`oc get ClusterServiceVersion \$CSVname -n
    openshift-storage -o jsonpath=\'{.status.phase}{\"\\n\"}\'\`\" !=
    \"Succeeded\" \] ; do echo -n \".\" && sleep 10 ; done\
    echo ]{.c4}
6.   Create Storage System and Storage cluster\
    [oc create -f ODF-CLI/odf-storagesystem.yaml]{.c1}
7.  [ Wait for storage cluster to be ready\
    while \[ \"\`oc get StorageCluster ocs-storagecluster -n
    openshift-storage -o jsonpath=\'{.status.phase}{\"\\n\"}\'\`\" !=
    \"Succeeded\" \] ; do echo -n \".\" && sleep 10 ; done\
    echo ]{.c4}
8.  [Set default storage class (optional if you already have a default
    storage class set)]{.c4}

[]{.c4}

[oc patch storageclass ocs-storagecluster-ceph-rbd -p \'{\"metadata\":
{\"annotations\": {\"storageclass.kubernetes.io/is-default-class\":
\"true\"}}}\']{.c1}

[]{.c4}

9.  [Verify ]{.c4}

[]{.c4}

[]{.c4}
