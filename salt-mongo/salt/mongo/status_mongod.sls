# status_mongod.sls
check_mongod_status:
  cmd.run:
    - name: sudo systemctl status mongod
