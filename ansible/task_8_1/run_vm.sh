#!/bin/bash
echo ---run docker machine---
docker start fedora
docker start centos7
#
echo ---run playbook---
ansible-playbook -i playbook/inventory/prod.yml playbook/site.yml --ask-vault-pass
#
echo ---stop docker machine---
docker stop fedora
docker stop centos7
#
echo ---GoodBye---