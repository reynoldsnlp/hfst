namespace hfst
{
  std::string pmatch_tokenize(hfst_ol::PmatchContainer & container,
			      const std::string & input_text)
  {
    hfst_ol_tokenize::TokenizeSettings ts;
    std::ostringstream ostr("");
    hfst_ol_tokenize::match_and_print(container, ostr, input_text, ts);
    return ostr.str();
  }
}
