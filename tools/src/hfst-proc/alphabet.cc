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

#if HAVE_CONFIG_H
#include <config.h>
#endif

#include <unicode/uchar.h>
#include <unicode/unistr.h>

#include "alphabet.h"
#include "tokenizer.h"
#include <cstdio>
#include <cstring>
#include <sstream>

//////////Function definitions for LetterTrie

bool
LetterTrie::has_symbol_0() const
{
    for (size_t i = 0; i < symbols.size(); i++)
    {
        if (symbols[i] == 0)
            return true;
    }
    for (size_t i = 0; i < letters.size(); i++)
    {
        if (letters[i] != NULL && letters[i]->has_symbol_0())
            return true;
    }
    return false;
}

void
LetterTrie::add_string(const char *p, SymbolNumber symbol_key)
{
    if (*(p + 1) == 0)
    {
        symbols[(unsigned char)(*p)] = symbol_key;
        return;
    }

    if (letters[(unsigned char)(*p)] == NULL)
        letters[(unsigned char)(*p)] = new LetterTrie();
    letters[(unsigned char)(*p)]->add_string(p + 1, symbol_key);
}

SymbolNumber
LetterTrie::find_symbol(const char *c) const
{
    if (strlen(c) == 1)
        return symbols[(unsigned char)(c[0])];

    if (letters[(unsigned char)(c[0])] == NULL)
        return NO_SYMBOL_NUMBER;
    else
        return letters[(unsigned char)(c[0])]->find_symbol(c + 1);
}

SymbolNumber
LetterTrie::extract_symbol(std::istream &is) const
{
    int c = is.get();
    if (c == EOF)
        return 0;

    if (letters[c] == NULL)
    {
        if (symbols[c] == NO_SYMBOL_NUMBER)
            is.putback(c);
        return symbols[c];
    }

    SymbolNumber s = letters[c]->extract_symbol(is);
    if (s == NO_SYMBOL_NUMBER)
    {
        if (symbols[c] == NO_SYMBOL_NUMBER)
            is.putback(c);
        return symbols[c];
    }
    return s;
}

//////////Function definitions for Symbolizer

void
Symbolizer::add_symbol(const std::string &symbol_str)
{
    std::string p = symbol_str;

    if (p.length() > 0)
    {
        unsigned char first = p.at(0);
        if (ascii_symbols[first] != 0)
        { // if the symbol's first character is ASCII and we're not ignoring it
          // yet
            if (p.length() == 1)
                ascii_symbols[first] = symbol_count;
            else
                ascii_symbols[first] = 0;
        }
        letters.add_string(p.c_str(), symbol_count);
    }
    symbol_count++;
}

void
Symbolizer::add_symbols(const SymbolTable &st)
{
    for (SymbolNumber k = 0; k < st.size(); ++k)
        add_symbol(st[k]);
}

SymbolNumber
Symbolizer::find_symbol(const char *c) const
{
    if (c[0] == 0)
        return NO_SYMBOL_NUMBER;
    if (strlen(c) > 1
        || ascii_symbols[(unsigned char)(c[0])] == NO_SYMBOL_NUMBER
        || ascii_symbols[(unsigned char)(c[0])] == 0)
        return letters.find_symbol(c);
    return ascii_symbols[(unsigned char)(c[0])];
}

SymbolNumber
Symbolizer::extract_symbol(std::istream &is) const
{
    int c = is.peek();
    if (c == 0)
        return NO_SYMBOL_NUMBER;
    if (ascii_symbols[c] == NO_SYMBOL_NUMBER || ascii_symbols[c] == 0)
        return letters.extract_symbol(is);

    return ascii_symbols[is.get()];
}

//////////Function definitions for ProcTransducerAlphabet

