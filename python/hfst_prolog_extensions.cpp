namespace hfst
{

  bool parse_prolog_network_line(const std::string & line, hfst::implementations::HfstIterableTransducer * graph)
  {
    bool retval = hfst::implementations::HfstIterableTransducer::parse_prolog_network_line(line, *graph);
    return retval;
  }

  bool parse_prolog_arc_line(const std::string & line, hfst::implementations::HfstIterableTransducer * graph)
  {
    bool retval = hfst::implementations::HfstIterableTransducer::parse_prolog_arc_line(line, *graph);
    return retval;
  }

  bool parse_prolog_symbol_line(const std::string & line, hfst::implementations::HfstIterableTransducer * graph)
  {
    bool retval = hfst::implementations::HfstIterableTransducer::parse_prolog_symbol_line(line, *graph);
    return retval;
  }
  
  bool parse_prolog_final_line(const std::string & line, hfst::implementations::HfstIterableTransducer * graph)
  {
    bool retval = hfst::implementations::HfstIterableTransducer::parse_prolog_final_line(line, *graph);
    return retval;
  }

}
