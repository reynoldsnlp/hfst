//! @file hfst-reweight.cc
//!
//! @brief Transducer reweighting tool
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

#include <fstream>
#include <iostream>
#include <memory>

#include <cfloat>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <getopt.h>

#include "HfstInputStream.h"
#include "HfstOutputStream.h"
#include "HfstTransducer.h"
#include "hfst-commandline.h"
#include "hfst-program-options.h"
#include "hfst-tool-metadata.h"
#include "implementations/HfstBasicTransducer.h"

#include "inc/globals-common.h"
#include "inc/globals-unary.h"

using hfst::HfstInputStream;
using hfst::HfstOutputStream;
using hfst::HfstTransducer;
using hfst::implementations::HfstBasicTransducer;
using hfst::implementations::HfstBasicTransition;
using hfst::implementations::HfstState;

// add tools-specific variables here
char *symbol = 0;
char *tsv_file_name = 0;
FILE *tsv_file = 0;

void
print_usage()
{
    // c.f. http://www.gnu.org/prep/standards/standards.html#g_t_002d_002dhelp
    // Usage line
    fprintf(message_out,
            "Usage: %s [OPTIONS...] [INFILE]\n"
            "Kill all paths with specific symbols\n"
            "\n",
            program_name);

    print_common_program_options(message_out);
    print_common_unary_program_options(message_out);
    fprintf(message_out,
            "Reweighting options:\n"
            "  -S, --symbol=SYM           remove arcs with input or output "
            "symbol SYM or both\n"
            "  -T, --tsv-file=TFILE       read kill rules from TFILE\n"
            "\n");
    fprintf(message_out, "\n");
    print_common_unary_program_parameter_instructions(message_out);
    fprintf(message_out,
            "TFILE should contain lines with tab-separated pairs of SYM and "
            "Comment lines starting with # and empty lines are ignored.\n");
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
                { "symbol", required_argument, 0, 'S' },
                { "tsv", required_argument, 0, 'T' },
                { 0, 0, 0, 0 } };
        int option_index = 0;
        // add tool-specific options here
        int c = getopt_long(argc, argv,
                            HFST_GETOPT_COMMON_SHORT HFST_GETOPT_UNARY_SHORT
                            "a:b:F:l:u:I:O:S:eT:A",
                            long_options, &option_index);
        if (-1 == c)
        {
            break;
        }

        switch (c)
        {
#include "inc/getopt-cases-common.h"
#include "inc/getopt-cases-unary.h"
        case 'S':
            symbol = hfst_strdup(optarg);
            break;
        case 'T':
            tsv_file_name = hfst_strdup(optarg);
            break;
#include "inc/getopt-cases-error.h"
        }
    }

    if (!symbol && !tsv_file_name)
    {
        error(EXIT_FAILURE, 0, "Either --symbol or --tsv-file is required");
        return EXIT_FAILURE;
    }

#include "inc/check-params-common.h"
#include "inc/check-params-unary.h"
    if (tsv_file_name != 0)
    {
        tsv_file = hfst_fopen(tsv_file_name, "r");
    }
    return EXIT_CONTINUE;
}

static HfstTransducer &
do_killing(HfstTransducer &trans)
{
    HfstBasicTransducer original(trans);
    HfstBasicTransducer replication;
    HfstState state_count = 1;
    std::map<HfstState, HfstState> rebuilt;
    rebuilt[0] = 0; // HfstBasicTransducer initially has state number zero
    if (original.is_final_state(0))
    {
        replication.set_final_weight(0, original.get_final_weight(0));
    }
    HfstState source_state = 0;
    for (HfstBasicTransducer::const_iterator state = original.begin();
         state != original.end(); ++state)
    {
        if (rebuilt.find(source_state) == rebuilt.end())
        {
            replication.add_state(state_count);
            if (original.is_final_state(source_state))
            {
                replication.set_final_weight(
                    state_count, original.get_final_weight(source_state));
            }
            rebuilt[source_state] = state_count;
            state_count++;
        }
        for (hfst::implementations::HfstBasicTransitions::const_iterator arc
             = state->begin();
             arc != state->end(); ++arc)
        {
            if (arc->get_input_symbol() == symbol
                || arc->get_output_symbol() == symbol)
            {
                // just skip replicating
                continue;
            }
            if (rebuilt.find(arc->get_target_state()) == rebuilt.end())
            {
                replication.add_state(state_count);
                if (original.is_final_state(arc->get_target_state()))
                {
                    replication.set_final_weight(
                        state_count,
                        original.get_final_weight(arc->get_target_state()));
                }
                rebuilt[arc->get_target_state()] = state_count;
                state_count++;
            }
            HfstBasicTransition nu(
                rebuilt[arc->get_target_state()], arc->get_input_symbol(),
                arc->get_output_symbol(), arc->get_weight());
            replication.add_transition(rebuilt[source_state], nu);
        }
        source_state++;
    }
    trans = HfstTransducer(replication, trans.get_type());
    return trans;
}

