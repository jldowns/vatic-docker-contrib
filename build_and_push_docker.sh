packer build \
    -var 'docker_username='`vault read -field=username secret/docker` \
    -var 'docker_password='`vault read -field=password secret/docker` \
    -var 'version_number=0.1' \
    vatic_packer.json
