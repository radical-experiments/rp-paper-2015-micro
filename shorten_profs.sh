#!/bin/sh

for file in `find . -name \*.prof`
do
    echo "cleaning $file"
    sed -i -e 's/PubsubZMQ object.*/PubsubZMQ object ...>/g' $file
done