ProcTransducerAlphabet::ProcTransducerAlphabet(std::istream &is,
                                               SymbolNumber symbol_count)
    : TransducerAlphabet(is, symbol_count), symbol_properties_table(),
      symbolizer(), blank_symbol(NO_SYMBOL_NUMBER)
{
    for (SymbolNumber k = 0; k < symbol_count; k++)
    {
        SymbolProperties prop;
        prop.alphabetic = is_alphabetic(symbol_table[k].c_str());
        symbol_properties_table.push_back(prop);
        if (fd_table.is_diacritic(k))
            symbol_table[k] = "";
        symbolizer.add_symbol(symbol_table[k]);
    }

    // assume the first symbol is epsilon which we don't want to print
    symbol_table[0] = "";

    check_for_overlapping();
    setup_blank_symbol();
    calculate_caps();
    if (printDebuggingInformationFlag)
        print_table();

    escaped_symbols.insert(symbolizer.find_symbol("["));
    escaped_symbols.insert(symbolizer.find_symbol("]"));
    escaped_symbols.insert(symbolizer.find_symbol("{"));
    escaped_symbols.insert(symbolizer.find_symbol("}"));
    escaped_symbols.insert(symbolizer.find_symbol("^"));
    escaped_symbols.insert(symbolizer.find_symbol("$"));
    escaped_symbols.insert(symbolizer.find_symbol("/"));
    escaped_symbols.insert(symbolizer.find_symbol("\\"));
    escaped_symbols.insert(symbolizer.find_symbol("@"));
    escaped_symbols.insert(symbolizer.find_symbol("<"));
    escaped_symbols.insert(symbolizer.find_symbol(">"));
}

void
ProcTransducerAlphabet::setup_blank_symbol()
{
    blank_symbol = NO_SYMBOL_NUMBER;
    for (size_t i = 0; i < symbol_table.size(); i++)
    {
        if (symbol_table[i] == " ")
        {
            blank_symbol = i;
            break;
        }
    }

    if (blank_symbol == NO_SYMBOL_NUMBER)
    {
        blank_symbol = symbol_table.size();
        std::string str = " ";
        SymbolProperties s;
        s.alphabetic = is_alphabetic(str.c_str());
        add_symbol(str, s);
    }
}

void
ProcTransducerAlphabet::check_for_overlapping() const
{
    std::vector<std::string> overlapping;

    for (size_t i = 0; i < symbol_table.size(); i++)
    {
        std::string str = symbol_table[i];
        if (str.length() > 1
            && !is_punctuation(std::string(1, str[0]).c_str()))
        {
            std::istringstream s(str);

            // divide the symbol into UTF8 characters
            std::vector<std::string> chars;
            while (true)
            {
                std::string ch = TokenIOStream::read_utf8_char(s);
                if (ch.empty())
                    break;
                else
                    chars.push_back(ch);
            }
            if (chars.size() < 2)
                continue;

            bool overlaps = true;
            for (size_t j = 0; j < chars.size(); j++)
            {
                std::string ch = chars[j];
                if (!is_alphabetic(ch.c_str())
                    || symbolizer.find_symbol(ch.c_str()) == NO_SYMBOL_NUMBER)
                {
                    overlaps = false;
                    break;
                }
            }

            if (overlaps)
                overlapping.push_back(str);
        }
    }

    if (!overlapping.empty())
    {
        if (!silentFlag)
        {
            std::cerr << "!! Warning: Transducer contains one or more "
                         "multi-character symbols made up of\n"
                      << "ASCII characters which are also available as "
                         "single-character symbols. The\n"
                      << "input stream will always be tokenised using the "
                         "longest symbols available.\n"
                      << "Use the -t option to view the tokenisation. The "
                         "problematic symbol(s):\n";
            for (size_t i = 0; i < overlapping.size(); i++)
                std::cerr << (i == 0 ? "" : " ") << overlapping[i];
            std::cerr << std::endl;
        }
    }
}

