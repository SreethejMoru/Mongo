# install_percona_mongodb.sls
install_percona_mongodb:
  cmd.run:
    - name: yum install -y percona-server-mongodb
    - unless: rpm -qa | grep -q percona-server-mongodb
