# Defining Project Global Variables
env="dev" # dev or prod
project="project_name"

#.SILENT:
# Create Private and Public keys
# This keys will be used to set EC2 and access it
cert:
	KEY_NAME=$(project)_key_$(env) && \
	cd ./certs && \
	source "../scripts/create_ssh_key.sh"

plan:
	source "./scripts/tf_vars.sh" && \
	terraform plan

apply:
	source "./scripts/tf_vars.sh" && \
	terraform apply