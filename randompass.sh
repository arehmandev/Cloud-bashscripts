# Create a random 32 char pass:

x=0;rand=`openssl rand -base64 64 | awk 'BEGIN{FS=""} {for (i=1;i<=64;i++) printf("%s",$i);} {printf "\n"}'`; limit=`head -200 /dev/urandom|cksum|head -c4`;until [ $x -ge $limit ];do salt=`dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev | cksum`; rand=`echo $salt$rand | sha256sum | base64`; ((x++));done; echo $rand | head -c 32
