name             "funnies"
maintainer       "Aaron Kalin"
maintainer_email "akalin@martinisoftware.com"
license          "Apache 2.0"
description      "Installs/Configures/Deploys funnies"
long_description IO.read(File.join(File.dirname(__FILE__), "README.md"))
version          "1.3.8"

supports "ubuntu", ">= 12.04"

depends "application", "2.0.0"
depends "build-essential"
depends "git"
depends "rvm"
depends "nginx"
depends "nodejs"

