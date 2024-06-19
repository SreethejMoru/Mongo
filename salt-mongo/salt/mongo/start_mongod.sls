# start_mongod.sls
start_mongod:
  cmd.run:
    - name: sudo systemctl start mongod
    - unless: systemctl is-active mongod
