name             'funnies'
maintainer       'Aaron Kalin'
maintainer_email 'akalin@martinisoftware.com'
license          'Apache 2.0'
description      'Installs/Configures/Deploys funnies'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'application', '2.0.0'
depends 'build-essential'
depends 'git'
depends 'rvm'

supports 'ubuntu', '>= 12.04'
