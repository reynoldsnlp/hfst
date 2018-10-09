import hfst_commandline
import hfst

short_getopts='f:'
long_getopts=['format=',]
short_opts=['-f',]
long_opts=['--format',]

hfst_commandline.hfst_getopt(short_opts, short_getopts, long_opts, long_getopts)

hfst.set_default_fst_type(hfst_commandline.impl)
result = hfst.compile_sfst_file("")
result.convert(hfst.get_default_fst_type())
ostr = hfst.HfstOutputStream(type=hfst.get_default_fst_type())
ostr.write(result)
