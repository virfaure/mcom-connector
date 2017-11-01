#!/bin/bash

if [ -z "$1" ]
  then
    echo "No version supplied, using latest Magento version"
    composer create-project --repository-url=https://repo.magento.com/ magento/project-enterprise-edition magento-ee
else
    echo "Install Magento version $1"
    composer create-project --repository-url=https://repo.magento.com/ magento/project-enterprise-edition=$1 magento-ee
fi

mv magento-ee/* . && rm -rf magento-ee
mkdir -p app/code/Magento
cd app/code/Magento
git submodule add git@github.com:magento-mcom/module-sales-message-bus.git SalesMessageBus
