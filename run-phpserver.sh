#!/bin/bash

php -S 127.0.0.1:8082 -d always_populate_raw_post_data=-1  -t ./pub/ ./phpserver/router.php