void
ProcTransducerAlphabet::print_table() const
{
    std::cout << "Symbol table containing " << symbol_table.size()
              << " symbols:" << std::endl;
    for (SymbolNumber i = 0; i < symbol_table.size(); i++)
    {
        const FdOperation *fd_op = fd_table.get_operation(i);
        std::cout << "Symbol: #" << i << ", '"
                  << (fd_op != NULL ? fd_op->Name() : symbol_to_string(i))
                  << "'," << (is_alphabetic(i) ? " " : " not ")
                  << "alphabetic, ";
        if (is_lower(i))
        {
            SymbolNumber s2 = to_upper(i);
            std::cout << "lowercase, upper: " << s2 << "/"
                      << symbol_to_string(s2);
        }
        else if (is_upper(i))
        {
            SymbolNumber s2 = to_lower(i);
            std::cout << "uppercase, lower: " << s2 << "/"
                      << symbol_to_string(s2);
        }
        else
            std::cout << "no case";

        if (fd_op != NULL)
            std::cout << " FD - feature: " << fd_op->Feature()
                      << ", value: " << fd_op->Value();
        std::cout << std::endl;
    }

    if (fd_table.num_features() > 0)
        std::cout << "Alphabet contains " << fd_table.num_features()
                  << " flag diacritic feature(s)" << std::endl;
}

void
ProcTransducerAlphabet::add_symbol(const std::string &str,
                                   const SymbolProperties &symbol)
{
    symbol_table.push_back(str);
    symbol_properties_table.push_back(symbol);
    if (FdOperation::is_diacritic(str))
    {
        fd_table.define_diacritic(symbol_table.size() - 1, str);
        symbol_table[symbol_table.size() - 1] = "";
    }
    symbolizer.add_symbol(str);
}

void
ProcTransducerAlphabet::calculate_caps()
{
    size_t size = symbol_table.size(); // size before any new symbols added
    for (size_t i = 0; i < size; i++)
    {
        int case_res = 0; // -1 = lower, 1 = upper
        std::string switched;
        if (is_alphabetic(i))
            switched = caps_helper(symbol_table[i].c_str(), case_res);
        else
            case_res = 0;

        if (case_res < 0)
        {
            symbol_properties_table[i].lower = i;
            symbol_properties_table[i].upper
                = (switched == "") ? NO_SYMBOL_NUMBER
                                   : symbolizer.find_symbol(switched.c_str());
        }
        else if (case_res > 0)
        {
            symbol_properties_table[i].lower
                = (switched == "") ? NO_SYMBOL_NUMBER
                                   : symbolizer.find_symbol(switched.c_str());
            symbol_properties_table[i].upper = i;
        }
        else
            symbol_properties_table[i].lower = symbol_properties_table[i].upper
                = NO_SYMBOL_NUMBER;

        if (to_lower(i) == to_upper(i)
            && symbol_properties_table[i].lower != NO_SYMBOL_NUMBER)
        {
            if (switched != "")
            {
                SymbolProperties prop;
                prop.alphabetic = is_alphabetic(i);
                if (symbol_properties_table[i].lower == i)
                {
                    symbol_properties_table[i].upper = symbol_table.size();
                    prop.lower = i;
                    prop.upper = symbol_table.size();
                }
                else
                {
                    symbol_properties_table[i].lower = symbol_table.size();
                    prop.upper = i;
                    prop.lower = symbol_table.size();
                }
                add_symbol(switched, prop);
                if (printDebuggingInformationFlag)
                    std::cout << "Added new symbol '" << switched << "' ("
                              << symbol_table.size() - 1
                              << ") as alternate case for '" << symbol_table[i]
                              << "' (" << i << ")" << std::endl;
            }
            else
            {
                if (printDebuggingInformationFlag)
                    std::cout << "Symbol " << i
                              << "'s alternate case is unknown" << std::endl;
            }
        }

        if (printDebuggingInformationFlag
            && symbol_properties_table[i].lower != NO_SYMBOL_NUMBER
            && symbol_properties_table[i].upper != NO_SYMBOL_NUMBER
            && symbol_to_string(symbol_properties_table[i].lower).length()
                   != symbol_to_string(symbol_properties_table[i].upper)
                          .length())
        {
            std::cout << "Symbol " << i
                      << "'s alternate case has a different string length"
                      << std::endl;
        }
    }
}

