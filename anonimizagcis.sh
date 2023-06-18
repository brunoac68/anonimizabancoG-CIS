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

# Função para instalar o pv
install_pv() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install pv
        elif command -v yum &> /dev/null; then
            sudo yum install pv
        elif command -v dnf &> /dev/null; then
            sudo dnf install pv
        elif command -v zypper &> /dev/null; then
            sudo zypper install pv
        else
            echo "Erro: Gerenciador de pacotes não encontrado. Instale o pv manualmente."
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install pv
        else
            echo "Erro: Homebrew não encontrado. Instale o pv manualmente."
            exit 1
        fi
    else
        echo "Erro: Sistema operacional não suportado. Instale o pv manualmente."
        exit 1
    fi
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

# Verifica se o pv está instalado
if ! command -v pv &> /dev/null; then
    echo "O utilitário 'pv' não foi encontrado. Será realizada a instalação..."
    install_pv
fi

# Comando SQL para contar o número de registros na tabela
SQL_COUNT="SELECT COUNT(*) FROM usuarioigms;"

# Comando SQL para anonimizar os nomes dos usuários
SQL_COMMAND="UPDATE usuarioigms
SET no_usuarioigms = CONCAT(
    SUBSTRING(no_usuarioigms, 1, 1),
    REPEAT('*', LENGTH(no_usuarioigms) - 2),
    SUBSTRING(no_usuarioigms, LENGTH(no_usuarioigms), 1)
);"

# Obtém o total de registros na tabela
total_records=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "$SQL_COUNT")

# Executa o comando SQL de anonimização dos nomes dos usuários com a exibição da barra de progresso
echo "Anonimizando nomes dos usuários..."
echo "$SQL_COMMAND" | psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME | pv -l -s $total_records -p -t -e

echo "Anonimização concluída com sucesso."
