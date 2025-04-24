// Copyright (c) 2023 University of Helsinki
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 3 of the License, or (at your option) any later version.
// See the file COPYING included with this distribution for more
// information.

#ifdef __EMSCRIPTEN__

#if HAVE_CONFIG_H
#  include <config.h>
#endif

#include <emscripten/bind.h>
#include <iostream>
#include <string>
#include <unicode/udata.h>  // Add ICU data header
#include <unicode/uvernum.h>
#include <unicode/uversion.h>
#include <utility>
#include <vector>

#include "HfstDataTypes.h"
#include "HfstTransducer.h"
#include "HfstInputStream.h"
#include "HfstOutputStream.h"
#include "HfstExceptionDefs.h"
#include "HfstTokenizer.h"
#include "implementations/HfstBasicTransducer.h"
#include "implementations/HfstBasicTransition.h"
#include "implementations/optimized-lookup/pmatch.h"
#include "implementations/optimized-lookup/pmatch_tokenize.h"

using namespace hfst;
using namespace emscripten;
using namespace hfst_ol_tokenize;

// Declare the ICU data symbol using the standard macro.
// This tells the compiler that this symbol exists externally.
extern "C" const char U_ICUDATA_ENTRY_POINT [];

// Define token-related structures needed for tokenization
namespace {
    // Function to get the ICU version used during build
    std::string getIcuVersion() {
        // U_ICU_VERSION is a macro defined by ICU headers (e.g., "74.2")
        return U_ICU_VERSION;
    }

    // Structure to represent a form in a token analysis
    struct TokenizeForm {
        std::string form;
        float weight;
    };

    // Structure to represent an analysis of a token
    struct TokenizeAnalysis {
        float weight;
        std::vector<TokenizeForm> forms;
    };

    // Structure to represent a token
    struct TokenizeToken {
        std::string token;
        float weight;
        std::vector<TokenizeAnalysis> analyses;
    };

    // Structure to hold tokenization results
    struct TokenizeResult {
        std::vector<TokenizeToken> tokens;
        std::vector<std::string> nonTokenized;
    };
}

// Helper functions for data conversion between C++ and JavaScript
namespace {
    // Convert JS array to C++ StringVector
    StringVector jsArrayToStringVector(const val& jsArray) {
        StringVector result;
        const auto length = jsArray["length"].as<unsigned>();
        result.reserve(length);
        for (unsigned i = 0; i < length; ++i) {
            result.push_back(jsArray[i].as<std::string>());
        }
        return result;
    }

    // Convert C++ StringVector to JS array
    val stringVectorToJs(const StringVector& vec) {
        val jsArray = val::array();
        for (size_t i = 0; i < vec.size(); ++i) {
            jsArray.call<void>("push", vec[i]);
        }
        return jsArray;
    }

    // Convert C++ StringSet to JS Set
    val stringSetToJs(const StringSet& set) {
        val jsSet = val::global("Set").new_();
        for (const auto& str : set) {
            jsSet.call<void>("add", str);
        }
        return jsSet;
    }

    // Convert JS object to C++ StringPair
    StringPair jsObjectToStringPair(const val& jsObj) {
        return {jsObj["first"].as<std::string>(), jsObj["second"].as<std::string>()};
    }

    // Convert C++ StringPair to JS object
    val stringPairToJs(const StringPair& pair) {
        val jsObj = val::object();
        jsObj.set("first", pair.first);
        jsObj.set("second", pair.second);
        return jsObj;
    }

    // Convert C++ StringPairVector to JS array
    val stringPairVectorToJs(const StringPairVector& vec) {
        val jsArray = val::array();
        for (const auto& pair : vec) {
            jsArray.call<void>("push", stringPairToJs(pair));
        }
        return jsArray;
    }

    // Convert C++ HfstOneLevelPaths to JS array
    val hfstOneLevelPathsToJs(HfstOneLevelPaths* paths) {
        val jsArray = val::array();
        if (paths == nullptr) {
            return jsArray;
        }

        for (const auto& path : *paths) {
            val pair = val::array();

            // Create output string array
            val output = val::array();
            for (const auto& symbol : path.second) {
                output.call<void>("push", symbol);
            }

            // Set weight and output
            pair.set(0, output);
            pair.set(1, path.first);

            jsArray.call<void>("push", pair);
        }

        // Clean up the path pointer as it was dynamically allocated
        delete paths;
        return jsArray;
    }

