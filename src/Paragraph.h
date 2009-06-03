#ifndef __PARAGRAPH_H
#define __PARAGRAPH_H

#ifndef __IOSTREAM_
#include <iostream>
#define __IOSTREAM_
#endif

#ifndef __STRING_
#include <string>
#define __STRING_
#endif

#ifndef __VECTOR_
#include <vector>
#define __VECTOR_
#endif

using std::cerr;
using std::string;
using std::vector;
using std::ostream;

class Paragraph {
    
    string paragraph;
    int currentPos;
    vector<string> phrases;
    string lastPhrase;

 public:
    Paragraph(string _paragraph = "") : currentPos(0){
        paragraph = _paragraph;
        SplitParagraph();
    }

    ~Paragraph(){}

    Paragraph& operator=(const Paragraph& p) {
        if (this != &p) {
            paragraph = p.to_str();
        }
        return *this;
     }

    Paragraph& operator=(const string &str) {
        paragraph = str;
        return *this;
    }

    bool operator==(const Paragraph& p) const {
        return paragraph == p.to_str();
    }

    bool operator!=(const Paragraph& p) const {
        return !(this->operator==(p));
    }

    const char& operator[](const int index) const{
        return paragraph[index];
    }
    
    string GetNextPhrase() {
        if (currentPos < phrases.size()) {
            lastPhrase = phrases[currentPos];
            ++currentPos;
            return lastPhrase;
        }
        else {
            return lastPhrase;
        }
    }

    int NumberOfPhrases() const {
        return phrases.size();
    }

    string& append(const string& string) {
        return paragraph.append(string);
    }

    int size() const {
        return paragraph.size();
    }

    string to_str() const {
        return paragraph;
    }
    
    void create_phrases(){
        phrases.clear();
        phrases = SplitParagraph();
    }
    
    vector<string> get_phrases(){return phrases;}
    
 private:
    vector<string> SplitParagraph(const string & delimiter = ".") {
        string phrase;
        // drop delimiters at start
        string::size_type lastPos = paragraph.find_first_not_of(delimiter);
        
        string::size_type pos = paragraph.find_first_of(delimiter);
        
        while (pos != string::npos || lastPos != string::npos) {
            phrase = paragraph.substr(lastPos, pos - lastPos);
//            cout<<"DEBUG FRASE!      "<<phrase<<endl;
            phrases.push_back(RemoveWhitespace(phrase));
            // use find_first_not_of instead of += 1  to skip "..."
            lastPos = paragraph.find_first_not_of(delimiter, pos);
            pos = paragraph.find_first_of(delimiter, lastPos);
        }
        return phrases;
    };
        
    // remove trailing whitespace at the beginning and at the end of a
    // string
    string RemoveWhitespace(const string &str) const {
        const string::size_type pos = str.find_first_not_of(" ");
        const string::size_type lastPos = str.find_last_not_of(" ");
        // add 1 to get the last character too
        return str.substr(pos, lastPos - pos + 1);
    };

    friend ostream & operator<<(ostream &os, const Paragraph& p);

    
};
  
ostream & operator<<(ostream &os, const Paragraph& p){
  return os << p.to_str();
};
#endif
