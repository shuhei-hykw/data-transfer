#!/bin/sh

. $HOME/.env

opt="theme=light&orgId=1&from=now-24h&to=now&timezone=browser&width=1800&height=3000"

url="http://localhost:3000/render/d/bej2uft3tyd4wa/shs-magnet?$opt"
output_shs=/tmp/grafana-shs-magnet.png
curl -s -o $output_shs "$url" -H "Authorization: Bearer $GRAFANA_API_KEY"

url="http://localhost:3000/render/d/eekkq2558fk74f/gas?$opt"
output_gas=/tmp/grafana-gas.png
curl -s -o $output_gas "$url" -H "Authorization: Bearer $GRAFANA_API_KEY"

webcam5=/export/share/onsite-homepage/webcam/webcam5.jpg
webcam6=/export/share/onsite-homepage/webcam/webcam6.jpg

rsync -a -e "ssh -i ~/.ssh/id_ed25519_wopass" $output_shs $webcam5 $webcam6 \
      lambda.phys.tohoku.ac.jp:/var/www/html/hyptpc-wiki/data/media/monitor/jparc/magnet/

rsync -a -e "ssh -i ~/.ssh/id_ed25519_wopass" $output_gas \
      lambda.phys.tohoku.ac.jp:/var/www/html/hyptpc-wiki/data/media/monitor/jparc/hyptpc/

