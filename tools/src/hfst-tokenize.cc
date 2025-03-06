//! @file hfst-tokenize.cc
//!
//! @brief A demo of a replacement for hfst-proc using pmatch
//!
//! @author HFST Team

//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, version 3 of the License.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif


#include <iterator>
#include <iostream>
#include <fstream>
#include <sstream>

#include <vector>
#include <map>
#include <string>
#include <set>

using std::string;
using std::vector;
using std::pair;

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <getopt.h>
#include <math.h>
#include <errno.h>

#include "hfst-commandline.h"
#include "hfst-program-options.h"
#include "hfst-tool-metadata.h"
#include "implementations/optimized-lookup/pmatch.h"
#include "implementations/optimized-lookup/pmatch_tokenize.h"
#include "parsers/pmatch_utils.h"
#include "HfstExceptionDefs.h"
#include "HfstDataTypes.h"
#include "HfstInputStream.h"
#include "implementations/ConvertTransducerFormat.h"

using hfst::HfstTransducer;

#include "inc/globals-common.h"
#include "inc/globals-unary.h"

using hfst_ol::Location;
using hfst_ol::LocationVector;
using hfst_ol::LocationVectorVector;
using namespace hfst_ol_tokenize;

static bool superblanks = false; // Input is apertium-style superblanks (overrides blankline_separated)
static bool blankline_separated = true; // Input is separated by blank lines (as opposed to single newlines)
static bool keep_newlines = false;
static int token_number = 1;
std::string tokenizer_filename;
static hfst::ImplementationType default_format = hfst::TROPICAL_OPENFST_TYPE;
TokenizeSettings settings;

void
print_usage()
{
    // c.f. http://www.gnu.org/prep/standards/standards.html#g_t_002d_002dhelp
    fprintf(message_out, "Usage: %s [--segment | --xerox | --cg | --giella-cg] [OPTIONS...] RULESET\n"
            "perform matching/lookup on text streams\n"
            "\n", program_name);
    print_common_program_options(message_out);
    fprintf(message_out,
            "  -n, --newline            Newline as input separator (default is blank line)\n"
            "  -a, --print-all          Print nonmatching text\n"
            "  -w, --print-weight       Print weights (overrides earlier -W option)\n"
            "  -W, --no-weights         Don't print weights (default; overrides earlier -w, or -w implied by -g, options)\n"
            "  -m, --tokenize-multichar Tokenize multicharacter symbols\n"
            "                           (by default only one utf-8 character is tokenized at a time\n"
            "                           regardless of what is present in the alphabet)\n"
            "  -b, --beam=B             Output only analyses whose weight is within B from best result\n"
            "  -tS, --time-cutoff=S     Limit search after having used S seconds per input\n"
            "  -lN, --weight-classes=N  Output no more than N best weight classes\n"
            "                           (where analyses with equal weight constitute a class\n"
            "  -u, --unique             Remove duplicate analyses\n"
            "  -z, --segment            Segmenting / tokenization mode (default)\n"
            "  -i, --space-separated    Tokenization with one sentence per line, space-separated tokens\n"
            "  -x, --xerox              Xerox output\n"
            "  -c, --cg                 Constraint Grammar output\n"
            "  -S, --superblanks        Ignore contents of unescaped [] (cf. apertium-destxt); flush on NUL\n"
            "  -g, --giella-cg          CG format used in Giella infrastructure (implies -w and -l2,\n"
            "                           treats @PMATCH_INPUT_MARK@ as subreading separator,\n"
            "                           expects tags to be Multichar_symbols, flush on NUL)\n"
            "  -C  --conllu             CoNLL-U format\n"
            "  -f, --finnpos            FinnPos output\n"
            "  -L, --visl               VISL input and output (implies -W, handles <s> as blocks and <STYLE> inline)\n"
            );
    fprintf(message_out,
            "Use standard streams for input and output (for now).\n"
            "\n"
        );

    print_report_bugs();
    fprintf(message_out, "\n");
    print_more_info();
    fprintf(message_out, "\n");
}



