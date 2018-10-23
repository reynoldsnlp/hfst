#include "HfstIterableTransducer.h"

namespace hfst {
  namespace implementations {

    int read_sfst_string( char *buffer, int size, FILE *file )
      
    {
      for( int i=0; i<size; i++ ) {
	int c=fgetc(file);
	if (c == EOF || c == 0) {
	  buffer[i] = 0;
	  return (c==0);
	}
	buffer[i] = (char)c;
      }
      buffer[size-1] = 0;
      return 0;
    }
    
      size_t read_sfst_num( void *p, size_t n, FILE *file )

      {
	char *pp=(char*)p;
	size_t result=fread( pp, 1, n, file );
	/*if (Switch_Bytes) {
	  size_t e=n/2;
	  for( size_t i=0; i<e; i++ ) {
	    char tmp=pp[i];
	    pp[i] = pp[--n];
	    pp[n] = tmp;
	  }
	  }*/
	return result;
      }

    std::vector<std::string> read_sfst_alphabet( FILE *file, unsigned short biggest_number)

      {
	//utf8 = (fgetc(file) != 0);

	std::vector<std::string> result(biggest_number+1, std::string(""));
	// read the symbol mapping
	unsigned short n=0; // todo: check Character type
	read_sfst_num(&n, sizeof(n), file);
	for( unsigned i=0; i<n; i++) {
	  char buffer[100000]; // const int BUFFER_SIZE = 100000
	  unsigned short c;
	  read_sfst_num(&c, sizeof(c), file);
	  if (!read_sfst_string(buffer, 100000, file) ||
	      feof(file) || ferror(file))
	    {
	      throw "Error1 occurred while reading alphabet!\n";
	    }

	  // added for HFST compatibility
	  if (strcmp(buffer, "") == 0) {
	    throw "Empty string cannot be a symbol in HFST!\n";
	  }
	  result[c] = std::string(buffer);
	  //add_symbol(buffer, c);
	}

	// read the character pairs
	read_sfst_num(&n, sizeof(n), file);
	if (ferror(file))
	  {
	    throw "Error2 occurred while reading alphabet!\n";
	  }
	for( unsigned i=0; i<n; i++) {
	  unsigned short lc, uc; // todo: check Character type
	  (void)read_sfst_num(&lc, sizeof(lc), file);
	  (void)read_sfst_num(&uc, sizeof(uc), file);
	  //insert(Label(lc, uc));
	}
	if (ferror(file))
	  {
	    throw "Error3 occurred while reading alphabet!\n";
	  }
	return result;
      }
      
      
      static void read_sfst_node( FILE *file, unsigned int node, std::vector<bool> & visited, HfstIterableTransducer & a, unsigned short & biggest_number)
      {
	char c;
	if (fread(&c,sizeof(c),1,file) != 1) // HFST addition: checking return value of fread
	  throw "read_node: fread failed";
	if (c != 0)
	  {
	    a.set_final_weight(node, 0.0); //node->set_final(c);
	  }
	
	unsigned short n;
	if (fread( &n, sizeof(n), 1, file) != 1)  // HFST addition: checking return value of fread
	  throw "read_node: fread failed";
	
	for( int i=0; i<n; i++ ) {
	  unsigned short lc,uc; // todo: check type of Character
	  unsigned int t;
	  if (fread(&lc,sizeof(lc),1,file) != 1) // HFST addition: checking return value of fread
	    throw "read_sfst_node: fread failed";
	  if (fread(&uc,sizeof(uc),1,file) != 1) // HFST addition: checking return value of fread
	    throw "read_sfst_node: fread failed";
	  if (fread(&t,sizeof(t),1,file) != 1) // HFST addition: checking return value of fread
	    throw "read_sfst_node: fread failed";
	  if (ferror(file))
	    throw "Error encountered while reading transducer from file";
	  if (visited[t]) //if (p[t])
	    {
	      a.add_transition(node, HfstTransition(t, std::to_string(lc), std::to_string(uc), 0.0)); //node->add_arc( Label(lc,uc), p[t], a );
	    }
	  else {
	    visited[t] = true; //p[t] = a->new_node();
	    a.add_transition(node, HfstTransition(t, std::to_string(lc), std::to_string(uc), 0.0)); //node->add_arc( Label(lc,uc), p[t], a );
	    read_sfst_node(file, t, visited, a, biggest_number );
	  }
	  if (lc > biggest_number)
	    { biggest_number = lc; }
	  if (uc > biggest_number)
	    { biggest_number = uc; }
	}
      }
      
      static HfstIterableTransducer read_binary_sfst_transducer( FILE *file )
	
      {
	if (fgetc(file) != 'a')
	  {
	    throw "Error: wrong file format (not a standard transducer)\n";
	  }
	unsigned int n; // number of nodes
	if (fread(&n,sizeof(n),1,file) != 1)
	  {
	    throw "read_transducer_binary: fread failed";
	  }
	if (ferror(file))
	  {
	    throw "Error encountered while reading transducer from file";
	  }
	// todo: check n>0 ?
	HfstIterableTransducer result;
	result.add_state(n-1);
	std::vector<bool> visited(n-1, false);
	visited[0] = true;
	unsigned short biggest_number = 0;
	read_sfst_node(file, 0, visited, result, biggest_number);
	std::vector<std::string> alpha = read_sfst_alphabet(file, biggest_number);	
	// todo: convert symbols
	return result;
      }
      
    }
  }
