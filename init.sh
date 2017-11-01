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

git clone git@github.com:magento-mcom/module-aqmp-message-bus.git app/code/Magento/AmqpMessageBus
git clone git@github.com:magento-mcom/module-catalog-message-bus.git app/code/Magento/CatalogMessageBus
git clone git@github.com:magento-mcom/module-common-message-bus.git app/code/Magento/CommonMessageBus
git clone git@github.com:magento-mcom/module-inventory-message-bus.git app/code/Magento/InventoryMessageBus
git clone git@github.com:magento-mcom/module-mcom-multiple-location-inventory.git app/code/Magento/McomMultipleLocationInventory
git clone git@github.com:magento-mcom/module-mcom-transactional-emails.git app/code/Magento/McomTransactionalEmails
git clone git@github.com:magento-mcom/module-message-bus-log.git app/code/Magento/MessageBusLog
git clone git@github.com:magento-mcom/module-postsales-message-bus.git app/code/Magento/PostsalesMessageBus
git clone git@github.com:magento-mcom/module-sales-message-bus.git app/code/Magento/SalesMessageBus
git clone git@github.com:magento-mcom/module-service-bus.git app/code/Magento/ServiceBus