hfst_ol::PmatchContainer make_naive_tokenizer(HfstTransducer * dictionary)
{
    HfstTransducer * word_boundary = hfst::pmatch::PmatchUtilityTransducers::
        make_latin1_whitespace_acceptor(default_format);
    HfstTransducer * punctuation = hfst::pmatch::PmatchUtilityTransducers::
        make_latin1_punct_acceptor(default_format);
    word_boundary->disjunct(*punctuation);
    HfstTransducer * others = hfst::pmatch::make_exc_list(word_boundary,
                                                          default_format);
    others->repeat_plus();
    // make the default token less likely than any dictionary token
    others->set_final_weights(std::numeric_limits<float>::max());
    HfstTransducer * word_boundary_list = hfst::pmatch::make_list(
        word_boundary, default_format);
    // @BOUNDARY@ is pmatch's special input boundary marker
    word_boundary_list->disjunct(HfstTransducer("@BOUNDARY@", default_format));
    delete word_boundary; delete punctuation;
    HfstTransducer * left_context = new HfstTransducer(
        hfst::internal_epsilon, hfst::pmatch::LC_ENTRY_SYMBOL, default_format);
    HfstTransducer * right_context = new HfstTransducer(
        hfst::internal_epsilon, hfst::pmatch::RC_ENTRY_SYMBOL, default_format);
    left_context->concatenate(*word_boundary_list);
    right_context->concatenate(*word_boundary_list);
    delete word_boundary_list;
    HfstTransducer * left_context_exit = new HfstTransducer(
        hfst::internal_epsilon, hfst::pmatch::LC_EXIT_SYMBOL, default_format);
    HfstTransducer * right_context_exit = new HfstTransducer(
        hfst::internal_epsilon, hfst::pmatch::RC_EXIT_SYMBOL, default_format);
    left_context->concatenate(*left_context_exit);
    right_context->concatenate(*right_context_exit);
    delete left_context_exit; delete right_context_exit;
    std::string dict_name = dictionary->get_name();
    if (dict_name.empty()) {
        dict_name = "unknown_pmatch_tokenized_dict";
        dictionary->set_name(dict_name);
    }
    HfstTransducer dict_ins_arc(hfst::pmatch::get_Ins_transition(dict_name.c_str()), default_format);
    // We now make the center of the tokenizer
    others->disjunct(dict_ins_arc);
    // And combine it with the context conditions
    left_context->concatenate(*others);
    left_context->concatenate(*right_context);
    delete others; delete right_context;
    // Because there are context conditions we need delimiter markers
    HfstTransducer * tokenizer = hfst::pmatch::add_pmatch_delimiters(left_context);
    tokenizer->set_name("TOP");
    tokenizer->minimize();
    // Convert the dictionary to olw if it wasn't already
    dictionary->convert(hfst::HFST_OLW_TYPE);
    // Get the alphabets
    std::set<std::string> dict_syms = dictionary->get_alphabet();
    std::set<std::string> tokenizer_syms = tokenizer->get_alphabet();
    std::vector<std::string> tokenizer_minus_dict;
    // What to add to the dictionary
    std::set_difference(tokenizer_syms.begin(), tokenizer_syms.end(),
                        dict_syms.begin(), dict_syms.end(),
                        std::inserter(tokenizer_minus_dict, tokenizer_minus_dict.begin()));
    for (std::vector<std::string>::const_iterator it = tokenizer_minus_dict.begin();
         it != tokenizer_minus_dict.end(); ++it) {
        dictionary->insert_to_alphabet(*it);
    }
    hfst::HfstBasicTransducer * tokenizer_basic = hfst::implementations::ConversionFunctions::
        hfst_transducer_to_hfst_basic_transducer(*tokenizer);
    hfst_ol::Transducer * tokenizer_ol = hfst::implementations::ConversionFunctions::
        hfst_basic_transducer_to_hfst_ol(tokenizer_basic,
                                         true, // weighted
                                         "", // no special options
                                         dictionary); // harmonize with the dictionary
    delete tokenizer_basic;
    hfst_ol::PmatchContainer retval(tokenizer_ol);
    hfst_ol::Transducer * dict_backend = hfst::implementations::ConversionFunctions::
        hfst_transducer_to_hfst_ol(dictionary);
    retval.add_rtn(dict_backend, dict_name);
    delete tokenizer_ol;
    return retval;
}

