.PHONY: bootstrap bootstrap-flux destroy

cluster-create:
	cd terraform && terraform init
	cd terraform && terraform apply -auto-approve

flux-bootstrap:
	bash scripts/bootstrap_flux.sh

bootstrap: cluster-create flux-bootstrap

destroy:
	cd terraform && terraform destroy -auto-approve
	bash scripts/uninstall_k3s.sh