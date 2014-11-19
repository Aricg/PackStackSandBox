
notify { 'Hello World': }

exec { 'foo':
  command => '/usr/bin/uptime',
  logoutput => true,
}

Exec {
  path => [
    '/bin',
    '/sbin',
    '/usr/bin',
    '/usr/sbin',
  ]
}

