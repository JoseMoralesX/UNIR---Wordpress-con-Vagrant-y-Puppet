node default {
  include nginx
  include php
  include mysql
  include wordpress
}

class wordpress {
  exec { 'download_wordpress':
    command => '/usr/bin/wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz',
    creates => '/tmp/wordpress.tar.gz',
  }

  exec { 'extract_wordpress':
    command => '/bin/tar xzvf /tmp/wordpress.tar.gz -C /var/www/html --strip-components=1',
    creates => '/var/www/html/index.php',
    require => Exec['download_wordpress'],
  }

  file { '/var/www/html/wp-config.php':
    ensure  => file,
    content => template('wordpress/wp-config.php.erb'),
    require => Exec['extract_wordpress'],
  }

  exec { 'set_permissions':
    command => '/bin/chown -R www-data:www-data /var/www/html',
    require => Exec['extract_wordpress'],
  }
}

class mysql {
  package { 'mysql-server':
    ensure => installed,
  }

  service { 'mysql':
    ensure     => running,
    enable     => true,
    require    => Package['mysql-server'],
  }

  exec { 'create_wordpress_db':
    command => '/usr/bin/mysql -u root -e "CREATE DATABASE IF NOT EXISTS wordpress;"',
    unless  => '/usr/bin/mysql -u root -e "SHOW DATABASES LIKE \'wordpress\';" | grep wordpress',
    require => Service['mysql'],
  }

  exec { 'create_wp_user':
    command => '/usr/bin/mysql -u root -e "CREATE USER IF NOT EXISTS \'wp_user\'@\'localhost\' IDENTIFIED BY \'password\';"',
    require => Exec['create_wordpress_db'],
  }

  exec { 'grant_privileges_wp_user':
    command => '/usr/bin/mysql -u root -e "GRANT ALL PRIVILEGES ON wordpress.* TO \'wp_user\'@\'localhost\'; FLUSH PRIVILEGES;"',
    require => Exec['create_wp_user'],
  }

  exec { 'restart_mysql':
    command     => '/bin/systemctl restart mysql',
    refreshonly => true,
    subscribe   => Exec['grant_privileges_wp_user'],
  }

  exec { 'restart_nginx':
    command     => '/bin/systemctl restart nginx',
    refreshonly => true,
    subscribe   => Class['nginx'],
  }
}

class nginx {
  package { 'nginx':
    ensure => installed,
  }

  service { 'nginx':
    ensure     => running,
    enable     => true,
    require    => Package['nginx'],
  }

  file { '/etc/nginx/sites-available/default':
    ensure  => file,
    content => template('nginx/default.erb'),
    require => Package['nginx'],
  }

  file { '/var/www/html':
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
    mode   => '0755',
    require => Package['nginx'],
  }
}

class php {
  package { ['php-fpm', 'php-mysql']:
    ensure => installed,
  }

  service { 'php7.2-fpm':
    ensure     => running,
    enable     => true,
    require    => Package['php-fpm'],
  }
}
