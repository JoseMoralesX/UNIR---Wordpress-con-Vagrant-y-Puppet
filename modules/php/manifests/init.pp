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
