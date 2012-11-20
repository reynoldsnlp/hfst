## A synchronous finite-state transducer.
# 
# \section argument_handling Argument handling
# 
# Transducer functions modify their calling object and return 
# a reference to the calling object after modification, 
# unless otherwise mentioned.
# Transducer arguments are usually not modified.
# \verbatim
# # transducer is reversed
# transducer.reverse()
# # transducer2 is not modified, but a copy of it is disjuncted with
# # transducer1 
# transducer1.disjunct(transducer2)                                       
# # a chain of functions is possible
# transducer.reverse().determinize().reverse().determinize()      
# \endverbatim
# 
# \section implementation_types Implementation types
# 
# Currently, an HfstTransducer has three implementation types that are well supported.
# When an HfstTransducer is created, its type is defined with an argument.
# For functions that take a transducer as an argument, the type of the calling transducer
# must be the same as the type of the argument transducer:
# \verbatim
# # this will cause an error
# tropical_transducer.disjunct(sfst_transducer)
# # this works, but weights are lost in the conversion
# tropical_transducer.convert(libhfst.SFST_TYPE).disjunct(sfst_transducer)     
# # this works, information is not lost
# tropical_transducer.disjunct(sfst_transducer.convert(libhfst.TROPICAL_OPENFST_TYPE)) 
# \endverbatim
# 
# \section creating_transducers Creating transducers
# 
# With HfstTransducer constructors it is possible to create empty, 
# epsilon, one-transition and single-path transducers.
# Transducers can also be created from scratch with #hfst_documentation.HfstBasicTransducer
# and converted to an HfstTransducer.
# More complex transducers can be combined from simple ones with various functions.
# 
# <a name="symbols"></a> 
# \section special_symbols Special symbols
# 
# The HFST transducers support transitions with epsilon, unknown and identity symbols.
# The special symbols are explained in TODO
# 
# An example:
# \verbatim
# # In the xerox formalism used here, "?" means the unknown symbol
# # and "?:?" the identity pair 
# 
# tr1 = libhfst.HfstBasicTransducer()
# tr1.add_state(1)
# tr1.set_final_weight(1, 0)
# tr1.add_transition(0, libhfst.HfstBasicTransition(1, '@_UNKNOWN_SYMBOL_@, 'foo', 0) )
# 
# # tr1 is now [ ?:foo ]
# 
# tr2 = libhfst.HfstBasicTransducer tr2
# tr2.add_state(1)
# tr2.add_state(2)
# tr2.set_final_weight(2, 0)
# tr2.add_transition(0, libhfst.HfstBasicTransition(1, '@_IDENTITY_SYMBOL_@', '@_IDENTITY_SYMBOL_@', 0) )
# tr2.add_transition(1, libhfst.HfstBasicTransition(2, 'bar', 'bar', 0) )
# 
# # tr2 is now [ [ ?:? ] [ bar:bar ] ]
# 
# type = libhfst.SFST_TYPE
# Tr1 = HfstTransducer (tr1, type)
# Tr2 = HfstTransducer (tr2, type)
# Tr1.disjunct(Tr2)
# 
# # Tr1 is now [ [ ?:foo | bar:foo ]  |  [[ ?:? | foo:foo ] [ bar:bar ]] ] 
# \endverbatim

 
## Whether HFST is linked to the transducer library needed by implementation type \a type.
# is_implementation_type_available(type)
 
## Create an uninitialized transducer (use with care). 
# 
# @note This constructor leaves the backend implementation variable
# uninitialized. An uninitialized transducer is likely to cause a
# TransducerHasWrongTypeException at some point unless it is given
# a value at some point. 
# HfstTransducer()
 
## Create an empty transducer, i.e. a transducer that does not recognize any string. The type of the transducer is defined by \a type.
# 
# @note Use HfstTransducer("@_EPSILON_SYMBOL_@") to create an epsilon transducer. 
# HfstTransducer(ImplementationType type)

## Create a transducer by tokenizing the utf8 string \a utf8_string with tokenizer \a multichar_symbol_tokenizer. The type of the transducer is defined by \a type. 
# 
# \a utf8_str is read one token at a time and for each token 
# a new transition is created in the resulting
# transducer. The input and output symbols of that transition are 
# the same as the token read.
# 
# An example:
# \verbatim
# ustring = 'foobar'
# TOK = libhfst.HfstTokenizer()
# tr = libfhst.HfstTransducer(ustring, TOK, FOMA_TYPE)
# # tr now contains one path [f o o b a r]
# \endverbatim
# 
# @see hfst_documentation.HfstTokenizer 
# HfstTransducer(const std::string& utf8_str, 
# const HfstTokenizer &multichar_symbol_tokenizer,
# ImplementationType type)

## Create a transducer by tokenizing  the utf8 input string \a input_utf8_string
# and output string \a output_utf8_string with tokenizer \a multichar_symbol_tokenizer.
# The type of the transducer is defined by \a type. 
# 
# \a input_utf8_str and \a output_utf8_str are read one token at a time
# and for each token a new transition is created in the resulting transducer. 
# The input and output symbols of that transition are the same as 
# the input and output tokens read. If either string contains less tokens
# than another, epsilons are used as transition symbols for the shorter string.
# 
# An example:
# \verbatim
# input = 'foo'
# output = 'barr'
# TOK = libhfst.HfstTokenizer()
# tr = libhfst.HfstTransducer(input, output, TOK, libhfst.SFST_TYPE)
# # tr now contains one path [f:b o:a o:r 0:r]
# \endverbatim
# 
# @see hfst_documentation.HfstTokenizer 
# HfstTransducer(const std::string& input_utf8_str,
# const std::string& output_utf8_str,
# const HfstTokenizer &multichar_symbol_tokenizer,
# ImplementationType type)

## Create a transducer that recognizes (any number of, if \a cyclic is True) the union of string pairs in \a sps. The type of the transducer is defined by \a type. 
# @param sps A tuple of consecutive string input/output pairs
# @param type The type of the transducer.
# @param cyclic Whether the transducer recognizes any number (from zero to infinity, inclusive) of consecutive string pairs in \s sps. 
# HfstTransducer(const StringPairSet & sps, ImplementationType type, bool cyclic=false)
 
## Create a transducer that recognizes the concatenation of string pairs in \a spv. The type of the transducer is defined by \a type.
# @param spv A tuple of string pairs.
# @param type The type of the transducer. 
# HfstTransducer(const StringPairVector & spv, ImplementationType type)
 
## Create a transducer that recognizes the concatenation of the unions of string pairs in string pair sets in \a spsv. The type of the transducer is defined by \a type. 
# @param spvs A tuple of tuples of string input/output pairs.
# @param type The type of the transducer.
# HfstTransducer(const std::vector<StringPairSet> & spsv, ImplementationType type)

