"""

Hfst Xerox-type rule functions and classes.

CLASSES

    class ReplaceType(builtins.object)
    class Rule(builtins.object)

FUNCTIONS

    after(left, right)
    before(left, right)
    replace(*args)
    replace_epenthesis(*args)
    replace_left(...)
    replace_leftmost_longest_match(*args)
    replace_leftmost_shortest_match(*args)
    replace_rightmost_longest_match(*args)
    replace_rightmost_shortest_match(*args)
    restriction(...)

"""

from libhfst_dev import Rule, \
replace, replace_left, replace_leftmost_longest_match, \
replace_rightmost_longest_match, replace_leftmost_shortest_match, \
replace_rightmost_shortest_match, replace_epenthesis, \
restriction, before, after, ReplaceType

import libhfst_dev
