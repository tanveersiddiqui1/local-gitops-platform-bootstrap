bootstrap:
	cd terraform && terraform init
	cd terraform && terraform apply -auto-approve

destroy:
	cd terraform && terraform destroy -auto-approve
	bash scripts/uninstall_k3s.sh