// Helper functions for tokenize_text
inline void trim(std::string& str) {
    while (!str.empty() && (std::isspace(str.back()) || str.back() == 0)) {
        str.pop_back();
    }
    while (!str.empty() && (std::isspace(str.front()) || str.front() == 0)) {
        str.erase(0, 1);
    }
}

inline void maybe_erase_newline(string& input_text, bool keep_newlines)
{
    if(!keep_newlines && input_text.size() > 0 && input_text.at(input_text.size() - 1) == '\n') {
        // Remove final newline
        input_text.erase(input_text.size() -1, 1);
    }
}

// Process input function that writes to string instead of stream
void process_input_string(hfst_ol::PmatchContainer & container,
                         const std::string& input_text,
                         std::ostringstream& outstream,
                         const TokenizeSettings& settings,
                         bool blankline_separated,
                         bool superblanks,
                         bool keep_newlines)
{
    // Prepare the output stream format
    if(settings.output_format == cg || settings.output_format == giellacg || settings.output_format == visl) {
        outstream << std::fixed << std::setprecision(10);
    }

    if(settings.output_format == visl) {
        std::istringstream istr(input_text);
        std::string line;
        while (std::getline(istr, line)) {
            trim(line);
            if (!line.empty()) {
                if (line.front() == '<' && line.back() == '>') {
                    print_nonmatching_sequence(line, outstream, settings);
                }
                else {
                    match_and_print(container, outstream, line, settings);
                }
            }
            else {
                outstream << '\n';
            }
        }
        return;
    }

    if(settings.output_format == giellacg || superblanks) {
        std::istringstream istr(input_text);
        std::string line;
        bool in_blank = false;
        std::ostringstream cur;

        while (std::getline(istr, line)) {
            line += '\n'; // Restore the newline that getline removes
            bool escaped = false;
            for(size_t i = 0; i < line.size(); ++i) {
                if(escaped) {
                    cur << line[i];
                    escaped = false;
                    continue;
                }
                else if(superblanks && !in_blank && line[i] == '[') {
                    std::string cur_str = cur.str();
                    if(!cur_str.empty()) {
                        match_and_print(container, outstream, cur_str, settings);
                    }
                    cur.str("");
                    cur.clear();
                    cur << line[i];
                    in_blank = true;
                }
                else if(superblanks && in_blank && line[i] == ']') {
                    cur << line[i];
                    if(i+1 < line.size() && line[i+1] == '[') {
                        // Join consecutive superblanks
                        ++i;
                        cur << line[i];
                    }
                    else {
                        in_blank = false;
                        print_nonmatching_sequence(cur.str(), outstream, settings);
                        cur.str("");
                        cur.clear();
                    }
                }
                else if(!in_blank && line[i] == '\n') {
                    cur << line[i];
                    std::string cur_str = cur.str();
                    if (settings.verbose) {
                        std::cout << "processing: " << cur_str << "\\n" << std::endl;
                    }
                    if(!cur_str.empty()) {
                        match_and_print(container, outstream, cur_str, settings);
                    }
                    cur.str("");
                    cur.clear();
                }
                else if(line[i] == '\0') {
                    std::string cur_str = cur.str();
                    if (settings.verbose) {
                        std::cout << "processing: " << cur_str << "\\0" << std::endl;
                    }
                    if(!cur_str.empty()) {
                        match_and_print(container, outstream, cur_str, settings);
                    }
                    cur.str("");
                    cur.clear();
                    outstream << "<STREAMCMD:FLUSH>" << std::endl; // CG format uses this instead of \0
                }
                else {
                    cur << line[i];
                }
                escaped = (line[i] == '\\');
            }
        }

        // Process any remaining text
        std::string cur_str = cur.str();
        if(!cur_str.empty()) {
            if(in_blank) {
                print_nonmatching_sequence(cur_str, outstream, settings);
            }
            else {
                match_and_print(container, outstream, cur_str, settings);
            }
        }

        return;
    }

    // Handle standard blankline-separated or newline-separated text
    if(blankline_separated) {
        std::istringstream istr(input_text);
        std::string line;
        std::string paragraph;

        while (std::getline(istr, line)) {
            if (line.empty()) {
                maybe_erase_newline(paragraph, keep_newlines);
                match_and_print(container, outstream, paragraph, settings);
                paragraph.clear();
            } else {
                paragraph.append(line).append("\n");
            }
        }

        if (!paragraph.empty()) {
            maybe_erase_newline(paragraph, keep_newlines);
            match_and_print(container, outstream, paragraph, settings);
        }
    }
    else {
        // Process line by line
        std::istringstream istr(input_text);
        std::string line;

        while (std::getline(istr, line)) {
            maybe_erase_newline(line, keep_newlines);
            match_and_print(container, outstream, line, settings);
        }
    }
}

