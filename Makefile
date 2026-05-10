bootstrap:
	cd terraform && terraform init
	cd terraform && terraform apply -auto-approve

destroy:
	bash scripts/uninstall_k3s.sh
