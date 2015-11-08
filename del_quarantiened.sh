
cp -i experiment.sids experiment.sids.bak

for qsid in quarantined/*
do
    sid=`echo $qsid | cut -f 2 -d /`
    grep -v $sid experiment.sids > tmp ; mv tmp experiment.sids
done

