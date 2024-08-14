#!/bin/bash

# Function to validate if a namespace exists in Kubernetes
validate_namespace() {
  local namespace=$1

  if kubectl get namespace "$namespace" > /dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

# Function to restart deployments in a namespace
restart_deployments() {
  local namespace=$1

  echo "Restarting deployments in namespace '$namespace'..."
  kubectl rollout restart deployment -n "$namespace"
}

# Check if at least one namespace was provided as an argument
if [ $# -lt 1 ]; then
  echo "Usage: $0 <namespace1> [<namespace2> ...]"
  exit 1
fi

# Loop through each namespace provided as an argument
for namespace in "$@"; do
  if validate_namespace "$namespace"; then
    echo "Namespace '$namespace' is valid."
  else
    echo "Namespace '$namespace' does not exist. Exiting."
    exit 1
  fi
done

# Ask user if they want to proceed with restarting the deployments
read -p "Do you want to restart deployments in the provided namespaces? (y/n): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
  for namespace in "$@"; do
  
    restart_deployments "$namespace"
  done
  echo "Deployments restarted successfully."
else
  echo "Operation canceled by the user."
  exit 0
fi
