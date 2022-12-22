class profile::hdm () {
# Ensure Docker is installed
  include docker
# generate directories and files
  $directories = [
    '/etc/hdm',
    '/etc/hdm/db',
  ]
  $dbs = [
    '/etc/hdm/db/development.sqlite3',
    '/etc/hdm/db/production.sqlite3',
  ]
  file { $directories:
    ensure => directory,
  }
  file { '/etc/hdm/hdm.yml':
    ensure => file,
    source => 'puppet:///modules/profile/hdm/hdm.yml',
  }
  file { '/etc/hdm/database.yml':
    ensure => file,
    source => 'puppet:///modules/profile/hdm/database.yml',
  }
  file { $dbs:
    ensure => file,
  }
  # get and run the image
  docker::image { 'ghcr.io/betadots/hdm':
    image_tag => 'main',
  }

  docker::run { 'hdm':
    image    => 'ghcr.io/betadots/hdm:main',
    env      => [
      'TZ=Europe/Berlin',
      "RAILS_DEVELOPMENT_HOSTS=puppet.${trusted['extensions']['pp_network']}",
    ],
    volumes  => [
      '/etc/hdm/:/etc/hdm',
      '/etc/puppetlabs/code:/etc/puppetlabs/code:ro',
      '/etc/hdm/hdm.yml:/hdm/config/hdm.yml:ro',
      '/etc/hdm/database.yml:/hdm/config/database.yml:ro',
    ],
    hostname => "puppet.${trusted['extensions']['pp_network']}",
    ports    => ['3000'],
    net      => 'host',
  }
}
