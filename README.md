# WoltLab Plugin

:construction:

## Packaging
 - https://docs.woltlab.com/5.5/getting-started/#building-the-package

### bash script
```bash
. create_tar.sh;
```

### line per line
```bash
# tar the files in files folder (without "files" directory itself)
cd files;
tar -cf ../files.tar .;

# tar the templates in files folder (without "templates" directory itself)
cd ../templates;
tar -cf ../templates.tar .;

# tar all the files for final archive
cd ../;
tar -cf com.example.test.tar package.xml page.xml files.tar templates.tar;

# list/verify .tar contents
tar -tvf com.example.test.tar;
```

# Installation

 - visit woltlab acp => http://sys-api.krone.at:8094/acp/
 - -> Konfiguration -> Pakete -> Paket installieren -> Paket hochladen
 - select the previously created .tar
 - Submit

after installation the files can be found in following directories:
 - `/CAPTCHA/woltlab-env/wsc-dockerized/public/lib/page/...`
 - `/CAPTCHA/woltlab-env/wsc-dockerized/public/templates/...`

the structure reflects the structural hierarchy from the .tar package:
 - files/
   - lib/
     - page/
       - TestPage.class.php
 - templates/
   - test.tpl