hfst_ol::PmatchContainer create_pmatch_container(std::ifstream& instream, const std::string& ruleset_filename, const TokenizeSettings& local_settings) {
    std::map<std::string, std::string> first_header_attributes;
    try {
        first_header_attributes = hfst_ol::PmatchContainer::parse_hfst3_header(instream);
        instream.seekg(0);
        instream.clear();
    } catch(TransducerHeaderException & e) {
        throw std::runtime_error(ruleset_filename +
            " doesn't look like a HFST archive. Exception thrown: " + e.what());
    }

    if (first_header_attributes.count("name") == 0 ||
        first_header_attributes["name"] != "TOP") {
        if (local_settings.verbose) {
            std::cerr << "No TOP automaton found, using naive tokeniser\n";
        }
        hfst::HfstInputStream is(ruleset_filename);
        HfstTransducer* dictionary = new HfstTransducer(is);
        hfst_ol::PmatchContainer naive_container = make_naive_tokenizer(dictionary);
        delete dictionary;
        instream.close();
        return naive_container;
    } else {
        if (local_settings.verbose) {
            std::cerr << "TOP automaton seen, treating as pmatch script...\n";
        }
        hfst_ol::PmatchContainer pmatch_container(instream);
        instream.close();
        return pmatch_container;
    }
}

std::string tokenize_text(const std::string& ruleset_filename,
                         const std::string& input_text,
                         const TokenizeSettings& local_settings,
                         bool use_superblanks = false,
                         bool use_blankline_separated = true,
                         bool use_keep_newlines = false)
{
    std::ostringstream result;

    try {
        std::ifstream instream(ruleset_filename.c_str(), std::ifstream::binary);
        if (!instream.good()) {
            throw std::runtime_error("Could not open file " + ruleset_filename);
        }

        hfst_ol::PmatchContainer container = create_pmatch_container(instream, ruleset_filename, local_settings);

        container.set_verbose(local_settings.verbose);
        container.set_single_codepoint_tokenization(!local_settings.tokenize_multichar);

        // Process the input with our stream-to-string version
        process_input_string(container, input_text, result, local_settings,
                           use_blankline_separated, use_superblanks, use_keep_newlines);

        return result.str();

    } catch(HfstException & e) {
        throw std::runtime_error(std::string("HfstException: ") + e.what());
    } catch(std::exception & e) {
        throw;
    }
}

// The original process_input functions for CLI operation
inline void process_input_0delim_print(hfst_ol::PmatchContainer & container,
                                       std::ostream & outstream,
                                       std::ostringstream& cur)
{
    const std::string& input_text{cur.str()};
    if(!input_text.empty()) {
        match_and_print(container, outstream, input_text, settings);
    }
    cur.clear();
    cur.str(string());
}