int
process_stream(HfstInputStream &instream, HfstOutputStream &outstream)
{
    size_t transducer_n = 0;
    while (instream.is_good())
    {
        transducer_n++;
        HfstTransducer trans(instream);
        char *inputname = hfst_get_name(trans, inputfilename);
        if (transducer_n == 1)
        {
            verbose_printf("Path killing %s...\n", inputname);
        }
        else
        {
            verbose_printf("Path killing %s..." SIZE_T_SPECIFIER "\n",
                           inputname, transducer_n);
        }
        if (NULL == tsv_file)
        {
            trans = do_killing(trans);
            hfst_set_name(trans, trans, "pathkill");
            hfst_set_formula(trans, trans, "PK");
        }
        else
        {
            rewind(tsv_file);
            free(symbol);
            char *line = NULL;
            size_t len = 0;
            size_t linen = 0;
            verbose_printf("Reading reweights from %s\n", tsv_file_name);
            while (hfst_getline(&line, &len, tsv_file) != -1)
            {
                linen++;
                if (*line == '\n')
                {
                    continue;
                }
                if (*line == '#')
                {
                    continue;
                }
                const char *endptr = line;
                while (*endptr != '\0' && *endptr != '\n')
                {
                    endptr++;
                }
                symbol = hfst_strndup(line, endptr - line);
                verbose_printf("Killing patsh with symbol %s\n", symbol);
                trans = do_killing(trans);
            } // getline
            free(line);
            hfst_set_name(trans, trans, "pathkill");
            hfst_set_formula(trans, trans, "PK");
        } // if tsv_file
        outstream << trans.remove_epsilons();
        free(inputname);
    } // foreach transducer
    instream.close();
    outstream.close();
    return EXIT_SUCCESS;
}

int
main(int argc, char **argv)
{
#ifdef WINDOWS
    _setmode(0, _O_BINARY);
    _setmode(1, _O_BINARY);
#endif

    hfst_set_program_name(argv[0], "0.1", "HfstKillPaths");
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
    if (outfile != stdout)
    {
        fclose(outfile);
    }
    verbose_printf("Reading from %s, writing to %s\n", inputfilename,
                   outfilename);
    verbose_printf("Killing paths\n");
    if (symbol)
    {
        verbose_printf("only if arc has symbol %s\n", symbol);
    }
    // here starts the buffer handling part
    std::unique_ptr<HfstInputStream> instream;
    try
    {
        instream.reset((inputfile != stdin)
                           ? new HfstInputStream(inputfilename)
                           : new HfstInputStream());
    }
    catch (const HfstException &e)
    {
        error(EXIT_FAILURE, 0, "%s is not a valid transducer file",
              inputfilename);
        return EXIT_FAILURE;
    }
    auto outstream
        = (outfile != stdout)
              ? std::make_unique<HfstOutputStream>(outfilename,
                                                   instream->get_type())
              : std::make_unique<HfstOutputStream>(instream->get_type());

    if (is_input_stream_in_ol_format(*instream, "hfst-kill-paths"))
    {
        return EXIT_FAILURE;
    }

    retval = process_stream(*instream, *outstream);
    free(inputfilename);
    free(outfilename);
    return retval;
}
