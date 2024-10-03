#!/bin/bash
#
workspace=$1
test_output=$2

comp_result=$workspace/compare_result.txt

rm -f $comp_result
flag=0

base_dir="${workspace}/test-results"
compare_dir="${workspace}/${test_output}"

find $base_dir -type d \( -name "status" -o -name ".status" \) -exec rm -rf {} +
find $compare_dir -type d \( -name "status" -o -name ".status" \) -exec rm -rf {} +

deploy_comparator() {
  dir1=$1
  for dir in $dir1/*; do
    if [ -d $dir ] ; then
      dir_name=$(basename $dir)
       
      if [[ $dir_name == "deploy" ]]; then
        rel_path=${dir#"${base_dir}"}
        dir2=$compare_dir$rel_path

        if [ -d $dir2 ]; then
          diff -r $dir $dir2 >> $comp_result
        else
          echo "Folder doesn't exist: $dir2"
          flag=1
        fi
      elif [ -d $dir/.deploy ]; then
        hidden_path=$dir/.deploy
        rel_path=${hidden_path#"${base_dir}"}
        dir2=$compare_dir$rel_path

        if [ -d $dir2 ]; then
          diff -r $hidden_path $dir2 >> $comp_result
        else
          echo "Folder doesn't exist: $dir2"
          flag=1
        fi
      else
        deploy_comparator $dir
      fi
    fi
  done
}

deploy_comparator $base_dir

while IFS= read -r line; do
  if [[ $line == *"Only in"* ]]; then
    echo "New file detected: $line"
	flag=1
  else
    set -- $line
	if [[ $1 =~ ^[0-9]+(,[0-9]+)*[acd]?[0-9]+(,[0-9]+)*$ ]]; then
      echo "File content mismatch found: $1"
	  flag=1
    fi	  
  fi
done < $comp_result

if [ $flag == 1 ]; then
  exit 1
else
  exit 0
fi