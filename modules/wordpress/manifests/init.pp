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
