// compat.cc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Author: riley@google.com (Michael Riley)
//
// \file
// Google compatibility definitions.

#include <cstring>
#include "../../../../config.h" // HFST ADDITION
#include <fst/compat.h>

using namespace std;

void FailedNewHandler() {
  cerr << "Memory allocation failed\n";
  exit(1);
}

namespace fst {

void SplitToVector(char* full, const char* delim, vector<char*>* vec,
                    bool omit_empty_strings) {
  char *p = full;
  while (p) {
    if ((p = strpbrk(full, delim)))
      p[0] = '\0';
    if (!omit_empty_strings || full[0] != '\0')
      vec->push_back(full);
    if (p)
      full = p + 1;
  }
}
}  // namespace fst