## Read a binary transducer from transducer stream \a in. 
# 
# The stream can contain tranducers or OpenFst, foma or SFST
# type in their native format, i.e. without an HFST header. 
# If the backend implementations are used as such, they are converted into HFST transducers.
# 
# For more information on transducer conversions and the HFST header
# structure, see 
# <a href="https://kitwiki.csc.fi/twiki/bin/view/KitWiki/HfstTransducerHeader">here</a>.
# 
# @pre ((in.is_eof() == in.is_bad() == False) and in.is_fst() ), Otherwise, an exception is thrown.
# 
# @throws NotTransducerStreamException 
# @throws StreamNotReadableException
# @throws StreamIsClosedException 
# @throws TransducerTypeMismatchException
# @throws MissingOpenFstInputSymbolTableException
# 
# @see hfst_documentation.HfstInputStream 
# HfstTransducer(HfstInputStream &in)

## Create a deep copy of transducer \a another. 
# HfstTransducer(const HfstTransducer &another)

## Create an HFST transducer equivalent to HfstBasicTransducer \a t. The type of the created transducer is defined by \a type.  
# HfstTransducer(const hfst::implementations::HfstBasicTransducer &t, 
# ImplementationType type)

## Create a transducer that recognizes the string pair &lt;"symbol","symbol"&gt;, i.e. [symbol:symbol]. The type of the transducer is defined by \a type. 
# HfstTransducer(const std::string &symbol, ImplementationType type)
 
## Create a transducer that recognizes the string pair &lt;"isymbol","osymbol"&gt;, i.e [isymbol:osymbol]. The type of the transducer is defined by \a type. 
# HfstTransducer(const std::string &isymbol, const std::string &osymbol, 
# ImplementationType type)
 
## Create a transducer of type \a type as defined in AT&T format in file \a ifile. \a epsilon_symbol defines how epsilons are represented.
# 
# In AT&T format, the transition lines are of the form:
# 
# \verbatim 
# [0-9]+[\w]+[0-9]+[\w]+[^\w]+[\w]+[^\w]([\w]+(-)[0-9]+(\.[0-9]+)) 
# \endverbatim
# 
# and final state lines:
# 
# \verbatim
# [0-9]+[\w]+([\w]+(-)[0-9]+(\.[0-9]+))
# \endverbatim
# 
# If several transducers are listed in the same file, they are separated by lines of 
# two consecutive hyphens "--". If the weight (<tt>([\\w]+(-)[0-9]+(\.[0-9]+))</tt>) 
# is missing, the transition or final state is given a zero weight.
# 
# NOTE: If transition symbols contains spaces, they must be escaped
# as "@_SPACE_@" because spaces are used as field separators.
# Both "@0@" and "@_EPSILON_SYMBOL_@" are always interpreted as
# epsilons.
# 
# 
# An example:
# \verbatim
# 0      1      foo      bar      0.3
# 1      0.5
# --
# 0      0.0
# --
# --
# 0      0.0
# 0      0      a        <eps>    0.2
# \endverbatim
# 
# The example lists four transducers in AT&T format: 
# one transducer accepting the string pair &lt;"foo","bar"&gt;, one
# epsilon transducer, one empty transducer and one transducer 
# that accepts any number of 'a's and produces an empty string
# in all cases. The transducers can be read with the following commands (from a file named 
# "testfile.att"):
# \verbatim
# transducers = []
# ifile = open("testfile.att", "rb")
# try:
#     while (not ifile.eof()):
#         t = libhfst.HfstTransducer(ifile, libhfst.TROPICAL_OPENFST_TYPE, "<eps>")
#         transducers.append(t)
#         print("read one transducer")
# except NotValidAttFormatException:
#     print("Error reading transducer: not valid AT&T format.")
# ifile.close()
# print "Read %i transducers in total" % len(transducers)
# \endverbatim
# 
# Epsilon will be represented as "@_EPSILON_SYMBOL_@" in the resulting transducer.
# The argument \a epsilon_symbol only denotes how epsilons are represented 
# in \a ifile.
# 
# @throws NotValidAttFormatException 
# @throws StreamNotReadableException
# @throws StreamIsClosedException
# @see #hfst_documentation.write_in_att_format 
# 
# HfstTransducer(HfstFile &ifile, ImplementationType type, const std::string &epsilon_symbol)

# /** @brief Assign this transducer a new value equivalent to transducer
# \a another.  
# HfstTransducer &operator=(const HfstTransducer &another)
# 
# HfstTransducer &assign(const HfstTransducer &another)

## Rename the transducer \a name. 
# @see get_name 
# void set_name(const std::string &name)
 
## Get the name of the transducer. 
# @see set_name 
# std::string get_name() const;

## Set arbitrary string property \a property to \a value.
#
# set_property("name") equals set_name(string&).
#
# @note  While this function is capable of creating endless amounts of arbitrary metadata, it is suggested that property names are
# drawn from central repository, or prefixed with "x-". A property that does not follow this convention may affect the behavior of
# transducer in future releases.
# 
# void set_property(const std::string& property, const std::string& value)

## Get arbitrary string propert @a property.
# get_property("name") works like get_name.
# 
# std::string get_property(const std::string& property) const;

## Get all properties from the transducer.
# @return A dictionary of string-to-string mappings.
# const std::map<std::string,std::string>& get_properties() const;

## Get the alphabet of the transducer. 
# 
# The alphabet is defined as the set of symbols known to the transducer. 
# @return A tuple of strings.
# StringSet get_alphabet() const;

## Explicitly insert \a symbol to the alphabet of the transducer. 
# 
# @note Usually this function is not needed since new symbols are
# added to the alphabet by default. 
# void insert_to_alphabet(const std::string &symbol) 
 
## Remove \a symbol from the alphabet of the transducer.CURRENTLY NOT IMPLEMENTED.
# 
# @pre \a symbol does not occur in any transition of the transducer.
# @note Use with care, removing a symbol that occurs in a transition
# of the transducer can have unexpected results. 
# void remove_from_alphabet(const std::string &symbol)
 
## Whether the transducer is cyclic. 
# bool is_cyclic(void) const;
 
## The implementation type of the transducer. 
# ImplementationType get_type(void) const;
 
## Whether this transducer and \a another are equivalent.
# 
# Two transducers are equivalent iff they accept the same input/output
# string pairs with the same weights and the same alignments. 
# 
# bool compare(const HfstTransducer &another) const;





## Convert the transducer into an equivalent transducer in format \a type. 
# 
# If a weighted transducer is converted into an unweighted one, 
# all weights are lost. In the reverse case, all weights are initialized to the 
# semiring's one. 
# 
# A transducer of type #libhfst.SFST_TYPE, #libhfst.TROPICAL_OPENFST_TYPE,
# #libhfst.LOG_OPENFST_TYPE or #FOMA_TYPE can be converted into an 
# #libhfst.HFST_OL_TYPE or #libhfst.HFST_OLW_TYPE transducer, but an #libhfst.HFST_OL_TYPE
# or #libhfst.HFST_OLW_TYPE transducer cannot be converted to any other type.
# 
# @note For conversion between HfstBasicTransducer and HfstTransducer,
# see #HfstTransducer(t, type) and #HfstBasicTransducer(transducer).
def convert(type, options="")

