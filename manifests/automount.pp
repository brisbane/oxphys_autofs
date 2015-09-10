define autofs::automount( $dmap , $ddir, $mapsource)
{
    ensure_packages ([autofs])
    #notify { "$dmap help  $mapsource $ddir" : }
    file { $dmap:
      ensure  => present,
      source  => $mapsource,
      require => [Package['autofs'],],
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      notify => Service['autofs']
  }

  $options_keys =['--timeout', '-g' ]
  $options_values  =[ '-120','']

   case $::augeasversion {
       '0.9.0','0.10.0', '1.0.0': { $lenspath = '/var/lib/puppet/lib/augeas/lenses' }
        default: { $lenspath = undef }
     }

#######################################
 #Pattern based on
 #http://projects.puppetlabs.com/projects/1/wiki/puppet_augeas

     augeas{"${ddir}_${dmap}_edit":

       context   => '/files/etc/auto.master/',

       load_path => $lenspath,
       #This part changes options on an already existing line

      changes   => [
             "set *[map = '$dmap']     $ddir",
             "set *[map = '$dmap']/map  $dmap",
             "set *[map = '$dmap']/opt[1] ${options_keys[0]}",
             "set *[map = '$dmap']/opt[1]/value ${options_values[0]}",
             "set *[map = '$dmap']/opt[2] ${options_keys[1]}",
        ]   ,
       notify    => Service['autofs']
     }
     augeas{"${ddir}_${dmap}_change":
       context   => '/files/etc/auto.master/',
       load_path => $lenspath,
       #This part changes options on an already existing line
       changes   => [
             "set 01   $ddir",
             "set 01/map  $dmap",
             "set 01/opt[1] ${options_keys[0]}",
             "set 01/opt[1]/value ${options_values[0]}",
             "set 01/opt[2] ${options_keys[1]}",
        ]   ,
       onlyif    => "match *[map = '$dmap'] size == 0",
       notify    => Service['autofs']
     }
}


