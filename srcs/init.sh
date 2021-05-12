# start mysql
service mysql restart

# start nginx
service nginx start

#start php-fpm
service php7.3-fpm start

# keep container running
sh