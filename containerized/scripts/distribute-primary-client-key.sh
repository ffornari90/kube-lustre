#!/bin/bash
ps_key=$(kubectl -n lustre exec -ti $(kubectl -n lustre get pod --field-selector spec.nodeName=cs-002.cr.cnaf.infn.it --output=jsonpath={.items..metadata.name} -l lustrefs/client) -- cat /root/.ssh/id_rsa.pub)
for i in 1 3 4
do
    kubectl -n lustre exec -ti $(kubectl -n lustre get pod --field-selector spec.nodeName=cs-00$i.cr.cnaf.infn.it --output=jsonpath={.items..metadata.name} -l lustrefs/client) -- bash -c 'echo "'"$ps_key"'" | tee -a /root/.ssh/authorized_keys'
done
for i in $(seq 1 4)
do
    kubectl -n lustre exec -ti $(kubectl -n lustre get pod --field-selector spec.nodeName=cs-002.cr.cnaf.infn.it --output=jsonpath={.items..metadata.name} -l lustrefs/client) -- bash -c 'ssh-keyscan -p 22222 cs-00'"$i"'.cr.cnaf.infn.it | tee -a /root/.ssh/known_hosts'
    kubectl -n lustre exec -ti $(kubectl -n lustre get pod --field-selector spec.nodeName=cs-002.cr.cnaf.infn.it --output=jsonpath={.items..metadata.name} -l lustrefs/client) -- bash -c 'ssh-keyscan -p 22222 cs-00'"$i"' | tee -a /root/.ssh/known_hosts'
done
