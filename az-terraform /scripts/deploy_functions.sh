#!/bin/bash
#
# source from organization environment/profile deploy scripts
# Which
#   define context variables
#   source deploy/profile/.env for account variables
#   source this script for common deploy fuctions
#   define deploy_sequence function from profile system/network/service lists
#     define service, template, parameters
#     call common deploy_template function
#
deploy_info() {
  echo " "  # separator for multiple org profiles
  echo "$cf_organization-$cf_environment"
  echo "- - - - -"
}

deploy_template() {
  echo $1 $2
}

deploy_profile() {
  output_options="-no-color"
  set -x
  echo $cf_deploy_env
  cd $cf_deploy_env

  echo "init..." >&4
  terraform init $output_options

  echo "validate..." >&4
  terraform validate $output_options

  echo "plan..." >&4
  terraform plan -out=$profile.plan $output_options

  echo "apply..." >&4
  terraform apply -json $profile.plan > ${cf_relative_status}/terraform.status.json
}

deploy_status() {
  # capture latest status revision checkpoint
  echo "status_rev=\"${new_status_rev}\"" > "${cf_status_rev}"
}

deploy_setup() {
  export TF_LOG=$logLevel
  export TF_LOG_PATH=$logFilePath
  echo "Log level: $TF_LOG"
  echo "Log file path: $TF_LOG_PATH"
}

#
deploy_main() {
  exec 4>&1
  log_date=`date --utc '+%Y-%m-%dT%H-%M-%SZ'`
  log_file="${cf_status}/${cf_environment}.${new_status_rev}-${log_date}.log.txt"
  deploy_info >&4
  deploy_info > $log_file 2>&1
  deploy_setup
#  deploy_sequence
  deploy_profile >> $log_file 2>&1
#  deploy_status
  exec 4>&-
}

undeploy_main(){
   cd $cf_deploy_env
   echo "destroy...."
  terraform destroy -auto-approve -json > ${cf_relative_status}/terraform-undeploy.status.json
}

profile_main() {
  if [ "$1" = deploy ] ; then
    deploy_main
  elif [ "$1" = delete ]; then
   undeploy_main
  else
     printf "unknown profile script command '$1'"
     printf "expecting 'deploy or delete'"
  fi
}
