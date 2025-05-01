#!/bin/sh

. $HOME/.env

opt="theme=light&orgId=1&from=now-24h&to=now&timezone=browser&width=1600&height=1200"

url="http://localhost:3000/render/d/bej2uft3tyd4wa/shs-magnet?$opt"

#url="http://localhost:3000/render/d/deiuy5tnommm8c/ess?$opt"

output=/tmp/grafana-shs-magnet.png

webcam5=/export/share/onsite-homepage/webcam/webcam5.jpg
webcam6=/export/share/onsite-homepage/webcam/webcam6.jpg

curl -s -o $output "$url" -H "Authorization: Bearer $GRAFANA_API_KEY"

rsync -a -e "ssh -i ~/.ssh/id_ed25519_wopass" $output $webcam5 $webcam6 \
      lambda.phys.tohoku.ac.jp:/var/www/html/hyptpc-wiki/data/media/monitor/jparc/magnet/

