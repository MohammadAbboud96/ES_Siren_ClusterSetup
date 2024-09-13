## Steps of adding siren log files

- ### Create a siren folder in ```/var/log```
  - ``sudo mkdir -p /var/log/siren``
  - ``sudo chown -R siren:siren /var/log/siren``
  - ``sudo chmod 755 /var/log/siren``
- ## Update ``config/investigate.yml`` file.
  - Add ``logging.dest: /var/log/siren/investigate.log``
- ## Restart Siren Service
  - ``sudo systemctl restart siren.service``
- ### Note 
  - #### To create a log file for each day follow the steps in [Log Rotation](./adding-daily-log-files)