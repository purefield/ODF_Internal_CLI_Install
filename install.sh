#! /bin/bash

pathtobin=`realpath $0`
pathtoyaml="`dirname $pathtobin`"/YAML

if [ "$KUBECONFIG"x == x ]; then exit; fi

## label nodes as storage so LSO can find disks, if not labeled by machineset
#oc label node openshift-worker-0.testme.libvirt2.smh cluster.ocs.openshift.io/openshift-storage=''
#oc label node openshift-worker-1.testme.libvirt2.smh cluster.ocs.openshift.io/openshift-storage=''
#oc label node openshift-worker-2.testme.libvirt2.smh cluster.ocs.openshift.io/openshift-storage=''

## label nodes as infra if using them as sucn, if not labeled by machineset
#oc label node openshift-worker-0.testme.libvirt2.smh node-role.kubernetes.io/infra=""
#oc label node openshift-worker-1.testme.libvirt2.smh node-role.kubernetes.io/infra=""
#oc label node openshift-worker-2.testme.libvirt2.smh node-role.kubernetes.io/infra=""

## taint nodes if they are dedicated storage nodes, if not tainted by machineset
#oc adm taint node openshift-worker-0.testme.libvirt2.smh node.ocs.openshift.io/storage="true":NoSchedule
#oc adm taint node openshift-worker-1.testme.libvirt2.smh node.ocs.openshift.io/storage="true":NoSchedule
#oc adm taint node openshift-worker-2.testme.libvirt2.smh node.ocs.openshift.io/storage="true":NoSchedule


CSVname=`oc get ClusterServiceVersion -n openshift-local-storage |grep -v NAME| cut -d' ' -f1`
if [ "$CSVname"x == "x" ]; then
  oc create -f $pathtoyaml/lso-namespace.yaml
  oc create -f $pathtoyaml/lso-opgroup.yaml
  oc create -f $pathtoyaml/lso-sub.yaml
  echo "waiting for LocalStorage to be ready"
  sleep 60
  CSVname=`oc get ClusterServiceVersion -n openshift-local-storage |grep -v NAME| cut -d' ' -f1`
  while [ "`oc get ClusterServiceVersion $CSVname -n openshift-local-storage -o jsonpath='{.status.phase}{"\n"}'`" != "Succeeded" ] ; do echo -n "." && sleep 10 ; done
  echo
  oc create -f $pathtoyaml/lso-localvolset.yaml
  echo "waiting for LocalStorage PVs to be ready"
  sleep 60
fi
CSVname=`oc get ClusterServiceVersion -n openshift-storage |grep odf-operator| cut -d' ' -f1`
if [ "$CSVname"x == "x" ]; then
  oc create -f $pathtoyaml/odf-namespace.yaml
  oc create -f $pathtoyaml/odf-operatorgroup.yaml
  oc create -f $pathtoyaml/odf-sub.yaml
  oc patch console.operator cluster -n openshift-storage --type json -p '[{"op": "add", "path": "/spec/plugins", "value": ["odf-console"]}]'
  echo "waiting for StorageSystem to be ready"
  sleep 60
  CSVname=`oc get ClusterServiceVersion -n openshift-storage |grep odf-operator| cut -d' ' -f1`
  while [ "`oc get ClusterServiceVersion $CSVname -n openshift-storage -o jsonpath='{.status.phase}{"\n"}'`" != "Succeeded" ] ; do echo -n "." && sleep 10 ; done
  echo
fi
CSVname=`oc get StorageCluster -n openshift-storage|grep -v NAME| cut -d' ' -f1`
if [ "$CSVname"x == "x" ]; then
  oc create -f $pathtoyaml/odf-storagesystem.yaml
#  oc create -f $pathtoyaml/odf-storagesystem-4node.yaml
  echo "waiting for StorageCluster to be ready"
  sleep 60
  while [ "`oc get StorageCluster ocs-storagecluster -n openshift-storage -o jsonpath='{.status.phase}{"\n"}'`" != "Ready" ] ; do echo -n "." && sleep 10 ; done
  echo
fi

oc patch storageclass ocs-storagecluster-ceph-rbd -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "true"}}}'

echo "done"
