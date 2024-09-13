## Install and configure Log Rotation

- ### Install Log Rotation
  - ``sudo apt-get update``
  - ``sudo apt-get upgrade``
  - ``sudo apt-get install logrotate ``
- ### Create and customize logrotate configuration file
  - ``sudo nano /etc/logrotate.d/siren-investigate``
  - Add the following configurations and save the file 
    - /var/log/siren/investigate.log {
            daily                         
            dateext                       
            missingok                     
            notifempty                    
            compress                      
            delaycompress                 
            copytruncate                  
            create 0644 siren siren 
            rotate 7                      
            }
  - Apply logrotate configs
    -       sudo logrotate -f /etc/logrotate.d/siren-investigate

