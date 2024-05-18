#!/bin/sh

# 
# Modified version of make_banner.sh from kernel/arch/dreamcast/kernel/make_banner.sh
#

BANNER_FILE=banner.h

printf 'static const char banner[] = \n' > $BANNER_FILE

gitrev='##gitsha##'

printf '"KallistiOS ' >> $BANNER_FILE
printf 'Git revision ' >> $BANNER_FILE
printf "$gitrev" >> $BANNER_FILE
printf ':\\n"\n' >> $BANNER_FILE


printf '"  ' >> $BANNER_FILE
tmp=`date`
printf "$tmp" >> $BANNER_FILE
printf '\\n"\n' >> $BANNER_FILE

printf '"  ' >> $BANNER_FILE
tmp=`whoami`
printf "$tmp" >> $BANNER_FILE
printf '@' >> $BANNER_FILE

if [ `uname` = Linux ]; then
    tmp=`hostname -f`
else
    tmp=`hostname`
fi

printf "$tmp" >> $BANNER_FILE

printf ':' >> $BANNER_FILE
printf "$KOS_BASE" >> $BANNER_FILE
printf '\\n"\n' >> $BANNER_FILE

printf '"  ' >> $BANNER_FILE
tmp=`$KOS_CC --version | head -n 1`
printf "$tmp" >> $BANNER_FILE
printf '\\n"\n' >> $BANNER_FILE
printf ';\n' >> $BANNER_FILE

printf 'static const char kern_version[] = \n"' >> $BANNER_FILE
printf "${gitrev#?}" >> $BANNER_FILE
printf '";\n' >> $BANNER_FILE
