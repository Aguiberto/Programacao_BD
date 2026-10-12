Com o PostgreSQL já  instalado

# Inicie o Postgres
    sudo service postgresql start
    
    - Verificar se o PostgreSQL está rodando:
    sudo service postgresql status

# Criar o DB - Passo realizado uma única vez

    sudo su postgres -c "createdb desafio_db"

    - Listar os banco de dados existentes:

        sudo su postgres -c "psql -l"

# Verificar se o PostgreSQL está rodando:
    sudo service postgresql status

# Executar o SQL do F1

    unzip -p utils/desafio_f1.zip | sudo su postgres -c "psql -d desafio_db"

# Acessando terminal do PostgreSQL
    sudo su postgres -c "psql -d desafio_db"