std::string
ProcTransducerAlphabet::caps_helper_single(const char *c, int &case_res)
{
    icu::UnicodeString us(c);
    if (us.countChar32() == 1)
    {
        UChar32 uc = us.char32At(0);
        icu::UnicodeString cased_u = us;
        std::string cased;
        if (u_isupper(uc))
        {
            case_res = 1;
            cased_u.toLower();
            cased_u.toUTF8String(cased);
            return cased;
        }
        else if (u_islower(uc))
        {
            case_res = -1;
            cased_u.toUpper();
            cased_u.toUTF8String(cased);
            return cased;
        }
    }
    case_res = 0;
    return "";
}

std::string
ProcTransducerAlphabet::caps_helper(const char *in, int &case_res)
{
    std::istringstream str(in);
    std::string out;
    case_res = 0;
    int tmp = -2; // -2 indicates first time through the loop

    std::vector<std::string> chars;
    while (true)
    {
        std::string c = TokenIOStream::read_utf8_char(str);
        if (c.empty())
            break;

        std::string switched
            = caps_helper_single(c.c_str(), (tmp == -2 ? case_res : tmp));
        tmp = 0;
        out.append((switched == "" ? c : switched));
    }
    return out;
}

int
ProcTransducerAlphabet::utf8_str_to_int(const char *c)
{
    icu::UnicodeString us = icu::UnicodeString::fromUTF8(c);
    return us.char32At(0);
}

std::string
ProcTransducerAlphabet::utf8_int_to_str(int c)
{
    std::string rv;
    icu::UnicodeString us = icu::UnicodeString(c);
    return us.toUTF8String(rv);
}

std::string
ProcTransducerAlphabet::symbols_to_string(const SymbolNumberVector &symbols,
                                          CapitalizationState caps,
                                          bool raw) const
{
    std::string str = "";
    bool first = true;
    for (SymbolNumberVector::const_iterator it = symbols.begin();
         it != symbols.end(); it++, first = false)
    {
        if (!is_tag(*it) && escaped_symbols.find(*it) != escaped_symbols.end()
            && !raw)
        {
            str += "\\";
        }
        if (caps == UpperCase || (caps == FirstUpperCase && first == true))
        {
            str += symbol_to_string(to_upper(*it));
        }
        else
        {
            str += symbol_to_string(*it);
        }
    }
    return str;
}

bool
ProcTransducerAlphabet::is_punctuation(const char *c) const
{
    icu::UnicodeString us = icu::UnicodeString::fromUTF8(c);
    if (us.countChar32() == 1)
    {
        return u_ispunct(us.charAt(0))
               || u_charType(us.charAt(0)) == U_MATH_SYMBOL;
    }
    else
    {
        return false;
    }
}

bool
ProcTransducerAlphabet::is_space(const char *c) const
{
    icu::UnicodeString us = icu::UnicodeString::fromUTF8(c);
    if (us.countChar32() == 1)
    {
        return u_isUWhiteSpace(us.charAt(0));
    }
    else
    {
        return false;
    }
}

bool
ProcTransducerAlphabet::is_tag(SymbolNumber symbol) const
{
    std::string str = symbol_to_string(symbol);
    if (str[0] == '<' && str[str.length() - 1] == '>')
        return true;
    // Added a test for GT-style tags, ie tags starting with + and ending with
    // a non-plus: This might break Apertium! Actually, the tag test should
    // depend on the output format, but I don't know how to do that
    if (str[0] == '+' && str.length() > 1)
        return true;
    return false;
}

bool /* @@@ */
ProcTransducerAlphabet::is_compound_boundary(SymbolNumber symbol) const
{
    extern bool processCompounds;
    std::string s = symbol_to_string(symbol);
    if (!processCompounds)
        return false;

    if (s == "+" || s[s.length() - 1] == '+' || s == "#"
        || s[s.length() - 1] == '#')
        return true;
    return false;
}

int
ProcTransducerAlphabet::num_compound_boundaries(
    const SymbolNumberVector &symbol) const
{
    int count = 0;
    for (SymbolNumberVector::const_iterator i = symbol.begin();
         i != symbol.end(); i++)
    {
        if (is_compound_boundary(*i))
            count++;
    }
    return count;
}

const Symbolizer &
ProcTransducerAlphabet::get_symbolizer() const
{
    return symbolizer;
}
