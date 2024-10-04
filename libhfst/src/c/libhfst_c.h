#ifndef MAIN_H
#define MAIN_H

#define EXTERN

#ifdef __cplusplus
#undef EXTERN
#define EXTERN extern "C"
#include <set>
#include <string>
#include <vector>

namespace hfst {
    class HfstTransducer;
    class HfstInputStream;
    typedef std::vector<std::string> StringVector;
    typedef std::pair<float, StringVector> HfstOneLevelPath;
    typedef std::set<HfstOneLevelPath> HfstOneLevelPaths;
}

#endif /* __cplusplus */

#include <stdlib.h>
typedef struct ResultIterator {
    void *begin;
    void *end;
} ResultIterator;

// typedef struct HfstValue {
//     float weight;
//     char *s;
// } HfstValue;

typedef void *hfst_empty_transducer_t();
typedef void *hfst_input_stream_t(const char *filename);
typedef void* hfst_input_stream_close_t(void*);
typedef bool hfst_input_stream_is_eof_t(void*);
typedef bool hfst_input_stream_is_bad_t(void*);
typedef void* hfst_transducer_from_stream_t(void*);

// maybe these
typedef size_t hfst_lookup_results_t(void*, char**, float*);

typedef void* hfst_lookup_t(void *, const char *);
typedef ResultIterator *hfst_lookup_iterator_t(void *);
typedef void hfst_lookup_iterator_value_t(ResultIterator *it, char **s, float *weight);
typedef void hfst_lookup_iterator_next_t(ResultIterator *);
typedef void hfst_lookup_iterator_free_t(ResultIterator *it);

typedef bool hfst_lookup_iterator_done_t(struct ResultIterator *it);

EXTERN void *hfst_empty_transducer();
EXTERN void *hfst_input_stream(const char *path);
EXTERN void hfst_input_stream_close(const void *);
EXTERN bool hfst_input_stream_is_eof(const void *);
EXTERN bool hfst_input_stream_is_bad(const void *);
EXTERN void *hfst_transducer_from_stream(const void *);

// these are a maybe
EXTERN void *hfst_lookup_begin(const void *);
EXTERN size_t hfst_lookup_results(const void *, char **, float *);

EXTERN void *hfst_lookup(void *handle, const char *input);
EXTERN ResultIterator *hfst_lookup_iterator(void *);
EXTERN void hfst_lookup_iterator_value(ResultIterator *it, char **s, float *w);
EXTERN void hfst_lookup_iterator_next(ResultIterator *it);
EXTERN void hfst_lookup_iterator_free(ResultIterator *it);

EXTERN bool hfst_lookup_iterator_done(struct ResultIterator *it);

#endif /* MAIN_H */
