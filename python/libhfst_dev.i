// Copyright (c) 2016 University of Helsinki
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 3 of the License, or (at your option) any later version.
// See the file COPYING included with this distribution for more
// information.

// This is a swig interface file that is used to create python bindings for HFST.
// Everything will be visible under module 'libhfst', but will be wrapped under
// package 'hfst' and its subpackages 'hfst.exceptions' and 'hfst.rules' (see
// folder 'hfst' in the current directory).

%module libhfst_dev
// Needed for type conversions between c++ and python.
%include "std_string.i"
%include "std_vector.i"
%include "std_pair.i"
%include "std_set.i"
%include "std_map.i"
%include "exception.i"

// We want warnings to be printed to standard error.
%init %{
    hfst::set_warning_stream(&std::cerr);
%}

// Make swig aware of what hfst offers.
%{
#define HFSTIMPORT
#include "HfstDataTypes.h"
#include "HfstTransducer.h"
#include "HfstOutputStream.h"
#include "HfstInputStream.h"
#include "HfstExceptionDefs.h"
#include "HfstTokenizer.h"
#include "HfstFlagDiacritics.h"
#include "HfstXeroxRules.h"
#include "HfstPrintDot.h"
#include "parsers/XreCompiler.h"
#include "parsers/LexcCompiler.h"
#include "parsers/XfstCompiler.h"
#include "parsers/SfstCompiler.h"
#include "implementations/HfstTransition.h"
#include "implementations/HfstIterableTransducer.h"
#include "implementations/optimized-lookup/pmatch.h"
#include "implementations/optimized-lookup/pmatch_tokenize.h"
#include "parsers/TwolcCompiler.h"
namespace hfst { typedef std::vector<hfst::xeroxRules::Rule> HfstRuleVector; }
namespace hfst { typedef std::pair<hfst::HfstTransducer*,unsigned int> HfstTransducerUIntPair; }

// Most of C++ extension code is located in separate files.
#include "hfst_extensions.cpp"
#include "hfst_pmatch_extensions.cpp"
#include "hfst_pmatch_tokenize_extensions.cpp"
#include "hfst_sfst_extensions.cpp"
#include "hfst_lookup_extensions.cpp"
#include "hfst_rules_extensions.cpp"
#include "hfst_prolog_extensions.cpp"
%}

#ifdef _MSC_VER
%include <windows.h>
#endif

// Contains docstrings for functions and classes that are generated
// from c++ by swig.
%include "docstrings.i"
// Extra code written with python is documented in this file.

// Templates needed for conversion between c++ and python datatypes.
//
// Note that templating order matters; simple templates used as part of
// more complex templates must be defined first, e.g. StringPair must be
// defined before StringPairSet. Also templates that are not used as such
// but are used as part of other templates must be defined.

%include "typemaps.i"

namespace std {
%template(StringVector) vector<string>;
%template(StringPair) pair<string, string>;
%template(StringPairVector) vector<pair<string, string > >;
%template(FloatVector) vector<float>;
%template(StringSet) set<string>;
%template(StringPairSet) set<pair<string, string> >;
%template(HfstTransducerVector) vector<hfst::HfstTransducer>;
%template(HfstSymbolSubstitutions) map<string, string>;
%template(HfstSymbolPairSubstitutions) map<pair<string, string>, pair<string, string> >;
// needed for HfstIterableTransducer.states()
%template(UIntVector) vector<unsigned int>;
%template(HfstTransitions) vector<hfst::implementations::HfstTransition>;
%template(HfstOneLevelPath) pair<float, vector<string> >;
%template(HfstOneLevelPaths) set<pair<float, vector<string> > >;
%template(HfstTwoLevelPath) pair<float, vector<pair<string, string > > >;
%template(HfstTwoLevelPaths) set<pair<float, vector<pair<string, string > > > >;
%template(HfstTransducerPair) pair<hfst::HfstTransducer, hfst::HfstTransducer>;
%template(HfstTransducerPairVector) vector<pair<hfst::HfstTransducer, hfst::HfstTransducer> >;
%template(HfstRuleVector) vector<hfst::xeroxRules::Rule>;
%template(HfstTransducerUIntPair) pair<hfst::HfstTransducer*,unsigned int>;
%template(LocationVector) vector<hfst_ol::Location>;
%template(LocationVectorVector) vector<vector<hfst_ol::Location> >;
%template(HfstTransducerStringPair) pair<hfst::HfstTransducer*,string>;
}


// ****************************************************** //
// ********** WHAT IS MADE AVAILABLE ON PYTHON ********** //
// ****************************************************** //

// *** HfstException and its subclasses (will be wrapped under module hfst.exceptions). *** //

class HfstException
{
  public:
    HfstException();
    HfstException(const std::string&, const std::string&, size_t);
    ~HfstException();
    std::string what() const;
%extend{
    char *__str__() {
      return strdup($self->what().c_str());
    }
}
};

class HfstTransducerTypeMismatchException : public HfstException { public: HfstTransducerTypeMismatchException(const std::string&, const std::string&, size_t); ~HfstTransducerTypeMismatchException(); std::string what() const; };
class ImplementationTypeNotAvailableException : public HfstException { public: ImplementationTypeNotAvailableException(const std::string&, const std::string&, size_t, hfst::ImplementationType type); ~ImplementationTypeNotAvailableException(); std::string what() const; hfst::ImplementationType get_type() const; };
class FunctionNotImplementedException : public HfstException { public: FunctionNotImplementedException(const std::string&, const std::string&, size_t); ~FunctionNotImplementedException(); std::string what() const; };
class StreamNotReadableException : public HfstException { public: StreamNotReadableException(const std::string&, const std::string&, size_t); ~StreamNotReadableException(); std::string what() const; };
class StreamCannotBeWrittenException : public HfstException { public: StreamCannotBeWrittenException(const std::string&, const std::string&, size_t); ~StreamCannotBeWrittenException(); std::string what() const; };
class StreamIsClosedException : public HfstException { public: StreamIsClosedException(const std::string&, const std::string&, size_t); ~StreamIsClosedException(); std::string what() const; };
class EndOfStreamException : public HfstException { public: EndOfStreamException(const std::string&, const std::string&, size_t); ~EndOfStreamException(); std::string what() const; };
class TransducerIsCyclicException : public HfstException { public: TransducerIsCyclicException(const std::string&, const std::string&, size_t); ~TransducerIsCyclicException(); std::string what() const; };
class NotTransducerStreamException : public HfstException { public: NotTransducerStreamException(const std::string&, const std::string&, size_t); ~NotTransducerStreamException(); std::string what() const; };
class NotValidAttFormatException : public HfstException { public: NotValidAttFormatException(const std::string&, const std::string&, size_t); ~NotValidAttFormatException(); std::string what() const; };
class NotValidPrologFormatException : public HfstException { public: NotValidPrologFormatException(const std::string&, const std::string&, size_t); ~NotValidPrologFormatException(); std::string what() const; };
class NotValidLexcFormatException : public HfstException { public: NotValidLexcFormatException(const std::string&, const std::string&, size_t); ~NotValidLexcFormatException(); std::string what() const; };
class StateIsNotFinalException : public HfstException { public: StateIsNotFinalException(const std::string&, const std::string&, size_t); ~StateIsNotFinalException(); std::string what() const; };
class ContextTransducersAreNotAutomataException : public HfstException { public: ContextTransducersAreNotAutomataException(const std::string&, const std::string&, size_t); ~ContextTransducersAreNotAutomataException(); std::string what() const; };
class TransducersAreNotAutomataException : public HfstException { public: TransducersAreNotAutomataException(const std::string&, const std::string&, size_t); ~TransducersAreNotAutomataException(); std::string what() const; };
class StateIndexOutOfBoundsException : public HfstException { public: StateIndexOutOfBoundsException(const std::string&, const std::string&, size_t); ~StateIndexOutOfBoundsException(); std::string what() const; };
class TransducerHeaderException : public HfstException { public: TransducerHeaderException(const std::string&, const std::string&, size_t); ~TransducerHeaderException(); std::string what() const; };
class MissingOpenFstInputSymbolTableException : public HfstException { public: MissingOpenFstInputSymbolTableException(const std::string&, const std::string&, size_t); ~MissingOpenFstInputSymbolTableException(); std::string what() const; };
class TransducerTypeMismatchException : public HfstException { public: TransducerTypeMismatchException(const std::string&, const std::string&, size_t); ~TransducerTypeMismatchException(); std::string what() const; };
class EmptySetOfContextsException : public HfstException { public: EmptySetOfContextsException(const std::string&, const std::string&, size_t); ~EmptySetOfContextsException(); std::string what() const; };
class SpecifiedTypeRequiredException : public HfstException { public: SpecifiedTypeRequiredException(const std::string&, const std::string&, size_t); ~SpecifiedTypeRequiredException(); std::string what() const; };
class HfstFatalException : public HfstException { public: HfstFatalException(const std::string&, const std::string&, size_t); ~HfstFatalException(); std::string what() const; };
class TransducerHasWrongTypeException : public HfstException { public: TransducerHasWrongTypeException(const std::string&, const std::string&, size_t); ~TransducerHasWrongTypeException(); std::string what() const; };
class IncorrectUtf8CodingException : public HfstException { public: IncorrectUtf8CodingException(const std::string&, const std::string&, size_t); ~IncorrectUtf8CodingException(); std::string what() const; };
class EmptyStringException : public HfstException { public: EmptyStringException(const std::string&, const std::string&, size_t); ~EmptyStringException(); std::string what() const; };
class SymbolNotFoundException : public HfstException { public: SymbolNotFoundException(const std::string&, const std::string&, size_t); ~SymbolNotFoundException(); std::string what() const; };
class MetadataException : public HfstException { public: MetadataException(const std::string&, const std::string&, size_t); ~MetadataException(); std::string what() const; };
class FlagDiacriticsAreNotIdentitiesException : public HfstException { public: FlagDiacriticsAreNotIdentitiesException(const std::string&, const std::string&, size_t); ~FlagDiacriticsAreNotIdentitiesException(); std::string what() const; };


namespace hfst_ol
{

  struct Location
  {
    unsigned int start;
    unsigned int length;
    std::string input;
    std::string output;
    std::string tag;
    float weight;
    std::vector<size_t> input_parts; // indices in input_symbol_strings
    std::vector<size_t> output_parts; // indices in output_symbol_strings
    std::vector<std::string> input_symbol_strings;
    std::vector<std::string> output_symbol_strings;

    //bool operator<(Location rhs) const
    //{ return this->weight < rhs.weight; }
  };

  typedef std::vector<hfst_ol::Location> LocationVector;
  typedef std::vector<std::vector<hfst_ol::Location> > LocationVectorVector;

}

namespace hfst
{

// Needed for conversion between c++ and python datatypes.

typedef std::vector<std::string> StringVector;
typedef std::pair<std::string, std::string> StringPair;
typedef std::vector<std::pair<std::string, std::string> > StringPairVector;
typedef std::vector<float> FloatVector;
typedef std::set<std::string> StringSet;
typedef std::set<std::pair<std::string, std::string> > StringPairSet;
typedef std::pair<float, std::vector<std::string> > HfstOneLevelPath;
typedef std::set<std::pair<float, std::vector<std::string> > > HfstOneLevelPaths;
typedef std::pair<float, std::vector<std::pair<std::string, std::string > > > HfstTwoLevelPath;
typedef std::set<std::pair<float, std::vector<std::pair<std::string, std::string> > > > HfstTwoLevelPaths;
typedef std::map<std::string, std::string> HfstSymbolSubstitutions;
typedef std::map<std::pair<std::string, std::string>, std::pair<std::string, std::string> > HfstSymbolPairSubstitutions;
typedef std::vector<hfst::HfstTransducer> HfstTransducerVector;
typedef std::pair<hfst::HfstTransducer, hfst::HfstTransducer> HfstTransducerPair;
typedef std::vector<std::pair<hfst::HfstTransducer, hfst::HfstTransducer> > HfstTransducerPairVector;
typedef std::vector<hfst::xeroxRules::Rule> HfstRuleVector;
typedef std::pair<hfst::HfstTransducer*,unsigned int> HfstTransducerUIntPair;
typedef std::pair<hfst::HfstTransducer*,std::string> HfstTransducerStringPair;

// *** Some enumerations *** //

enum ImplementationType
{ SFST_TYPE, TROPICAL_OPENFST_TYPE, LOG_OPENFST_TYPE, FOMA_TYPE,
  XFSM_TYPE, HFST_OL_TYPE, HFST_OLW_TYPE, HFST2_TYPE,
  UNSPECIFIED_TYPE, ERROR_TYPE };

  namespace xeroxRules
  {
    enum ReplaceType {REPL_UP, REPL_DOWN, REPL_RIGHT, REPL_LEFT};

    class Rule
    {
    public:
      Rule();
      Rule(const hfst::HfstTransducerPairVector&);
      Rule(const hfst::HfstTransducerPairVector&, const hfst::HfstTransducerPairVector&, ReplaceType);
      Rule(const Rule&);
      hfst::HfstTransducerPairVector get_mapping() const;
      hfst::HfstTransducerPairVector get_context() const;
      ReplaceType get_replType() const;
      void encodeFlags();
      // friend std::ostream& operator<<(std::ostream &out, const Rule &r);
    };

    // replace up, left, right, down
    hfst::HfstTransducer replace(const Rule &rule, bool optional);
    // for parallel rules
    hfst::HfstTransducer replace(const HfstRuleVector &ruleVector, bool optional);

    // replace up, left, right, down
    hfst::HfstTransducer replace_left(const Rule &rule, bool optional);
    // for parallel rules
    hfst::HfstTransducer replace_left(const HfstRuleVector &ruleVector, bool optional);

    // left to right
    hfst::HfstTransducer replace_leftmost_longest_match(const Rule &rule);
    hfst::HfstTransducer replace_leftmost_longest_match(const HfstRuleVector &ruleVector);

    // right to left
    hfst::HfstTransducer replace_rightmost_longest_match(const Rule &rule);
    hfst::HfstTransducer replace_rightmost_longest_match(const HfstRuleVector &ruleVector);

    hfst::HfstTransducer replace_leftmost_shortest_match(const Rule &rule);
    hfst::HfstTransducer replace_leftmost_shortest_match(const HfstRuleVector &ruleVector);

    hfst::HfstTransducer replace_rightmost_shortest_match(const Rule &rule);
    hfst::HfstTransducer replace_rightmost_shortest_match(const HfstRuleVector &ruleVector);

    // replace up, left, right, down
    hfst::HfstTransducer replace_epenthesis(const Rule &rule, bool optional);
    hfst::HfstTransducer replace_epenthesis(const HfstRuleVector &ruleVector, bool optional);

