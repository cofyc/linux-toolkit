# k8s

## Generate kube config files for all nodes

```
SERVER=https://...
./hack/gen-node-kubeconfig.sh $SERVER $(kubectl get nodes -ojsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
```