template<bool do_superblank>
int process_input_0delim(hfst_ol::PmatchContainer & container,
                         std::ostream & outstream)
{
    char * line = NULL;
    size_t bufsize = 0;
    bool in_blank = false;
    std::ostringstream cur;
    ssize_t len = -1;
    while ((len = hfst_getdelim(&line, &bufsize, '\0', inputfile)) > 0) {
        bool escaped = false; // beginning of line is necessarily unescaped
        for(ssize_t i = 0; i < len; ++i) {
            if(escaped) {
                cur << line[i];
                escaped = false;
                continue;
            }
            else if(do_superblank && !in_blank && line[i] == '[') {
                process_input_0delim_print(container, outstream, cur);
                cur << line[i];
                in_blank = true;
            }
            else if(do_superblank && in_blank && line[i] == ']') {
                cur << line[i];
                if(i+1 < len && line[i+1] == '[') {
                    // Join consecutive superblanks
                    ++i;
                    cur << line[i];
                }
                else {
                    in_blank = false;
                    print_nonmatching_sequence(cur.str(), outstream, settings);
                    cur.clear();
                    cur.str(string());
                }
            }
            else if(!in_blank && line[i] == '\n') {
                cur << line[i];
                if (verbose) {
                    std::cout << "processing: " << cur.str() << "\\n" <<
                                 std::endl;
                }
                process_input_0delim_print(container, outstream, cur);
            }
            else if(line[i] == '\0') {
                if (verbose) {
                    std::cout << "processing: " << cur.str() << "\\0" <<
                                 std::endl;
                }
                process_input_0delim_print(container, outstream, cur);
                outstream << "<STREAMCMD:FLUSH>" << std::endl; // CG format uses this instead of \0
                outstream.flush();
                if(outstream.bad()) {
                    std::cerr << "hfst-tokenize: Could not flush file" << std::endl;
                }
            }
            else {
                cur << line[i];
            }
            escaped = (line[i] == '\\');
        }
        free(line);
        line = NULL;
        if(std::feof(inputfile)) {
            break;
        }
    }
    if(in_blank) {
        print_nonmatching_sequence(cur.str(), outstream, settings);
    }
    else {
        process_input_0delim_print(container, outstream, cur);
    }
    return EXIT_SUCCESS;
}

int process_input_visl(hfst_ol::PmatchContainer& container, std::ostream& outstream) {
    size_t bufsize = 0;
    char *buffer = 0;
    std::string line;

    ssize_t len = 0;
    while ((len = hfst_getline(&buffer, &bufsize, inputfile)) > 0) {
        line.assign(buffer, buffer+len);
        trim(line);
        if (!line.empty()) {
            if (line.front() == '<' && line.back() == '>') {
                print_nonmatching_sequence(line, outstream, settings);
            }
            else {
                match_and_print(container, outstream, line, settings);
            }
        }
        else {
            outstream << '\n';
        }
        outstream.flush();

        buffer[0] = 0;
        len = 0;

        if (feof(inputfile)) {
            break;
        }
    }

    if (len < 0) {
        len = 0;
    }

    line.assign(buffer, buffer+len);
    trim(line);
    if (!line.empty()) {
        if (line.front() == '<' && line.back() == '>') {
            print_nonmatching_sequence(line, outstream, settings);
        }
        else {
            match_and_print(container, outstream, line, settings);
        }
    }
    outstream.flush();

    free(buffer);
    return EXIT_SUCCESS;
}

int process_input(hfst_ol::PmatchContainer & container,
                  std::ostream & outstream)
{
    if(settings.output_format == cg || settings.output_format == giellacg || settings.output_format == visl) {
        outstream << std::fixed << std::setprecision(10);
    }
    if(settings.output_format == giellacg || superblanks) {
        if(superblanks) {
            verbose_printf("Processign giellacg with superblanks\n");
            return process_input_0delim<true>(container, outstream);
        }
        else {
            verbose_printf("Processign giellacg without superblanks\n");
            return process_input_0delim<false>(container, outstream);
        }
    }
    if(settings.output_format == visl) {
        verbose_printf("Processign VISL CG 3\n");
        return process_input_visl(container, outstream);
    }
    string input_text;
    char * line = NULL;
    size_t bufsize = 0;
    if(blankline_separated) {
        verbose_printf("Processing blankline separated input\n");
        while (hfst_getline(&line, &bufsize, inputfile) > 0) {
            if (line[0] == '\n') {
                maybe_erase_newline(input_text, keep_newlines);
                match_and_print(container, outstream, input_text, settings);
                input_text.clear();
            } else {
                input_text.append(line);
            }
            free(line);
            line = NULL;
        }
        if (!input_text.empty()) {
            maybe_erase_newline(input_text, keep_newlines);
            match_and_print(container, outstream, input_text, settings);
        }
    }
    else {
        // newline or non-separated
        verbose_printf("Processing non-separated input\n");
        while (hfst_getline(&line, &bufsize, inputfile) > 0) {
            input_text = line;
            maybe_erase_newline(input_text, keep_newlines);
            match_and_print(container, outstream, input_text, settings);
            free(line);
            line = NULL;
        }
    }

    return EXIT_SUCCESS;
}

