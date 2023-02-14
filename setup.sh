sudo dnf install ansible -y
ansible-galaxy collection install -r requirements.yaml
ansible-playbook 1_setup.yaml