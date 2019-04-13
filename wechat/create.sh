#!/bin/bash

rm -rf content
mkdir content

# 生成文件
position=1;
for loop in `ls ../_posts`
do
 id=${loop/.md/};
 echo "$id $position";
 content=`cat template`;
 content=${content/cb_page_index/$position}
 echo "${content}" > "content/$id"
 ((position++));
done