    // Restriction function "=>"
    hfst::HfstTransducer restriction(const hfst::HfstTransducer &automata, const hfst::HfstTransducerPairVector &context);

    hfst::HfstTransducer before(const hfst::HfstTransducer &left, const hfst::HfstTransducer &right);

    hfst::HfstTransducer after(const hfst::HfstTransducer &left, const hfst::HfstTransducer &right);

  }

// *** Some other functions *** //

bool is_diacritic(const std::string & symbol);
bool is_epsilon(const std::string & symbol);
hfst::HfstTransducerVector compile_pmatch_expression(const std::string & pmatch) throw(HfstException);

// internal functions
%pythoncode %{
  def _is_string(s):
      if isinstance(s, str):
         return True
      else:
         return False
  def _is_string_pair(sp):
      if not isinstance(sp, tuple):
         return False
      if len(sp) != 2:
         return False
      if not _is_string(sp[0]):
         return False
      if not _is_string(sp[1]):
         return False
      return True
  def _is_string_vector(sv):
      if not isinstance(sv, tuple):
         return False
      for s in sv:
         if not _is_string(s):
            return False
      return True
  def _is_string_pair_vector(spv):
      if not isinstance(spv, tuple):
         return False
      for sp in spv:
         if not _is_string_pair(sp):
            return False
      return True

  def _two_level_paths_to_dict(tlps):
      retval = {}
      for tlp in tlps:
         input = ""
         output = ""
         for sp in tlp[1]:
            input += sp[0]
            output += sp[1]
         if input in retval:
            retval[input].append((output, tlp[0]))
         else:
            retval[input] = [(output, tlp[0])]
      return retval

  def _one_level_paths_to_tuple(olps, show_special_symbols):
      retval = []
      for olp in olps:
         path = ""
         for s in olp[1]:
            if not show_special_symbols and (is_diacritic(s) or is_epsilon(s)):
               pass
            else:
               path += s
         retval.append((path, olp[0]))
      return tuple(retval)
%}

// *** HfstTransducer *** //

// NOTE: all functions returning an HfstTransducer& are commented out and extended
// by replacing them with equivalent functions that return void. This is done in
// order to avoid use of references that are not handled well by swig/python.
// Some constructors and the destructor are also redefined.

class HfstTransducer
{
public:
  void set_name(const std::string &name);
  std::string get_name() const;
  hfst::ImplementationType get_type() const;
  void set_property(const std::string& property, const std::string& value);
  std::string get_property(const std::string& property) const;
  const std::map<std::string,std::string>& get_properties() const;
  bool compare(const HfstTransducer&, bool harmonize=true) const throw(TransducerTypeMismatchException);
  unsigned int number_of_states() const;
  unsigned int number_of_arcs() const;
  StringSet get_alphabet() const;
  bool is_cyclic() const;
  bool is_automaton() const;
  bool is_infinitely_ambiguous() const;
  bool is_lookup_infinitely_ambiguous(const std::string &) const;
  bool has_flag_diacritics() const;
  void insert_to_alphabet(const std::string &);
  void remove_from_alphabet(const std::string &);
  static bool is_implementation_type_available(hfst::ImplementationType type);
  int longest_path_size(bool obey_flags=true) const;

%extend {

  // First versions of all functions returning an HfstTransducer& that return void instead:

  void concatenate(const HfstTransducer& tr, bool harmonize=true) throw(TransducerTypeMismatchException) { self->concatenate(tr, harmonize); }
  void disjunct(const HfstTransducer& tr, bool harmonize=true) throw(TransducerTypeMismatchException) { self->disjunct(tr, harmonize); }
  void subtract(const HfstTransducer& tr, bool harmonize=true) throw(TransducerTypeMismatchException) { self->subtract(tr, harmonize); }
  void intersect(const HfstTransducer& tr, bool harmonize=true) throw(TransducerTypeMismatchException) { self->intersect(tr, harmonize); }
  void compose(const HfstTransducer& tr, bool harmonize=true) throw(TransducerTypeMismatchException) { self->compose(tr, harmonize); }
  void compose_intersect(const HfstTransducerVector &v, bool invert=false, bool harmonize=true) { self->compose_intersect(v, invert, harmonize); }
  void priority_union(const HfstTransducer &another) { self->priority_union(another); }
  void lenient_composition(const HfstTransducer &another, bool harmonize=true) { self->lenient_composition(another, harmonize); }
  void cross_product(const HfstTransducer &another, bool harmonize=true) throw(TransducersAreNotAutomataException) { self->cross_product(another, harmonize); }
  void shuffle(const HfstTransducer &another, bool harmonize=true) { self->shuffle(another, harmonize); }
  void remove_epsilons() { self->remove_epsilons(); }
  void determinize() { self->determinize(); }
  void minimize() { self->minimize(); }
  void prune() { self->prune(); }
  void eliminate_flags() { self->eliminate_flags(); }
  void eliminate_flag(const std::string& f) throw(HfstException) { self->eliminate_flag(f); }
  void n_best(unsigned int n) { self->n_best(n); }
  void convert(ImplementationType impl) { self->convert(impl); }
  void repeat_star() { self->repeat_star(); }
  void repeat_plus() { self->repeat_plus(); }
  void repeat_n(unsigned int n) { self->repeat_n(n); }
  void repeat_n_to_k(unsigned int n, unsigned int k) { self->repeat_n_to_k(n, k); }
  void repeat_n_minus(unsigned int n) { self->repeat_n_minus(n); }
  void repeat_n_plus(unsigned int n) { self->repeat_n_plus(n); }
  void invert() { self->invert(); }
  void reverse() { self->reverse(); }
  void input_project() { self->input_project(); }
  void output_project() { self->output_project(); }
  void optionalize() { self->optionalize(); }
  void insert_freely(const StringPair &symbol_pair, bool harmonize=true) { self->insert_freely(symbol_pair, harmonize); }
  void insert_freely(const HfstTransducer &tr, bool harmonize=true) { self->insert_freely(tr, harmonize); }
  void _substitute_symbol(const std::string &old_symbol, const std::string &new_symbol, bool input_side=true, bool output_side=true) { self->substitute_symbol(old_symbol, new_symbol, input_side, output_side); }
  void _substitute_symbol_pair(const StringPair &old_symbol_pair, const StringPair &new_symbol_pair) { self->substitute_symbol_pair(old_symbol_pair, new_symbol_pair); }
  void _substitute_symbol_pair_with_set(const StringPair &old_symbol_pair, const hfst::StringPairSet &new_symbol_pair_set) { self->substitute_symbol_pair_with_set(old_symbol_pair, new_symbol_pair_set); }
  void _substitute_symbol_pair_with_transducer(const StringPair &symbol_pair, HfstTransducer &transducer, bool harmonize=true) { self->substitute_symbol_pair_with_transducer(symbol_pair, transducer, harmonize); }
  void _substitute_symbols(const hfst::HfstSymbolSubstitutions &substitutions) { self->substitute_symbols(substitutions); } // alias for the previous function which is shadowed
  void _substitute_symbol_pairs(const hfst::HfstSymbolPairSubstitutions &substitutions) { self->substitute_symbol_pairs(substitutions); } // alias for the previous function which is shadowed
  void set_final_weights(float weight, bool increment=false) { self->set_final_weights(weight, increment); };

  void push_weights_to_start() { self->push_weights(hfst::TO_INITIAL_STATE); };
  void push_weights_to_end() { self->push_weights(hfst::TO_FINAL_STATE); };

  // And some aliases:
  // 'union' is a reserved word in python, so it cannot be used as an alias for function 'disjunct'
  void minus(const HfstTransducer& t, bool harmonize=true) { $self->subtract(t, harmonize); }
  void conjunct(const HfstTransducer& t, bool harmonize=true) { $self->intersect(t, harmonize); }

  // Then the actual extensions:

  void lookup_optimize() { self->convert(hfst::HFST_OLW_TYPE); }
  void remove_optimization() { self->convert(hfst::get_default_fst_type()); }

    HfstTransducer() { return hfst::empty_transducer(); }
    HfstTransducer(const hfst::HfstTransducer & t) { return hfst::copy_hfst_transducer(t); }
    HfstTransducer(const hfst::implementations::HfstIterableTransducer & t) { return hfst::copy_hfst_transducer_from_basic_transducer(t); }
    HfstTransducer(const hfst::implementations::HfstIterableTransducer & t, hfst::ImplementationType impl) { return hfst::copy_hfst_transducer_from_basic_transducer(t, impl); }
    ~HfstTransducer()
    {
        if ($self->get_type() == hfst::UNSPECIFIED_TYPE || $self->get_type() == hfst::ERROR_TYPE)
        {
            return;
        }
        delete $self;
    }
    // For python's 'print'
    char *__str__() {
         std::ostringstream oss;
         hfst::implementations::HfstIterableTransducer fsm(*$self);
         fsm.write_in_att_format(oss,true);
         return strdup(oss.str().c_str());
    }
    void write(hfst::HfstOutputStream & os) { (void) os.redirect(*$self); }

    std::string _get_dot_graph() {
      std::ostringstream oss;
      hfst::print_dot(oss, *$self, NULL);
      return oss.str();
    }

    hfst::HfstTwoLevelPaths _extract_shortest_paths()
    {
        hfst::HfstTwoLevelPaths results;
        $self->extract_shortest_paths(results);
        return results;
    }
    hfst::HfstTwoLevelPaths _extract_longest_paths(bool obey_flags)
    {
        hfst::HfstTwoLevelPaths results;
        $self->extract_longest_paths(results, obey_flags);
        return results;
    }
    hfst::HfstTwoLevelPaths _extract_paths(int max_num=-1, int cycles=-1) const throw(TransducerIsCyclicException)
    {
      hfst::HfstTwoLevelPaths results;
      $self->extract_paths(results, max_num, cycles);
      return results;
    }
    hfst::HfstTwoLevelPaths _extract_paths_fd(int max_num=-1, int cycles=-1, bool filter_fd=true) const throw(TransducerIsCyclicException)
    {
      hfst::HfstTwoLevelPaths results;
      $self->extract_paths_fd(results, max_num, cycles, filter_fd);
      return results;
    }
    hfst::HfstTwoLevelPaths _extract_random_paths(int max_num) const
    {
      hfst::HfstTwoLevelPaths results;
      $self->extract_random_paths(results, max_num);
      return results;
    }
    hfst::HfstTwoLevelPaths _extract_random_paths_fd(int max_num, bool filter_fd) const
    {
      hfst::HfstTwoLevelPaths results;
      $self->extract_random_paths_fd(results, max_num, filter_fd);
      return results;
    }

    HfstOneLevelPaths _lookup_vector(const StringVector& s, int limit = -1, double time_cutoff = 0.0) const throw(TransducerIsCyclicException, FunctionNotImplementedException)
    {
      return hfst::lookup_vector($self, false /*fd*/, s, limit, time_cutoff);
    }
    HfstOneLevelPaths _lookup_fd_vector(const StringVector& s, int limit = -1, double time_cutoff = 0.0) const throw(TransducerIsCyclicException, FunctionNotImplementedException)
    {
      return hfst::lookup_vector($self, true /*fd*/, s, limit, time_cutoff);
    }
    HfstOneLevelPaths _lookup_fd_string(const std::string& s, int limit = -1, double time_cutoff = 0.0) const throw(TransducerIsCyclicException, FunctionNotImplementedException)
    {
      return hfst::lookup_string($self, true /*fd*/, s, limit, time_cutoff);
    }
    HfstOneLevelPaths _lookup_string(const std::string & s, int limit = -1, double time_cutoff = 0.0) const throw(TransducerIsCyclicException, FunctionNotImplementedException)
    {
      return hfst::lookup_string($self, false /*fd*/, s, limit, time_cutoff);
    }

%pythoncode %{

  def view(self):
      """
      Return a dot Digraph representation of the transducer as a graphviz.Source object.

      Inside a Jupyter notebook, the return value will be automatically
      rendered to an svg image and displayed on the console.

      Examples:

      tr = hfst_dev.regex('foo:bar')
      tr.view()

      If inside an intended block, 'display' must be called:

      if (Foo):
          tr = hfst_dev.regex('foo:bar')
          display(tr.view())

      Note: The function requires graphviz package.
      """
      from graphviz import Source
      graph = self._get_dot_graph()
      s = Source(graph)
      return s

  def copy(self):
      """
      Return a deep copy of the transducer.
      """
      return HfstTransducer(self)

  def write_to_file(self, filename_):
      """
      Write the transducer in binary format to file *filename_*.
      """
      ostr = HfstOutputStream(filename=filename_, type=self.get_type(), hfst_format=True)
      ostr.write(self)
      ostr.close()

  def read_from_file(filename_):
      """
      Read a binary transducer from file *filename_*.
      """
      istr = HfstInputStream(filename_)
      tr = istr.read()
      istr.close()
      return tr

  def read_all_from_file(filename_):
      """
      Read all binary transducers from file *filename_*.
      """
      istr = HfstInputStream(filename_)
      tr = istr.read_all()
      istr.close()
      return tr

  def write_prolog(self, f, write_weights=True):
      """
      Write the transducer in prolog format with name *name* to file *f*,
      *write_weights* defined whether weights are written.

      Parameters
      ----------
      * `f` :
          A python file where the transducer is written.
      * `write_weights` :
          Whether weights are written.
      """
      fsm = HfstIterableTransducer(self)
      fsm.name = self.get_name()
      prologstr = fsm.get_prolog_string(write_weights)
      f.write(prologstr)

  def write_xfst(self, f, write_weights=True):
      """
      Write the transducer in xfst format to file *f*, *write_weights* defined whether
      weights are written.

      Parameters
      ----------
      * `f` :
          A python file where transducer is written.
      * `write_weights` :
          Whether weights are written.
      """
      fsm = HfstIterableTransducer(self)
      fsm.name = self.get_name()
      xfststr = fsm.get_xfst_string(write_weights)
      f.write(xfst)

  def write_att(self, f, write_weights=True):
      """
      Write the transducer in AT&T format to file *f*, *write_weights* defined whether
      weights are written.

      Parameters
      ----------
      * `f` :
          A python file where transducer is written.
      * `write_weights` :
          Whether weights are written.
      """
      fsm = HfstIterableTransducer(self)
      fsm.name = self.get_name()
      attstr = fsm.get_att_string(write_weights)
      f.write(attstr)

  def lookup(self, input, **kwargs):
      """
      Lookup string *input*.

      Parameters
      ----------
      * `input` :
          The input. A string or a pre-tokenized tuple of symbols (i.e. a tuple of strings).
      * `kwargs` :
          Possible parameters and their default values are: obey_flags=True,
          max_number=-1, time_cutoff=0.0, output='tuple'
      * `obey_flags` :
          Whether flag diacritics are obeyed. Always True for HFST_OL(W)_TYPE transducers.
      * `show_flags` :
          Whether flag diacritics are shown when output is 'text' or 'tuple'. Defaults to False.
      * `max_number` :
          Maximum number of results returned, defaults to -1, i.e. infinity.
      * `time_cutoff` :
          How long the function can search for results before returning, expressed in
          seconds. Defaults to 0.0, i.e. infinitely. Always 0.0 for transducers that are
          not of HFST_OL(W)_TYPE.
      * `output` :
          Possible values are 'tuple', 'text' and 'raw', 'tuple' being the default.

      Note: This function has an efficient implementation only for optimized lookup format
      (hfst.ImplementationType.HFST_OL_TYPE or hfst.ImplementationType.HFST_OLW_TYPE). Other formats perform the
      lookup via composition. Consider converting the transducer to optimized lookup format
      or to a HfstIterableTransducer. Conversion to HFST_OL(W)_TYPE might take a while but the
      lookup is fast. Conversion to HfstIterableTransducer is quick but lookup is slower.
      """
      obey_flags=True
      show_flags=False
      max_number=-1
      time_cutoff=0.0
      output='tuple' # 'tuple' (default), 'text', 'raw'

      for k,v in kwargs.items():
          if k == 'obey_flags':
             if v == True:
                pass
             elif v == False:
                obey_flags=False
             else:
                print('Warning: ignoring argument %s as it has value %s.' % (k, v))
                print("Possible values are True and False.")
          if k == 'show_flags':
             if v == False:
                pass
             elif v == True:
                show_flags=True
             else:
                print('Warning: ignoring argument %s as it has value %s.' % (k, v))
                print("Possible values are True and False.")
          elif k == 'output':
             if v == 'text':
                output='text'
             elif v == 'raw':
                output='raw'
             elif v == 'tuple':
                output='tuple'
             else:
                print('Warning: ignoring argument %s as it has value %s.' % (k, v))
                print("Possible values are 'tuple' (default), 'text', 'raw'.")
          elif k == 'max_number' :
             max_number=v
          elif k == 'time_cutoff' :
             time_cutoff=v
          else:
             print('Warning: ignoring unknown argument %s.' % (k))

      retval=0

      if isinstance(input, tuple):
         if obey_flags:
            retval=self._lookup_fd_vector(input, max_number, time_cutoff)
         else:
            retval=self._lookup_vector(input, max_number, time_cutoff)
      elif isinstance(input, str):
         if obey_flags:
            retval=self._lookup_fd_string(input, max_number, time_cutoff)
         else:
            retval=self._lookup_string(input, max_number, time_cutoff)
      else:
         try:
            if obey_flags:
                retval=self._lookup_fd_string(str(input), max_number, time_cutoff)
            else:
                retval=self._lookup_string(str(input), max_number, time_cutoff)
         except:
            raise RuntimeError('Input argument must be string or tuple.')
      if output == 'text':
         return _one_level_paths_to_string(retval, show_flags)
      elif output == 'tuple':
         return _one_level_paths_to_tuple(retval, show_flags)
      else:
         return retval

  def extract_longest_paths(self, **kwargs):
      """
      Extract longest paths of the transducer.

      Parameters
      ----------
      * `kwargs` :
          Possible parameters and their default values are: obey_flags=True,
          output='dict'
      * `obey_flags` :
          Whether flag diacritics are obeyed. The default is True.
      * `output` :
          Possible values are 'dict', 'text' and 'raw', 'dict' being the default.

      """
      obey_flags=True
      output='dict' # 'dict' (default), 'text', 'raw'

      for k,v in kwargs.items():
          if k == 'obey_flags':
             if v == True:
                pass
             elif v == False:
                obey_flags=False
             else:
                print('Warning: ignoring argument %s as it has value %s.' % (k, v))
                print("Possible values are True and False.")
          elif k == 'output':
             if v == 'text':
                output == 'text'
             elif v == 'raw':
                output='raw'
             elif v == 'dict':
                output='dict'
             else:
                print('Warning: ignoring argument %s as it has value %s.' % (k, v))
                print("Possible values are 'dict' (default), 'text', 'raw'.")
          else:
             print('Warning: ignoring unknown argument %s.' % (k))

      retval = self._extract_longest_paths(obey_flags)

      if output == 'text':
         return _two_level_paths_to_string(retval)
      elif output == 'dict':
         return _two_level_paths_to_dict(retval)
      else:
         return retval

  def extract_shortest_paths(self, **kwargs):
      """
      Extract shortest paths of the transducer.

      Parameters
      ----------
      * `kwargs` :
          Possible parameters and their default values are: obey_flags=True.
      * `output` :
          Possible values are 'dict', 'text' and 'raw', 'dict' being the default.

      """
      output='dict' # 'dict' (default), 'text', 'raw'

      for k,v in kwargs.items():
          if k == 'output':
             if v == 'text':
                output == 'text'
             elif v == 'raw':
                output='raw'
             elif v == 'dict':
                output='dict'
             else:
                print('Warning: ignoring argument %s as it has value %s.' % (k, v))
                print("Possible values are 'dict' (default), 'text', 'raw'.")
          else:
             print('Warning: ignoring unknown argument %s.' % (k))

      retval = self._extract_shortest_paths()

      if output == 'text':
         return _two_level_paths_to_string(retval)
      elif output == 'dict':
         return _two_level_paths_to_dict(retval)
      else:
         return retval

  def extract_paths(self, **kwargs):
      """

      Extract paths that are recognized by the transducer.

      Parameters
      ----------
      * `kwargs` :
          Arguments recognized are filter_flags, max_cycles, max_number, obey_flags,
          output, random.
      * `filter_flags` :
          Whether flags diacritics are filtered out from the result (default True).
      * `max_cycles` :
          Indicates how many times a cycle will be followed, with negative numbers
          indicating unlimited (default -1 i.e. unlimited).
      * `max_number` :
          The total number of resulting strings is capped at this value, with 0 or
          negative indicating unlimited (default -1 i.e. unlimited).
      * `obey_flags` :
          Whether flag diacritics are validated (default True).
      * `output` :
          Output format. Values recognized: 'text' (as a string, separated by
          newlines), 'raw' (a dictionary that maps each input string into a list of
          tuples of an output string and a weight), 'dict' (a dictionary that maps
          each input string into a tuple of tuples of an output string and a weight,
          the default).
      * `random` :
          Whether result strings are fetched randomly (default False).

      Returns
      -------
      The extracted strings. *output* controls how they are represented.

      pre: The transducer must be acyclic, if both *max_number* and *max_cycles* have
      unlimited values. Else a hfst.exceptions.TransducerIsCyclicException will be
      thrown.

      An example:

      >>> tr = hfst.regex('a:b+ (a:c+)')
      >>> print(tr)
      0       1       a       b       0.000000
      1       1       a       b       0.000000
      1       2       a       c       0.000000
      1       0.000000
      2       2       a       c       0.000000
      2       0.000000

      >>> print(tr.extract_paths(max_cycles=1, output='text'))
      a:b     0
      aa:bb   0
      aaa:bbc 0
      aaaa:bbcc       0
      aa:bc   0
      aaa:bcc 0

      >>> print(tr.extract_paths(max_number=4, output='text'))
      a:b     0
      aa:bc   0
      aaa:bcc 0
      aaaa:bccc       0

      >>> print(tr.extract_paths(max_cycles=1, max_number=4, output='text'))
      a:b     0
      aa:bb   0
      aa:bc   0
      aaa:bcc 0

      Exceptions
      ----------
      * `TransducerIsCyclicException` :

      See also: hfst.HfstTransducer.n_best
      """
      obey_flags=True
      filter_flags=True
      max_cycles=-1
      max_number=-1
      random=False
      output='dict' # 'dict' (default), 'text', 'raw'

      for k,v in kwargs.items():
          if k == 'obey_flags' :
             if v == True:
                pass
             elif v == False:
                obey_flags=False
             else:
                print('Warning: ignoring argument %s as it has value %s.' % (k, v))
                print("Possible values are True and False.")
          elif k == 'filter_flags' :
             if v == True:
                pass
             elif v == False:
                filter_flags=False
             else:
                print('Warning: ignoring argument %s as it has value %s.' % (k, v))
                print("Possible values are True and False.")
          elif k == 'max_cycles' :
             max_cycles=v
          elif k == 'max_number' :
             max_number=v
          elif k == 'random' :
             if v == False:
                pass
             elif v == True:
                random=True
             else:
                print('Warning: ignoring argument %s as it has value %s.' % (k, v))
                print("Possible values are True and False.")
          elif k == 'output':
             if v == 'text':
                output = 'text'
             elif v == 'raw':
                output='raw'
             elif v == 'dict':
                output='dict'
             else:
                print('Warning: ignoring argument %s as it has value %s.' % (k, v))
                print("Possible values are 'dict' (default), 'text', 'raw'.")
          else:
             print('Warning: ignoring unknown argument %s.' % (k))

      retval=0

      if obey_flags :
         if random :
            retval=self._extract_random_paths_fd(max_number, filter_flags)
         else :
            retval=self._extract_paths_fd(max_number, max_cycles)
      else :
         if random :
            retval=self._extract_random_paths(max_number)
         else :
            retval=self._extract_paths(max_number, max_cycles)

      if output == 'text':
         return _two_level_paths_to_string(retval)
      elif output == 'dict':
         return _two_level_paths_to_dict(retval)
      else:
         return retval

  def substitute(self, s, S=None, **kwargs):
      """
      Substitute symbols or transitions in the transducer.

      Parameters
      ----------
      * `s` :
          The symbol or transition to be substituted. Can also be a dictionary of
          substitutions, if S == None.
      * `S` :
          The symbol, transition, a tuple of transitions or a transducer
          (hfst.HfstTransducer) that substitutes *s*.
      * `kwargs` :
          Arguments recognized are 'input' and 'output', their values can be False or
          True, True being the default. These arguments are valid only if *s* and *S*
          are strings, else they are ignored.
      * `input` :
          Whether substitution is performed on input side, defaults to True. Valid
          only if *s* and *S* are strings.
      * `output` :
          Whether substitution is performed on output side, defaults to True. Valid
          only if *s* and \\ S are strings.

      For more information, see hfst.HfstIterableTransducer.substitute. The function
      works similarly, with the exception of argument *S*, which must be
      hfst.HfstTransducer instead of hfst.HfstIterableTransducer.

      See also: hfst.HfstIterableTransducer.substitute
      """
      if S == None:
         if not isinstance(s, dict):
            raise RuntimeError('Sole input argument must be a dictionary.')

         subst_type=""

         for k, v in s.items():
             if _is_string(k):
                if subst_type == "":
                   subst_type="string"
                elif subst_type == "string pair":
                   raise RuntimeError('')
                if not _is_string(v):
                   raise RuntimeError('')
             elif _is_string_pair(k):
                if subst_type == "":
                   subst_type="string pair"
                elif subst_type == "string":
                   raise RuntimeError('')
                if not _is_string_pair(v):
                   raise RuntimeError('')
             else:
                raise RuntimeError('')

         if subst_type == "string":
            return self._substitute_symbols(s)
         else:
            return self._substitute_symbol_pairs(s)

      if _is_string(s):
         if _is_string(S):
            input=True
            output=True
            for k,v in kwargs.items():
                if k == 'input':
                   if v == False:
                      input=False
                elif k == 'output':
                   if v == False:
                      output=False
                else:
                   raise RuntimeError('Free argument not recognized.')
            return self._substitute_symbol(s, S, input, output)
         else:
            raise RuntimeError('...')
      elif _is_string_pair(s):
         if _is_string_pair(S):
            return self._substitute_symbol_pair(s, S)
         elif _is_string_pair_vector(S):
            return self._substitute_symbol_pair_with_set(s, S)
         elif isinstance(S, HfstTransducer):
            return self._substitute_symbol_pair_with_transducer(s, S, True)
         else:
            raise RuntimeError('...')
      else:
         raise RuntimeError('...')
%}

};

}; // class HfstTransducer


// *** HfstOutputStream *** //

hfst::HfstOutputStream * _create_hfst_output_stream(const std::string & filename, hfst::ImplementationType type, bool hfst_format);

class HfstOutputStream
{
public:
~HfstOutputStream(void);
HfstOutputStream &flush();
void close(void);
hfst::HfstOutputStream & redirect(hfst::HfstTransducer &) throw(StreamIsClosedException);

%extend {

HfstOutputStream() { return new hfst::HfstOutputStream(hfst::get_default_fst_type()); }

%pythoncode %{

def write(self, tr):
    """
    Write one or more transducers to stream.

    Parameters
    ----------
    * `tr` :
        An HfstTransducer or an iterable object of several HfstTransducers.
    """
    if isinstance(tr, HfstTransducer):
        self.redirect(tr)
    else:
        for t in tr:
            if isinstance(t, HfstTransducer):
                self.redirect(t)
            else:
                raise RuntimeError('Cannot write objects that are not instances of HfstTransducer')

def __init__(self, **kwargs):
    """
    Open a stream for writing binary transducers. Note: hfst.HfstTransducer.write_to_file
    is probably the easiest way to write a single binary transducer to a file.

    Parameters
    ----------
    * `kwargs` :
        Arguments recognized are filename, hfst_format, type.
    * `filename` :
        The name of the file where transducers are written. If the file exists, it
        is overwritten. If *filename* is not given, transducers are written to
        standard output.
    * `hfst_format` :
        Whether transducers are written in hfst format (default is True) or as such
        in their backend format.
    * `type` :
        The type of the transducers that will be written to the stream. Default is
        hfst.get_default_fst_type().

    Examples:

        # a stream for writing default type transducers in hfst format to standard output
        ostr = hfst.HfstOutputStream()
        transducer = hfst.regex('foo:bar::0.5')
        ostr.write(transducer)
        ostr.flush()

        # a stream for writing native sfst type transducers to a file
        ostr = hfst.HfstOutputStream(filename='transducer.sfst', hfst_format=False, type=hfst.ImplementationType.SFST_TYPE)
        transducer1 = hfst.regex('foo:bar')
        transducer1.convert(hfst.ImplementationType.SFST_TYPE)  # if not set as the default type
        transducer2 = hfst.regex('bar:baz')
        transducer2.convert(hfst.ImplementationType.SFST_TYPE)  # if not set as the default type
        ostr.write(transducer1)
        ostr.write(transducer2)
        ostr.flush()
        ostr.close()
    """
    filename = ""
    hfst_format = True
    type = _libhfst_dev.get_default_fst_type()
    for k,v in kwargs.items():
        if k == 'filename':
            filename = v
        if k == 'hfst_format':
            hfst_format = v
        if k == 'type':
            type = v
    if filename == "":
        self.this = _libhfst_dev._create_hfst_output_stream("", type, hfst_format)
    else:
        self.this = _libhfst_dev._create_hfst_output_stream(filename, type, hfst_format)
%}

}

}; // class HfstOutputStream

// *** HfstInputStream *** //

class HfstInputStream
{
public:
    HfstInputStream(void) throw(StreamNotReadableException, NotTransducerStreamException, EndOfStreamException, TransducerHeaderException);
    HfstInputStream(const std::string &filename) throw(StreamNotReadableException, NotTransducerStreamException, EndOfStreamException, TransducerHeaderException);
    ~HfstInputStream(void);
    void close(void);
    bool is_eof(void);
    bool is_bad(void);
    bool is_good(void);
    ImplementationType get_type(void) const throw(TransducerTypeMismatchException);

%extend {

hfst::HfstTransducer * read() throw (EndOfStreamException) { return new hfst::HfstTransducer(*($self)); }

%pythoncode %{

def read_all(self):
    """
    Read all transducers from stream and return them in a list.
    """
    retval = []
    while(not self.is_eof()):
        retval.append(self.read())
    return retval

def __iter__(self):
    """
    Return *self*. Needed for 'for ... in' statement.
    """
    return self

def next(self):
    """
    Read next transducer from stream and return it. Needed for 'for ... in' statement.
    """
    if self.is_eof():
        raise StopIteration
    else:
        return self.read();

def __next__(self):
    """
    Read next transducer from stream and return it. Needed for 'for ... in' statement.
    """
    return self.next()

%}

}

}; // class HfstInputStream


// *** HfstTokenizer *** //
  
