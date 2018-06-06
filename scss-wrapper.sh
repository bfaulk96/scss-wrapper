#!/bin/bash

if [ $# -eq 0 ]; then
  echo "No argument provided. Using folder name."
  folderName=${PWD##*/}
  if [[ $folderName == *" "* ]]; then
    folderName=${folderName// /"-"}
    echo "Converting spaces to hyphens in project name."
  fi
else
  folderName="$1"
fi
if [[ $folderName =~ ^[A-Za-z0-9_-]+$ ]]; then
  echo "Project name is $folderName."
  prefix=".$folderName {"
  suffix="}"

  for file in $(find . -regex ".*/*.scss"); do
    if [[ $file != *"node_modules"* ]] &&
    [[ $file == *"src"* ]] &&
    ! grep -q "$prefix" "$file" &&
    ! grep -q "@import" "$file"; then
      tabs 2
      sed -i '' 's/^/\\t/' "$file" &&
      echo -e "$prefix\n$(cat $file)\n$suffix" > "$file"
      echo "Wrapper has been added to $file"
    else
      if [[ $file == *"node_modules"* ]]; then
          continue
      else
        if grep -q "@import" "$file"; then
          echo "@import does not support scss nesting. Please move @import statements to styles.scss file. Skipping $file"
        else
          if [[ $file != *"src"* ]]; then
            echo "$file is not in src directory. Skipped"
          else
            echo "Wrapper already exists in $file; Skipping"
          fi
        fi
      fi
    fi
  done
else
  echo "Project name must contain only alphanumeric characters, underscore, and hyphen."
fi
