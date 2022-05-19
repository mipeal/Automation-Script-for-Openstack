#!/bin/bash
sed -i ''s/groovy/focal/g'' /etc/apt/sources.list
echo "Running boot script"
apt-get update
curl -so ~/unattended-installation.sh https://packages.wazuh.com/resources/4.2/open-distro/unattended-installation/unattended-installation.sh
&& bash ~/unattended-installation.sh
apt install docker.io -y
apt install docker-compose -y
git clone https://github.com/Netflix/dispatch-docker.git
cd dispatch-docker
cp .env.example .env
rm -r install.sh
curl -so install.sh https://raw.githubusercontent.com/mipeal/Automation-Script-for-Openstack/main/Dispatch/install.sh
chmod +x install.sh
bash install.sh
docker-compose up -d
wget --no-check-certificate --quiet  --method POST  --timeout=0 --header ''Content-Type: application/json''  --body-data ''{"email": "noreply@dispatch.org","projects": [],  "password": "Dispatch123"}'' ''http://10.212.139.227:8000/api/v1/default/auth/register''
docker exec -it dispatch_web_1 bash -c ''dispatch user update --role Owner --organization default noreply@dispatch.org''
echo "Adding dispatcher"
curl -so /var/ossec/integrations/custom-dispatch https://raw.githubusercontent.com/mipeal/Automation-Script-for-Openstack/main/Dispatch/custom-dispatch
chmod 770 /var/ossec/integrations/custom-dispatch
chown root:ossec /var/ossec/integrations/custom-dispatch
echo "Updating ossec.conf"
echo "<!-- DISPATCH -->" >> /var/ossec/etc/ossec.conf
echo "<ossec_config>" >> /var/ossec/etc/ossec.conf
echo "  <integration>" >> /var/ossec/etc/ossec.conf
echo "    <name>custom-dispatch</name>" >> /var/ossec/etc/ossec.conf
echo "    <group>syscheck|vulnerability-detector</group>" >> /var/ossec/etc/ossec.conf
echo "    <hook_url>http://localhost:8000/api/v1/default/</hook_url>" >> /var/ossec/etc/ossec.conf
echo "    <api_key>dispatch@noreply.org:Dispatch123</api_key>" >> /var/ossec/etc/ossec.conf
echo "    <alert_format>json</alert_format>" >> /var/ossec/etc/ossec.conf
echo "  </integration" >> /var/ossec/etc/ossec.conf
echo "</ossec_config>" >> /var/ossec/etc/ossec.conf
systemctl restart wazuh-manager
touch /home/ubuntu/wazuh.pass
grep -i ''The password for'' /var/log/cloud-init-output.log > /home/ubuntu/wazuh.pass