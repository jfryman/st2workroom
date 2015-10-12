class profile::python {
  include ::st2::profile::python
  include ::st2::profile::repos

  file { '/etc/facter/facts.d/pip_upgrade_20150902.txt':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => 'pip_upgrade_20150902=true',
    notify  => Exec['update-pip'],
  }

  exec { 'update-pip':
    command     => 'pip install -U pip',
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    refreshonly => true,
    require     => Class['::st2::profile::repos'],
  }

  Exec['update-pip'] -> Python::Pip<||>
  Class['::st2::profile::repos'] -> Class['::st2::profile::python']

  # RedHad 6 uses Python 2.6 by default, and we are pulling upstream
  # from IUS to provide Python 2.7. The following sets up latest Python
  # to be the System Python
  if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == '6' {
    alternative_entry {'/usr/bin/python2.7':
      ensure   => present,
      altlink  => '/usr/bin/python',
      altname  => 'python',
      priority => 10,
      require  => Class['::st2::profile::python'],
    }
    alternatives { 'python':
      ensure  => present,
      path    => '/usr/bin/python2.7',
      require => Class['::st2::profile::python'],
    }

    alternative_entry {'/usr/bin/pip2.7':
      ensure   => present,
      altlink  => '/usr/bin/pip',
      altname  => 'pip',
      priority => 10,
      require  => Class['::st2::profile::python'],
    }
    alternatives { 'pip':
      ensure  => present,
      path    => '/usr/bin/pip2.7',
      require => Class['::st2::profile::python'],
    }

    alternative_entry {'/usr/bin/virtualenv2.7':
      ensure   => present,
      altlink  => '/usr/bin/virtualenv',
      altname  => 'virtualenv',
      priority => 10,
      require  => Class['::st2::profile::python'],
    }
    alternatives { 'virtualenv':
      ensure  => present,
      path    => '/usr/bin/virtualenv-2.7',
      require => Class['::st2::profile::python'],
    }

    Alternatives['virtualenv'] -> Exec<| tag == 'virtualenv' |>
  }
}
