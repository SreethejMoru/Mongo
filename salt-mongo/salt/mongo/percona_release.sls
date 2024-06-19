# percona_release.sls
percona-release:
  cmd.run:
    - name: yum install -y https://repo.percona.com/yum/percona-release-latest.noarch.rpm
    - unless: rpm -qa | grep -q percona-release