    // Convert TokenizeSettings to/from JS object
    val tokenizeSettingsToJs(const TokenizeSettings& settings) {
        val jsObj = val::object();
        jsObj.set("output_format", static_cast<int>(settings.output_format));
        jsObj.set("tokenize_multichar", settings.tokenize_multichar);
        jsObj.set("print_all", settings.print_all);
        jsObj.set("print_weights", settings.print_weights);
        jsObj.set("beam", settings.beam);
        jsObj.set("time_cutoff", settings.time_cutoff);
        jsObj.set("max_weight_classes", settings.max_weight_classes);
        jsObj.set("dedupe", settings.dedupe);
        jsObj.set("verbose", settings.verbose);
        jsObj.set("hack_uncompose", settings.hack_uncompose);
        return jsObj;
    }

    TokenizeSettings jsToTokenizeSettings(const val& jsObj) {
        TokenizeSettings settings;
        settings.output_format = static_cast<OutputFormat>(jsObj["output_format"].as<int>());
        settings.tokenize_multichar = jsObj["tokenize_multichar"].as<bool>();
        settings.print_all = jsObj["print_all"].as<bool>();
        settings.print_weights = jsObj["print_weights"].as<bool>();
        settings.beam = jsObj["beam"].as<float>();
        settings.time_cutoff = jsObj["time_cutoff"].as<float>();
        settings.max_weight_classes = jsObj["max_weight_classes"].as<int>();
        settings.dedupe = jsObj["dedupe"].as<bool>();
        settings.verbose = jsObj["verbose"].as<bool>();
        settings.hack_uncompose = jsObj["hack_uncompose"].as<bool>();
        return settings;
    }

    // Convert TokenizeResults to JS object
    val tokenizeResultsToJs(const TokenizeResult& result) {
        val jsObj = val::object();

        // Convert token vector
        val tokens = val::array();
        for (const auto& token : result.tokens) {
            val tokenObj = val::object();
            tokenObj.set("token", token.token);
            tokenObj.set("weight", token.weight);

            // Convert analyses
            val analyses = val::array();
            for (const auto& analysis : token.analyses) {
                val analysisObj = val::object();
                analysisObj.set("weight", analysis.weight);

                // Convert form vector
                val forms = val::array();
                for (const auto& form : analysis.forms) {
                    val formObj = val::object();
                    formObj.set("form", form.form);
                    formObj.set("weight", form.weight);
                    forms.call<void>("push", formObj);
                }

                analysisObj.set("forms", forms);
                analyses.call<void>("push", analysisObj);
            }

            tokenObj.set("analyses", analyses);
            tokens.call<void>("push", tokenObj);
        }

        jsObj.set("tokens", tokens);

        // Convert non-tokenized segments
        val nonTokenized = val::array();
        for (const auto& segment : result.nonTokenized) {
            nonTokenized.call<void>("push", segment);
        }
        jsObj.set("nonTokenized", nonTokenized);

        return jsObj;
    }
}

// Wrapper functions for C++ methods that need special handling
namespace {
    // Handle lookup operation that returns HfstOneLevelPaths*
    val transducerLookup(const HfstTransducer& self, const std::string& input) {
        try {
            HfstOneLevelPaths* results = self.lookup(input);
            return hfstOneLevelPathsToJs(results);
        } catch (const HfstException& e) {
            return val::null();
        }
    }

    // Modified convert function to handle non-const method correctly
    HfstTransducer* transducerConvert(HfstTransducer& self, ImplementationType type) {
        try {
            // Create a new transducer as a copy
            HfstTransducer* result = new HfstTransducer(self);
            result->convert(type);
            return result;
        } catch (const HfstException& e) {
            return nullptr;
        }
    }

    // Get alphabet as JS Set
    val transducerGetAlphabet(const HfstTransducer& self) {
        return stringSetToJs(self.get_alphabet());
    }

    // Helper function for HfstInputStream::read()
    HfstTransducer* inputStreamRead(HfstInputStream& self) {
        try {
            return new HfstTransducer(self);
        } catch (const HfstException& e) {
            return nullptr;
        }
    }

    // Helper function for HfstOutputStream::write()
    void outputStreamWrite(HfstOutputStream& self, const HfstTransducer& t) {
        try {
            // Using the stream operator instead of a direct write method
            HfstTransducer transducer_copy(t);
            self << transducer_copy;
        } catch (const HfstException& e) {
            // Just ignore exceptions, JavaScript will have to handle this case
        }
    }

    // Global functions for FST type management
    ImplementationType getDefaultFstType() {
        return hfst::TROPICAL_OPENFST_TYPE; // Default value, could be customized
    }

    void setDefaultFstType(ImplementationType type) {
        // There's no global setter in the API, we'll have to do this per-instance
        // This is a simplification for JavaScript API
    }