## Write the transducer in AT&T format to file \a ofile, \a write_weights defines whether weights are written.
# 
# The fields in the resulting AT&T format are separated by tabulator characters.
# 
# NOTE: If the transition symbols contain space characters,the spaces are printed as "@_SPACE_@" because
# whitespace characters are used as field separators in AT&T format. Epsilon symbols are printed as "@0@".
# 
# If several transducers are written in the same file, they must be separated by a line of two consecutive hyphens "--", so that
# they will be read correctly by HfstTransducer(file, type, epsilon).
# 
# An example:
# \verbatim
# type = libhfst.FOMA_TYPE
# foobar = libhfst.HfstTransducer("foo","bar",type)
# epsilon = libhfst.HfstTransducer("@_EPSILON_SYMBOL_@",type)
# empty = libhfst.HfstTransducer(type)
# a_star = libhfst.HfstTransducer("a",type)
# a_star.repeat_star()
# 
# ofile = open("testfile.att", "wb")
# foobar.write_in_att_format(ofile)
# ofile.write("--\n")
# epsilon.write_in_att_format(ofile)
# ofile.write("--\n")
# empty.write_in_att_format(ofile)
# ofile.write("--\n")
# a_star.write_in_att_format(ofile)
# ofile.close()
# \endverbatim
# 
# This will yield a file "testfile.att" that looks as follows:
# \verbatim
# 0    1    foo  bar  0.0
# 1    0.0
# --
# 0    0.0
# --
# --
# 0    0.0
# 0    0    a    a    0.0
# \endverbatim
# 
# @throws StreamCannotBeWrittenException 
# @throws StreamIsClosedException
# 
# @see redirect(out, t)
# @see HfstTransducer(file, type, epsilon) 
def write_in_att_format(ofile, write_weights=True):
    pass

## Write the transducer in AT&T format to file named \a filename. \a write_weights defines whether weights are written.
# 
# If the file exists, it is overwritten. If the file does not exist, it is created. 
# 
# @see #write_in_att_format 
def write_in_att_format(filename, write_weights=True):
    pass


## TODO
def extract_paths(callback, cycles=-1):
    pass
 
## TODO: Extract a maximum of \a max_num paths that are recognized by the transducer following a maximum of \a cycles cycles.
# 
# @return The extracted paths. 
# @param max_num The total number of resulting strings is capped at \a max_num, with 0 or negative indicating unlimited. 
# @param cycles Indicates how many times a cycle will be followed, with negative numbers indicating unlimited.
# 
# This is a version of extract_paths that handles flag diacritics 
# as ordinary symbols and does not validate the sequences prior to
# outputting as opposed to #extract_paths_fd(paths, int, int, bool) const.
# 
# If this function is called on a cyclic transducer with unlimited
# values for both \a max_num and \a cycles, an exception will be thrown.
# 
# This example
# 
# \verbatim
# type = libhfst.SFST_TYPE
# tr1 = libhfst.HfstTransducer("a", "b", type)
# tr1.repeat_star()
# tr2 = libhfst.HfstTransducer("c", "d", type)
# tr2.repeat_star()
# tr1.concatenate(tr2).minimize()
# HfstTwoLevelPaths results;
# results tr1.extract_paths(results, MAX_NUM, CYCLES)
# 
# # Go through all paths.
# for (HfstTwoLevelPaths::const_iterator it = results.begin()
# it != results.end() it++)
# {
# std::string istring;
# std::string ostring;
# 
# for (StringPairVector::const_iterator IT = it->second.begin()
# IT != it->second.end() IT++)
# {
# istring.append(IT->first)
# ostring.append(IT->second)
# }
# # Print input and output strings of each path
# std::cerr << istring << ":" << ostring; 
# # and optionally the weight of the path.
# #std::cerr << "\t" << it->first;
# std::cerr << std::endl; 
# }
# \endverbatim
# 
# prints with values MAX_NUM == -1 and CYCLES == 1 all paths
# that have no consecutive cycles:
# 
# \verbatim
# a : b
# ac : bd
# acc : bdd
# c : d
# cc : dd
# \endverbatim
# 
# and with values MAX_NUM == 7 and CYCLES == 2 a maximum of 7 paths
# that follow a cycle a maximum of 2 times (there are 11 such paths,
# but MAX_NUM limits their number to 7):
# 
# \verbatim
# a : b
# aa : bb
# aac : bbd
# aacc : bbdd
# c : d
# cc : dd
# ccc : ddd
# \endverbatim
# 
# @bug Does not work for HFST_OL_TYPE or HFST_OLW_TYPE?
# @throws TransducerIsCyclicException
# @see #n_best 
# @see hfst::HfstTransducer::extract_paths_fd(hfst::HfstTwoLevelPaths&, int, int, bool) const
# 
def extract_paths(max_num=-1, cycles=-1):
    pass
 
# TODO: void extract_random_paths
# (HfstTwoLevelPaths &results, int max_num) const;
# 
# void extract_random_paths_fd
# (HfstTwoLevelPaths &results, int max_num, bool filter_fd) const;
# 
# /* \brief Call \a callback with extracted strings that are not 
# invalidated by flag diacritic rules.
# 
# @see extract_paths(HfstTwoLevelPaths&, int, int) 
# void extract_paths_fd
# (ExtractStringsCb& callback, int cycles=-1, bool filter_fd=true) const;
# 
# public:
## Extract a maximum of \a max_num paths that are 
# recognized by the transducer and are not invalidated by flag 
# diacritic rules following a maximum of \a cycles cycles
# and store the paths into \a results. \a filter_fd defines whether
# the flag diacritics themselves are filtered out of the result strings.
# 
# @param results  The extracted paths are inserted here. 
# @param max_num  The total number of resulting strings is capped at 
# \a max_num, with 0 or negative indicating unlimited. 
# @param cycles  Indicates how many times a cycle will be followed, with
# negative numbers indicating unlimited.
# @param filter_fd  Whether the flag diacritics are filtered out of the
# result strings.
# 
# If this function is called on a cyclic transducer with unlimited
# values for both \a max_num and \a cycles, an exception will be thrown.
# 
# Flag diacritics are of the form @[PNDRCU][.][A-Z]+([.][A-Z]+)?@. 
# 
# For example the transducer 
# 
# \verbatim
# [[@U.FEATURE.FOO@ foo] | [@U.FEATURE.BAR@ bar]]  |  [[foo @U.FEATURE.FOO@] | [bar @U.FEATURE.BAR@]]
# \endverbatim
# 
# will yield the paths <CODE>[foo foo]</CODE> and <CODE>[bar bar]</CODE>.
# <CODE>[foo bar]</CODE> and <CODE>[bar foo]</CODE> are invalidated
# by the flag diacritics so thay will not be included in \a results.
# 
# 
# @bug Does not work for HFST_OL_TYPE or HFST_OLW_TYPE?
# @throws TransducerIsCyclicException
# @see extract_paths(HfstTwoLevelPaths&, int, int) const 
# void extract_paths_fd
# (HfstTwoLevelPaths &results, int max_num=-1, int cycles=-1, 
# bool filter_fd=true) const;
# 
# @brief Lookup or apply a single tokenized string \a s and
# return a maximum of \a limit results.
# 
# This is a version of lookup that handles flag diacritics as ordinary
# symbols and does not validate the sequences prior to outputting.
# Currently, this function calls lookup_fd.
#
# @todo Handle flag diacritics as ordinary symbols instead of calling
#       lookup_fd.
# @sa lookup_fd
# HfstOneLevelPaths * lookup(const StringVector& s,
# ssize_t limit = -1) const;
# 
# @brief Lookup or apply a single string \a s and
# return a maximum of \a limit results.
# 
# This is an overloaded lookup function that leaves tokenizing to the
# transducer.
# HfstOneLevelPaths * lookup(const std::string & s,
# ssize_t limit = -1) const;
# 
# @brief Lookup or apply a single string \a s minding flag diacritics
# properly and store a maximum of \a limit results to \a results.
#
# Traverse all paths on logical first level of the transducer to produce
# all possible outputs on the second.
# This is in effect a fast composition of single path from left
# hand side.
#
# This is a version of lookup that handles flag diacritics as epsilons
# and validates the sequences prior to outputting.
# Epsilons on the second level are represented by empty strings
# in \a results. For an example of flag diacritics, see
# #hfst::HfstTransducer::extract_paths_fd(hfst::HfstTwoLevelPaths&, int, int, bool) const
# 
#
# @pre The transducer must be of type #HFST_OL_TYPE or #HFST_OLW_TYPE.
#      This function is not implemented for other transducer types.
#
# @param s  String to look up. The weight is ignored.
# @param limit  (Currently ignored.) Number of strings to look up. 
#               -1 tries to look up all and may get stuck 
#               if infinitely ambiguous.
# \return{A pointer to a HfstOneLevelPaths container allocated by callee}
# 
# @see HfstTokenizer::tokenize_one_level
# @see is_lookup_infinitely_ambiguous(const StringVector&) const
#
# @todo Do not ignore argument \a limit.
#
# HfstOneLevelPaths * lookup_fd(const StringVector& s,
# ssize_t limit = -1) const;
 
