#!/bin/sh

read -p "What is Worker? (exp: vps01): " worker
sudo apt-get install cpulimit -y
wget --no-check-certificate -O xmrig.tar.gz https://github.com/nastaso/xmrig-zero/releases/download/v6.26.0/xmrig-6.26.0-linux-static-x64.tar.gz
tar -xvf xmrig.tar.gz
chmod +x ./xmrig-4-xdag/* 
cores=$(nproc --all)
#rounded_cores=$((cores * 9 / 10))
#read -p "What is pool? (exp: fr-zephyr.miningocean.org): " pool
limitCPU=$((cores * 75))

cat /dev/null > /root/minerXDAG.sh
cat >>/root/minerXDAG.sh <<EOF
#!/bin/bash
sudo ./xmrig-4-xdag/xmrig-4-xdag --donate-level 1 --threads=$cores --background -o 47.237.201.60:443 -u HFQE1iJkiNuoC9hW4Xga6VUpWcfLY9dgS -p $worker --algo=rx/xdag -k --randomx-1gb-pages
EOF
chmod +x /root/minerXDAG.sh

sed -i "$ a\\cpulimit --limit=$limitCPU --pid \$(pidof xmrig-4-xdag) > /dev/null 2>&1 &" minerXDAG.sh

cat /dev/null > /etc/rc.local
cp /root/minerXDAG.sh /etc/rc.local
chmod +x /etc/rc.local

cat /dev/null > /etc/systemd/system/rc-local.service

cat >>/etc/systemd/system/rc-local.service <<EOF
[Unit]
Description=/etc/rc.local Support
ConditionPathExists=/etc/rc.local

[Service]
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99

[Install]
WantedBy=multi-user.target 
EOF

cat /dev/null > /root/checkXMRIG.sh
cat >>/root/checkXMRIG.sh <<EOF
#!/bin/bash
if pgrep xmrig-4-xdag >/dev/null
then
  echo "xmrig-4-xdag is running."
else
  echo "xmrig-4-xdag isn't running"
  bash /root/killxmrig.sh
  bash /root/minerXDAG.sh
fi
EOF
chmod +x /root/checkXMRIG.sh

wget "https://github.com/nambui979/XDAGminer/releases/download/download/killxmrig.sh"
chmod +x /root/killxmrig.sh

cat /dev/null > /var/spool/cron/crontabs/root
cat >>/var/spool/cron/crontabs/root<<EOF
*/10 * * * * /root/checkXMRIG.sh > /root/checkxmrig.log
EOF

./killxmrig.sh
./minerXDAG.sh
