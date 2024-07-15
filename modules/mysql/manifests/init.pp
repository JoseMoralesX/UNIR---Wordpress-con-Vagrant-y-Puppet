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
}
