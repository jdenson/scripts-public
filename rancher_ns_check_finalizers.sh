# Function to remove finalizers
remove_finalizers() {
  local namespace=$1
  local resource=$2
  local kind=$3
  echo "Removing finalizers from $kind in namespace $namespace..."
  kubectl get $kind -n $namespace -o json | jq '.items[] | select(.metadata.finalizers!=null) | .metadata.name' | xargs -I {} kubectl patch $kind {} -n $namespace -p '{"metadata":{"finalizers":[]}}' --type=merge
}

# Namespaces with finalizers based on ns_check output
namespaces=("cattle-global-data" "cattle-global-nt" "cattle-impersonation-system" "cattle-system" "cattle-fleet-system" "cattle-fleet-clusters-system" "cattle-fleet-local-system" "cattle-provisioning-capi-system")

# Resource types to check for finalizers
resource_types=("configmaps" "serviceaccounts" "rolebindings.rbac.authorization.k8s.io" "roles.rbac.authorization.k8s.io" "catalogtemplates.management.cattle.io" "catalogtemplateversions.management.cattle.io" "rkeaddons.management.cattle.io" "rkek8sserviceoptions.management.cattle.io" "rkek8ssystemimages.management.cattle.io")

# Iterate over each namespace and resource type
for ns in "${namespaces[@]}"; do
  for resource in "${resource_types[@]}"; do
    remove_finalizers "$ns" "$resource" "$resource"
  done
done

echo "Finalizer removal process completed."
