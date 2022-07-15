#!/bin/sh
HORA=`date +%H`
DATA=`date +'%Y%m%d'`
TIPO="pm"
CLIENTE="cidreira"
LOGFILE=/suporte/backup_multi.log
DESTINO=/backups
DESTINO2=/backups/nuvem
DESTINO3=/backups/multi24/2018
DB=pmcidreira
USUARIO=postgres
DUMP=/usr/local/pgsql/bin/./pg_dump
rm -rf $LOGFILE
touch $LOGFILE
chmod 777 $LOGFILE
case "$HORA" in
   (06|07|08|09|10|11|12) HORA='man';;
   (13|14|15|16|17|18|19) HORA='tar';;
   (20|21|22|23|00|01|02|03|04|05) HORA='noi';;
esac
echo "-----------------------------------------------------" >> $LOGFILE
echo "`date +%c` - Iniciando o backup" >> $LOGFILE
echo "-----------------------------------------------------" >> $LOGFILE
$DUMP -U $USUARIO $DB > $DESTINO/"$TIPO"_"$CLIENTE"_"$DATA"_"$HORA".txt
if [ $? = 0 ]; then
   echo "`date +%c` - Backup gerado" >> $LOGFILE
else
   echo "`date +%c` - ERRO ao gerar backup" >> $LOGFILE
fi
pigz -f $DESTINO/"$TIPO"_"$CLIENTE"_"$DATA"_"$HORA".txt
if [ $? = 0 ]; then
   echo "`date +%c` - Backup compactado" >> $LOGFILE
   echo "Arquivo gerado:               " >> $LOGFILE
   du -hs $DESTINO/"$TIPO"_"$CLIENTE"_"$DATA"_"$HORA".txt.gz >> $LOGFILE
else
   echo "`date +%c` - ERRO ao compactar backup" >> $LOGFILE
fi
cp $DESTINO/"$TIPO"_"$CLIENTE"_"$DATA"_"$HORA".txt.gz /$DESTINO2 
cp $DESTINO/"$TIPO"_"$CLIENTE"_"$DATA"_"$HORA".txt.gz /$DESTINO3
rm $DESTINO/"$TIPO"_"$CLIENTE"_"$DATA"_"$HORA".txt.gz
echo "Arquivos excluídos:----------------------------------" >> $LOGFILE
find $DESTINO2/*.txt.gz -mtime +5 -type f -exec ls -lah {} \; >> $LOGFILE
find $DESTINO2/*.txt.gz -mtime +5 -type f -exec rm -rf {} \;
