# Namespace Setup Instructions
Create a namespace, a namespace admin service account, and provide the corresponding kubeconfig.

# Create the NS, SA, Role*
deploy/create-ns.sh project-x

# get the namespace admin kubeconfig
deploy/get-ns-kubeconfig.sh project-x