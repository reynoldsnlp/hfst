//       This program is free software: you can redistribute it and/or modify
//       it under the terms of the GNU General Public License as published by
//       the Free Software Foundation, version 3 of the License.
//
//       This program is distributed in the hope that it will be useful,
//       but WITHOUT ANY WARRANTY; without even the implied warranty of
//       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//       GNU General Public License for more details.
//
//       You should have received a copy of the GNU General Public License
//       along with this program.  If not, see <http://www.gnu.org/licenses/>.

case 'd':
debug = true;
break;
case 'h':
print_usage();
return EXIT_SUCCESS;
break;
case 'V':
print_version();
return EXIT_SUCCESS;
break;
case 'v':
verbose = true;
silent = false;
break;
case 'q':
case 's':
verbose = false;
silent = true;
break;
case 'o':
outfilename = hfst_strdup(optarg);
outfile = ::hfst_fopen(outfilename, "w");
if (outfile == stdout)
{
    free(outfilename);
    outfilename = hfst_strdup("<stdout>");
    message_out = stderr;
}
outputNamed = true;
break;
case GETOPT_COLOUR:
if (optarg == 0)
{
    colour = COLOUR_ALWAYS;
}
else if (strcmp(optarg, "always") == 0)
{
    colour = COLOUR_ALWAYS;
}
else if (strcmp(optarg, "never") == 0)
{
    colour = COLOUR_NEVER;
}
else if (strcmp(optarg, "auto") == 0)
{
    colour = COLOUR_AUTO;
}
else
{
    error(EXIT_FAILURE, 0,
          "--colour must be one of always, never, auto, not %s", optarg);
}
break;
