INICIAR O POSTGRES

    sudo service postgresql start
    senha de acesso 1234

RESTAURAR A BASE DE DADOS

    sudo -u postgres pg_restore -d dvdrental dvdrental.tar

ACESSO A BASE DE DADOS

    sudo -u postgres psql -d dvdrental