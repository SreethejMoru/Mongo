# enable_mongod.sls
enable_mongod:
  cmd.run:
    - name: sudo systemctl enable mongod
    - unless: systemctl is-enabled mongod
