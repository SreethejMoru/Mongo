/etc/mongod.conf:
  file.managed:
    - source: salt://mongo/mongod.conf
    - user: root
    - group: root
    - mode: 644

restart_mongod:
  service.running:
    - name: mongod
    - enable: True
    - watch:
      - file: /etc/mongod.conf
