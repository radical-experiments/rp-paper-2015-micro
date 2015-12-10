for d in ../*.*.plots; do for f in $d/*.png; do ln -s $f "`basename $d`_`basename $f`"; done; done
