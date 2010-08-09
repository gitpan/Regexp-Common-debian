./Build realclean
rm MANIFEST
./Build.PL
./Build test
./Build manifest
./Build distmeta