int parse_options(int argc, char** argv)
{
    extend_options_getenv(&argc, &argv);
    // use of this function requires options are settable on global scope
    while (true)
    {
        static const struct option long_options[] =
            {
                HFST_GETOPT_COMMON_LONG,
                {"newline", no_argument, 0, 'n'},
                {"keep-newline", no_argument, 0, 'k'},
                {"print-all", no_argument, 0, 'a'},
                {"print-weights", no_argument, 0, 'w'},
                {"no-weights", no_argument, 0, 'W'},
                {"tokenize-multichar", no_argument, 0, 'm'},
                {"beam", required_argument, 0, 'b'},
                {"time-cutoff", required_argument, 0, 't'},
                {"weight-classes", required_argument, 0, 'l'},
                {"unique", no_argument, 0, 'u'},
                {"segment", no_argument, 0, 'z'},
                {"space-separated", no_argument, 0, 'd'},
                {"xerox", no_argument, 0, 'x'},
                {"cg", no_argument, 0, 'c'},
                {"superblanks", no_argument, 0, 'S'},
                {"giella-cg", no_argument, 0, 'g'},
                {"gtd", no_argument, 0, 'g'},
                {"conllu", no_argument, 0, 'C'},
                {"finnpos", no_argument, 0, 'f'},
                {"visl", no_argument, 0, 'L'},
                {0,0,0,0}
            };
        int option_index = 0;
        int c = getopt_long(argc, argv, HFST_GETOPT_COMMON_SHORT "nkawWmub:t:l:zixcSgCfL",
                             long_options, &option_index);
        if (-1 == c)
        {
            break;
        }


        switch (c)
        {
#include "inc/getopt-cases-common.h"
        case 'k':
            keep_newlines = true;
            blankline_separated = false;
            break;
        case 'n':
            blankline_separated = false;
            break;
        case 'a':
            settings.print_all = true;
            break;
        case 'w':
            settings.print_weights = true;
            break;
        case 'W':
            settings.print_weights = false;
            break;
        case 'm':
            settings.tokenize_multichar = true;
            break;
        case 't':
            settings.time_cutoff = atof(optarg);
            if (settings.time_cutoff < 0.0)
            {
                std::cerr << "Invalid argument for --time-cutoff\n";
                return EXIT_FAILURE;
            }
            break;
        case 'u':
            settings.dedupe = true;
            break;
        case 'b':
          settings.beam = atof(optarg);
          if (settings.beam < 0)
          {
              std::cerr << "Invalid argument for --beam\n";
              return EXIT_FAILURE;
          }
          break;
        case 'l':
            settings.max_weight_classes = atoi(optarg);
            if (settings.max_weight_classes < 1)
            {
                std::cerr << "Invalid or no argument --weight-classes count\n";
                return EXIT_FAILURE;
            }
            break;
        case 'z':
            settings.output_format = tokenize;
            break;
        case 'i':
            settings.output_format = space_separated;
            break;
        case 'x':
            settings.output_format = xerox;
            break;
        case 'c':
            settings.output_format = cg;
            break;
        case 'C':
            settings.output_format = conllu;
            break;
        case 'S':
            superblanks = true;
            break;
        case 'g':
            settings.output_format = giellacg;
            settings.print_weights = true;
            settings.print_all = true;
            settings.dedupe = true;
            settings.hack_uncompose = true;
            settings.verbose = false;
            if(settings.max_weight_classes == std::numeric_limits<int>::max()) {
                settings.max_weight_classes = 2;
            }
            break;
        case 'L':
            settings.output_format = visl;
            settings.print_weights = false;
            settings.print_all = true;
            settings.dedupe = true;
            settings.verbose = false;
            break;
        case 'f':
            settings.output_format = finnpos;
            break;
#include "inc/getopt-cases-error.h"
        }

    if (verbose) {
        settings.verbose = true;
    }

    }

//            if (!inputNamed)
//        {
//            inputfile = stdin;
//            inputfilename = hfst_strdup("<stdin>");
//        }

        // no more options, we should now be at the input filename
        if ( (optind + 1) < argc)
        {
            std::cerr << "More than one input file given\n";
            return EXIT_FAILURE;
        }
        else if ( (optind + 1) == argc)
        {
            tokenizer_filename = argv[(optind)];
            return EXIT_CONTINUE;
        }
        else
        {
            std::cerr << "No input file given\n";
            return EXIT_FAILURE;
        }


#include "inc/check-params-common.h"



    return EXIT_FAILURE;  // TODO unreachable?
}

