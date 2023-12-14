#!/bin/bash

KEY_NAME=${KEY_NAME:-"default_key_name"}

# Create the certs directory if it doesn't exist
cd certs && \
	if [ -f "$$KEY_NAME.cert" ] && [ -f "$$KEY_NAME.key" ]; then \
		echo "Certs exist already"; \
	else \
		source ./create.sh; \
	fi


# Check if the key already exists. If not, generate it.
if [ ! -f "$KEY_NAME" ]; then
  ssh-keygen -t rsa -b 4096 -f "$KEY_NAME" -N ""
  echo "SSH key pair created."
else
  echo "SSH key pair already exists."
fi