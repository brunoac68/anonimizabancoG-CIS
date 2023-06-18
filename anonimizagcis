#!/bin/bash

# Função para exibir a ajuda
display_help() {
    echo "Uso: $0 [OPÇÕES]"
    echo "Opções:"
    echo "  -d <valor>            Nome do banco de dados"
    echo "  -p <valor>            Porta do banco de dados (padrão: 5432)"
    echo "  -h <valor>            Endereço do banco de dados (padrão: localhost)"
    echo "  -u <valor>            Usuário do banco de dados (padrão: inovadora)"
    echo "  -s <valor>            Senha do banco de dados"
    echo "  --help                Exibir esta mensagem de ajuda"
    exit 1
}

# Valores padrão
DB_HOST="localhost"
DB_PORT="5432"
DB_USER="inovadora"

# Processa os argumentos passados para o script
while getopts "d:p:h:u:s:-:" opt; do
    case "${opt}" in
        d)
            DB_NAME="${OPTARG}"
            ;;
        p)
            DB_PORT="${OPTARG}"
            ;;
        h)
            DB_HOST="${OPTARG}"
            ;;
        u)
            DB_USER="${OPTARG}"
            ;;
        s)
            DB_PASSWORD="${OPTARG}"
            ;;
        -)
            case "${OPTARG}" in
                help)
                    display_help
                    ;;
                *)
                    echo "Opção inválida: --${OPTARG}"
                    display_help
                    ;;
            esac
            ;;
        *)
            display_help
            ;;
    esac
done

# Verifica se todas as informações necessárias foram fornecidas
if [[ -z $DB_NAME ]] || [[ -z $DB_PASSWORD ]]; then
    echo "Erro: Nome do banco de dados e senha são obrigatórios."
    display_help
fi

# Comando SQL para anonimizar os nomes dos usuários
#SQL_COMMAND1="BEGIN;"
SQL_COMMAND="begin;
UPDATE usuarioigms
SET no_usuarioigms = CONCAT(
    SUBSTRING(no_usuarioigms, 1, 1),
    REPEAT('*', LENGTH(no_usuarioigms) - 2),
    SUBSTRING(no_usuarioigms, LENGTH(no_usuarioigms), 1)
);
commit;
UPDATE usuarioigms
SET no_mae  = CONCAT(
    SUBSTRING(no_mae  , 1, 1), -- Mantém a primeira letra do nome
    REPEAT('*', LENGTH(no_mae) - 2), -- Substitui o restante do nome por asteriscos
    SUBSTRING(no_mae  , LENGTH(no_mae), 1) -- Mantém a última letra do nome
);
UPDATE usuarioigms
SET no_pai  = CONCAT(
    SUBSTRING(no_pai , 1, 1), -- Mantém a primeira letra do nome
    REPEAT('*', LENGTH(no_pai) - 2), -- Substitui o restante do nome por asteriscos
    SUBSTRING(no_pai  , LENGTH(no_pai), 1) -- Mantém a última letra do nome
);"

# Executa o comando SQL utilizando o utilitário psql
#psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "$SQL_COMMAND1"
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "$SQL_COMMAND"
