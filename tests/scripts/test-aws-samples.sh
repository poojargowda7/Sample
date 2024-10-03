#!/bin/bash
#
# regression test for the sample organizations
# The performs init/compile/deploy for each of the known samples
# The AWS test subscription is used for each of the test cases.
#
#if [ -z "$cfa_install" ] ; then
#  cfa_install="C:\Program Files (x86)\Unisys\CloudForte\cfa"
#  #cfa_install="C:\Dev\CloudForte\Accelerators\cfa"
#fi
#cfa_install_aws_scripts="${cfa_install}/lib/aws/scripts"
cfa_install_tests="${cfa_install}/tests/aws-samples"
# test output location
if [ -z "$test_output" ] ; then
  test_output="C:\Dev\CloudForte\Accelerators\cf-test-results"
fi
test_output_folder="${test_output}/test-aws-samples"
cfa_install_tests="${cfa_install}/tests/aws-samples"
#
#source "${test_output_folder}/deploy/s2a/policy/.env"

# set environment variable to ignore both npm semver '-' prerelease and '+' build metadata
export CF4LIB_VERSION=1
customSystemHash="$CF4AWS_SYSTEMHASH"
if [ -z "$customSystemHash" ] ; then
    customSystemHash="0042"
fi
customSystemHash2="$CF4AWS_SYSTEMHASH2"
if [ -z "$customSystemHash2" ] ; then
    customSystemHash2="0901"
fi
echo $customSystemHash
echo $customSystemHash2

# test parameters
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
        # test alternate subscription by adding parameter to cfc init --systemHash2 "${customSystemHash2}"
        set -x
        echo "aws, aws, $1, $2, init, `date`" >> ../test-samples.perf.csv
        ${cfc_exec} init    src/$1/$2.org --logLevel "${logLevel}" --sample $3 --config "$4" --cloud "$5" --environment "${customEnvironment}" --systemHash "${customSystemHash}" --systemHash2 "${customSystemHash2}"
        if [ -f ${cfa_install_tests}/$1-$3.org.yaml ] ; then
            # enable properties for condition expressions
            ${cfc_exec} update src/$1/$2.org --organization "${cfa_install_tests}/$1-$3.org.yaml"
        fi
        echo "aws, aws, $1, $2, compile, `date`" >> ../test-samples.perf.csv
        ${cfc_exec} compile src/$1/$2.org --logLevel "${logLevel}"
    if [ "$deployStage" == "1" ] ; then
        echo "aws, aws, $1, $2, deploy, `date`" >> ../test-samples.perf.csv
        ${cfc_exec} deploy  src/$1/$2.org --logLevel "${logLevel}" --wait "${deployOrgWait}"
        #
    fi
        echo "aws, aws, $1, $2, done, `date`" >> ../test-samples.perf.csv
    )
    if [ "$deployStage" == "1" ] ; then
    git diff **/$1 > ../test-samples-$1.diff
    fi
}

test_cases() {
    echo "aws, aws, s0, t0, begin, `date`" >> ../test-samples.perf.csv

    #         folder       org      sample      config  cloud
    test_case "s1"         "t1min"  "min"       ""      "AWSCloud"
    #test_case "s2a"        "t2pol"  "policy"   ""      "AWSCloud"
    test_case "s2b"        "t2ref"  "reference" "all"   "AWSCloud"
    test_case "s3"         "t3sing" "single"    "all"   "AWSCloud"
    #test_case "s4a"        "t4sh1"  "shared1"  ""       "AWSCloud"
    #test_case "s4b"        "t4shar" "shared"   ""       "AWSCloud"
    #
    echo "aws, aws, s0, t0, end, `date`" >> ../test-samples.perf.csv
    if [ "$deployStage" == "1" ] ; then
    git diff ../test-samples-s*.diff > ../test-samples.diff
    fi
}

delete_profiles(){
    # ${cfc_exec} delete  src/$1/$2.org --logLevel "${logLevel}" --wait "${deployOrgWait}"
    ./deploy/$1/$2.org.deploy.sh delete
}

if [ "$1" == "clean" ] ; then
    pushd "${test_output_folder}"
    # match test_cases parameter lists
    delete_profiles "s1"        "t1min"
    delete_profiles "s2b"       "t2ref"
    delete_profiles "s3"        "t3sing"
    popd
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
    echo " test-aws-samples.sh test"
    echo " test-aws-samples.sh clean"
fi
