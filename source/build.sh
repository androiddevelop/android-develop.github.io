#!/bin/bash
cd /Users/yuedong/Blog/source
rm -rf _site
jekyll b
cd /Users/yuedong/Blog/
ls | grep -v source | xargs rm -rf
mv source/_site/* ../
git add . && git commit -am 'update post'
git push
