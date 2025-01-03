# Setup ElasticSearch cluster and Siren Investigate using Ansible

- ### Installing Ansible
    On Ubuntu / debian:
    - sudo apt update 
    - sudo apt install software-properties-common 
    - sudo add-apt-repository --yes --update ppa:ansible/ansible 
    - sudo apt install ansible

- ### Setting up SSH key-based authentication
    - Generate SSH Key
      -     ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
    
      - Copy the Public Key to Host Machines
        
        -      ssh-copy-id your_username@server1 
        -      ssh-copy-id your_username@server2
        -      ssh-copy-id your_username@server3
    
    - Verify SSH Key authentication:
        - ssh your_username@server1
        - ssh your_username@server2
        - ssh your_username@server3

- ### Update Ansible Inventory 
  - Update the hosts file inside inventory directory with your corresponding IP addresses.

- ### Running the Playbook
  -     ansible-playbook -i inventory/hosts.ini playbook.yml --ask-become-pass
  - Use -vvv  for verbose output to get more details about what Ansible is doing.


## Generating TLS Keys
- Download and unzip the search-guard offline tool: https://maven.search-guard.com/search-guard-tlstool/1.8/search-guard-tlstool-1.8.zip
- Add tls_config.yml file in the config directory.
- Adjust the configuration to fit your needs.
- Inside the search-guard-tlstool directory run the following command:  
  -     ./tools/sgtlstool.sh -c config/tls_config.yml -ca -crt -o -t output -v
- After generating the .key and .pem certificates generate the .jks 
  - Generate p12 files:
    -       openssl pkcs12 -export -in <node-certificate-name>.pem -inkey <node-certificate-name>.key -out <node-certificate-name>.p12 -name  <node-name> -CAfile root-ca.pem -caname root -password pass:password
  - Generate keystore:
    -       keytool -importkeystore -deststorepass password -destkeypass password -destkeystore 	<node-name>-keystore.jks -srckeystore <node-certificate-name>.p12 -srcstoretype PKCS12 -srcstorepass 	password -alias <node-name>
  - The previous steps should be done for all nodes and sgadmin.
  - Generate truststore:
    -        keytool -importcert -keystore truststore.jks -storepass password -alias root -file root-ca.pem -noprompt
- Add those keys to the elasticsearch/config directory and siren/config directory
- Inside ElasticSearch folder initialize searchguard:
  -     /path/to/elasticsearch/plugins/search-guard-7/tools/sgadmin.sh \
        -cd /path/to/searchguard/config \
        -ks /path/to/keystore.jks \
        -kspass <keystore_password> \
        -ts /path/to/truststore.jks \
        -tspass <truststore_password> \
        -icl \
        -nhnv \
        -h <IP> \
        -p <9330>

## Creating a service for Elasticsearch:
- From the ansible controller copy the elasticsearch.environment and elasticsearch.service files into the /opt folder, and /etc/systemd/system/ folder of each machine respectively using the following commands:
  -     scp elasticsearch.environment USERNAME@IP_ADDRESS:/opt
  -     scp elasticsearch.service USERNAME@IP_ADDRESS:/etc/systemd/system/
- Login to each machine and run the following commands:
  -      echo "vm.max_map_count = 262144" > /etc/sysctl.d/99-elasticsearch.conf
  -      sysctl -p /etc/sysctl.d/99-elasticsearch.conf
  -      ln -s ../elasticsearch.service /etc/systemd/system/multi-user.target.wants/
  -      systemctl daemon-reload
  -      systemctl start elasticsearch

## Creating a service for Siren:
- From the ansible controller copy the siren.service files into the  /etc/systemd/system/ folder of each machine using the following commands:
  -     scp siren.service USERNAME@IP_ADDRESS:/etc/systemd/system/
- Login to each machine as the root user (su - ) and run the following commands:
  -      ln -s ../siren.service /etc/systemd/system/multi-user.target.wants/
  -      systemctl daemon-reload
  -      systemctl start siren

## Notes:
- Ensure that max_map_count is enough.
- To set it to its proper value:
  -     sudo nano /etc/sysctl.conf
  - Add [vm.max_map_count=262144]
  -     sudo sysctl -p

- To backup siren investigate:
  - Copy the siren_backup.sh file
  - Create a backup directory and logs directory:
    -     sudo mkdir siren-backup-dir
    -     sudo mkdir log-siren-backup 
  - Ensure backup scrip executable
    -     chmod +x /path/to/siren_backup.sh
    -     ./path/to/siren_backup.sh
  - To restore the indices:
    -     bin/investigate backup --backup-dir=/path/to/siren-backup-dir
- To automate the process schedule the backup using cron job:
  - Open the crontab editor:
    -     crontab -e
  - Add this line to run it every Sunday at midnight
    -     0 0 * * 0 /path/to/siren_backup.sh


