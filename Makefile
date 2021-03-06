.PHONEY: all network infrastructure domain install destroy

all: domain

init:
	@terraform init examples/$(CLUSTER_CONFIG)

refresh:
	@terraform refresh examples/$(CLUSTER_CONFIG)

test:
	@terraform apply -target null_resource.openshift_check examples/$(CLUSTER_CONFIG)

key:
	@TF_DATA_DIR=example/$(CLUSTER_CONFIG) terraform output -module openshift_platform platform_private_key

sshspec:
	@TF_DATA_DIR=example/$(CLUSTER_CONFIG) terraform output -module openshift_platform bastion_ssh

master-url:
	@TF_DATA_DIR=example/$(CLUSTER_CONFIG) terraform output -module openshift_platform.infrastructure master_url

network:
	@echo "Builds network for OpenShift"
	@terraform apply -target module.openshift_platform.module.network examples/$(CLUSTER_CONFIG)

infrastructure: network
	@echo "Builds infrastructure for OpenShift"
	@terraform apply -target module.openshift_platform.module.infrastructure examples/$(CLUSTER_CONFIG)
	@TF_DATA_DIR=example/$(CLUSTER_CONFIG) terraform output -module openshift_platform.infrastructure

domain: infrastructure
	@echo "Builds domain zone for OpenShift"
	@terraform apply -target module.openshift_platform.module.domain examples/$(CLUSTER_CONFIG)

install:
	@terraform apply examples/$(CLUSTER_CONFIG)

destroy-network:
	@echo "Destroy platform network resources ..."
	@terraform destroy -target module.openshift_platform.module.network examples/$(CLUSTER_CONFIG)

destroy-infrastructure:
	@echo "Destroy platform infrastructure resources ..."
	@terraform destroy -target module.openshift_platform.module.infrastructure examples/$(CLUSTER_CONFIG)

destroy-domain:
	@echo "Destroy platform domain resources ..."
	@terraform destroy -target module.openshift_platform.module.domain examples/$(CLUSTER_CONFIG)

destroy:
	@echo "Destroy domain settings ..."
	@terraform destroy -target module.openshift_platform.module.domain examples/$(CLUSTER_CONFIG)
	@echo "Destroy infrastructure resources ..."
	@terraform destroy -target module.openshift_platform.module.infrastructure examples/$(CLUSTER_CONFIG)
	@echo "Destroy platform network resources ..."
	@terraform destroy -target module.openshift_platform.module.network examples/$(CLUSTER_CONFIG)
