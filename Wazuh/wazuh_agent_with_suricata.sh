#!/bin/bash
sed -i ''s/groovy/focal/g'' /etc/apt/sources.list
echo "Running boot script"
apt-get update
apt-get install -y rpm
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
echo "deb https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list
apt-get update
WAZUH_MANAGER="$wazuh_server_ip" apt-get install -y wazuh-agent
echo "Running suricata boot script"
add-apt-repository ppa:oisf/suricata-stable -y
apt update
apt install -y suricata
echo "<ossec_config>" >> /var/ossec/etc/ossec.conf
echo "  <localfile>" >> /var/ossec/etc/ossec.conf
echo "    <log_format>json</log_format>" >> /var/ossec/etc/ossec.conf
echo "    <location>/var/log/suricata/eve.json</location>" >> /var/ossec/etc/ossec.conf
echo "  </localfile>" >> /var/ossec/etc/ossec.conf
echo "</ossec_config>" >> /var/ossec/etc/ossec.conf
sed -i "s/eth0/ens3/g" /etc/suricata/suricata.yaml
sed -i "s/eth1/enp0s3/g" /etc/suricata/suricata.yaml
sed -i "s/#- rule-reload: false/rule-reload: true/g" /etc/suricata/suricata.yaml
sed -i "s/#community-id: false/community-id: true/g" /etc/suricata/suricata.yaml
suricata-update
suricata-update enable-source tgreen/hunting
systemctl enable suricata
systemctl start suricata
systemctl status suricata
curl http://testmynids.org/uid/index.html
tail -n1 /var/log/suricata/eve.json | jq .
systemctl enable wazuh-agent
systemctl start wazuh-agent
systemctl status wazuh-agent
apt-get install -y upx
apt-get install -y golang-go
export GOCACHE=/root/go/cache
export GOPATH=/root/go
export PATH=$PATH:$GOPATH/bin
mkdir ~/.go
echo "export GOCACHE=/root/go/cache" >> ~/.bashrc
echo "export GOPATH=/root/go" >> ~/.bashrc
echo "export PATH=$PATH:/root/go/bin" >> ~/.bashrc
source ~/.bashrc
echo "Done"
sed -i "s/^deb/#deb/" /etc/apt/sources.list.d/wazuh.list