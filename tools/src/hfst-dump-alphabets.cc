//! @file hfst-dump-alphabets.cc
//!
//! @brief Transducer information command line tool
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
#include <config.h>
#endif

#ifdef WINDOWS
#include <io.h>
#endif

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <getopt.h>
#include <memory>

#include "HfstInputStream.h"
#include "HfstOutputStream.h"
#include "HfstTransducer.h"
#include "implementations/HfstBasicTransducer.h"

using std::map;
using std::string;

using hfst::HfstInputStream;
using hfst::HfstTransducer;
using hfst::StringSet;
using hfst::implementations::HfstBasicTransducer;
using hfst::implementations::HfstState;
using hfst::implementations::HfstTransitionGraph;

#include "hfst-commandline.h"
#include "hfst-program-options.h"

#include "inc/globals-common.h"
#include "inc/globals-unary.h"

// add tools-specific variables here
enum alphadumpformat
{
    TSV,
    VISLCG3_LIST,
    VISLCG3_TAGS
} output_format
    = TSV;
bool print_seen = true;
bool print_meta = true;
bool only_multichars = false;

bool
is_multichar(const std::string &s)
{
    if (s.length() > 2)
    {
        if (s.rfind("+", 0) == 0 || s.rfind(" ", 0) == 0
            || s.rfind("@", 0) == 0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    return false;
}

void
print_usage()
{
    // c.f. http://www.gnu.org/prep/standards/standards.html#g_t_002d_002dhelp
    fprintf(message_out,
            "Usage: %s [OPTIONS...] [INFILE]\n"
            "Print alphabets of automaton\n"
            "\n",
            program_name);

    print_common_program_options(message_out);
    print_common_unary_program_options(message_out);
    // fprintf(message_out, (tool-specific options and short descriptions)
    fprintf(message_out, "Alphabet dump options:\n");
    fprintf(message_out,
            "  -f, --format=AFORMAT     Print alphabet in AFORAMT\n");
    fprintf(message_out,
            "  -1, --exclude-seen       Ignore alphabets seen in automaton\n");
    fprintf(message_out,
            "  -2, --exclude-metadata   Ignore alphabets from headers\n");
    fprintf(message_out, "\n");
    print_common_unary_program_parameter_instructions(message_out);
    fprintf(message_out, "\n");
    print_report_bugs();
    fprintf(message_out, "\n");
    print_more_info();
}

int
parse_options(int argc, char **argv)
{
    extend_options_getenv(&argc, &argv);
    // use of this function requires options are settable on global scope
    while (true)
    {
        static const struct option long_options[]
            = { HFST_GETOPT_COMMON_LONG,
                HFST_GETOPT_UNARY_LONG,
                // add tool-specific options here
                { "format", required_argument, 0, 'f' },
                { "include-seen", no_argument, 0, '1' },
                { "include-metadata", no_argument, 0, '2' },
                { 0, 0, 0, 0 } };
        int option_index = 0;
        // add tool-specific options here
        int c = getopt_long(argc, argv,
                            HFST_GETOPT_COMMON_SHORT HFST_GETOPT_UNARY_SHORT
                            "f:12",
                            long_options, &option_index);
        if (-1 == c)
        {
            break;
        }

        switch (c)
        {
#include "inc/getopt-cases-common.h"
#include "inc/getopt-cases-unary.h"
            // add tool-specific cases here
        case 'f':
            if (strcmp(optarg, "tsv") == 0)
            {
                output_format = TSV;
                only_multichars = false;
                verbose_printf("printing one symbol per line\n");
            }
            else if (strcmp(optarg, "vislcg3-list") == 0)
            {
                output_format = VISLCG3_LIST;
                only_multichars = true;
                verbose_printf("printing LIST x = x ; for VISL CG 3...\n");
            }
            else if (strcmp(optarg, "vislcg3-tags") == 0)
            {
                output_format = VISLCG3_TAGS;
                only_multichars = true;
                verbose_printf("printing STRICT-TAGS += for VISL CG 3...\n");
            }
            else
            {
                fprintf(stderr, "Error: unrecognised format %s\n", optarg);
                exit(EXIT_FAILURE);
            }
            break;
        case '1':
            print_seen = false;
            break;
        case '2':
            print_meta = false;
            break;
#include "inc/getopt-cases-error.h"
        }
    }

#include "inc/check-params-common.h"
#include "inc/check-params-unary.h"
    return EXIT_CONTINUE;
}

int
process_stream(HfstInputStream &instream)
{
    size_t transducer_n = 0;
    while (instream.is_good())
    {
        transducer_n++;
        if (transducer_n < 2)
        {
            verbose_printf("Alphadumping...\n");
        }
        else
        {
            verbose_printf("Alphadumping... " SIZE_T_SPECIFIER "\n",
                           transducer_n);
        }
        HfstTransducer trans{ instream };
        HfstBasicTransducer mutt{ trans };
        unsigned int initial_state = 0; // mutt.get_initial_state();
        StringSet transducerAlphabet;
        bool transducerKnowsAlphabet = false;
        try
        {
            transducerAlphabet = trans.get_alphabet();
            transducerKnowsAlphabet = true;
        }
        catch (FunctionNotImplementedException)
        {
            transducerKnowsAlphabet = false;
        }
        StringSet foundAlphabet;
        std::map<std::pair<std::string, std::string>, unsigned int>
            symbol_pairs;
        // iterate states in random order
        HfstState source_state = 0;
        for (HfstBasicTransducer::const_iterator it = mutt.begin();
             it != mutt.end(); it++)
        {
            HfstState s = source_state;
            for (hfst::implementations::HfstBasicTransitions::const_iterator
                     tr_it
                 = it->begin();
                 tr_it != it->end(); tr_it++)
            {
                foundAlphabet.insert(tr_it->get_input_symbol());
                foundAlphabet.insert(tr_it->get_output_symbol());
            }
            source_state++;
        }
        if (output_format == VISLCG3_TAGS)
        {
            fprintf(outfile, "## automatically generated VISL CG 3 file from "
                             "HFST automaton's alphabet data:\n");
            fprintf(outfile, "## (some statistics here TODO)\n");
            fprintf(outfile, "STRICT-TAGS +=\n");
        }
        else if (output_format == VISLCG3_LIST)
        {
            fprintf(outfile, "## automatically generated VISL CG 3 file from "
                             "HFST automaton's alphabet data:\n");
            fprintf(outfile, "## (some statistics here TODO)\n");
        }
        if (print_meta)
        {
            if (transducerKnowsAlphabet)
            {
                bool first = true;
                for (StringSet::const_iterator s = transducerAlphabet.begin();
                     s != transducerAlphabet.end(); ++s)
                {
                    if (only_multichars && !is_multichar(*s))
                    {
                        continue;
                    }
                    if (!first)
                    {
                        if (false)
                        {
                            fprintf(outfile, ", ");
                        }
                    }
                    if (output_format == TSV)
                    {
                        fprintf(outfile, "%s\n", s->c_str());
                    }
                    else if (output_format == VISLCG3_TAGS)
                    {
                        fprintf(outfile, "\t%s\n", s->c_str());
                    }
                    else if (output_format == VISLCG3_LIST)
                    {
                        fprintf(outfile, "LIST %s = %s ;\n", s->c_str(),
                                s->c_str());
                    }
                    first = false;
                }
            }
            else
            {
                fprintf(stderr,
                        "Error: cannot dump non-existent header alphabet\n");
                exit(EXIT_FAILURE);
            }
        }
        if (print_seen)
        {
            bool first = true;
            for (StringSet::const_iterator s = foundAlphabet.begin();
                 s != foundAlphabet.end(); ++s)
            {
                if (only_multichars && !is_multichar(*s))
                {
                    continue;
                }
                if (!first)
                {
                    if (false)
                    {
                        fprintf(outfile, ", ");
                    }
                }
                if (output_format == TSV)
                {
                    fprintf(outfile, "%s\n", s->c_str());
                }
                else if (output_format == VISLCG3_TAGS)
                {
                    fprintf(outfile, "\t%s\n", s->c_str());
                }
                else if (output_format == VISLCG3_LIST)
                {
                    fprintf(outfile, "LIST %s = %s ;\n", s->c_str(),
                            s->c_str());
                }
                first = false;
            }
        }
    } // for each automaton
    if (output_format == VISLCG3_TAGS)
    {
        fprintf(outfile, "\t;\n");
    }
    return EXIT_SUCCESS;
}

int
main(int argc, char **argv)
{
#ifdef WINDOWS
    _setmode(0, _O_BINARY);
#endif

    hfst_set_program_name(argv[0], "0.1", "HfstSummarize");
    int retval = parse_options(argc, argv);
    if (retval != EXIT_CONTINUE)
    {
        return retval;
    }
    // close buffers, we use streams
    if (inputfile != stdin)
    {
        fclose(inputfile);
    }
    verbose_printf("Reading from %s, writing to %s\n", inputfilename,
                   outfilename);
    // here starts the buffer handling part
    std::unique_ptr<HfstInputStream> instream;
    try
    {
        instream.reset((inputfile != stdin)
                           ? new HfstInputStream(inputfilename)
                           : new HfstInputStream());
    } // NotTransducerStreamException
    catch (const HfstException e)
    {
        error(EXIT_FAILURE, 0, "%s is not a valid transducer file",
              inputfilename);
        return EXIT_FAILURE;
    }
    retval = process_stream(*instream);

    if (outfile != stdout)
    {
        fclose(outfile);
    }
    free(inputfilename);
    free(outfilename);
    return EXIT_SUCCESS;
}
