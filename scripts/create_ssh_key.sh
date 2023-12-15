#!/bin/bash

KEY_NAME=${KEY_NAME:-"default_key_name"}


# Check if the key already exists. If not, generate it.


if [ ! -f "$KEY_NAME" ]; then
  ssh-keygen -t ed25519 -f "$KEY_NAME" -C "tf-ssh-key-${KEY_NAME}"
  echo "SSH key pair created."
else
  echo "SSH key pair already exists."
fi