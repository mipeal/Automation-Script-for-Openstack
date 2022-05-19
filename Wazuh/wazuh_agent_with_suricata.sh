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
wget https://rules.emergingthreats.net/open/suricata-6.0.3/emerging.rules.tar.gz
tar zxvf emerging.rules.tar.gz
rm /etc/suricata/rules/* -f
mv rules/*.rules /etc/suricata/rules/
rm -f /etc/suricata/suricata.yaml
curl -so /etc/suricata/suricata.yaml https://raw.githubusercontent.com/mipeal/Automation-Script-for-Openstack/main/Suricata/suricata.yml
suricata-update
suricata-update enable-source tgreen/hunting
systemctl daemon-reload
systemctl enable suricata
systemctl start suricata
systemctl status suricata
echo "Verifying suricata"
curl http://testmynids.org/uid/index.html
grep 2100498 /var/log/suricata/fast.log
jq 'select(.alert .signature_id==2100498)' /var/log/suricata/eve.json
echo "<ossec_config>" >> /var/ossec/etc/ossec.conf
echo "  <localfile>" >> /var/ossec/etc/ossec.conf
echo "    <log_format>json</log_format>" >> /var/ossec/etc/ossec.conf
echo "    <location>/var/log/suricata/eve.json</location>" >> /var/ossec/etc/ossec.conf
echo "  </localfile>" >> /var/ossec/etc/ossec.conf
echo "</ossec_config>" >> /var/ossec/etc/ossec.conf
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