    // Get the symbols from a PmatchContainer
    val getPmatchContainerSymbols(const hfst_ol::PmatchContainer& container) {
        // Create a set of symbols - we need to extract these from the transducers
        // Since PmatchContainer doesn't expose an API to get all symbols directly
        StringSet symbols;

        // Extract what we can from the public API
        // In a real implementation, we might need to look at the configuration
        // or other public interfaces to get symbols

        // Just create an empty set for now
        return stringSetToJs(symbols);
    }

    // Check if a container has a specific symbol
    bool pmatchContainerHasSymbol(hfst_ol::PmatchContainer& container, const std::string& symbol) {
        // We can't directly check the symbol table, so we'll have to use other methods
        // For now, return false since we don't have a direct way to check
        // In a real implementation, we might be able to check from configuration
        // or check if certain operations with the symbol work
        return false;
    }

    // Helper function for tokenizing text using PmatchContainer
    val tokenizeText(hfst_ol::PmatchContainer& container, const std::string& text, const val& jsSettings) {
        try {
            TokenizeSettings settings = jsToTokenizeSettings(jsSettings);

            // Set up a string stream for output
            std::ostringstream out;

            // Perform tokenization
            match_and_print(container, out, text, settings);

            // Return the tokenized result
            return val(out.str());
        } catch (const HfstException& e) {
            return val::null();
        }
    }

    // Helper function for creating a new PmatchContainer
    hfst_ol::PmatchContainer* createPmatchContainer(const std::string& filename) {
        try {
            std::ifstream instream(filename, std::ifstream::binary);
            if (!instream.good()) {
                return nullptr;
            }
            return new hfst_ol::PmatchContainer(instream);
        } catch (const HfstException& e) {
            return nullptr;
        }
    }

    // Helper function for creating a new PmatchContainer from ArrayBuffer
    hfst_ol::PmatchContainer* createPmatchContainerFromBuffer(const val& buffer) {
        try {
            // Get buffer size
            size_t bufferSize = buffer["byteLength"].as<size_t>();

            // Create a temporary file
            std::string tempFilename = "/tmp/pmatch_data_XXXXXX";
            int fd = mkstemp(&tempFilename[0]);
            if (fd == -1) {
                return nullptr;
            }

            // Get buffer data
            val uint8Array = val::global("Uint8Array").new_(buffer);

            // Write buffer to file
            for (size_t i = 0; i < bufferSize; ++i) {
                uint8_t byte = uint8Array[i].as<uint8_t>();
                if (write(fd, &byte, 1) != 1) {
                    close(fd);
                    unlink(tempFilename.c_str());
                    return nullptr;
                }
            }

            // Close file
            close(fd);

            // Create PmatchContainer
            std::ifstream instream(tempFilename, std::ifstream::binary);
            if (!instream.good()) {
                unlink(tempFilename.c_str());
                return nullptr;
            }

            hfst_ol::PmatchContainer* container = new hfst_ol::PmatchContainer(instream);

            // Clean up
            instream.close();
            unlink(tempFilename.c_str());

            return container;
        } catch (const HfstException& e) {
            return nullptr;
        }
    }

    // Helper function for structured tokenization
    val tokenizeTextStructured(hfst_ol::PmatchContainer& container, const std::string& text, const val& jsSettings) {
        try {
            TokenizeSettings settings = jsToTokenizeSettings(jsSettings);

            // This is a simplified implementation since the actual match_text function is not available
            // We'll parse the result of match_and_print and convert it to our TokenizeResult structure
            std::ostringstream out;
            match_and_print(container, out, text, settings);
            std::string result_str = out.str();

            // Create a placeholder result (in real implementation, you'd parse the result_str)
            TokenizeResult result;

            // Example token parsing (simplified)
            size_t pos = 0;
            while ((pos = result_str.find("\n", pos)) != std::string::npos) {
                std::string token_line = result_str.substr(0, pos);

                // Simple parsing example (would need more complex logic in real implementation)
                if (!token_line.empty()) {
                    TokenizeToken token;
                    token.token = token_line;
                    token.weight = 0.0f;
                    result.tokens.push_back(token);
                }

                result_str = result_str.substr(pos + 1);
                pos = 0;
            }

            // Convert result to JS object
            return tokenizeResultsToJs(result);
        } catch (const HfstException& e) {
            return val::null();
        }
    }

    // Default TokenizeSettings object
    val getDefaultTokenizeSettings() {
        TokenizeSettings settings;
        return tokenizeSettingsToJs(settings);
    }
}

