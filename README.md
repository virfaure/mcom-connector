# Magento MCOM Connector

This repository provides a workspace to work on Magento MCOM connector for Magento Digital Commerce.

## Pre-requirements

- PHP 5.6+ with extensions: `php-intl`, `php-mcrypt`
- Docker 1.10+
- Composer

## Install

### 1. Fork

Use [Fork](https://github.com/magento-mcom/mcom-connector#fork-destination-box) button in the header to create your own copy of this repository.

### 2. Clone

```
git clone git@github.com:PUT-YOUR-GITHUB-USERNAME-HERE/mcom-connector && cd mcom-connector
```

### 3. Start services

Use docker-compose to run MySQL and RabbitMQ

```bash
docker-compose up -d
```

### 4. Install Magento

First, create an auth.json file with your credentials in order to install Magento EE with composer. Your access keys can be found in your Magento Marketplace account -> Access Keys.

To install last version of Magento EE
```bash
./init.sh 
```
To install specific version of Magento EE
```bash
./init.sh 2.1.8
```

The script will install Magento EE and clone all MCOM Connector modules in the app/code/Magento folder:
- AmqpMessageBus
- CatalogMessageBus
- CommonMessageBus
- InventoryMessageBus
- McomMultipleLocationInventory
- McomTransactionalEmails
- MessageBusLog
- PostsalesMessageBus
- SalesMessageBus
- Service Bus

Run `bin/magento setup:install` to initalize database and environment configuration. Change `DOCKER_IP` environment variable to point to the IP address where docker is running. 

```
php -d memory_limit=-1 bin/magento setup:install \
  --amqp-host 127.0.0.1 \
  --amqp-port 5672 \
  --amqp-user guest \
  --amqp-password guest \
  --amqp-virtualhost \/ \
  --admin-user admin \
  --admin-password admin123 \
  --admin-firstname John \
  --admin-lastname Doe \
  --admin-email admin@magento.com \
  --db-host 127.0.0.1 \
  --db-name magento \
  --db-user root \
  --db-password magento \
  --session-save db \
  --base-url http://127.0.0.1:8082/ \
  --backend-frontname admin
```

### 5. Start webserver

Use build-in PHP server to serve Magento web pages.

```
php -S 127.0.0.1:8082 -t ./pub/ ./phpserver/router.php
```

### 6. Connector Configuration

In MCOM -> Manage Stock Aggregates, add or edit a stock aggregate in order to have the stock code equal to an existing external id of a stock aggregate in MCOM (ex STORE in Luma)

Go to Store -> Configuration -> MCOM CONNECTOR and fill in the following fields:
- General -> Store ID (Should be the external id of a sales channel in MCOM, ex: STORE in Luma)
- Taxes -> Vat Country (Should be an existing vat code in MCOM, for ex: ES, US ...) 
- Transport -> Driver: Choose between AMQP or SERVICE BUS

If you choose AMQP, you should have the parameters of the connection in the env.php file:
```
'queue' => 
  array (
    'amqp' => 
    array (
      'host' => '127.0.0.1',
      'port' => '5672',
      'user' => 'guest',
      'password' => 'guest',
      'virtualhost' => '/',
      'ssl' => '',
    ),
  ),
```

If you choose SERVICE BUS, you should have the parameters of the connection in the env.php file:
```
 'serviceBus' => 
    array (
      'url' => 'http://luma-loc.bcn.magento.com:8081/LUMA/', //url of the service bus in your vagrant machine
      'application_base_url' => 'http://10.0.2.2:8082/', //url of MDC seen from the vagrant machine
    ),
```

### 7. Enable developer mode for easy debugging

Open `app/etc/env.php` and find line `"MAGE_MODE" => "default",`, change it to look like `"MAGE_MODE" => "developer",`.

Use build-in PHP server to serve Magento web pages and execute Behat Acceptance test:
```
php -S 127.0.0.1:8082 -d always_populate_raw_post_data=-1  -t ./pub/ ./phpserver/router.php
```

## Access website

You local website URL depends on the URL used during installation, by default your magento website will be available at [http://localhost:8082/index.php](http://localhost:8082/index.php).

If the CSS and JS are not loaded correctly, you need to add the following configuration into the database :
```
INSERT INTO core_config_data (`path`, `value`) VALUES ('dev/static/sign', '0');
```

#### Default Backoffice username and password

- URL: [http://localhost:8082/index.php/admin](http://localhost:8082/index.php/admin)
- Username: admin
- Password: admin123

# Testing
### Unit tests
In the root path you can just run phpunit against folder unit tests:
```bash
vendor/bin/phpunit -c $YOUR_MDC_FOLDER/dev/tests/unit/phpunit.xml.dist
```

### Integration tests
Create a new empty database called ``magento_integration_tests`` for example.

Rename or copy the mysql configuration file from `dev/tests/integration/etc/install-config-mysql.php.dist` to `dev/tests/integration/etc/install-config-mysql.php` and configure it with your instance of MySQL Server.

It's easier if you have a local MySQL instance but you can do it with the Docker Mysql Container but keep in mind that `mysql` and `mysqldump` are needed. 
So for instance, in my own case I'm using Docker MySQL container and I have installed `MysqlWorkbench` as well, so I just pointed the binary of `mysql` and `mysqldump` from it as executable either exporting path or creating a symlink

Exporting path:
```bash
export PATH=$PATH:/Applications/MySQLWorkbench.app/Contents/MacOS/
```

Creating symlink:
```bash
ln -s /Applications/MySQLWorkbench.app/Contents/MacOS/mysql /usr/bin/mysql
ln -s /Applications/MySQLWorkbench.app/Contents/MacOS/mysqldump /usr/bin/mysqldump
```

Then you must to configure ``dev/tests/integration/phpunit.xml.dist`` with the following parameters inside PHP part:
 
```
<ini name="memory_limit" value="-1"/>
<const name="TESTS_CLEANUP" value="enabled"/>
```

\* Keep in mind that ***TEST_CLEANUP*** param would be configured as ***ENABLED*** just for the first execution and then we could change it to ***DISABLED*** in order to make faster the execution of our tests. This param just creates our needed database structure.

Then we can run the tests:

```bash
vendor/bin/phpunit -c $YOUR_MDC_FOLDER/dev/tests/integration/phpunit.xml.dist  -vvv
```

It's recommended to disable xdebug in order to run faster the whole tests set. 

## Tools
Once the environment is up, you can use the provided scripts in the bin folder to easy stop/start (and more) the services.

Simply try:

```bash
  $YOUR_MDC_FOLDER/bin/mdc help
```
to see the help for the launcher script.

**NOTE**: You could include the bin folder in your PATH

Some values used by the scripts are configurable in the file 
```
  $YOUR_MDC_FOLDER/bin/.mdc
```
You will need to change it if you didn't use the default values from this readme, like the web port (section 5) or the name of docker containers (section 3).

## Deploy

This repository connected with Magento Enterprise Cloud so you can deploy your changes to remote environment using git.

First, add remote called `cloud` to your local repository:

```bash
git remote add cloud txciwtbulhe2g@git.us.magento.cloud:txciwtbulhe2g.git
```

Then, simply push to this remote:

```bash
git push cloud my-feature-branch
```

# FAQ

### The CSS or the JS files don't load correctly
Usually is due to the unexistant softlink inside `pub/static` folder with the assets generated. Run this command from the app root:
```
cd pub/static
ln -s . version`cat deployed_version.txt`
```

Another and (should be) permanent solution will eb changing configuration on the database using this sentence:
```sql
INSERT INTO core_config_data (path, `value`) VALUES ('dev/static/sign', '0');
```
and cleaning cache with `php ./bin/magento cache:clean`

### The Cloud environment was totally broken
A message with a text saying *Service is temporarily unavailable* appears in every page, and there are no log traces inside server.
This is kind of magic as you run the following command with the already existing admin information, and it works as some recreations happens.
`php bin/magento setup:install --admin-firstname=John --admin-lastname=Smith --admin-user=XXXX --admin-password=YYYY --admin-email="ZZZZ@magento.com"`

### Cloud Read-Only
If you have problems with *Read-Only* devices/folders, when running CLI commands you will need to overwrite some folders.
```bash
mv /app/var/generation generation_moved
mv /app/var/di di_moved
mkdir /app/var/generation
mkdir /app/var/di
```

### Redirection to localhost
After a deployment sometimes the application redirects you to the localhost host. That should be unnecessary, but we can fix the issue by hardcoding the app URLs at the configuration inside database:
```sql
INSERT INTO `core_config_data` (path, `value`) VALUES ('web/unsecure/base_url', 'http://bombers-with-data-lwfs75i-zbvgixenzhf6e.us.magentosite.cloud/'), ('web/secure/base_url', 'https://bombers-with-data-lwfs75i-zbvgixenzhf6e.us.magentosite.cloud/');
```