  class HfstTokenizer
  {
  public:
     HfstTokenizer();
     void add_skip_symbol(const std::string &symbol);
     void add_multichar_symbol(const std::string& symbol);
     void add_multichar_symbols(const StringSet& symbols);
     StringPairVector tokenize(const std::string &input_string) const;
     StringVector tokenize_one_level(const std::string &input_string) const;
     static StringPairVector tokenize_space_separated(const std::string & str);
     StringPairVector tokenize(const std::string &input_string,
                              const std::string &output_string) const;
     static void check_utf8_correctness(const std::string &input_string);
  };

namespace implementations {

  class HfstIterableTransducer;
  class HfstTransition;
  typedef unsigned int HfstState;

  typedef std::vector<hfst::implementations::HfstTransition> HfstTransitions;


// *** HfstIterableTransducer *** //

class HfstIterableTransducer {

  public:

    HfstIterableTransducer(void);
    HfstIterableTransducer(const HfstIterableTransducer &graph);
    HfstIterableTransducer(const hfst::HfstTransducer &transducer);

    std::string name;
    void add_symbol_to_alphabet(const std::string &symbol);
    void remove_symbol_from_alphabet(const std::string &symbol);
    void remove_symbols_from_alphabet(const StringSet &symbols);
    void add_symbols_to_alphabet(const StringSet &symbols);
    // shadowed by the previous function: void add_symbols_to_alphabet(const StringPairSet &symbols);
    std::set<std::string> symbols_used();
    void prune_alphabet(bool force=true);
    const std::set<std::string> &get_alphabet() const;
    StringSet get_input_symbols() const;
    StringSet get_output_symbols() const;
    StringPairSet get_transition_pairs() const;
    HfstState add_state(void);
    HfstState add_state(HfstState s);
    HfstState get_max_state() const;
    std::vector<HfstState> states() const;
    void add_transition(HfstState s, const hfst::implementations::HfstTransition & transition, bool add_symbols_to_alphabet=true);
    void remove_transition(HfstState s, const hfst::implementations::HfstTransition & transition, bool remove_symbols_from_alphabet=false);
    bool is_final_state(HfstState s) const;
    float get_final_weight(HfstState s) const throw(StateIsNotFinalException, StateIndexOutOfBoundsException);
    void set_final_weight(HfstState s, const float & weight);
    void remove_final_weight(HfstState s);
    hfst::implementations::HfstTransitions & transitions(HfstState s);
    bool is_infinitely_ambiguous();
    bool is_lookup_infinitely_ambiguous(const StringVector & s);
    int longest_path_size();

%extend {

    void _substitute_symbol(const std::string &old_symbol, const std::string &new_symbol, bool input_side=true, bool output_side=true) { self->substitute_symbol(old_symbol, new_symbol, input_side, output_side); }
    void _substitute_symbol_pair(const StringPair &old_symbol_pair, const StringPair &new_symbol_pair) { self->substitute_symbol_pair(old_symbol_pair, new_symbol_pair); }
    void _substitute_symbol_pair_with_set(const StringPair &old_symbol_pair, const hfst::StringPairSet &new_symbol_pair_set) { self->substitute_symbol_pair_with_set(old_symbol_pair, new_symbol_pair_set); }
    void _substitute_symbol_pair_with_transducer(const StringPair &symbol_pair, HfstIterableTransducer &transducer) { self->substitute_symbol_pair_with_transducer(symbol_pair, transducer); }
    void _substitute_symbols(const hfst::HfstSymbolSubstitutions &substitutions) { self->substitute_symbols(substitutions); } // alias for the previous function which is shadowed
    void _substitute_symbol_pairs(const hfst::HfstSymbolPairSubstitutions &substitutions) { self->substitute_symbol_pairs(substitutions); } // alias for the previous function which is shadowed
    void insert_freely(const StringPair &symbol_pair, float weight) { self->insert_freely(symbol_pair, weight); }
    void insert_freely(const HfstIterableTransducer &tr) { self->insert_freely(tr); }
    void sort_arcs() { self->sort_arcs(); }
    void disjunct(const StringPairVector &spv, float weight) { self->disjunct(spv, weight); }
    void harmonize(HfstIterableTransducer &another) { self->harmonize(another); }

    static hfst::implementations::HfstIterableTransducer read_binary_sfst_transducer(const std::string & filename)
    {
      try
	{
	  return hfst::hfst_read_binary_sfst_transducer(filename);
	}
      catch (const char * msg)
	{
	  std::cerr << std::string(msg) << std::endl;
	  return hfst::implementations::HfstIterableTransducer();
	}
    }

    void write_binary_sfst_transducer(const std::string & filename)
    {
      try
	{
	  hfst::hfst_write_binary_sfst_transducer(*self, filename);
	}
      catch (const char * msg)
	{
	  std::cerr << std::string(msg) << std::endl;
	}
    }
    
  HfstTwoLevelPaths _lookup(const StringVector &lookup_path, size_t * infinite_cutoff, float * max_weight, bool obey_flags) throw(TransducerIsCyclicException)
  {
    hfst::HfstTwoLevelPaths results;
    $self->lookup(lookup_path, results, infinite_cutoff, max_weight, -1, obey_flags);
    return results;
  }

  std::string get_prolog_string(bool write_weights)
  {
    std::ostringstream oss;
    $self->write_in_prolog_format(oss, self->name, write_weights);
    return oss.str();
  }

  std::string get_xfst_string(bool write_weights)
  {
    std::ostringstream oss;
    $self->write_in_xfst_format(oss, write_weights);
    return oss.str();
  }

  std::string get_att_string(bool write_weights)
  {
    std::ostringstream oss;
    $self->write_in_att_format(oss, write_weights);
    std::string retval = oss.str();
    if (retval == "") // empty transducer must be represented as empty line in python, else read_att fails...
      retval = std::string("\n");
    return retval;
  }

  char * __str__()
  {
    std::ostringstream oss;
    $self->write_in_att_format(oss, true);
    return strdup(oss.str().c_str());
  }

  void add_transition(HfstState source, HfstState target, std::string input, std::string output, float weight=0, bool add_symbols_to_alphabet=true) {
    hfst::implementations::HfstTransition tr(target, input, output, weight);
    $self->add_transition(source, tr, add_symbols_to_alphabet);
  }

%pythoncode %{

  def view(self):
      """
      Return a dot Digraph representation of the transducer as a graphviz.Source object.

      Examples:

      Inside a Jupyter notebook, the return value will be automatically
      rendered to an svg image and displayed on the console:

      tr = hfst_dev.regex('foo:bar')
      tr.view()

      If inside an intended block, 'display' must be called:

      if (Foo):
          tr = hfst_dev.regex('foo:bar')
          display(tr.view())

      On other environments, the return value must be explicitely rendered
      to an svg image before displaying it:

      tr = hfst_dev.regex('foo:bar')
      from IPython.core.display import display, SVG
      display(SVG(tr.view()._repr_svg_()))
      """
      TR = HfstTransducer(self)
      return TR.view()

  def transitions(self, s):
      """
      ...
      """
      tr = self._transitions(s)
      retval = []
      for i in range(0, len(tr)):
          retval.append(tr[i])
      return retval

  def states_and_transitions(self):
      """
      ...
      """
      retval = []
      for s in self.states():
          retval.append(self.transitions(s))
      return retval

  def __iter__(self):
      """
      Return states and transitions of the transducer.
      """
      return self.states_and_transitions().__iter__()

  def __enumerate__(self):
      """
      Return an enumeration of states and transitions of the transducer.
      """
      return enumerate(self.states_and_transitions())

  def write_prolog(self, f, write_weights=True):
      """
      Write the transducer in prolog format with name *name* to file *f*,
      *write_weights* defined whether weights are written.

      Parameters
      ----------
      * `f` :
          A python file where the transducer is written.
      * `write_weights` :
          Whether weights are written.
      """
      prologstr = self.get_prolog_string(write_weights)
      f.write(prologstr)

  def write_xfst(self, f, write_weights=True):
      """
      Write the transducer in xfst format to file *f*, *write_weights* defined whether
      weights are written.

      Parameters
      ----------
      * `f` :
          A python file where transducer is written.
      * `write_weights` :
          Whether weights are written.
      """
      xfststr = self.get_xfst_string(write_weights)
      f.write(prologstr)

  def write_att(self, f, write_weights=True):
      """
      Write the transducer in AT&T format to file *f*, *write_weights* defined whether
      weights are written.

      Parameters
      ----------
      * `f` :
          A python file where transducer is written.
      * `write_weights` :
          Whether weights are written.
      """
      attstr = self.get_att_string(write_weights)
      f.write(attstr)

  def lookup(self, lookup_path, **kwargs):
      """
      Lookup tokenized input *input* in the transducer.

      Parameters
      ----------
      * `str` :
          A list/tuple of strings to look up.
      * `kwargs` :
          infinite_cutoff=-1, max_weight=None, obey_flags=False
      * `max_epsilon_loops` :
          How many times epsilon input loops are followed. Defaults to -1, i.e. infinitely.
      * `max_weight` :
          What is the maximum weight of a result allowed. Defaults to None, i.e. infinity.
      * `obey_flags` :
          Whether flag diacritic constraints are obeyed. Defaults to False.
      """
      max_weight = None
      max_epsilon_loops = None
      obey_flags = False
      output='dict' # 'dict' (default), 'text', 'raw'

      for k,v in kwargs.items():
          if k == 'max_weight' :
             max_weight=v
          elif k == 'max_epsilon_loops' :
             infinite_cutoff=v
          elif k == 'obey_flags' :
             obey_flags=v
          elif k == 'output':
             if v == 'text':
                output == 'text'
             elif v == 'raw':
                output='raw'
             elif v == 'dict':
                output='dict'
             else:
                print('Warning: ignoring argument %s as it has value %s.' % (k, v))
                print("Possible values are 'dict' (default), 'text', 'raw'.")
          else:
             print('Warning: ignoring unknown argument %s.' % (k))

      retval = self._lookup(lookup_path, max_epsilon_loops, max_weight, obey_flags)

      if output == 'text':
         return _two_level_paths_to_string(retval)
      elif output == 'dict':
         return _two_level_paths_to_dict(retval)
      else:
         return retval

  def substitute(self, s, S=None, **kwargs):
      """

      Substitute symbols or transitions in the transducer.

      Parameters
      ----------
      * `s` :
          The symbol or transition to be substituted. Can also be a dictionary of
          substitutions, if S == None.
      * `S` :
          The symbol, transition, a tuple of transitions or a transducer
          (hfst.HfstIterableTransducer) that substitutes *s*.
      * `kwargs` :
          Arguments recognized are 'input' and 'output', their values can be False or
          True, True being the default. These arguments are valid only if *s* and *S*
          are strings, else they are ignored.
      * `input` :
          Whether substitution is performed on input side, defaults to True. Valid
          only if *s* and *S* are strings.
      * `output` :
          Whether substitution is performed on output side, defaults to True. Valid
          only if *s* and *S* are strings.

      Possible combinations of arguments and their types are:

      (1) substitute(str, str, input=bool, output=bool): substitute symbol with symbol
      on input, output or both sides of each transition in the transducer. (2)
      substitute(strpair, strpair): substitute transition with transition (3)
      substitute(strpair, strpairtuple): substitute transition with several
      transitions (4) substitute(strpair, transducer): substitute transition with a
      transducer (5) substitute(dict): perform several symbol-to-symbol substitutions
      (6) substitute(dict): perform several transition-to-transition substitutions

      Examples:

      (1) tr.substitute('a', 'A', input=True, output=False): substitute lowercase a:s
      with uppercase ones (2) tr.substitute(('a','b'),('A','B')): substitute
      transitions that map lowercase a into lowercase b with transitions that map
      uppercase a into uppercase b (3) tr.substitute(('a','b'),
      (('A','B'),('a','B'),('A','b'))): change either or both sides of a transition
      [a:b] to uppercase (4) tr.substitute(('a','b'), hfst.regex('[a:b]+')) change
      [a:b] transition into one or more consecutive [a:b] transitions (5)
      tr.substitute({'a':'A', 'b':'B', 'c':'C'}) change lowercase a, b and c into
      their uppercase variants (6) tr.substitute( {('a','a'):('A','A'),
      ('b','b'):('B','B'), ('c','c'):('C','C')} ): change lowercase a, b and c into
      their uppercase variants

      In case (4), epsilon transitions are used to attach copies of transducer *S*
      between the SOURCE and TARGET state of each transition that is substituted. The
      transition itself is deleted, but its weight is copied to the epsilon transition
      leading from SOURCE to the initial state of *S*. Each final state of *S* is made
      non-final and an epsilon transition leading to TARGET is attached to it. The
      final weight is copied to the epsilon transition.
      """
      if S == None:
         if not isinstance(s, dict):
            raise RuntimeError('First input argument must be a dictionary.')

         subst_type=""

         for k, v in s.items():
             if _is_string(k):
                if subst_type == "":
                   subst_type="string"
                elif subst_type == "string pair":
                   raise RuntimeError('')
                if not _is_string(v):
                   raise RuntimeError('')
             elif _is_string_pair(k):
                if subst_type == "":
                   subst_type="string pair"
                elif subst_type == "string":
                   raise RuntimeError('')
                if not _is_string_pair(v):
                   raise RuntimeError('')
             else:
                raise RuntimeError('')

         if subst_type == "string":
            return self._substitute_symbols(s)
         else:
            return self._substitute_symbol_pairs(s)

      if _is_string(s):
         if _is_string(S):
            input=True
            output=True
            for k,v in kwargs.items():
                if k == 'input':
                   if v == False:
                      input=False
                elif k == 'output':
                   if v == False:
                      output=False
                else:
                   raise RuntimeError('Free argument not recognized.')
            return self._substitute_symbol(s, S, input, output)
         else:
            raise RuntimeError('...')
      elif _is_string_pair(s):
         if _is_string_pair(S):
            return self._substitute_symbol_pair(s, S)
         elif _is_string_pair_vector(S):
            return self._substitute_symbol_pair_with_set(s, S)
         elif isinstance(S, HfstIterableTransducer):
            return self._substitute_symbol_pair_with_transducer(s, S)
         else:
            raise RuntimeError('...')
      else:
         raise RuntimeError('...')

%}

}
        
}; // class HfstIterableTransducer

// *** HfstTransition *** //

class HfstTransition {
  public:
    HfstTransition();
    HfstTransition(hfst::implementations::HfstState, std::string, std::string, float);
    ~HfstTransition();
    HfstState get_target_state() const;
    std::string get_input_symbol() const;
    void set_input_symbol(const std::string & symbol);
    std::string get_output_symbol() const;
    void set_output_symbol(const std::string & symbol);
    float get_weight() const;
    void set_weight(float f);
  
%extend{
    char *__str__() {
      static char str[1024];
      sprintf(str, "%u %s %s %f", $self->get_target_state(), $self->get_input_symbol().c_str(), $self->get_output_symbol().c_str(), $self->get_weight());
      return str;
    }
}

}; // class HfstTransition

} // namespace implementations


// *** XreCompiler: offer only a limited set of functions ***

namespace xre {
class XreCompiler
{
  public:
  XreCompiler();
  XreCompiler(hfst::ImplementationType impl);
  void define_list(const std::string& name, const std::set<std::string>& symbol_list);
  bool define_function(const std::string& name, unsigned int arguments, const std::string& xre);
  bool is_definition(const std::string& name);
  bool is_function_definition(const std::string& name);
  void undefine(const std::string& name);
  HfstTransducer* compile(const std::string& xre);
  //HfstTransducer* compile_first(const std::string& xre, unsigned int & chars_read);
  void set_verbosity(bool verbose);
  void set_expand_definitions(bool expand); // TODO: should this be set automatically to True?
  void set_harmonization(bool harmonize);
  bool contained_only_comments();

