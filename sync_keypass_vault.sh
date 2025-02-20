#!/bin/bash

# Definindo os caminhos
LOCAL_FILE="$HOME/Passwords.kdbx"
PROTON_MOUNT="$HOME/mounts/proton_drive"

# Verificando se o Proton Drive está montado
if [ ! -d "$PROTON_MOUNT" ]; then
    echo "Erro: Proton Drive não está montado em $PROTON_MOUNT"
    exit 1
fi

# Verificando se o arquivo local existe
if [ ! -f "$LOCAL_FILE" ]; then
    echo "Erro: Arquivo local não encontrado em $LOCAL_FILE"
    exit 1
fi

# Sincronizando o arquivo
echo "Sincronizando arquivo KeePass..."
cp -f "$LOCAL_FILE" "$PROTON_MOUNT/"

# Verificando se a cópia foi bem-sucedida
if [ $? -eq 0 ]; then
    echo "Sincronização concluída com sucesso!"
    echo "Arquivo atualizado em: $(date)"
else
    echo "Erro durante a sincronização!"
    exit 1
fi
