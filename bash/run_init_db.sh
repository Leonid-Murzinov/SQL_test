#!/bin/bash
rm -rf ./data
mkdir data
docker pull postgres:9.6.3
docker run -d \
    --name some-postgres \
    -e POSTGRES_PASSWORD=@sde_password012 \
    -e POSTGRES_USER=test_sde \
    -e POSTGRES_DB=demo \
    -p 5432:5432 \
    -v "$(pwd)/data":/var/lib/postgresql/data \
    postgres

sleep 10
cat $(pwd)/sql/init_db/demo.sql | docker exec -i some-postgres psql -U test_sde -d postgres
#Команда sleep необходима для того, чтобы дождаться полного включения субд, 
#так как по условию задачи при инициализации контейнера должна создаваться бд 'demo', 
#которая в заданном в задаче скрипте с тестовыми данным сбрасывается, из-за чего при 
#инициализации контейнера его  невозможно применить из папки, в связи с чем, его необходимо применять отдельно. 
#Альтернативным решением является удаление строк "drop database 'demo';" из заполняющего бд скрипта