  // *** Some wrappers *** //
%extend{
  void define_xre(const std::string& name, const std::string& xre)
  {
    self->set_expand_definitions(true);
    self->define(name, xre);
  }
  void define_transducer(const std::string& name, const HfstTransducer & transducer)
  {
    self->set_expand_definitions(true);
    self->define(name, transducer);
  }
  HfstTransducerUIntPair compile_first(const std::string & xre)
  {
    unsigned int c=0;
    hfst::HfstTransducer * result = self->compile_first(xre, c);
    return std::pair<hfst::HfstTransducer*, unsigned int>(result, c);
  }
  std::pair<hfst::HfstTransducer*,std::string> compile_iostream(const std::string & xre)
  {
    std::ostringstream os(std::ostringstream::ate);
    self->set_error_stream(&os);
    hfst::set_warning_stream(&os);
    hfst::HfstTransducer * tr = self->compile(xre);
    hfst::set_warning_stream(&std::cerr);
    self->set_error_stream(NULL);
    std::pair<hfst::HfstTransducer*,std::string> retval(tr,os.str());
    return retval;
  }
}

};
}

namespace lexc {
  class LexcCompiler
  {
    public:
      LexcCompiler();
      LexcCompiler(hfst::ImplementationType impl);
      LexcCompiler(hfst::ImplementationType impl, bool withFlags, bool alignStrings);
      LexcCompiler& setVerbosity(unsigned int verbose);
      void print_output(const char * str);
      LexcCompiler& parse(const char* filename);
      LexcCompiler& parse_line(std::string line);
      hfst::HfstTransducer* compileLexical();
  };

}

namespace xfst {
  class XfstCompiler
  {
    public:
      XfstCompiler();
      XfstCompiler(hfst::ImplementationType impl);
      XfstCompiler& setReadInteractiveTextFromStdin(bool Value);
      XfstCompiler& setReadline(bool value);
      XfstCompiler& setVerbosity(bool verbosity);
      XfstCompiler& setInspectNetSupported(bool value);
      XfstCompiler& set(const char* name, const char* text);
      std::string get(const char* name);
      HfstTransducer * top(bool silent=false);
      char * get_prompt() const;
      XfstCompiler& apply_up(const char* indata);
      XfstCompiler& apply_down(const char* indata);
      int parse_line(std::string line);
      bool quit_requested() const;
  };
}

// internal functions

std::string hfst::_get_hfst_sfst_output();
hfst::HfstTransducer * hfst::_hfst_compile_sfst(const std::string & filename, const std::string & error_stream, bool verbose);

std::string hfst::_one_level_paths_to_string(const HfstOneLevelPaths &, bool show_flags);
std::string hfst::_two_level_paths_to_string(const HfstTwoLevelPaths &);

bool _parse_prolog_network_line(const std::string & line, hfst::implementations::HfstIterableTransducer * graph);
bool _parse_prolog_arc_line(const std::string & line, hfst::implementations::HfstIterableTransducer * graph);
bool _parse_prolog_symbol_line(const std::string & line, hfst::implementations::HfstIterableTransducer * graph);
bool _parse_prolog_final_line(const std::string & line, hfst::implementations::HfstIterableTransducer * graph);


// fuctions visible under module hfst

void hfst::set_default_fst_type(hfst::ImplementationType t);
hfst::ImplementationType hfst::get_default_fst_type();
std::string hfst::fst_type_to_string(hfst::ImplementationType t);


// *** hfst_rules (will be wrapped under module hfst.rules) *** //

namespace hfst_rules {

