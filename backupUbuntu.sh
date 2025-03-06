#!/bin/bash

# Script: backupUbuntu.sh
# Autor: Adriano de Azevedo
# Data: 2023-12-27
# Versão: 5.5

# Este script cria backups compactados (tar.gz) de diretórios específicos.
# Antes de executar o backup, o script verifica se há espaço suficiente no destino.
# Requer privilégios de root para ser executado.
# Copiado para o diretorio /usr/local/bin/backup para ser executado com comando: $ sudo backup

#Variáveis
origem="/home/adrianoazevedo"
destino="/home/Backups/noteDell"
logfile="/home/Backups/BkpNoteDell.log"
backupfile="/home/Backups/Backup_noteDell.tar.gz"
compactar=false
pontoMontagem="/home"

#Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, execute o script como root (use 'sudo backup')."
  exit 1
fi

#Retorno conforme a confirmação do usuário
echo "Backup Iniciado [$(date '+%d-%m-%Y %H:%M:%S')]"

#Copia de arquivos
  #Registra log início copia 
  echo '---Início Backup' > "$logfile"
  echo '---' >> "$logfile"
  echo "---Início Copia de Arquivos [$(date '+%d-%m-%Y %H:%M:%S')]" >> "$logfile" 
  
  #Copia de arquivos
  echo "Copiando arquivos..."
  sudo rsync -av --delete --exclude=.cache --exclude=.thumbnails --exclude=.dbtools --exclude=Downloads --exclude=.local/share/Trash --exclude=.config/Code/Cache --exclude=snap/firefox --exclude=snap/spotify/common/.cache --exclude=.config/google-chrome/Default/Service\ Worker/CacheStorage --exclude=.config/google-chrome/Default/Service\ Worker/ScriptCache --exclude=.config/google-chrome/Profile\ 1/Service\ Worker/CacheStorage --exclude=.config/google-chrome/Profile\ 1/Service\ Worker/ScriptCache --exclude=snap/chromium/common/chromium/Default/Service\ Worker/ScriptCache --exclude=snap/chromium/common/chromium/Default/Cache/Cache_Data --exclude=snap/chromium/common/chromium/Default/Code\ Cache --exclude=snap/chromium/common/chromium/Default/Service\ Worker/CacheStorage --exclude=snap/chromium/common/chromium/Profile\ 2/Cache/Cache_Data/ --exclude=snap/chromium/common/chromium/Profile\ 2/Code\ Cache --exclude=snap/chromium/common/chromium/Profile\ 2/Service\ Worker/CacheStorage --exclude=.config/FortiClient/Cache --exclude=.config/Code/Cache --exclude=.config/Code/CachedData --exclude=.config/Code/logs --exclude=.config/Code/Service\ Worker/CacheStoragel --exclude=.config/Code/Service\ Worker/ScriptCache --exclude=*.iso --exclude=*.tmp "$origem" "$destino" >> "$logfile"
    if [ $? -ne 0 ]; then
      echo '---ATENÇÃO!! ERRO!!---'
      echo 'Erro: Falha ao copiar arquivos com rsync.'
      echo '---ATENÇÃO!! ERRO!!---' >> "$logfile"
      echo 'Erro: Falha ao copiar arquivos com rsync.' >> "$logfile"
      echo '---' >> "$logfile"
      exit 1
    fi
  echo "Cópia OK! [$(date '+%d-%m-%Y %H:%M:%S')]"

  #Registra log fim copia
  echo ' ' >> "$logfile"
  echo "---Fim Cópia de Arquivos [$(date '+%d-%m-%Y %H:%M:%S')]" >> "$logfile"
  echo '---' >> "$logfile"

#Compactacao dos arquivos copiados, em um arquivo tar.gz e altera as permissões do arquivo de backup
#Pergunta ao usuário se deseja seguir com a compactação do backup
read -p "Deseja seguir com a compactação do backup? [S/n]: " confirmacao
if [[ "$confirmacao" =~ ^[Ss]$ ]] || [[ -z "$confirmacao" ]]; then
  compactar=true
  #Resgistro log inicio compactacao
  echo "---Inicio Compactação de Arquivos [$(date '+%d-%m-%Y %H:%M:%S')]" >> "$logfile" 
  echo '---' >> "$logfile"

  #Compactacao dos arquivos
  echo 'Compactado arquivos...'
  sudo tar -czvf "$backupfile" -C "$destino" . >> "$logfile"
    if [ $? -ne 0 ]; then
      echo '---ATENÇÃO!! ERRO!!---' >> "$logfile"
      echo 'Erro: Falha ao compactar arquivos com tar.'
      echo 'Erro: Falha ao compactar arquivos com tar.' >> "$logfile"
      exit 1
    fi
  echo "Compactação OK! [$(date '+%d-%m-%Y %H:%M:%S')]"

  #Alteracao de permissoes do arquivo de backup
  chown -R adrianoazevedo:adrianoazevedo "$backupfile"

  #Registra log fim compactacao
  echo "---Fim Compactação de Arquivos [$(date '+%d-%m-%Y %H:%M:%S')]" >> "$logfile"

else
  echo "Compactação do backup cancelada pelo usuário."
  echo "Compactação do backup cancelada pelo usuário." >> "$logfile"
fi

#Lista o tamanho da pasta de backup
echo '---' >> "$logfile"
tamanho_pasta=$(du -sh "$destino" | awk '{print $1}')
echo "Tamanho da pasta de backup: $tamanho_pasta"
echo "Tamanho da pasta de backup: $tamanho_pasta" >> "$logfile" 

#Lista o tamanho do arquivo tar.gz se a compactação foi realizada
if [ "$compactar" = true ]; then
  echo '---' >> "$logfile"
  tamanho_arquivo=$(du -sh "$backupfile" | awk '{print $1}')
  echo "Tamanho do arquivo tar.gz: $tamanho_arquivo"
  echo "Tamanho do arquivo tar.gz: $tamanho_arquivo" >> "$logfile"
fi
echo '---' >> "$logfile" 

#Lista o espaço livre no ponto de montagem
espaco_livre=$(df -h "$pontoMontagem" | awk 'NR==2 {print $4}')
echo "Espaço livre no ponto de montagem: $espaco_livre"
echo "Espaço livre no ponto de montagem: $espaco_livre" >> "$logfile" 
echo '---' >> "$logfile" 


#Registra a data de fim no log
echo "---Fim do Backup [$(date '+%d-%m-%Y %H:%M:%S')]" >> "$logfile"
echo '---' >> "$logfile" 

echo "---"
echo "Backup concluído com sucesso [$(date '+%d-%m-%Y %H:%M:%S')]."
echo "---"

#Exemplo de restauração do backup
  #Restaurando o backup em um novo diretório
  #mkdir /home/novo_usuario
  #tar -xzvf Backup_noteDell.tar.gz -C /home/novo_usuario