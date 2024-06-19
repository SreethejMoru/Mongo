# init.sls
include:
  - mongo.percona_release
  - mongo.percona_psmdb
  - mongo.install_percona_mongodb
  - mongo.start_mongod
  - mongo.status_mongod
  - mongo.enable_mongod
  - mongo.install_mongosh