  HfstTransducer two_level_if(const HfstTransducerPair & context, const StringPairSet & mappings, const StringPairSet & alphabet);
  HfstTransducer two_level_only_if(const HfstTransducerPair &context, const StringPairSet &mappings, const StringPairSet &alphabet);
  HfstTransducer two_level_if_and_only_if(const HfstTransducerPair &context, const StringPairSet &mappings, const StringPairSet &alphabet);
  HfstTransducer replace_down(const HfstTransducerPair * context, const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet);
  HfstTransducer replace_down_karttunen(const HfstTransducerPair &context, const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet);
  HfstTransducer replace_right(const HfstTransducerPair &context, const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet);

  // rename to avoid name collision with sfst rules
  //HfstTransducer replace_left(const HfstTransducerPair &context, const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet);
  HfstTransducer sfst_replace_left(const HfstTransducerPair &context, const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet);

  HfstTransducer replace_up(const HfstTransducerPair * context, const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet);
  HfstTransducer left_replace_up(const HfstTransducerPair * context, const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet);
  HfstTransducer left_replace_down(const HfstTransducerPair &context, const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet);
  HfstTransducer left_replace_down_karttunen(const HfstTransducerPair &context, const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet);
  HfstTransducer left_replace_left(const HfstTransducerPair &context, const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet);
  HfstTransducer left_replace_right(const HfstTransducerPair &context, const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet);

  // rename to avoid name collision with sfst rules
  //HfstTransducer restriction(const HfstTransducerPairVector &contexts, const HfstTransducer &mapping, const StringPairSet &alphabet);
  HfstTransducer sfst_restriction(const HfstTransducerPairVector &contexts, const HfstTransducer &mapping, const StringPairSet &alphabet);

  HfstTransducer coercion(const HfstTransducerPairVector &contexts, const HfstTransducer &mapping, const StringPairSet &alphabet);
  HfstTransducer restriction_and_coercion(const HfstTransducerPairVector &contexts, const HfstTransducer &mapping, const StringPairSet &alphabet);
  HfstTransducer surface_restriction(const HfstTransducerPairVector &contexts, const HfstTransducer &mapping, const StringPairSet &alphabet);
  HfstTransducer surface_coercion(const HfstTransducerPairVector &contexts, const HfstTransducer &mapping, const StringPairSet &alphabet);
  HfstTransducer surface_restriction_and_coercion(const HfstTransducerPairVector &contexts, const HfstTransducer &mapping, const StringPairSet &alphabet);
  HfstTransducer deep_restriction(const HfstTransducerPairVector &contexts, const HfstTransducer &mapping, const StringPairSet &alphabet);
  HfstTransducer deep_coercion(const HfstTransducerPairVector &contexts, const HfstTransducer &mapping, const StringPairSet &alphabet);
  HfstTransducer deep_restriction_and_coercion(const HfstTransducerPairVector &contexts, const HfstTransducer &mapping, const StringPairSet &alphabet);

} // namespace hfst_rules


} // namespace hfst

namespace hfst {
  namespace twolc {
    class TwolcCompiler
    {
    public:
      /*static int compile(const std::string & inputfile, const std::string & outputfile,
			 bool silent, bool verbose, bool resolve_left_conflicts,
			 bool resolve_right_conflicts, hfst::ImplementationType type,
			 std::ostream * ostr=NULL);*/
      static std::vector<hfst::HfstTransducer> compile_file_and_get_storable_rules
	(const std::string & inputfile,
	 bool silent, bool verbose, bool resolve_left_conflicts,
	 bool resolve_right_conflicts, hfst::ImplementationType type,
	 std::ostream * ostr=NULL);
      static std::vector<hfst::HfstTransducer> compile_script_and_get_storable_rules
	(const std::string & script,
	 bool silent, bool verbose, bool resolve_left_conflicts,
	 bool resolve_right_conflicts, hfst::ImplementationType type,
	 std::ostream * ostr=NULL);
    };
  }
}

// *** PmatchContainer *** //

// hfst_pmatch_tokenize_extensions.cc
namespace hfst {
  std::string _pmatch_get_tokenized_output(hfst_ol::PmatchContainer * cont,
					  const std::string & input_text,
					  const std::string & output_format,
					  int * max_weight_classes,
					  bool dedupe,
					  bool print_weights,
					  bool print_all,
					  double time_cutoff,
					  bool verbose,
					  float beam,
					  bool tokenize_multichar);
  hfst_ol::LocationVectorVector _pmatch_locate(hfst_ol::PmatchContainer * cont,
					      const std::string & input,
					      double time_cutoff = 0.0);
  hfst_ol::LocationVectorVector _pmatch_locate(hfst_ol::PmatchContainer * cont,
					      const std::string & input,
					      double time_cutoff,
					      float weight_cutoff);
}

namespace hfst_ol {
    class PmatchContainer
    {
    public:
        PmatchContainer(void);
        PmatchContainer(hfst::HfstTransducerVector transducers);
        ~PmatchContainer(void);
        std::string match(const std::string & input, double time_cutoff = 0.0);
        std::string get_profiling_info(void);
        void set_verbose(bool b);
        //void set_extract_tags_mode(bool b);
        void set_profile(bool b);

%extend {
	  PmatchContainer(const std::string & filename)
	    {
	      std::ifstream ifs(filename.c_str());
	      hfst_ol::PmatchContainer * retval = new hfst_ol::PmatchContainer(ifs);
	      ifs.close();
	      return retval;
	    }
	  // extension because of inf default value of weight_cutoff...
	  hfst_ol::LocationVectorVector locate(const std::string & input,
					       double time_cutoff = 0.0)
	    {
	      return hfst::_pmatch_locate(self, input, time_cutoff);
	    };
	  hfst_ol::LocationVectorVector locate(const std::string & input,
					       double time_cutoff,
					       float weight_cutoff)
	    {
	      return hfst::_pmatch_locate(self, input, time_cutoff, weight_cutoff);
	    };
%pythoncode %{
  def get_tokenized_output(self, input, **kwargs):
      """
      Tokenize *input* and get a string representation of the tokenization
      (essentially the same that command line tool hfst-tokenize would give).

      Parameters
      ----------
      * `input` :
          The input string to be tokenized.
      * `kwargs` :
          Possible parameters are:
          output_format, max_weight_classes, dedupe, print_weights, print_all,
          time_cutoff, verbose, beam, tokenize_multichar.
      * `output_format` :
          The format of output; possible values are 'tokenize', 'xerox', 'cg', 'finnpos',
          'giellacg', 'conllu' and 'visl'; 'tokenize' being the default.
      * `max_weight_classes` :
          Maximum number of best weight classes to output
          (where analyses with equal weight constitute a class), defaults to None i.e. no limit.
      * `dedupe` :
          Whether duplicate analyses are removed, defaults to False.
      * `print_weights` :
          Whether weights are printd, defaults to False.
      * `print_all` :
          Whether nonmatching text is printed, defaults to False.
      * `time_cutoff` :
          Maximum number of seconds used per input after limiting the search.
      * `verbose` :
          Whether input is processed verbosely, defaults to True.
      * `beam` :
          Beam within analyses must be to get printed.
      * `tokenize_multichar` :
          Tokenize input into multicharacter symbols present in the transducer, defaults to false.
      """
      output_format='tokenize'
      max_weight_classes=None
      dedupe=False
      print_weights=False
      print_all=False
      time_cutoff=0.0
      verbose=True
      beam=-1.0
      tokenize_multichar=False
      for k,v in kwargs.items():
         if k == 'output_format':
            if v == 'tokenize' or v == 'space_separated' or v == 'xerox' or v == 'cg' or v == 'finnpos' or v == 'giellacg' or v == 'conllu':
               output_format=v
            else:
               print('Warning: ignoring unknown value %s for argument %s.' % (v,k))
         elif k == 'max_weight_classes':
            max_weight_classes=int(v)
         elif k == 'dedupe':
            dedupe=v
         elif k == 'print_weights':
            print_weights=v
         elif k == 'print_all':
            print_all=v
         elif k == 'time_cutoff':
            time_cutoff=float(v)
         elif k == 'verbose':
            verbose=v
         elif k == 'beam':
            beam=float(v)
         elif k == 'tokenize_multichar':
            tokenize_multichar=v
         else:
            print('Warning: ignoring unknown argument %s.' % (k))
      return pmatch_get_tokenized_output(self, input, output_format, max_weight_classes, dedupe, print_weights, print_all, time_cutoff, verbose, beam, tokenize_multichar)

  def tokenize(self, input):
      """
      Tokenize *input* and return a list of tokens i.e. strings.

      Parameters
      ----------
      * `input` :
          The string to be tokenized.
      """
      retval = []
      locations = self.locate(input)
      for loc in locations:
         if loc[0].output != "@_NONMATCHING_@":
            retval.append(loc[0].input)
      return retval

%}

}

}; // class PmatchContainer
} // namespace hfst_ol

