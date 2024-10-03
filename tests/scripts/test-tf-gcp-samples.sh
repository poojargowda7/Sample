#!/bin/bash
#
# regression test for the sample organizations
# The performs init/compile/deploy for each of the known samples
# The GCP test subscription is used for each of the test cases.
#

if [ -z "$cfa_install" ] ; then
  cfa_install="`${cfc_exec} info --path library`/.."
fi
#cfa_install_gcp_scripts="${cfa_install}/lib/gcp/scripts"
# test output location
if [ -z "$test_output" ] ; then
  test_output=$(pwd)
  echo "${test_output}"
fi
cf_test_account_yaml_path="${cfa_install}/tests/gcp-samples/cf-test.account.yaml"
test_output_folder="${test_output}/test-tf-gcp-samples"
#
#source "${test_output_folder}/deploy/s2a/policy/.env"

# set environment variable to ignore both npm semver '-' prerelease and '+' build metadata
export CF4LIB_VERSION=1

# test parameters
CF4LIB_LIBRARY=tf
logLevel="2"
deployStage="1"
deployOrgWait="0"
#
# The customEnvironment is a .env.yaml file that specifies settings and/or settingLists values.
# in particular custom adminCidrClients values are needed to connect to Bastion hosts,
# and custom adminSshKeys values are needed to deploy Linux VMs (currently uses only SshKey[0] for admin user key)
#
# To eliminate differences in test output,
#  1: Use generic installation location (used in generated *.deploy.sh scripts)
#  2: Use same test output location (used in generated *.deploy.sh scripts)
#  3: In selected sample, change *.profile.yaml line
#       EditedOn: # $ # YYYY-MM-DD
#     to
#       EditedOn: '2020-09-26' # $ # YYYY-MM-DD
#
#
test_case() {
    (
        set -x
        echo "gcp, tf, $1, $2, init, `date`" >> ../test-samples.perf.csv
        ${cfc_exec} init    src/$1/$2.org --logLevel "${logLevel}" --sample $3 --cloud "$4" --library "${CF4LIB_LIBRARY}" --subscription "$5" --environment "${customEnvironment}"
        cp ${cf_test_account_yaml_path} ${test_output_folder}/src/$1/$3.account.yaml
        echo "gcp, tf, $1, $2, compile, `date`" >> ../test-samples.perf.csv
        ${cfc_exec} compile src/$1/$2.org --logLevel "${logLevel}"
    if [ "$deployStage" == "1" ] ; then
        echo "gcp, tf, $1, $2, deploy, `date`" >> ../test-samples.perf.csv
        ${cfc_exec} deploy  src/$1/$2.org --logLevel "${logLevel}" --wait "${deployOrgWait}"
        #
    fi
        echo "gcp, tf, $1, $2, done, `date`" >> ../test-samples.perf.csv
    )
    if [ "$deployStage" == "1" ] ; then
    git diff **/$1 > ../test-samples-$1.diff
    fi
}

test_cases() {
    echo "gcp, tf, s0, tf0, begin, `date`" >> ../test-samples.perf.csv

    #         folder       org      sample      cloud
    #test_case "s1"         "tf1"     "min"       "GCP"
    #test_case "s2a"        "tf2"     "policy"    "GCP"
    #test_case "s2b"        "tf2"     "reference" "GCP"
    test_case "s3"         "tf3"     "single"    "GCP"
    test_case "s4a"        "tf4a"    "shared1"   "GCP"
    #test_case "s4b"        "tf4b" "shared"    "GCP"
    #test_case "s4c"        "tf4c"    "hawaii"    "GCP"
    #
    echo "gcp, tf, s0, tf0, end, `date`" >> ../test-samples.perf.csv
    if [ "$deployStage" == "1" ] ; then
    git diff ../test-tf-gcp-samples-s*.diff > ../test-tf-gcp-samples.diff
    fi
}

if [ "$1" == "clean" ] ; then
    set -x
    pushd "${test_output_folder}"
    pushd deploy/s3/single
    terraform destroy -auto-approve
    popd
    pushd deploy/s3/state
    terraform destroy -auto-approve
    popd
    pushd deploy/s4a/dev
    terraform destroy -auto-approve
    popd
    popd
    exit 0
#
elif [ "$1" == "test" ] ; then
    rm -rf "${test_output_folder}"
    mkdir -p "${test_output_folder}"
    pushd "${test_output_folder}"
    ${cfc_exec} version
    test_cases
    popd
elif [ "$1" == "testcompile" ] ; then
    deployStage="0"
    #rm -rf "${test_output_folder}"
    rm -r "${test_output_folder}/src"
    rm -r "${test_output_folder}/built"
    rm -r "${test_output_folder}/deploy"
    mkdir -p "${test_output_folder}"
    pushd "${test_output_folder}"
    ${cfc_exec} version
    test_cases
    popd
else
    echo "usage "
    echo " test-tf-gcp-samples.sh test"
    echo " test-tf-gcp-samples.sh clean"
fi
