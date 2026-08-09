.PHONY: bootstrap bootstrap-flux destroy

bootstrap:
	cd terraform && terraform init
	cd terraform && terraform apply -auto-approve
	bash scripts/bootstrap_flux.sh

bootstrap-flux:
	bash scripts/bootstrap_flux.sh

destroy:
	cd terraform && terraform destroy -auto-approve
	bash scripts/uninstall_k3s.sh