%pythoncode %{

class ImplementationType:
    """
    Back-end implementation.

    Attributes:

        SFST_TYPE:               SFST type, unweighted
        TROPICAL_OPENFST_TYPE:   OpenFst type with tropical weights
        LOG_OPENFST_TYPE:        OpenFst type with logarithmic weights (limited support)
        FOMA_TYPE:               FOMA type, unweighted
        XFSM_TYPE:               XFST type, unweighted (limited support)
        HFST_OL_TYPE:            HFST optimized-lookup type, unweighted
        HFST_OLW_TYPE:           HFST optimized-lookup type, weighted
        HFST2_TYPE:              HFST version 2 legacy type
        UNSPECIFIED_TYPE:        type not specified
        ERROR_TYPE:              (something went wrong)

    """
    SFST_TYPE = _libhfst_dev.SFST_TYPE
    TROPICAL_OPENFST_TYPE = _libhfst_dev.TROPICAL_OPENFST_TYPE
    LOG_OPENFST_TYPE = _libhfst_dev.LOG_OPENFST_TYPE
    FOMA_TYPE = _libhfst_dev.FOMA_TYPE
    XFSM_TYPE = _libhfst_dev.XFSM_TYPE
    HFST_OL_TYPE = _libhfst_dev.HFST_OL_TYPE
    HFST_OLW_TYPE = _libhfst_dev.HFST_OLW_TYPE
    HFST2_TYPE = _libhfst_dev.HFST2_TYPE
    UNSPECIFIED_TYPE = _libhfst_dev.UNSPECIFIED_TYPE
    ERROR_TYPE = _libhfst_dev.ERROR_TYPE

class ReplaceType:
    """
    Replace type in Xerox-type rules.

    Attributes:

        REPL_UP:      Match contexts on input level
        REPL_DOWN:    Match contexts on output level
        REPL_RIGHT:   Match left contexts on input level and right contexts on output level
        REPL_LEFT:    Match left contexts on output level and right contexts on input level

    """
    REPL_UP = _libhfst_dev.REPL_UP
    REPL_DOWN = _libhfst_dev.REPL_DOWN
    REPL_RIGHT = _libhfst_dev.REPL_RIGHT
    REPL_LEFT = _libhfst_dev.REPL_LEFT


from sys import version
if int(version[0]) > 2:
    def unicode(s, c):
        return s

EPSILON='@_EPSILON_SYMBOL_@'
UNKNOWN='@_UNKNOWN_SYMBOL_@'
IDENTITY='@_IDENTITY_SYMBOL_@'

def start_xfst(**kwargs):
    """
    Start interactive xfst compiler.

    Parameters
    ----------
    * `kwargs` :
        Arguments recognized are: type, quit_on_fail.
    * `quit_on_fail` :
        Whether the compiler exits on any error, defaults to False.
    * `type` :
        Implementation type of the compiler, defaults to
        hfst_dev.get_default_fst_type().
    """
    type = get_default_fst_type()
    quit_on_fail = 'OFF'
    for k,v in kwargs.items():
      if k == 'type':
        type = v
      elif k == 'quit_on_fail':
        if v == True:
          quit_on_fail='ON'
      else:
        print('Warning: ignoring unknown argument %s.' % (k))

    comp = XfstCompiler(type)
    comp.setReadInteractiveTextFromStdin(True) # ?
    comp.setReadline(False) # do not mix python and c++ readline
    comp.set('quit-on-fail', quit_on_fail)

    rl_length_1 = 0
    rl_found = False
    try:
      import readline
      rl_found = True
      rl_length_1 = readline.get_current_history_length()
    except ImportError:
      pass

    expression=""
    while True:
        expression += input(comp.get_prompt()).rstrip().lstrip()
        if len(expression) == 0:
           continue
        if expression[-1] == '\\':
           expression = expression[:-2] + '\n'
           continue
        retval = -1
        if True:
            if (expression == "apply down" or expression == "apply up" or expression == "inspect" or expression == "inspect net"):
               stdout.write('interactive command \'' + expression + '\' not supported\n')
               retval = 0
            # Viewing must be handled in python
            elif (expression == "view" or expression == "view net"):
               tr = comp.top(True) # silent mode
               if tr == None:
                  stdout.write('Empty stack.\n')
                  if comp.get("quit-on-fail") == "ON":
                     return
               else:
                  from IPython.core.display import display, SVG
                  display(SVG(tr.view()._repr_svg_()))
               retval = 0
            else:
               retval = comp.parse_line(expression);
        # at the moment, interactive commands are not supported
        else:
            # interactive command
            if (expression == "apply down" or expression == "apply up"):
               rl_length_2=0
               if rl_found:
                  rl_length_2 = readline.get_current_history_length()
               while True:
                  try:
                     line = input().rstrip().lstrip()
                  except EOFError:
                     break
                  if expression == "apply down":
                     comp.apply_down(line)
                  elif expression == "apply up":
                     comp.apply_up(line)
               if rl_found:
                  for foo in range(readline.get_current_history_length() - rl_length_2):
                     readline.remove_history_item(rl_length_2)
               retval = 0
            elif expression == "inspect" or expression == "inspect net":
               print('inspect net not supported')
               retval = 0
            else:
               retval = comp.parse_line(expression + "\n")
        if retval != 0:
           stdout.write("expression '%s' could not be parsed\n" % expression)
           if comp.get("quit-on-fail") == "ON":
              return
        if comp.quit_requested():
           break
        expression = ""

    if rl_found:
      for foo in range(readline.get_current_history_length() - rl_length_1):
         readline.remove_history_item(rl_length_1)

from sys import stdout

def regex(re, **kwargs):
    """
    Get a transducer as defined by regular expression *re*.

    Parameters
    ----------
    * `re` :
        The regular expression defined with Xerox transducer notation.
    * `kwargs` :
        Arguments recognized are: 'output' and 'definitions'.
    * `output` :
        Where warnings and errors are printed. Possible values are sys.stderr
        (the default), a StringIO or None, indicating a quiet mode.
    * `definitions` :
        A dictionary mapping variable names into transducers.


    Regular expression operators:

    ~   complement
    \   term complement
    &   intersection
    -   minus

    $.  contains once
    $?  contains optionally
    $   contains once or more
    ( ) optionality

    +   Kleene plus
    *   Kleene star

    ./. ignore internally (not yet implemented)
    /   ignoring

    |   union

    <>  shuffle
    <   before
    >   after

    .o.   composition
    .O.   lenient composition
    .m>.  merge right
    .<m.  merge left
    .x.   cross product
    .P.   input priority union
    .p.   output priority union
    .-u.  input minus
    .-l.  output minus
    `[ ]  substitute

    ^n,k  catenate from n to k times, inclusive
    ^>n   catenate more than n times
    ^>n   catenate less than n times
    ^n    catenate n times

    .r   reverse
    .i   invert
    .u   input side
    .l   output side

    \\\\\\  left quotient

    Two-level rules:

     \<=   left restriction
     <=>   left and right arrow
     <=    left arrow
     =>    right arrow

    Replace rules:

     ->    replace right
     (->)  optionally replace right
     <-    replace left
     (<-)  optionally replace left
     <->   replace left and right
     (<->) optionally replace left and right
     @->   left-to-right longest match
     @>    left-to-right shortest match
     ->@   right-to-left longest match
     >@    right-to-left shortest match

    Rule contexts, markers and separators:

     ||   match contexts on input sides
     //   match left context on output side and right context on input side
     \\   match left context on input side and right context on output side
     \/   match contexts on output sides
     _    center marker
     ...  markup marker
     ,,   rule separator in parallel rules
     ,    context separator
     [. .]  match epsilons only once

    Read from file:

     @bin" "  read binary transducer
     @txt" "  read transducer in att text format
     @stxt" " read spaced text
     @pl" "   read transducer in prolog text format
     @re" "   read regular expression

    Symbols:

     .#.  word boundary symbol in replacements, restrictions
     0    the epsilon
     ?    any token
     %    escape character
     { }  concatenate symbols
     " "  quote symbol

    :    pair separator
    ::   weight

    ;   end of expression
    !   starts a comment until end of line
    #   starts a comment until end of line
    """
    type_ = get_default_fst_type()
    defs=None
    import sys
    output=sys.stderr

    for k,v in kwargs.items():
      if k == 'output':
          output=v;
      elif k == 'definitions':
          defs=v;
      else:
        print('Warning: ignoring unknown argument %s.' % (k))

    comp = XreCompiler(type_)
    if not defs == None:
        for k,v in defs.items():
            vtype = str(type(v))
            if "HfstTransducer" in vtype:
                comp.define_transducer(k,v)
                # print('defining transducer')
            else:
                pass

    comp.set_verbosity((output != None))
    if 'StringIO' in str(type(output)):
        retval = comp.compile_iostream(re)
        output.write(retval[1])
        return retval[0]
    else:
        return comp.compile(re)

def _replace_symbols(symbol, epsilonstr=EPSILON):
    if symbol == epsilonstr:
       return EPSILON
    if symbol == "@0@":
       return EPSILON
    symbol = symbol.replace("@_SPACE_@", " ")
    symbol = symbol.replace("@_TAB_@", "\t")
    symbol = symbol.replace("@_COLON_@", ":")
    return symbol

def _parse_att_line(line, fsm, epsilonstr=EPSILON):
    # get rid of extra whitespace
    line = line.replace('\t',' ')
    line = " ".join(line.split())
    fields = line.split(' ')
    try:
        if len(fields) == 1:
           if fields[0] == '': # empty transducer...
               return True
           fsm.add_state(int(fields[0]))
           fsm.set_final_weight(int(fields[0]), 0)
        elif len(fields) == 2:
           fsm.add_state(int(fields[0]))
           fsm.set_final_weight(int(fields[0]), float(fields[1]))
        elif len(fields) == 4:
           fsm.add_transition(int(fields[0]), int(fields[1]), _replace_symbols(fields[2]), _replace_symbols(fields[3]), 0)
        elif len(fields) == 5:
           fsm.add_transition(int(fields[0]), int(fields[1]), _replace_symbols(fields[2]), _replace_symbols(fields[3]), float(fields[4]))
        else:
           return False
    except ValueError as e:
        return False
    return True

def read_att_string(att):
    """
    Create a transducer as defined in AT&T format in *att*.
    """
    linecount = 0
    fsm = HfstIterableTransducer()
    lines = att.split('\n')
    for line in lines:
        linecount = linecount + 1
        if not _parse_att_line(line, fsm):
           raise hfst_dev.exceptions.NotValidAttFormatException(line, "", linecount)
    return HfstTransducer(fsm, get_default_fst_type())

def read_att_input():
    """
    Create a transducer as defined in AT&T format in user input.
    An empty line signals the end of input.
    """
    linecount = 0
    fsm = HfstIterableTransducer()
    while True:
        line = input().rstrip()
        if line == "":
           break
        linecount = linecount + 1
        if not _parse_att_line(line, fsm):
           raise hfst_dev.exceptions.NotValidAttFormatException(line, "", linecount)
    return HfstTransducer(fsm, get_default_fst_type())

def read_att_transducer(f, epsilonstr=EPSILON, linecount=[0]):
    """
    Create a transducer as defined in AT&T format in file *f*. *epsilonstr*
    defines how epsilons are represented. *linecount* keeps track of the current
    line in the file.
    """
    linecount_ = 0
    fsm = HfstIterableTransducer()
    while True:
        line = f.readline()
        if line == "":
           if linecount_ == 0:
              raise hfst_dev.exceptions.EndOfStreamException("","",0)
           else:
              linecount_ = linecount_ + 1
              break
        linecount_ = linecount_ + 1
        if line[0] == '-':
           break
        if not _parse_att_line(line, fsm, epsilonstr):
           raise hfst_dev.exceptions.NotValidAttFormatException(line, "", linecount[0] + linecount_)
    linecount[0] = linecount[0] + linecount_
    return HfstTransducer(fsm, get_default_fst_type())

class AttReader:
      """
      A class for reading input in AT&T text format and converting it into
      transducer(s).

      An example that reads AT&T input from file 'testfile.att' where epsilon is
      represented as \"<eps>\" and creates the corresponding transducers and prints
      them. If the input cannot be parsed, a message showing the invalid line in AT&T
      input is printed and reading is stopped.

      with open('testfile.att', 'r') as f:
           try:
                r = hfst_dev.AttReader(f, \"<eps>\")
                for tr in r:
                    print(tr)
           except hfst_dev.exceptions.NotValidAttFormatException as e:
                print(e.what())
      """
      def __init__(self, f, epsilonstr=EPSILON):
          """
          Create an AttReader that reads input from file *f* where the epsilon is
          represented as *epsilonstr*.

          Parameters
          ----------
          * `f` :
              A python file.
          * `epsilonstr` :
              How epsilon is represented in the file. By default, \"@_EPSILON_SYMBOL_@\"
              and \"@0@\" are both recognized.
          """
          self.file = f
          self.epsilonstr = epsilonstr
          self.linecount = [0]

      def read(self):
          """
          Read next transducer.

          Read next transducer description in AT&T format and return a corresponding
          transducer.

          Exceptions
          ----------
          * `hfst_dev.exceptions.NotValidAttFormatException` :
          * `hfst_dev.exceptions.EndOfStreamException` :
          """
          return read_att_transducer(self.file, self.epsilonstr, self.linecount)

      def __iter__(self):
          """
          An iterator to the reader.

          Needed for 'for ... in' statement.

          for transducer in att_reader:
              print(transducer)
          """
          return self

      def next(self):
          """
          Return next element (for python version 3).

          Needed for 'for ... in' statement.

          for transducer in att_reader:
              print(transducer)

          Exceptions
          ----------
          * `StopIteration` :
          """
          try:
             return self.read()
          except hfst_dev.exceptions.EndOfStreamException as e:
             raise StopIteration

      def __next__(self):
          """
          Return next element (for python version 2).

          Needed for 'for ... in' statement.

          for transducer in att_reader:
              print(transducer)

          Exceptions
          ----------
          * `StopIteration` :
          """
          return self.next()

def read_prolog_transducer(f, linecount=[0]):
    """
    Create a transducer as defined in prolog format in file *f*. *linecount*
    keeps track of the current line in the file.
    """
    linecount_ = 0
    fsm = HfstIterableTransducer()

    line = ""
    while(True):
        line = f.readline()
        linecount_ = linecount_ + 1
        if line == "":
            raise hfst_dev.exceptions.EndOfStreamException("","",linecount[0] + linecount_)
        line = line.rstrip()
        if line == "":
            pass # allow extra prolog separator(s)
        if line[0] == '#':
            pass # comment line
        else:
            break

    if not _libhfst_dev._parse_prolog_network_line(line, fsm):
        raise hfst_dev.exceptions.NotValidPrologFormatException(line,"",linecount[0] + linecount_)

    while(True):
        line = f.readline()
        if (line == ""):
            retval = HfstTransducer(fsm, get_default_fst_type())
            retval.set_name(fsm.name)
            linecount[0] = linecount[0] + linecount_
            return retval
        line = line.rstrip()
        linecount_ = linecount_ + 1
        if line == "":  # prolog separator
            retval = HfstTransducer(fsm, get_default_fst_type())
            retval.set_name(fsm.name)
            linecount[0] = linecount[0] + linecount_
            return retval
        if _libhfst_dev._parse_prolog_arc_line(line, fsm):
            pass
        elif _libhfst_dev._parse_prolog_final_line(line, fsm):
            pass
        elif _libhfst_dev._parse_prolog_symbol_line(line, fsm):
            pass
        else:
            raise hfst_dev.exceptions.NotValidPrologFormatException(line,"",linecount[0] + linecount_)

class PrologReader:
      """
      A class for reading input in prolog text format and converting it into
      transducer(s).

      An example that reads prolog input from file 'testfile.prolog' and creates the
      corresponding transducers and prints them. If the input cannot be parsed, a
      message showing the invalid line in prolog input is printed and reading is
      stopped.

          with open('testfile.prolog', 'r') as f:
              try:
                 r = hfst_dev.PrologReader(f)
                 for tr in r:
                     print(tr)
              except hfst_dev.exceptions.NotValidPrologFormatException as e:
                  print(e.what())
      """
      def __init__(self, f):
          """
          Create a PrologReader that reads input from file *f*.

          Parameters
          ----------
          * `f` :
              A python file.
          """
          self.file = f
          self.linecount = [0]

      def read(self):
          """

          Read next transducer.

          Read next transducer description in prolog format and return a corresponding
          transducer.

          Exceptions
          ----------
          * `hfst_dev.exceptions.NotValidPrologFormatException` :
          * `hfst_dev.exceptions.EndOfStreamException` :
          """
          return read_prolog_transducer(self.file, self.linecount)

      def __iter__(self):
          """
          An iterator to the reader.

          Needed for 'for ... in' statement.

          for transducer in prolog_reader:
              print(transducer)
          """
          return self

      def next(self):
          """
          Return next element (for python version 2).

          Needed for 'for ... in' statement.

          for transducer in prolog_reader:
              print(transducer)

          Exceptions
          ----------
          * `StopIteration` :
          """
          try:
             return self.read()
          except hfst_dev.exceptions.EndOfStreamException as e:
             raise StopIteration

      def __next__(self):
          """
          Return next element (for python version 2).

          Needed for 'for ... in' statement.

          for transducer in prolog_reader:
              print(transducer)

          Exceptions
          ----------
          * `StopIteration` :
          """
          return self.next()

def compile_xfst_file(filename, **kwargs):
    """
    Compile (run) xfst.

    Parameters
    ----------
    * `filename` :
        The name of the xfst file.
    * `kwargs` :
        Arguments recognized are: verbosity, quit_on_fail, output, type.
    * `verbosity` :
        The verbosity of the compiler, defaults to 0 (silent). Possible values are:
        0, 1, 2.
    * `quit_on_fail` :
        Whether the script is exited on any error, defaults to True.
    * `output` :
        Where output is printed. Possible values are sys.stdout, sys.stderr, a
        StringIO, sys.stdout being the default.
    * `type` :
        Implementation type of the compiler, defaults to
        hfst_dev.get_default_fst_type().

    Returns
    -------
    On success 0, else an integer greater than 0.
    """
    return _compile_xfst(filename=filename, **kwargs)

def compile_xfst_script(script, **kwargs):
    """
    Compile (run) xfst.

    Parameters
    ----------
    * `script` :
        The xfst script to be compiled (a string).
    * `kwargs` :
        Arguments recognized are: verbosity, quit_on_fail, output, type.
    * `verbosity` :
        The verbosity of the compiler, defaults to 0 (silent). Possible values are:
        0, 1, 2.
    * `quit_on_fail` :
        Whether the script is exited on any error, defaults to True.
    * `output` :
        Where output is printed. Possible values are sys.stdout, sys.stderr, a
        StringIO, sys.stdout being the default.
    * `type` :
        Implementation type of the compiler, defaults to
        hfst_dev.get_default_fst_type().

    Returns
    -------
    On success 0, else an integer greater than 0.
    """
    return _compile_xfst(script=script, **kwargs)

def _compile_xfst(**kwargs):
    """
    Compile (run) xfst.

    Parameters
    ----------
    * `kwargs` :
        Arguments recognized are: filename, data, verbosity, quit_on_fail, output, type.
    * `filename` :
        The name of the xfst file.
    * `script` :
        The xfst script to be compiled (a string).
    * `verbosity` :
        The verbosity of the compiler, defaults to 0 (silent). Possible values are:
        0, 1, 2.
    * `quit_on_fail` :
        Whether the script is exited on any error, defaults to True.
    * `output` :
        Where output is printed. Possible values are sys.stdout, sys.stderr, a
        StringIO, sys.stdout being the default.
    * `type` :
        Implementation type of the compiler, defaults to
        hfst_dev.get_default_fst_type().

    Returns
    -------
    On success 0, else an integer greater than 0.
    """
    if int(version[0]) > 2:
      pass
    else:
      raise RuntimeError('hfst_dev.compile_xfst_file not supported for python version 2')
    verbosity=0
    quit_on_fail='ON'
    type = get_default_fst_type()
    import sys
    output=sys.stdout
    filename=None
    script=None

    for k,v in kwargs.items():
      if k == 'verbosity':
        verbosity=v
      elif k == 'quit_on_fail':
        if v == False:
          quit_on_fail='OFF'
      elif k == 'output':
          output=v
      elif k == 'filename':
          filename=v
      elif k == 'script':
          script=v
      else:
        print('Warning: ignoring unknown argument %s.' % (k))

    if verbosity > 1:
      output.write('Compiling with %s implementation...' % fst_type_to_string(type))
    xfstcomp = XfstCompiler(type)
    xfstcomp.setVerbosity(verbosity > 0)
    xfstcomp.setInspectNetSupported(False)
    xfstcomp.set('quit-on-fail', quit_on_fail)
    if filename == None:
      data = script
    else:
      if verbosity > 1:
        output.write('Opening xfst file %s...' % filename)
      f = open(filename, 'r', encoding='utf-8')
      data = f.read()
      f.close()
      if verbosity > 1:
        output.write('File closed...')

    retval = xfstcomp.parse_line(data);
    #retval=-1
    #retval = _libhfst_dev.hfst_compile_xfst_to_string_one(xfstcomp, data)
    #output.write(unicode(_libhfst_dev.get_hfst_xfst_string_one(), 'utf-8'))

    if verbosity > 1:
      output.write('Parsed file with return value %i (0 indicating succesful parsing).' % retval)
    return retval

def compile_twolc_file(filename, **kwargs):
    """
    Compile twolc file *filename* and return the result.

    Parameters
    ----------
    * `filename` :
        The name of the twolc input file.
    * `kwargs` :
        Arguments recognized are: silent, verbose, resolve_right_conflicts, resolve_left_conflicts, type.
    * `silent` :
        Whether compilation is performed in silent mode, defaults to False.
    * `verbose` :
        Whether compilation is performed in verbose mode, defaults to False.
    * `resolve_right_conflicts` :
        Whether right arrow conflicts are resolved, defaults to True.
    * `resolve_left_conflicts` :
        Whether left arrow conflicts are resolved, defaults to False.
    * `type` :
        Implementation type of the compiler, defaults to hfst_dev.get_default_fst_type().

    Returns
    -------
    The compiled rules.
    """
    return _compile_twolc(filename=filename, **kwargs)

def compile_twolc_script(script, **kwargs):
    """
    Compile twolc script *script* and return the result.

    Parameters
    ----------
    * `script` :
        The twolc script.
    * `kwargs` :
        Arguments recognized are: silent, verbose, resolve_right_conflicts, resolve_left_conflicts, type.
    * `silent` :
        Whether compilation is performed in silent mode, defaults to False.
    * `verbose` :
        Whether compilation is performed in verbose mode, defaults to False.
    * `resolve_right_conflicts` :
        Whether right arrow conflicts are resolved, defaults to True.
    * `resolve_left_conflicts` :
        Whether left arrow conflicts are resolved, defaults to False.
    * `type` :
        Implementation type of the compiler, defaults to hfst_dev.get_default_fst_type().

    Returns
    -------
    A tuple containing the compiled rules.
    """
    return _compile_twolc(script=script, **kwargs)

def _compile_twolc(**kwargs):
    """
    Compile twolc script *script* and return the result.

    Parameters
    ----------
    * `kwargs` :
        Arguments recognized are: script, inputfilename, silent, verbose, resolve_right_conflicts, resolve_left_conflicts, type.
    * `script` :
        The twolc script.
    * `filename` :
        The name of the twolc input file.
    * `silent` :
        Whether compilation is performed in silent mode, defaults to False.
    * `verbose` :
        Whether compilation is performed in verbose mode, defaults to False.
    * `resolve_right_conflicts` :
        Whether right arrow conflicts are resolved, defaults to True.
    * `resolve_left_conflicts` :
        Whether left arrow conflicts are resolved, defaults to False.
    * `type` :
        Implementation type of the compiler, defaults to hfst_dev.get_default_fst_type().

    Returns
    -------
    A tuple containing the compiled rules.
    """
    script=None
    filename=None
    silent=False
    verbose=False
    resolve_right_conflicts=True
    resolve_left_conflicts=False
    implementation_type=get_default_fst_type()

    for k,v in kwargs.items():
        if k == 'script':
            script = v
        elif k == 'filename':
            filename = v
        elif k == 'type':
            implementation_type = v
        elif k == 'silent':
            silent=v
        elif k == 'verbose':
            verbose=v
        elif k == 'resolve_right_conflicts':
            resolve_right_conflicts=v
        elif k == 'resolve_left_conflicts':
            resolve_left_conflicts=v
        else:
            print('Warning: ignoring unknown argument %s.' % (k))

    if filename == None:
        retval = TwolcCompiler.compile_script_and_get_storable_rules(script, silent, verbose,
                                                    resolve_right_conflicts, resolve_left_conflicts,
                                                    implementation_type)
    else:
        retval = TwolcCompiler.compile_file_and_get_storable_rules(filename, silent, verbose,
                                                    resolve_right_conflicts, resolve_left_conflicts,
                                                    implementation_type)
    return retval

def compile_pmatch_file(filename):
    """
    Compile pmatch expressions as defined in *filename* and return a tuple of
    transducers.

    An example:

    If we have a file named streets.txt that contains:

    define CapWord UppercaseAlpha Alpha* ; define StreetWordFr [{avenue} |
    {boulevard} | {rue}] ; define DeFr [ [{de} | {du} | {des} | {de la}] Whitespace
    ] | [{d'} | {l'}] ; define StreetFr StreetWordFr (Whitespace DeFr) CapWord+ ;
    regex StreetFr EndTag(FrenchStreetName) ;

    we can run:

    defs = hfst_dev.compile_pmatch_file('streets.txt')
    const = hfst_dev.PmatchContainer(defs)
    assert cont.match("Je marche seul dans l'avenue desTernes.") ==
      "Je marche seul dans l'<FrenchStreetName>avenue des Ternes</FrenchStreetName>."
    """
    with open(filename, 'r') as myfile:
      data=myfile.read()
      myfile.close()
    defs = compile_pmatch_expression(data)
    return defs

def compile_sfst_file(filename, **kwargs):
    """
    Compile sfst file *filename* into a transducer.

    Parameters
    ----------
    * `filename` :
        The name of the sfst file.
    * `kwargs` :
        Arguments recognized are: verbose, output.
    * `verbose` :
        Whether sfst file is processed in verbose mode, defaults to False.
    * `output` :
        Where output is printed. Possible values are sys.stdout, sys.stderr, a
        StringI0, sys.stderr being the default. TODO

    Returns
    -------
    On success the resulting transducer, else None.
    """
    verbosity=False
    type = get_default_fst_type()
    output=None

    for k,v in kwargs.items():
      if k == 'verbose':
        verbosity=v
      elif k == 'output':
          output=v
      else:
        print('Warning: ignoring unknown argument %s.' % (k))

    retval=None
    import sys
    if output == None:
       retval = _hfst_compile_sfst(filename, "", verbosity)
    elif output == sys.stdout:
       retval = libhfst_dev._hfst_compile_sfst(filename, "cout", verbosity)
    elif output == sys.stderr:
       retval = _hfst_compile_sfst(filename, "cerr", verbosity)
    else:
       retval = _hfst_compile_sfst(filename, "", verbosity)
       output.write(unicode(_get_hfst_sfst_output(), 'utf-8'))

    return retval

def _compile_lexc(**kwargs):
    """
    Compile lexc into a transducer.

    Parameters
    ----------
    * `kwargs` :
        Arguments recognized are: filenames, script, verbosity, with_flags, output.
    * `filenames` :
        The names of the lexc files.
    * `script` :
        The lexc script to be compiled (a string).
    * `verbosity` :
        The verbosity of the compiler, defaults to 0 (silent). Possible values are:
        0, 1, 2.
    * `with_flags` :
        Whether lexc flags are used when compiling, defaults to False.
    * `output` :
        Where output is printed. Possible values are sys.stdout, sys.stderr, a
        StringIO, sys.stderr being the default.

    Returns
    -------
    On success the resulting transducer, else None.
    """
    verbosity=0
    withflags=False
    alignstrings=False
    type = get_default_fst_type()
    import sys
    output=sys.stderr
    filenames=None
    script=None

    for k,v in kwargs.items():
      if k == 'verbosity':
        verbosity=v
      elif k == 'with_flags':
        if v == True:
          withflags = v
      elif k == 'align_strings':
          alignstrings = v
      elif k == 'output':
          output=v
      elif k == 'filenames':
          filenames=v
      elif k == 'script':
          script=v

      else:
        print('Warning: ignoring unknown argument %s.' % (k))

    lexccomp = LexcCompiler(type, withflags, alignstrings)
    lexccomp.setVerbosity(verbosity)

    retval=-1
    if filenames == None:
        lexccomp.parse_line(script)
        retval = lexccomp.compileLexical()
        #retval = hfst_compile_lexc_script(lexccomp, script, "")
        #output.write(unicode(get_hfst_lexc_output(), 'utf-8'))
    else:
        for filename in filenames:
            lexccomp.parse(filename)
        retval = lexccomp.compileLexical()
        #retval = hfst_compile_lexc_files(lexccomp, filenames, "")
        #output.write(unicode(get_hfst_lexc_output(), 'utf-8'))

    return retval

def compile_lexc_file(filename, **kwargs):
    """
    Compile lexc file *filename* or into a transducer.

    Parameters
    ----------
    * `filename` :
        The name of the lexc file.
    * `kwargs` :
        Arguments recognized are: verbosity, with_flags, output.
    * `verbosity` :
        The verbosity of the compiler, defaults to 0 (silent). Possible values are:
        0, 1, 2.
    * `with_flags` :
        Whether lexc flags are used when compiling, defaults to False.
    * `output` :
        Where output is printed. Possible values are sys.stdout, sys.stderr, a
        StringIO, sys.stderr being the default.

    Returns
    -------
    On success the resulting transducer, else None.
    """
    return _compile_lexc(filenames=(filename,), **kwargs)

def compile_lexc_files(filenames, **kwargs):
    """
    Compile lexc files *filenames* or into a transducer.

    Parameters
    ----------
    * `filenames` :
        The list of lexc filenames.
    * `kwargs` :
        Arguments recognized are: verbosity, with_flags, output.
    * `verbosity` :
        The verbosity of the compiler, defaults to 0 (silent). Possible values are:
        0, 1, 2.
    * `with_flags` :
        Whether lexc flags are used when compiling, defaults to False.
    * `output` :
        Where output is printed. Possible values are sys.stdout, sys.stderr, a
        StringIO, sys.stderr being the default.

    Returns
    -------
    On success the resulting transducer, else None.
    """
    return _compile_lexc(filenames=filenames, **kwargs)

def compile_lexc_script(script, **kwargs):
    """
    Compile lexc script *script* into a transducer.

    Parameters
    ----------
    * `script` :
        The lexc script to be compiled (a string).
    * `kwargs` :
        Arguments recognized are: verbosity, with_flags, output.
    * `verbosity` :
        The verbosity of the compiler, defaults to 0 (silent). Possible values are:
        0, 1, 2.
    * `with_flags` :
        Whether lexc flags are used when compiling, defaults to False.
    * `output` :
        Where output is printed. Possible values are sys.stdout, sys.stderr, a
        StringIO, sys.stderr being the default.

    Returns
    -------
    On success the resulting transducer, else None.
    """
    return _compile_lexc(script=script, **kwargs)

def _is_weighted_word(arg):
    if isinstance(arg, tuple) and len(arg) == 2 and isinstance(arg[0], str) and isinstance(arg[1], (int, float)):
       return True
    return False

def _check_word(arg):
    if len(arg) == 0:
       raise RuntimeError('Empty word.')
    return arg

def fsa(arg):
    """
    Get a transducer (automaton in this case) that recognizes one or more paths.

    Parameters
    ----------
    * `arg` :
        See example below

    Possible inputs:

      One unweighted identity path:
        'foo'  ->  [f o o]

      Weighted path: a tuple of string and number, e.g.
        ('foo',1.4)
        ('bar',-3)
        ('baz',0)

      Several paths: a list or a tuple of paths and/or weighted paths, e.g.
        ['foo', 'bar']
        ('foo', ('bar',5.0))
        ('foo', ('bar',5.0), 'baz', 'Foo', ('Bar',2.4))
        [('foo',-1), ('bar',0), ('baz',3.5)]

    """
    deftok = HfstTokenizer()
    retval = HfstIterableTransducer()
    if isinstance(arg, str):
       if len(arg) == 0:
           retval.set_final_weight(0, 0) # epsilon transducer with zero weight
       else:
           retval.disjunct(deftok.tokenize(_check_word(arg)), 0)
    elif _is_weighted_word(arg):
       if len(arg) == 0:
           retval.set_final_weight(0, arg[1]) # epsilon transducer with weight
       else:
           retval.disjunct(deftok.tokenize(_check_word(arg[0])), arg[1])
    elif isinstance(arg, tuple) or isinstance(arg, list):
       for word in arg:
           if _is_weighted_word(word):
              if len(word) == 0:
                  retval.set_final_weight(0, word[1]) # epsilon transducer with weight
              else:
                  retval.disjunct(deftok.tokenize(_check_word(word[0])), word[1])
           elif isinstance(word, str):
              if len(word) == 0:
                  retval.set_final_weight(0, 0) # epsilon transducer with zero weight
              else:
                  retval.disjunct(deftok.tokenize(_check_word(word)), 0)
           else:
              raise RuntimeError('Tuple/list element not a string or tuple of string and weight.')
    else:
       raise RuntimeError('Not a string or tuple/list of strings.')
    return HfstTransducer(retval, get_default_fst_type())

def fst(arg):
    """
    Get a transducer that recognizes one or more paths.

    Parameters
    ----------
    * `arg` :
        See example below

    Possible inputs:

      One unweighted identity path:
        'foo'  ->  [f o o]

      Weighted path: a tuple of string and number, e.g.
        ('foo',1.4)
        ('bar',-3)
        ('baz',0)

      Several paths: a list or a tuple of paths and/or weighted paths, e.g.
        ['foo', 'bar']
        ('foo', ('bar',5.0))
        ('foo', ('bar',5.0), 'baz', 'Foo', ('Bar',2.4))
        [('foo',-1), ('bar',0), ('baz',3.5)]

      A dictionary mapping strings to any of the above cases:
        {'foo':'foo', 'bar':('foo',1.4), 'baz':(('foo',-1),'BAZ')}
    """
    if isinstance(arg, dict):
       retval = regex('[0-0]') # empty transducer
       for input, output in arg.items():
           if not isinstance(input, str):
              raise RuntimeError('Key not a string.')
           left = fsa(input)
           right = 0
           if isinstance(output, str):
              right = fsa(output)
           elif isinstance(output, list) or isinstance(output, tuple):
              right = fsa(output)
           else:
              raise RuntimeError('Value not a string or tuple/list of strings.')
           left.cross_product(right)
           retval.disjunct(left)
       return retval
    return fsa(arg)

def fst_to_fsa(fst, separator=''):
    """
    (Experimental)

    Encode a transducer into an automaton, i.e. create a transducer where each
    transition <in:out> of *fst* is replaced with a transition <inSout:inSout>
    where 'S' is *separator*, except if the transition symbol on both sides is
    hfst_dev.EPSILON, hfst_dev.IDENTITY or hfst_dev.UNKNOWN.

    All states and weights of transitions and end states are copied otherwise
    as such. The alphabet is copied, and new symbols which are created when
    encoding the transitions, are inserted to it.

    Parameters
    ----------
    * `fst` :
        The transducer.
    * `separator` :
        The separator symbol inserted between input and output symbols.

    Examples:

        import hfst
        foo2bar = hfst_dev.fst({'foo':'bar'})

    creates a transducer [f:b o:a o:r]. Calling

        foobar = hfst_dev.fst_to_fsa(foo2bar)

    will create the transducer [fb:fb oa:oa or:or] and

        foobar = hfst_dev.fst_to_fsa(foo2bar, '^')

    the transducer [f^b:f^b o^a:o^a o^r:o^r].

    """
    encoded_symbols = StringSet()
    retval = hfst_dev.HfstIterableTransducer(fst)
    for state in retval.states():
        arcs = retval.transitions(state)
        for arc in arcs:
            input = arc.get_input_symbol()
            output = arc.get_output_symbol()
            if (input == output) and ((input == hfst_dev.EPSILON) or (input == hfst_dev.UNKNOWN) or (input == hfst_dev.IDENTITY)):
                continue
            symbol = input + separator + output
            arc.set_input_symbol(symbol)
            arc.set_output_symbol(symbol)
            encoded_symbols.insert(symbol)
    retval.add_symbols_to_alphabet(encoded_symbols)
    if 'HfstTransducer' in str(type(fst)):
        return hfst_dev.HfstTransducer(retval)
    else:
        return retval

def fsa_to_fst(fsa, separator=''):
    """
    (Experimental)

    Decode an encoded automaton back into a transducer, i.e. create a
    transducer where each transition <inSout:inSout> of *fsa*, where 'S' is
    the first *separator* found in the compound symbol 'inSout', is replaced
    with a transition <in:out>.

    If no *separator* is found in the symbol, transition is copied as such. All
    states and weights of transitions and end states are copied as such. The
    alphabet is copied, omitting encoded symbols which were decoded according
    to *separator*. Any new input and output symbols extracted from encoded
    symbols are added to the alphabet.

    If *separator* is the empty string, 'in' must either be single-character
    symbol or a special symbol of form '@...@'.

    Parameters
    ----------
    * `fsa` :
        The encoded transducer. Must be an automaton, i.e. for each
        transition, the input and output symbols must be the same. Else, a
        RuntimeError is thrown.
    * `separator` :
        The symbol separating input and output symbol parts in *fsa*. If it is
        the empty string, each encoded transition symbol is must be of form
        'x...' (single-character input symbol 'x') or '@...@...' (special
        symbol as input symbol). Else, a RuntimeError is thrown.

    Examples:

        import hfst
        foo2bar = hfst_dev.fst({'foo':'bar'})  # creates transducer [f:b o:a o:r]
        foobar = hfst_dev.fst_to_fsa(foo2bar, '^')

    creates the transducer [f^b:f^b o^a:o^a o^r:o^r]. Then calling

        foo2bar = hfst_dev.fsa_to_fst(foobar, '^')

    will create again the original transducer [f:b o:a o:r].
    """
    retval = hfst_dev.HfstIterableTransducer(fsa)
    encoded_symbols = StringSet()
    for state in retval.states():
        arcs = retval.transitions(state)
        for arc in arcs:
            input = arc.get_input_symbol()
            output = arc.get_output_symbol()
            symbols = []
            if not (input == output):
                raise RuntimeError('Transition input and output symbols differ.')
            if input == "":
                raise RuntimeError('Transition symbol cannot be the empty string.')
            # separator given:
            if len(separator) > 0:
                symbols = input.split(separator, 1)
            # no separator given:
            else:
                index = input.find('@')
                if not index == 0:
                    symbols.append(input[0])
                    if not input[1] == '':
                        symbols.append(input[1:])
                else:
                    index = input.find('@', 1)
                    if index == -1:
                        raise RuntimeError('Transition symbol cannot have only one "@" sign.')
                    symbols.append(input[0:index+1])
                    if not input[index+1] == '':
                        symbols.append(input[index+1:])
            arc.set_input_symbol(symbols[0])
            arc.set_output_symbol(symbols[-1])
            # encoded symbol to be removed from alphabet of result
            if len(symbols) > 1:
                encoded_symbols.insert(input)
    retval.remove_symbols_from_alphabet(encoded_symbols)
    if 'HfstTransducer' in str(type(fsa)):
        return hfst_dev.HfstTransducer(retval)
    else:
        return retval

def tokenized_fst(arg, weight=0):
    """
    Get a transducer that recognizes the concatenation of symbols or symbol pairs in
    *arg*.

    Parameters
    ----------
    * `arg` :
        The symbols or symbol pairs that form the path to be recognized.

    Example

       import hfst
       tok = hfst_dev.HfstTokenizer()
       tok.add_multichar_symbol('foo')
       tok.add_multichar_symbol('bar')
       tr = hfst_dev.tokenized_fst(tok.tokenize('foobar', 'foobaz'))

    will create the transducer [foo:foo bar:b 0:a 0:z].
    """
    retval = HfstIterableTransducer()
    state = 0
    if isinstance(arg, list) or isinstance(arg, tuple):
       for token in arg:
           if isinstance(token, str):
              new_state = retval.add_state()
              retval.add_transition(state, new_state, token, token, 0)
              state = new_state
           elif isinstance(token, list) or isinstance(token, tuple):
              if len(token) == 2:
                 new_state = retval.add_state()
                 retval.add_transition(state, new_state, token[0], token[1], 0)
                 state = new_state
              elif len(token) == 1:
                 new_state = retval.add_state()
                 retval.add_transition(state, new_state, token, token, 0)
                 state = new_state
              else:
                 raise RuntimeError('Symbol or symbol pair must be given.')
       retval.set_final_weight(state, weight)
       return HfstTransducer(retval, get_default_fst_type())
    else:
       raise RuntimeError('Argument must be a list or a tuple')

def empty_fst():
    """
    Get an empty transducer.

    Empty transducer has one state that is not final, i.e. it does not recognize any
    string.
    """
    return regex('[0-0]')

def epsilon_fst(weight=0):
    """
    Get an epsilon transducer.

    Parameters
    ----------
    * `weight` :
        The weight of the final state. Epsilon transducer has one state that is
        final (with final weight *weight*), i.e. it recognizes the empty string.
    """
    return regex('[0]::' + str(weight))

def concatenate(transducers):
    """
    Return a concatenation of *transducers*.
    """
    retval = epsilon_fst()
    for tr in transducers:
      retval.concatenate(tr)
    retval.minimize()
    return retval

def disjunct(transducers):
    """
    Return a disjunction of *transducers*.
    """
    retval = empty_fst()
    for tr in transducers:
      retval.disjunct(tr)
    retval.minimize()
    return retval

def intersect(transducers):
    """
    Return an intersection of *transducers*.
    """
    retval = None
    for tr in transducers:
      if retval == None:
        retval = HfstTransducer(tr)
      else:
        retval.intersect(tr)
    retval.minimize()
    return retval

def subtract(transducers):
    """
    Return a subtraction of *transducers*.
    """
    retval = None
    for tr in transducers:
      if retval == None:
        retval = HfstTransducer(tr)
      else:
        retval.subtract(tr)
    retval.minimize()
    return retval

def compose(transducers):
    """
    Return a composition of *transducers*.
    """
    retval = None
    for tr in transducers:
        if retval == None:
            retval = HfstTransducer(tr)
        else:
            retval.compose(tr)
    retval.minimize()
    return retval

def cross_product(transducers):
    """
    Return a cross product of *transducers*.
    """
    retval = None
    for tr in transducers:
        if retval == None:
            retval = HfstTransducer(tr)
        else:
            retval.cross_product(tr)
    retval.minimize()
    return retval

%}
