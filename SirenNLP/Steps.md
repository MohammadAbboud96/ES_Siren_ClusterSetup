## Installing Siren NLP plugin

    Check ES version "curl -XGET 'http://host:port'"

    Download the NLP plugin from '' based on your ES version

    Stop the ES service "sudo systemctl stop elasticsearch.service"

    Install the plugin: "./bin/elasticsearch-plugin  install file:///PATH-TO-SIREN-NLP-PLUGIN/siren-nlp-{elasticsearch-version}-{version}-plugin.zip"

    Restart the ES service "sudo systemctl restart elasticsearch.service"