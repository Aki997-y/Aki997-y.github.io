#!/bin/bash
# usage: bash r.sh p.txt   (p.txt = IT2-DB.txt の中身)
B=dcl-pngn-tes-v2-mid-file
rm -rf it2res it2res.zip; mkdir -p it2res
S=it2res/summary.tsv
printf "case\t7\t8\t22\t25\t28\t30\t42\t43\t44\n" > $S
n=0
for k in $(tr -d '\r' < "$1" | grep -o 'scan/st/[^ ]*'); do
  n=$((n+1)); c=$(printf "C%02d" $n)
  aws s3 cp "s3://$B/$(dirname "$k")/" "it2res/$c/" --recursive --quiet
  r=$(ls it2res/$c/*.res 2>/dev/null | head -1)
  if [ -z "$r" ]; then printf "%s\tNO_RES\n" $c >> $S; continue; fi
  tr -d '\r' < "$r" | awk -F'\t' -v c=$c 'NR==2{o=c; split("7 8 22 25 28 30 42 43 44",p," "); for(i=1;i<=9;i++){v=$p[i]; if(v=="")v="-"; o=o"\t"v}; print o}' >> $S
done
column -t -s $'\t' $S
zip -qr it2res.zip it2res && echo "OK: /home/cloudshell-user/it2res.zip"
