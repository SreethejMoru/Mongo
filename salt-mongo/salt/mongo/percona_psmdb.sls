# percona_psmdb.sls
enable_percona_repo:
  cmd.run:
    - name: percona-release enable psmdb-60 release
    - unless: grep -q '^enabled=1' /etc/yum.repos.d/percona-release.repo
