#!/bin/sh

file="copyright-`date +%s`.txt"

find . -not -path "*/.metadata/*" -path "*/src/*" -name "*.java" -not -exec grep -q "Copyright (C)" {} \; -print >> $file
find . -not -path "*/.metadata/*" -path "*/src/*" -name "*.xtend" -not -exec grep -q "Copyright (C)" {} \; -print >> $file
find . -not -path "*/.metadata/*" -not -path "*/target/*" -name "feature.xml" -not -exec grep -q "Copyright (C)" {} \; -print >> $file
find . -not -path "*/.metadata/*" -not -path "*/target/*" -name "plugin.properties" -not -exec grep -q "Copyright (C)" {} \; -print >> $file
find . -not -path "*/.metadata/*" -not -path "*/target/*" -name "feature.properties" -not -exec grep -q "Copyright (C)" {} \; -print >> $file
find . -not -path "*/.metadata/*" -not -path "*/target/*" -name "*.exsd" -not -exec grep -q "Copyright (C)" {} \; -print >> $file

if [ "`cat $file`" != "" ]; then
  echo "These files have no copyright header:"
  cat $file
  rm $file
  exit 1
fi

rm $file
