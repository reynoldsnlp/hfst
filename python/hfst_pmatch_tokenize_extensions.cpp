namespace hfst
{
  hfst_ol::LocationVectorVector pmatch_locate(hfst_ol::PmatchContainer * cont,
					      const std::string & input,
					      double time_cutoff = 0.0)
  {
    return cont->locate(input, time_cutoff);
  }

  hfst_ol::LocationVectorVector pmatch_locate(hfst_ol::PmatchContainer * cont,
					      const std::string & input,
					      double time_cutoff,
					      float weight_cutoff)
  {
    return cont->locate(input, time_cutoff, weight_cutoff);
  }

  std::ostringstream pmatch_tokenize_ostringstream;

  std::string pmatch_tokenize(hfst_ol::PmatchContainer * container,
			      const std::string & input)
			      //const hfst_ol_tokenize::TokenizeSettings & ts)
  {
    pmatch_tokenize_ostringstream.str("");
    hfst_ol_tokenize::TokenizeSettings settings;
    hfst_ol_tokenize::match_and_print(*container, pmatch_tokenize_ostringstream, input, settings);
    return pmatch_tokenize_ostringstream.str();
  }
}