// Function to read the entire file content into a string
std::string read_file_to_string(FILE* file) {
    std::ostringstream result;
    char* line = NULL;
    size_t bufsize = 0;
    ssize_t len;

    while ((len = hfst_getline(&line, &bufsize, file)) > 0) {
        result.write(line, len);
        free(line);
        line = NULL;
    }

    if (line != NULL) {
        free(line);
    }

    return result.str();
}

int main(int argc, char ** argv)
{
    hfst_set_program_name(argv[0], "0.1", "HfstTokenize");
    hfst_setlocale();
    int retval = parse_options(argc, argv);
    if (retval != EXIT_CONTINUE) {
        return retval;
    }
    verbose_printf("Reading from %s, writing to %s\n",
                   tokenizer_filename.c_str(), outfilename);

    try {
        // First, determine if we should use the new tokenize_text function or the original process_input
        // If we're reading from stdin and writing to stdout, we use the original approach for efficiency
        if (inputfile == stdin) {
            // Use the original functionality with direct processing of input/output streams
            std::ifstream instream(tokenizer_filename.c_str(), std::ifstream::binary);
            if (!instream.good()) {
                std::cerr << "Could not open file " << tokenizer_filename << std::endl;
                return EXIT_FAILURE;
            }

            // Check if we're working with a pmatch ruleset or naive tokenizer
            std::map<std::string, std::string> first_header_attributes;
            try {
                first_header_attributes = hfst_ol::PmatchContainer::parse_hfst3_header(instream);
                instream.seekg(0);
                instream.clear();
            } catch(TransducerHeaderException & e) {
                std::cerr << tokenizer_filename <<
                    " doesn't look like an HFST archive. Exiting.\n"
                    "Exception thrown:\n" << e.what() << std::endl;
                return 1;
            }

            if (first_header_attributes.count("name") == 0 ||
                    first_header_attributes["name"] != "TOP") {
                verbose_printf("No TOP automaton found, using naive tokeniser?\n");
                hfst::HfstInputStream is(tokenizer_filename);
                HfstTransducer * dictionary = new HfstTransducer(is);
                instream.close();
                hfst_ol::PmatchContainer container = make_naive_tokenizer(dictionary);
                delete dictionary;
                container.set_verbose(verbose);
                container.set_single_codepoint_tokenization(!settings.tokenize_multichar);
                return process_input(container, std::cout);
            } else {
                verbose_printf("TOP automaton seen, treating as pmatch script...\n");
                hfst_ol::PmatchContainer container(instream);
                container.set_verbose(verbose);
                container.set_single_codepoint_tokenization(!settings.tokenize_multichar);
                return process_input(container, std::cout);
            }
        } else {
            // Use the new tokenize_text function for in-memory processing
            // Read the input file into a string
            std::string input_text = read_file_to_string(inputfile);

            // Call the tokenize_text function
            std::string result = tokenize_text(
                tokenizer_filename,
                input_text,
                settings,
                superblanks,
                blankline_separated,
                keep_newlines
            );

            // Write the result to the output file
            if (outfile != stdout) {
                std::ofstream out(outfilename);
                if (!out) {
                    std::cerr << "Could not open file " << outfilename << " for writing" << std::endl;
                    return EXIT_FAILURE;
                }
                out << result;
                out.close();
            } else {
                std::cout << result;
            }

            return EXIT_SUCCESS;
        }
    } catch(HfstException & e) {
        std::cerr << "Exception thrown:\n" << e.what() << std::endl;
        return 1;
    } catch(std::runtime_error & e) {
        std::cerr << "Runtime error: " << e.what() << std::endl;
        return 1;
    } catch(std::exception & e) {
        std::cerr << "Exception: " << e.what() << std::endl;
        return 1;
    }
}
