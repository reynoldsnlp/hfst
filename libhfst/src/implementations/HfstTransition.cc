// Copyright (c) 2016 University of Helsinki
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 3 of the License, or (at your option) any later version.
// See the file COPYING included with this distribution for more
// information.

#include "HfstTransition.h"

namespace hfst {

  namespace implementations {

    HfstTransition::HfstTransition(): target_state(0) {};

    HfstTransition::HfstTransition(HfstState s,
                     HfstTropicalTransducerTransitionData::SymbolType isymbol,
                     HfstTropicalTransducerTransitionData::SymbolType osymbol,
                     HfstTropicalTransducerTransitionData::WeightType weight):
        target_state(s), transition_data(isymbol, osymbol, weight)
    {};
        
    HfstTransition::HfstTransition(HfstState s,
                                             unsigned int inumber,
                                             unsigned int onumber,
                                             HfstTropicalTransducerTransitionData::WeightType weight,
                                             bool foo):
      target_state(s), transition_data(inumber, onumber, weight)
    { (void)foo; };
        
    HfstTransition::HfstTransition(const HfstTransition &another):
      target_state(another.target_state),
      transition_data(another.transition_data)
    {};
    
    HfstTransition::~HfstTransition() {};
    
    bool HfstTransition::operator<(const HfstTransition &another) const {
      if (target_state == another.target_state)
        return (transition_data < another.transition_data);
      return (target_state < another.target_state);
    }

    void HfstTransition::operator=(const HfstTransition &another) {
      target_state = another.target_state;
      transition_data = another.transition_data;
    }
    
    HfstState HfstTransition::get_target_state() const {
      return target_state;
    }
    
    const HfstTropicalTransducerTransitionData & HfstTransition::get_transition_data() const {
      return transition_data;
    }
    
    HfstTropicalTransducerTransitionData::SymbolType HfstTransition::get_input_symbol() const {
      return transition_data.get_input_symbol();
    }
    
    void HfstTransition::set_input_symbol(const HfstTropicalTransducerTransitionData::SymbolType & symbol) {
      transition_data.set_input_symbol(symbol);
    }

    HfstTropicalTransducerTransitionData::SymbolType HfstTransition::get_output_symbol() const {
      return transition_data.get_output_symbol();
    }

    void HfstTransition::set_output_symbol(const HfstTropicalTransducerTransitionData::SymbolType & symbol) {
      transition_data.set_output_symbol(symbol);
    }
    
    unsigned int HfstTransition::get_input_number() const {
      return transition_data.get_input_number();
    }
    
    unsigned int HfstTransition::get_output_number() const {
      return transition_data.get_output_number();
    }
    
    HfstTropicalTransducerTransitionData::WeightType HfstTransition::get_weight() const {
      return transition_data.get_weight();
    }
    
    void HfstTransition::set_weight(HfstTropicalTransducerTransitionData::WeightType w) {
      transition_data.set_weight(w);
    }
  }
  
}

