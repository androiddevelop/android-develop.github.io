#!/bin/bash
cd /Users/yuedong/Blog/source
rm -rf _site
jekyll b
mv _site/* ../
cd /Users/yuedong/Blog/
ls | grep -v source | xargs rm -rf
git add . && git commit -am 'update post'
git push


