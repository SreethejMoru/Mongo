# install_mongosh.sls
install_mongosh:
  cmd.run:
    - name: npm install -g @mongosh/cli
    - unless: mongosh --version
