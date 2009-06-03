#ifndef __BOOKREADER_H
#define __BOOKREADER_H

#ifndef __STRING_
#include <string>
#define __STRING_
#endif

#ifndef __FSTREAM_
#include <fstream>
#define __FSTREAM_
#endif

#ifndef __CTYPE_H
#include <ctype.h>
#define __CTYPE_H
#endif

#ifndef __IOSTREAM_
#include <iostream>
#define __IOSTREAM_
#endif

#ifndef __PARAGRAPH_H
#include "Paragraph.h"
#define __PARAGRAPH_H
#endif

using std::cout;
using std::endl;
using std::cerr;
using std::string;
using std::ifstream;
using std::streampos;
using std::ios;

class BookReader {

    ifstream inputStream;
    string streamName;
    vector<Paragraph> book;
    int lineCount;
    int phrasePos;
	
    string trim(string& s,const string& drop = " ") {
	s.erase(s.find_last_not_of(drop)+1);
	return s.erase(0,s.find_first_not_of(drop));
    }

 public:
	
 BookReader(string fileName, int linesToJoin) : streamName(fileName), lineCount(linesToJoin) {
	inputStream.open(streamName.c_str(), ifstream::in);
	if (!inputStream) {
	    cerr << "Error al abrir el archivo " << fileName << endl;
	    exit(-1);
	}
    };
    
    ~BookReader() {
	inputStream.close();
    }
    
    Paragraph GetNextParagraph() {
        Paragraph paragraph;
	bool done = false;
	bool firstLine = true;
	string l;
	int linesProcessed = 1;
	while (!done) {
	    getline(inputStream, l);
	    if (!inputStream.eof())  {
		trim(l);
		if (l.size() > 0) {
                    
		    if (firstLine && isdigit(l[0])) {
			firstLine = false;
		    } else if (firstLine){
			done = true;
		    } else {
                        string k = "";
			k = paragraph.append(" ");
		    }
		    paragraph.append(l);
		} else if (!firstLine) {
		    linesProcessed++;
		    if (linesProcessed > lineCount) {
			done = true;
		    }
		}
	    } else {
		done = true;
	    }
	}
	return paragraph;
    };
    
    int NumberOfParagraphs() {

	streampos current = inputStream.tellg();
	inputStream.seekg(0,ios::beg);
	int paragraphs = 0;
	Paragraph paragraph;
	
	do {
            paragraph = GetNextParagraph();
            book.push_back(paragraph);
	    paragraphs++;

	} while (paragraph.size() > 0);

	inputStream.close();
	inputStream.open(streamName.c_str(), ifstream::in);      
	inputStream.seekg(current);
	return paragraphs;
    };


    // Returns the book as a vector of strings where each string is a
    // paragraph.
    vector<Paragraph> GetParagraphs() {
        return book;
//        vector<Paragraph> book(NumberOfParagraphs());
//
//        for (int i = 0; i < NumberOfParagraphs(); i++) {
//            book[i] = GetNextParagraph();
//        }
//
//        return book;

    };
};

#endif
