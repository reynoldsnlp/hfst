"""

functions for creating transducers implementing two-level rules

FUNCTIONS

    coercion(...)
    deep_coercion(...)
    deep_restriction(...)
    deep_restriction_and_coercion(...)
    left_replace_down(...)
    left_replace_down_karttunen(...)
    left_replace_left(...)
    left_replace_right(...)
    left_replace_up(...)
    replace_down(...)
    replace_down_karttunen(...)
    replace_left(...) # -> libhfst_dev.sfst_replace_left
    replace_right(...)
    replace_up(...)
    restriction(...) # -> libhfst_dev.sfst_restriction
    restriction_and_coercion(...)
    surface_coercion(...)
    surface_restriction(...)
    surface_restriction_and_coercion(...)
    two_level_if(...)
    two_level_if_and_only_if(...)
    two_level_only_if(...)

"""

from libhfst_dev import two_level_if, \
two_level_only_if, \
two_level_if_and_only_if, \
replace_down, \
replace_down_karttunen, \
replace_right, \
replace_up, \
left_replace_up, \
left_replace_down, \
left_replace_down_karttunen, \
left_replace_left, \
left_replace_right, \
coercion, \
restriction_and_coercion, \
surface_restriction, \
surface_coercion, \
surface_restriction_and_coercion, \
deep_restriction, \
deep_coercion, \
deep_restriction_and_coercion

# these functions had to be renamed in the swig interface
# to prevent name collision
from libhfst_dev import sfst_replace_left as replace_left
from libhfst_dev import sfst_restriction as restriction