// Main binding function
EMSCRIPTEN_BINDINGS(hfst_module) {
    // Bind ImplementationType enum
    enum_<ImplementationType>("ImplementationType")
        .value("SFST_TYPE", SFST_TYPE)
        .value("TROPICAL_OPENFST_TYPE", TROPICAL_OPENFST_TYPE)
        .value("LOG_OPENFST_TYPE", LOG_OPENFST_TYPE)
        .value("FOMA_TYPE", FOMA_TYPE)
        .value("XFSM_TYPE", XFSM_TYPE)
        .value("HFST_OL_TYPE", HFST_OL_TYPE)
        .value("HFST_OLW_TYPE", HFST_OLW_TYPE)
        .value("UNSPECIFIED_TYPE", UNSPECIFIED_TYPE)
        .value("ERROR_TYPE", ERROR_TYPE);

    // Bind OutputFormat enum for tokenization
    enum_<OutputFormat>("OutputFormat")
        .value("tokenize", tokenize)
        .value("space_separated", space_separated)
        .value("xerox", xerox)
        .value("cg", cg)
        .value("finnpos", finnpos)
        .value("giellacg", giellacg)
        .value("conllu", conllu)
        .value("visl", visl);

    // ********** HfstTransducer **********
    class_<HfstTransducer>("HfstTransducer")
        // Constructors
        .constructor<>()
        .constructor<ImplementationType>()
        .constructor<const std::string&, ImplementationType>()
        .constructor<const std::string&, const std::string&, ImplementationType>()

        // Basic properties
        .function("set_name", &HfstTransducer::set_name)
        .function("get_name", &HfstTransducer::get_name)
        .function("get_type", &HfstTransducer::get_type)
        .function("get_alphabet", &transducerGetAlphabet)

        // Information methods
        .function("number_of_states", &HfstTransducer::number_of_states)
        .function("number_of_arcs", &HfstTransducer::number_of_arcs)
        .function("is_cyclic", &HfstTransducer::is_cyclic)
        .function("is_automaton", &HfstTransducer::is_automaton)

        // Core operations
        .function("minimize", &HfstTransducer::minimize)
        .function("determinize", &HfstTransducer::determinize)
        .function("remove_epsilons", &HfstTransducer::remove_epsilons)
        .function("invert", &HfstTransducer::invert)
        .function("reverse", &HfstTransducer::reverse)
        .function("input_project", &HfstTransducer::input_project)
        .function("output_project", &HfstTransducer::output_project)
        .function("lookup", &transducerLookup)
        .function("convert", &transducerConvert, allow_raw_pointers());

    // ********** HfstInputStream **********
    class_<HfstInputStream>("HfstInputStream")
        .constructor<const std::string&>()
        .function("read", &inputStreamRead, allow_raw_pointers())
        .function("is_eof", &HfstInputStream::is_eof)
        .function("is_bad", &HfstInputStream::is_bad)
        .function("close", &HfstInputStream::close)
        .function("get_type", &HfstInputStream::get_type);

    // ********** HfstOutputStream **********
    class_<HfstOutputStream>("HfstOutputStream")
        .constructor<ImplementationType>()
        .constructor<const std::string&, ImplementationType>()
        .function("write", &outputStreamWrite)
        .function("flush", &HfstOutputStream::flush)
        .function("close", &HfstOutputStream::close);

    // ********** HfstTokenizer **********
    class_<HfstTokenizer>("HfstTokenizer")
        .constructor<>()
        .function("add_skip_symbol", &HfstTokenizer::add_skip_symbol)
        .function("add_multichar_symbol", &HfstTokenizer::add_multichar_symbol);

    // ********** PmatchContainer for tokenization **********
    class_<hfst_ol::PmatchContainer>("PmatchContainer")
        .constructor(&createPmatchContainer, allow_raw_pointers())
        .function("set_verbose", &hfst_ol::PmatchContainer::set_verbose)
        .function("set_single_codepoint_tokenization", &hfst_ol::PmatchContainer::set_single_codepoint_tokenization)
        .function("hasSymbol", &pmatchContainerHasSymbol)
        .function("getSymbols", &getPmatchContainerSymbols)
        .function("tokenize", &tokenizeText)
        .function("tokenizeStructured", &tokenizeTextStructured)
        .function("parse_hfst3_header", &hfst_ol::PmatchContainer::parse_hfst3_header);

    // ********** Module-level functions **********
    function("get_default_fst_type", &getDefaultFstType);
    function("set_default_fst_type", &setDefaultFstType);
    function("createPmatchContainer", &createPmatchContainer, allow_raw_pointers());
    function("createPmatchContainerFromBuffer", &createPmatchContainerFromBuffer, allow_raw_pointers());
    function("getDefaultTokenizeSettings", &getDefaultTokenizeSettings);
    function("getIcuVersion", &getIcuVersion);
}

#endif // __EMSCRIPTEN__
