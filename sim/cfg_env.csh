alias runSVUnit='runSVUnit -s questa -o ./sim_output -r -voptargs=+acc -r -gui -r work.glbl -r "-do ../wave.do" -t tb01_unit_test.sv'
git submodule update --init --recursive
cd common/svunit/
export SVUNIT_INSTALL=`pwd`
export PATH="$PATH:${SVUNIT_INSTALL}/bin"
export PATH="$PATH:/mnt/c/questasim64_2021.1/win64"
cd ../../
cd sim