# @brief Lookup or apply a single string \a s minding flag diacritics
# properly and store a maximum of \a limit results to \a results.
#
# This is an overloaded lookup_fd that leaves tokenizing to the
# transducer.
#
# @param s  String to look up. The weight is ignored.
# @param limit  (Currently ignored.) Number of strings to look up. 
#               -1 tries to look up all and may get stuck 
#               if infinitely ambiguous.
# \return{A pointer to a HfstOneLevelPaths container allocated by callee}
#
#
#@sa lookup_fd
# HfstOneLevelPaths * lookup_fd(const std::string& s,
# ssize_t limit = -1) const;
# 
# @brief Lookup or apply a single string \a s and store a maximum of 
# \a limit results to \a results. \a tok defined how \a s is tokenized.
#
#
# This function is the same as 
# #lookup(const StringVector&, ssize_t) const
# but lookup is not done using a string and a tokenizer instead of
# a StringVector.
# HfstOneLevelPaths * lookup(const HfstTokenizer& tok,
# const std::string &s, ssize_t limit = -1) const;
# 
# @brief Lookup or apply a single string \a s minding flag diacritics 
# properly and store a maximum of \a limit results to \a results. 
# \a tok defines how s is tokenized.
#
# The same as 
# #lookup_fd(const StringVector&, ssize_t) const 
# but uses a tokenizer and a string instead of a StringVector.
#
# HfstOneLevelPaths * lookup_fd(
# const HfstTokenizer& tok,
# const std::string &s, ssize_t limit = -1) const;
# 
# @brief (Not implemented) Lookdown a single string \a s and return 
# a maximum of \a limit results.
#
# Traverse all paths on logical second level of the transducer to produce
# all possible inputs on the first.
# This is in effect a fast composition of single
# path from left hand side.
#
# @param s  string to look down
# <!-- @param tok  tokenizer to split string in arcs? -->
# @param limit  number of strings to extract. -1 tries to extract all and
#             may get stuck if infinitely ambiguous
# @return  output parameter to store unique results
# @todo todo
# HfstOneLevelPaths * lookdown(const StringVector& s,
# ssize_t limit = -1) const;
# 
# @brief (Not implemented) Lookdown a single string minding 
# flag diacritics properly.
# 
# This is a version of lookdown that handles flag diacritics as epsilons
# and validates the sequences prior to outputting.
#
# @sa lookdown
# @todo todo
# HfstOneLevelPaths * lookdown_fd(StringVector& s,
# ssize_t limit = -1) const;
# 
# @brief Whether lookup of path \a s will have infinite results.
#
# Currently, this function will return whether the transducer
# is infinitely ambiguous on any lookup path found in the transducer,
# i.e. the argument \a s is ignored.
#
# @todo Do not ignore the argument s
# @see lookup(HfstOneLevelPaths&, const StringVector&, ssize_t) const
# bool is_lookup_infinitely_ambiguous(const StringVector& s) const;
# 
# @brief (Not implemented) Whether lookdown of path \a s will have
# infinite results.
# @todo todo
# bool is_lookdown_infinitely_ambiguous(const StringVector& s) const;









## Remove all <i>epsilon:epsilon</i> transitions from the transducer so that the resulting transducer is equivalent to the original one. 
def remove_epsilons():
    pass

## Determinize the transducer.
# 
# Determinizing a transducer yields an equivalent transducer that has
# no state with two or more transitions whose input:output symbol
# pairs are the same. 
def determinize():
    pass

## Minimize the transducer.
# 
# Minimizing a transducer yields an equivalent transducer with 
# the smallest number of states. 
# 
# @bug OpenFst's minimization algorithm seems to add epsilon transitions to weighted transducers? 
def minimize():
    pass

## Extract \a n best paths of the transducer. 
# 
# In the case of a weighted transducer (#TROPICAL_OPENFST_TYPE or 
# #LOG_OPENFST_TYPE), best paths are defined as paths with 
# the lowest weight.
# In the case of an unweighted transducer (#SFST_TYPE or #FOMA_TYPE), 
# the function returns random paths.
# 
# This function is not implemented for #FOMA_TYPE or #SFST_TYPE.
# If this function is called by an HfstTransducer of type #FOMA_TYPE 
# or #SFST_TYPE, it is converted to #TROPICAL_OPENFST_TYPE,
# paths are extracted and it is converted back to #FOMA_TYPE or 
# #SFST_TYPE. If HFST is not linked to OpenFst library, an
# ImplementationTypeNotAvailableException is thrown.
def n_best(n):
    pass

## A concatenation of N transducers where N is any number from zero to infinity. 
def repeat_star():
    pass
 
## A concatenation of N transducers where N is any number from one to infinity. 
def repeat_plus():
    pass

## A concatenation of \a n transducers. 
def repeat_n(unsigned int n):
    pass

## A concatenation of N transducers where N is any number from zero to \a n, inclusive.
def repeat_n_minus(n):
    pass
 
## A concatenation of N transducers where N is any number from \a n to infinity, inclusive.
def repeat_n_plus(n):
    pass
 
## A concatenation of N transducers where N is any number from \a n to \a k, inclusive.
def repeat_n_to_k(n, k):
    pass

## Disjunct the transducer with an epsilon transducer. 
def optionalize():
    pass

## Swap the input and output symbols of each transition in the transducer. 
def invert():
    pass

