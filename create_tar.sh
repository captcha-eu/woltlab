#!/bin/bash

TAR_NAME='com.captchaeu.captcha.tar';

RED='\033[0;31m';
GREEN='\033[0;32m';
GRAY='\033[0;37m';
RESET='\033[0m';

ERRORS_OCCURED=0;

CMD_TAR="tar --xform s:'./':: -cf";

# tar the files in files folder (without "files" directory itself)
cd files;
echo -e "[${GRAY}INFO${RESET}] packing files.tar";
$CMD_TAR ../files.tar *;
if [ $? -ne 0 ]; then ERRORS_OCCURED=1; fi

# tar the templates in templates folder (without "templates" directory itself)
cd ../templates;
echo -e "[${GRAY}INFO${RESET}] packing templates.tar";
$CMD_TAR ../templates.tar *;
if [ $? -ne 0 ]; then ERRORS_OCCURED=1; fi

# tar the templates in acptemplate folder (without "acptemplates" directory itself)
cd ../acptemplates;
echo -e "[${GRAY}INFO${RESET}] packing acptemplates.tar";
$CMD_TAR ../acptemplates.tar *;
if [ $? -ne 0 ]; then ERRORS_OCCURED=1; fi

# tar all the files for final archive
cd ../;
$CMD_TAR $TAR_NAME package.xml option.xml objectType.xml files.tar templates.tar acptemplates.tar language;
if [ $? -ne 0 ]; then ERRORS_OCCURED=1; fi

if [ $ERRORS_OCCURED -eq 1 ]; then
	STATUS="ERROR";
else
	STATUS="SUCCESS";
fi

echo -e "[${GREEN}${STATUS}${RESET}] package created/updated:\n";

# list/verify .tar contents
tar -tvf $TAR_NAME;
