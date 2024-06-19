alias runSVUnit='runSVUnit -s questa -o ./sim_output -r -voptargs=+acc -r -gui -r work.glbl -r "-do ../wave.do" -t tb01_unit_test.sv'
git submodule update --init --recursive
cd sim/
cd common/svunit/
setenv SVUNIT_INSTALL `pwd`
setenv PATH "$PATH:${SVUNIT_INSTALL}/bin"
cd ../..
cd sim