## Reverse the transducer. 
# 
# A reverted transducer accepts the string "n(0) n(1) ... n(N)" 
# iff the original
# transducer accepts the string "n(N) n(N-1) ... n(0)" 
def reverse():
    pass
 
## Extract the input language of the transducer. 
# 
# All transition symbol pairs <i>isymbol:osymbol</i> are changed 
# to <i>isymbol:isymbol</i>. 
def input_project():
    pass
 
## Extract the output language of the transducer.
# 
# All transition symbol pairs <i>isymbol:osymbol</i> are changed 
# to <i>osymbol:osymbol</i>. 
def output_project():
    pass

## Compose this transducer with \a another. 
def compose(another):
    pass

## Compose this transducer with the intersection of
# transducers in \a v. If \a invert is true, then compose the
# intersection of the transducers in \a v with this transducer.
# 
# The algorithm used by this function is faster than intersecting 
# all transducers one by one and then composing this transducer 
# with the intersection. 
# 
# @pre The transducers in \a v are deterministic and epsilon-free.
# @param v A tuple of transducers.
def compose_intersect(v, invert=False):
    pass

## Concatenate this transducer with \a another. 
def concatenate(another):
    pass

## Disjunct this transducer with \a another. 
def disjunct(another):
    pass












## Make priority union of this transducer with \a another.
# *
# * For the operation t1.priority_union(t2), the result is a union of t1 and t2,
# * except that whenever t1 and t2 have the same string on left side,
# * the path in t2 overrides the path in t1.
# *
# * Example
# *
# * Transducer 1 (t1):
# * a : a
# * b : b
# *
# * Transducer 2 (t2):
# * b : B
# * c : C
# *
# * Result ( t1.priority_union(t2) ):
# * a : a
# * b : B
# * c : C
# *
# * For more information, read: www.fsmbook.com
# *  
def priority_union(const HfstTransducer &another)
# 
# 
# /*
# *  \brief Make cross product of this transducer with \a.
# *  It pairs every string of this with every string of \a.
# *
# *  Both transducers must be automata, i.e. map strings onto themselves.
# *
# *  If strings are not the same length, epsilon padding will be added in the end of the shorter string.
# *
# 
def cross_product(const HfstTransducer &another)
# 
# 
# /*
# *  \brief Shuffle this transducer with transducer \@ another.
# *
# *  If transducer A accepts string "foo" and transducer B string "bar",
# *  the transducer that results from shuffling A and B accepts all strings
# *  [(f|b)(o|a)(o|r)].
# *  
# *  @pre Both transducers must be automata, i.e. map strings onto themselves.
# *
# 
def shuffle(const HfstTransducer &another)
# 
## Create universal pair transducer of \a type.
# *
# *  The transducer has only one state, and it accepts:
# *  Identity:Identity, Unknown:Unknown, Unknown:Epsilon and Epsilon:Unknown
# *
# *  Transducer weight is 0.
# 
# static HfstTransducer universal_pair ( ImplementationType type )
# 
## Create identity pair transducer of \a type.
# *
# * The transducer has only one state, and it accepts:
# * Identity:Identity
# *
# * Transducer weight is 0.
# 
# static HfstTransducer identity_pair ( ImplementationType type )
# 
# 
# 
# 
# 
# /* For HfstCompiler: Optimized disjunction function. 
def disjunct(const StringPairVector &spv)
# 
## Intersect this transducer with \a another. 
def intersect(const HfstTransducer &another)
# 
## Subtract transducer \a another from this transducer. 
def subtract(const HfstTransducer &another)
# 
# 
# // ------------------------------------------------
# // ---------- Insertion and substitution ----------
# // ------------------------------------------------
# 
## Freely insert symbol pair \a symbol_pair into the transducer. 
# 
# To each state in this transducer is added a transition that 
# leads from that state to itself with input and output symbols 
# defined by \a symbol_pair.
# 
def insert_freely(const StringPair &symbol_pair)
# 
## Freely insert a copy of \a tr into the transducer. 
# 
# A copy of \a tr is attached with epsilon transitions 
# to each state of this transducer. After the operation, for each 
# state S in this transducer, there is an epsilon transition 
# that leads from state S to the initial state of \a tr, 
# and for each final state of \a tr, there is an epsilon transition
# that leads from that final state to state S in this transducer.
# The weights of the final states in \a tr are copied to the 
# epsilon transitions leading to state S.
# 
# Implemented only for implementations::HfstBasicTransducer. 
# Conversion is carried out for an HfstTransducer, if this function
# is called.
# 
def insert_freely(const HfstTransducer &tr)
# 
## Substitute all transition \a sp with transitions \a sps 
# as defined by function \a func. 
# 
# @param func A pointer to a function that takes as its argument
# a StringPair sp and inserts to StringPairSet sps all StringPairs
# with which sp is to be substituted. Returns whether any substituting
# string pairs were inserted in sps, i.e. whether there is a need to
# perform substitution on transition sp.
# 
# An example:
# \verbatim
# bool function(const StringPair &sp, StringPairSet &sps) 
# {
# if (sp.second.compare(sp.first) != 0)
# return false;
# 
# std::string isymbol = sp.first;
# std::string osymbol;
# 
# if (sp.second.compare("a") == 0 ||
# sp.second.compare("o") == 0 ||
# sp.second.compare("u") == 0)
# osymbol = std::string("<back_wovel>")
# if (sp.second.compare("e") == 0 ||
# sp.second.compare("i") == 0)
# osymbol = std::string("<front_wovel>")
# 
# sps.insert(StringPair(isymbol, osymbol))
# return true;
# }
# 
# ...
# 
# # For all transitions in transducer t whose input and output wovels 
# # are equivalent, substitute the output wovel with a symbol that defines
# # whether the wovel in question is a front or back wovel.
# t.substitute(&function)
# \endverbatim               
# 
# @see String
# 
def substitute
# (bool (*func)(const StringPair &sp, StringPairSet &sps))
# 
## Substitute all transition symbols equal to \a old_symbol 
# with symbol \a new_symbol.
# \a input_side and \a output_side define whether 
# the substitution is made on input and output sides.
# 
# @param old_symbol Symbol to be substituted.
# @param new_symbol The substituting symbol.
# @param input_side Whether the substitution is made on the input side
# of a transition.
# @param output_side Whether the substitution is made on the output side
# of a transition.
# 
# The transition weights remain the same. 
# 
# @see String 
def substitute(const std::string &old_symbol,
# const std::string &new_symbol,
# bool input_side=true,
# bool output_side=true)
# 
## Substitute all transition symbol pairs equal to 
# \a old_symbol_pair with \a new_symbol_pair. 
# 
# The transition weights remain the same.
# 
# Implemented only for #TROPICAL_OPENFST_TYPE and #LOG_OPENFST_TYPE.
# If this function is called by an unweighted HfstTransducer, 
# it is converted to a weighted one,
# substitution is made and the transducer is converted back 
# to the original format.
# 
# @see String
# 
def substitute(const StringPair &old_symbol_pair,
# const StringPair &new_symbol_pair)
# 
## Substitute all transitions equal to \a old_symbol_pair 
# with a set of transitions equal to \a new_symbol_pair_set. 
# 
# The weight of the original transition is copied to all new transitions.
# 
# Implemented only for #TROPICAL_OPENFST_TYPE and #LOG_OPENFST_TYPE.
# If this function is called by an unweighted HfstTransducer 
# (#SFST_TYPE or #FOMA_TYPE), it is converted to #TROPICAL_OPENFST_TYPE,
# substitution is done and it is converted back to the original format.
# 
# @see String
# 
def substitute(const StringPair &old_symbol_pair,
# const StringPairSet &new_symbol_pair_set)
# 
## Substitute all transition symbols as defined in \a substitutions.
# 
# Each symbol old_symbol is substituted with symbol new_symbol, iff 
# substitutions.find(old_symbol) == new_symbol != substitutions.end(). 
# Otherwise, old_symbol remains the same.
# 
# This function performs all substitutions at the same time, so it is
# more efficient than calling substitute separately for each substitution.
# 
def substitute(const HfstSymbolSubstitutions &substitutions)
# 
def substitute_symbols(const HfstSymbolSubstitutions &substitutions)
# 
## Substitute all transition symbol pairs as defined in \a substitutions.
# 
# Each symbol pair old_isymbol:old_osymbol is substituted with symbol pair
# new_isymbol:new_osymbol, iff substitutions.find(old_isymbol:old_osymbol) == 
# new_isymbol:new_osymbol != substitutions.end(). 
# Otherwise, old_isymbol:old_osymbol remains the same.
# 
# This function performs all substitutions at the same time, so it is
# more efficient than calling substitute separately for each substitution.
# 
def substitute(const HfstSymbolPairSubstitutions &substitutions)
# 
def substitute_symbol_pairs(const HfstSymbolPairSubstitutions &substitutions)
# 
## Substitute all transitions equal to \a symbol_pair 
# with a copy of transducer \a transducer. 
# 
# A copy of \a transducer is attached (using epsilon transitions) 
# between the source and target states of the transition 
# to be substituted.
# The weight of the original transition is copied to 
# the epsilon transition leaving from the source state.
# 
# Implemented only for #TROPICAL_OPENFST_TYPE and #LOG_OPENFST_TYPE.
# If this function is called by an unweighted HfstTransducer 
# (#SFST_TYPE or #FOMA_TYPE), it is converted to #TROPICAL_OPENFST_TYPE,
# substitution is done and it is converted back to the original format.
# 
# @see String
# 
def substitute(const StringPair &symbol_pair,
# HfstTransducer &transducer)
# 
# 
# // -----------------------------------------------
# // --------------- Weight handling --------------- 
# // -----------------------------------------------
# 
## Set the weights of all final states to \a weight. 
# 
# If the HfstTransducer is of unweighted type 
# (#SFST_TYPE or #FOMA_TYPE), nothing is done.
# 
def set_final_weights(float weight)
# 
## Transform all transition and state weights as defined 
# in \a func. 
# 
# @param func A pointer to a function that takes a weight as its
# argument and returns a weight that will be the new
# value of the weight given as the argument.
# 
# An example:
# \verbatim
# float func(float f) { 
# return 2*f + 0.5; 
# }
# 
# ...
# 
# # All transition and final weights are multiplied by two and summed with 0.5.
# transducer.transform_weights(&func)
# \endverbatim 
# 
# If the HfstTransducer is of unweighted type 
# (#SFST_TYPE or #FOMA_TYPE), nothing is done.
# 
def transform_weights(float (*func)(float))
# 
## Push weights towards initial or final state(s) 
# as defined by \a type.
# 
# If the HfstTransducer is of unweighted type 
# (#SFST_TYPE or #FOMA_TYPE), nothing is done.
# @see PushType
# 
def push_weights(PushType type)
# 
# 
## Compile a lexc file in file \a filename into an HfstTransducer
# of type \a type and return the transducer. 
# static HfstTransducer * read_lexc(const std::string &filename,
# ImplementationType type)
# 
# // *** For commandline programs. ***
# 
# /* For each flag diacritic fd that is included in the alphabet of
# transducer \a another but not in the alphabet of this transducer,
# insert freely a transition fd:fd in this transducer. 
# void insert_freely_missing_flags_from
# (const HfstTransducer &another)
# 
# /*
# If both \a this and \a another contain flag diacritics, replace flag
# diacritic @X.Y.(.Z)@ by @X.Y_1(.Z)@ in \a this and replace it by
# @X.Y_2(.Z)@ in \a another. 
# 
# If \a insert_renamed_flags is true, then the flags from \a this are 
# inserted freely in \a another and vice versa after replacing.
# 
# void harmonize_flag_diacritics(HfstTransducer &another,
# bool insert_renamed_flags=true)
# 
# /* Whether the alphabet of transducer \a another includes flag diacritics
# that are not included in the alphabet of this transducer. 
# bool check_for_missing_flags_in(const HfstTransducer &another) const;
# 
# /* Return true if \a this has flag diacritics in the alphabet. 
# bool has_flag_diacritics(void) const;
# 
# // *** Friends **** //
# 
# friend std::ostream& operator<<(std::ostream &out, const HfstTransducer &t)
# friend std::ostream& redirect(std::ostream &out, const HfstTransducer &t)
# friend class HfstInputStream;
# friend class HfstOutputStream;
# friend class hfst::implementations::HfstTransitionGraph<class C>;
# friend class HfstCompiler;
# friend class hfst::implementations::ConversionFunctions;
# friend class HfstGrammar;
# };
# 
## Write transducer \a t in AT&T format to ostream \a out.
# 
# The same as 
# #hfst::HfstTransducer::write_in_att_format(FILE*, bool) const 
# with ostreams. Weights are written if the type of \a t is weighted. 
# std::ostream &operator<<(std::ostream &out,const HfstTransducer &t)
# 
# std::ostream &redirect(std::ostream &out,const HfstTransducer &t)
# 
## A namespace for functions that create two-level, replace, 
# restriction and coercion rule transducers. 
# namespace rules
# {
# enum ReplaceType {REPL_UP, REPL_DOWN, REPL_RIGHT, REPL_LEFT,
# REPL_DOWN_KARTTUNEN};
# enum TwolType {twol_right, twol_left, twol_both};
# 
# /* helping methods 
# HfstTransducer universal_fst
# (const StringPairSet &alphabet, ImplementationType type)
# HfstTransducer negation_fst
# (const HfstTransducer &t, const StringPairSet &alphabet)
# 
# HfstTransducer replace
# (HfstTransducer &t, ReplaceType repl_type, bool optional, 
# StringPairSet &alphabet)
# HfstTransducer replace_transducer
# (HfstTransducer &t, std::string lm, std::string rm, 
# ReplaceType repl_type, StringPairSet &alphabet)
# HfstTransducer replace_context
# (HfstTransducer &t, std::string m1, std::string m2, 
# StringPairSet &alphabet)
# HfstTransducer replace_in_context
# (HfstTransducerPair &context, ReplaceType repl_type, 
# HfstTransducer &t, bool optional, StringPairSet &alphabet)
# 
# /* Used by hfst-calculate. 
# HfstTransducer restriction
# (HfstTransducerPairVector &contexts, HfstTransducer &mapping, 
# StringPairSet &alphabet,        TwolType twol_type, int direction ) 
# 
# 
# 
# // ***** THE PUBLIC INTERFACE *****
# 
## A transducer that obligatorily performs the mappings 
# defined by \a mappings in the context \a context
# when the alphabet is \a alphabet. 
# 
# @param context A pair of transducers where the first transducer
# defines the left context and the second transducer
# the right context.
# @param mappings A set of mappings that the resulting transducer
# will perform in the context given in \a context.
# @param alphabet The set of symbol pairs that defines the alphabet
# (see the example).
# 
# For example, a transducer yielded by the following arguments
# \verbatim
# context = pair( [c|d], [e] )
# mappings = set(a:b)
# alphabet = set(a, a:b, b, c, d, e, ...)
# \endverbatim
# obligatorily maps the symbol a to b if c or d precedes 
# and e follows. (Elsewhere,
# the mapping of a to b is optional)
# This expression is identical to ![.* [c|d] [a:. & !a:b] [e] .*]
# Note that the alphabet must contain the pair a:b here.
# 
# @see
# <a href="ftp://ftp.ims.uni-stuttgart.de/pub/corpora/SFST/SFST-Manual.pdf">
# SFST manual</a>
# 
# HfstTransducer two_level_if(HfstTransducerPair &context, 
# StringPairSet &mappings, 
# StringPairSet &alphabet)
# 
## A transducer that allows the mappings defined by 
# \a mappings only in the context \a context,
# when the alphabet is \a alphabet. 
# 
# If called with the same arguments as in the example of 
# #two_level_if, the transducer
# allows the mapping of symbol a to b only if c or d precedes 
# and e follows. The
# mapping of a to b is optional in this context but cannot occur 
# in any other context.
# The expression is equivalent to 
# ![  [ ![.* [c|d]] a:b .* ] | [ .* a:b ![[e] .*] ]  ]
# 
# @see #two_level_if
# 
# HfstTransducer two_level_only_if(HfstTransducerPair &context, 
# StringPairSet &mappings, 
# StringPairSet &alphabet)
# 
## A transducer that always performs the mappings defined 
# by \a mappings in the context \a context
# and only in that context, when the alphabet is \a alphabet. 
# 
# If called with the same arguments as in the example of 
# #two_level_if, the transducer
# maps symbol a to b only and only if c or d precedes and e follows.
# The mapping of a to b is obligatory in this context and cannot 
# occur in any other context.
# The expression is equivalent to ![.* [c|d] [a:. & !a:b] [e] .*]  &
# ![  [ ![.* [c|d]] a:b .* ] | [ .* a:b ![[e] .*] ]  ]
# 
# @see #two_level_if
# 
# HfstTransducer two_level_if_and_only_if(HfstTransducerPair &context, 
# StringPairSet &mappings, 
# StringPairSet &alphabet)
# 
# 
## A transducer that performs an upward mapping \a mapping 
# in the context \a context when the alphabet is \a alphabet.
# \a optional defines whether the mapping is optional. 
# 
# @param context A pair of transducers where the first transducer
# defines the left context and the second transducer
# the right context. Both transducers must be automata,
# i.e. map strings onto themselves.
# @param mapping The mapping that the resulting transducer
# will perform in the context given in \a context.
# @param optional Whether the mapping is optional.
# @param alphabet The set of symbol pairs that defines the alphabet
# (see the explanation below).
# 
# Each substring s of the input string which is in the input language
# of the transducer \a mapping and whose left context is matched 
# by the expression
# [.* l] (where l is the first element of \a context) and 
# whose right context is matched by [r .*] 
# (where r is the second element in the context) is mapped 
# to the respective
# surface strings defined by transducer \a mapping. Any other 
# character is mapped to
# the characters specified in \a alphabet. The left and right 
# contexts must
# be automata (i.e. transducers which map strings onto themselves).
# 
# For example, a transducer yielded by the following arguments
# \verbatim
# context = pair( [c], [c] )
# mappings = [ a:b a:b ]
# alphabet = set(a, b, c)
# \endverbatim
# would map the string "caacac" to "cbbcac".
# 
# Note that the alphabet must contain the characters a and b, 
# but not the pair
# a:b (unless this replacement is to be allowed everywhere 
# in the context).
# 
# Note that replace operations (unlike the two-level rules) 
# have to be combined by composition
# rather than intersection.
# 
# @throws ContextTransducersAreNotAutomataException
# 
# @see
# <a href="ftp://ftp.ims.uni-stuttgart.de/pub/corpora/SFST/SFST-Manual.pdf">
# SFST manual</a>
# 
# HfstTransducer replace_up(HfstTransducerPair &context, 
# HfstTransducer &mapping, 
# bool optional, 
# StringPairSet &alphabet)
# 
## The same as replace_up, but matching is done on 
# the output side of \a mapping 
# 
# @see replace_up 
# <a href="ftp://ftp.ims.uni-stuttgart.de/pub/corpora/SFST/SFST-Manual.pdf">
# SFST manual</a>. 
# HfstTransducer replace_down(HfstTransducerPair &context, 
# HfstTransducer &mapping, 
# bool optional, 
# StringPairSet &alphabet)
# 
# HfstTransducer replace_down_karttunen(HfstTransducerPair &context, 
# HfstTransducer &mapping, 
# bool optional, 
# StringPairSet &alphabet)
# 
## The same as replace_up, but left context matching is 
# done on the output side of \a mapping
# and right context on the input side of \a mapping 
# 
# @see replace_up 
# <a href="ftp://ftp.ims.uni-stuttgart.de/pub/corpora/SFST/SFST-Manual.pdf">
# SFST manual</a>. 
# HfstTransducer replace_right(HfstTransducerPair &context, 
# HfstTransducer &mapping, 
# bool optional, 
# StringPairSet &alphabet)
# 
## The same as replace_up, but left context matching is 
# done on the input side of \a mapping
# and right context on the output side of \a mapping. 
# 
# @see replace_up 
# <a href="ftp://ftp.ims.uni-stuttgart.de/pub/corpora/SFST/SFST-Manual.pdf">
# SFST manual</a>. 
# HfstTransducer replace_left(HfstTransducerPair &context, 
# HfstTransducer &mapping, 
# bool optional, 
# StringPairSet &alphabet)
# 
# 
## The same as replace_up but \a mapping is performed 
# in every context. 
# 
# @see replace_up 
# HfstTransducer replace_up(HfstTransducer &mapping, 
# bool optional, 
# StringPairSet &alphabet)
# 
## The same as replace_down(HfstTransducerPair&, HfstTransducer&, bool, StringPairSet&)
# but \a mapping is performed in every context.
# 
# @see replace_up 
# HfstTransducer replace_down(HfstTransducer &mapping, 
# bool optional, 
# StringPairSet &alphabet)
# 
## Inversion of the replace_up and the result needs to be composed on the upper side
# *   of the input language.
# *
# *   B <- A is the inversion of A -> B.
# *
# *   \a Mapping is performed in every context.
# *
# *   @see replace_up 
# HfstTransducer left_replace_up(     HfstTransducer          &mapping,
# bool                optional,
# StringPairSet       &alphabet)
# 
## Inversion of the replace_up and the result needs to be composed on the upper side
# *   of the input language.
# *
# *   B <- A is the inversion of A -> B.
# *
# *   @see replace_up 
# HfstTransducer left_replace_up( HfstTransducerPair  &context,
# HfstTransducer      &mapping,
# bool                optional,
# StringPairSet       &alphabet)
## Inversion of the replace_up and the result needs to be composed on the upper side
# *   of the input language. However, matching is done on the output side of \a mapping
# *
# *   @see replace_up 
# HfstTransducer left_replace_down(HfstTransducerPair &context,
# HfstTransducer         &mapping,
# bool                           optional,
# StringPairSet          &alphabet)
# 
## Inversion of the replace_up and the result needs to be composed on the upper side
# *         of the input language. However, matching is done on the output side of \a mapping
# *
# *         @see replace_up 
# HfstTransducer left_replace_down_karttunen( HfstTransducerPair      &context,
# HfstTransducer          &mapping,
# bool                            optional,
# StringPairSet           &alphabet)
# 
## Inversion of the replace_up and the result needs to be composed on the upper side
# *   of the input language. However, left context matching is done on the input side of \a mapping
# *   and right context on the output side of \a mapping.
# *
# *   @see replace_up 
# HfstTransducer left_replace_left(HfstTransducerPair &context,
# HfstTransducer         &mapping,
# bool                           optional,
# StringPairSet          &alphabet)
# 
## Inversion of the replace_up and the result needs to be composed on the upper side
# *   of the input language. However, left context matching is done on the output side of \a mapping
# *   and right context on the input side of \a mapping.
# *
# *   @see replace_up 
# HfstTransducer left_replace_right(HfstTransducerPair        &context,
# HfstTransducer                &mapping,
# bool                          optional,
# StringPairSet         &alphabet)
# 
# 
# 
# 
# 
## A transducer that allows any (substring) mapping defined 
# by \a mapping
# only if it occurs in any of the contexts in \a contexts. 
# Symbols outside of the matching
# substrings are mapped to any symbol allowed by \a alphabet. 
# 
# @throws EmptySetOfContextsException
# 
# @see
# <a href="ftp://ftp.ims.uni-stuttgart.de/pub/corpora/SFST/SFST-Manual.pdf">
# SFST manual</a>. 
# HfstTransducer restriction(HfstTransducerPairVector &contexts, 
# HfstTransducer &mapping, 
# StringPairSet &alphabet)
# 
## A transducer that requires that one of the mappings 
# defined by \a mapping
# must occur in each context in \a contexts. Symbols outside of 
# the matching
# substrings are mapped to any symbol allowed by \a alphabet.
# 
# @see
# <a href="ftp://ftp.ims.uni-stuttgart.de/pub/corpora/SFST/SFST-Manual.pdf">
# SFST manual</a>. 
# HfstTransducer coercion(HfstTransducerPairVector &contexts, 
# HfstTransducer &mapping, 
# StringPairSet &alphabet)
# 
## A transducer that is equivalent to the intersection 
# of restriction and coercion
# and requires that the mappings defined by \a mapping occur 
# always and only in the
# given contexts in \a contexts. Symbols outside of the matching
# substrings are mapped to any symbol allowed by \a alphabet.
# 
# @see
# restriction(HfstTransducerPairVector&, HfstTransducer&, StringPairSet&) 
# #coercion 
# <a href="ftp://ftp.ims.uni-stuttgart.de/pub/corpora/SFST/SFST-Manual.pdf">
# SFST manual</a> 
# HfstTransducer restriction_and_coercion(HfstTransducerPairVector &contexts,
# HfstTransducer &mapping, 
# StringPairSet &alphabet)
# 
## A transducer that specifies that a string from 
# the input language of the
# transducer \a mapping may only be mapped to one of its 
# output strings (according
# to transducer \a mapping) if it appears in any of the contexts 
# in \a contexts.
# Symbols outside of the matching substrings are mapped
# to any symbol allowed by \a alphabet.
# 
# @see
# <a href="ftp://ftp.ims.uni-stuttgart.de/pub/corpora/SFST/SFST-Manual.pdf">
# SFST manual</a>. 
# HfstTransducer surface_restriction(HfstTransducerPairVector &contexts, 
# HfstTransducer &mapping, 
# StringPairSet &alphabet)
# 
## A transducer that specifies that a string from 
# the input language of the transducer
# \a mapping always has to the mapped to one of its output 
# strings according to
# transducer \a mapping if it appears in any of the contexts 
# in \a contexts.
# Symbols outside of the matching substrings are mapped to 
# any symbol allowed by \a alphabet.
# 
# @see
# <a href="ftp://ftp.ims.uni-stuttgart.de/pub/corpora/SFST/SFST-Manual.pdf">
# SFST manual</a>. 
# HfstTransducer surface_coercion(HfstTransducerPairVector &contexts, 
# HfstTransducer &mapping, 
# StringPairSet &alphabet)
# 
## A transducer that is equivalent to the intersection of 
# surface_restriction and surface_coercion.
# 
# @see #surface_restriction #surface_coercion 
# <a href="ftp://ftp.ims.uni-stuttgart.de/pub/corpora/SFST/SFST-Manual.pdf">
# SFST manual</a>. 
# HfstTransducer surface_restriction_and_coercion
# (HfstTransducerPairVector &contexts, 
# HfstTransducer &mapping, 
# StringPairSet &alphabet)
# 
## A transducer that specifies that a string from 
# the output language of the transducer
# \a mapping may only be mapped to one of its input strings 
# (according to transducer \a mappings)
# if it appears in any of the contexts in \a contexts.
# Symbols outside of the matching substrings are mapped 
# to any symbol allowed by \a alphabet.
# 
# @see
# <a href="ftp://ftp.ims.uni-stuttgart.de/pub/corpora/SFST/SFST-Manual.pdf">
# SFST manual</a>. 
# HfstTransducer deep_restriction(HfstTransducerPairVector &contexts, 
# HfstTransducer &mapping, 
# StringPairSet &alphabet)
# 
## A transducer that specifies that a string from 
# the output language of the transducer
# \a mapping always has to be mapped to one of its input strings 
# (according to transducer \a mappings)
# if it appears in any of the contexts in \a contexts.
# Symbols outside of the matching substrings are mapped 
# to any symbol allowed by \a alphabet.
# 
# @see
# <a href="ftp://ftp.ims.uni-stuttgart.de/pub/corpora/SFST/SFST-Manual.pdf">
# SFST manual</a>. 
# HfstTransducer deep_coercion(HfstTransducerPairVector &contexts, 
# HfstTransducer &mapping, 
# StringPairSet &alphabet)
# 
## A transducer that is equivalent to the intersection 
# of deep_restriction and deep_coercion.
# 
# @see #deep_restriction #deep_coercion 
# <a href="ftp://ftp.ims.uni-stuttgart.de/pub/corpora/SFST/SFST-Manual.pdf">
# SFST manual</a>. 
# HfstTransducer deep_restriction_and_coercion
# (HfstTransducerPairVector &contexts, 
# HfstTransducer &mapping, 
# StringPairSet &alphabet)
