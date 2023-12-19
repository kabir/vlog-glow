#!/bin/bash

jboss_home="${1}"

if [ ! -d "${jboss_home}" ]; then
  echo "No directory containing the server found at '${jboss_home}'"
  exit 1
fi
if [ ! -d "${jboss_home}/modules" ]; then
  echo "'${jboss_home}' has no sub-directory called modules/. This does not appear to be a valid WildFly installation"
  exit 1
fi

number_module_xmls=$(find "${jboss_home}/modules"  -name 'module.xml' | wc -l)
number_module_xmls=$(echo "${number_module_xmls}" | awk '{gsub(/^ +| +$/,"")} {print$0}')

echo "${number_module_xmls} module.xml found"

# For the zip distribution we need to use standalone-microprofile.xml to get the MicroProfile Config functionality.
# For the Galleon or Glow provisioned distributions there is only a standalone.xml with the relevant subsystems
config_dir="${jboss_home}/standalone/configuration"
use_config="standalone.xml"
if [ -f "${config_dir}/standalone-microprofile.xml" ]; then
  use_config="standalone-microprofile.xml"
fi

number_subsystems="$(grep "<subsystem" "${config_dir}/${use_config}" | wc -l)"
number_subsystems=$(echo "${number_subsystems}" | awk '{gsub(/^ +| +$/,"")} {print$0}')

echo "${number_subsystems} subsytems found in ${use_config}"
