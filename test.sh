TO_REPLACE="Xcode.app"
NEW_STRING="Xcode_$(xcodeVersion).app"
sed -ie "s#${TO_REPLACE}#${NEW_STRING}#g" *.txt
