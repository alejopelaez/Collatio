#ifndef __MD5_H
#include <string>

#include "md5.h"
#define __MD5_H
#endif

#ifndef __EDITDISTANCE_H
#include "EditDistance.h"
#define __EDITDISTANCE_H
#endif

#ifndef __STDLIB_H
#include "stdlib.h"
#define __STDLIB_H
#endif

#ifndef __IOSTREAM_
#include <iostream>
#define __IOSTREAM_
#endif

#ifndef __BOOKREADER_H
#include "BookReader.h"
#define __BOOKREADER_H
#endif

#ifndef __SIGNATURE_H
#include "Signature.h"
#define __SIGNATURE_H
#endif

#ifndef __VECTOR_
#include <vector>
#define __VECTOR_
#endif

#ifndef __STRING_
#include <string>
#define __STRING_
#endif

#ifndef __TIME_H
#include <time.h>
#define __TIME_H
#endif

using std::cerr;
using std::cout;
using std::endl;
using std::vector;
using std::string;

vector<string> get_words(string s){
    vector<string>words;
    string delimiter = " ",word;
    string::size_type poss;
    while((poss=s.find(","))!=string::npos) s.erase(poss,1); //Remove Commas
    string::size_type lastPos = s.find_first_not_of(delimiter);
    string::size_type pos = s.find_first_of(delimiter);
    while (pos != string::npos || lastPos != string::npos) {
        word = s.substr(lastPos, pos - lastPos);
        while((poss=word.find(" "))!=string::npos) word.erase(poss,1); //Remove WhiteSpaces
        words.push_back(word);
        lastPos = s.find_first_not_of(delimiter, pos);
        pos = s.find_first_of(delimiter, lastPos);
    }
    return words;
}

int main(int argc, char *argv[]){

	int paragraphSize = 1;

	if (argc > 1) {
		paragraphSize = atoi(argv[1]);
	}
	
	if (paragraphSize < 0) {
		paragraphSize = 0;
	}

	cerr << "Lineas por parrafo: " << paragraphSize << endl << endl;

	BookReader book1("datasets/prueba1.txt",paragraphSize);
	BookReader book2("datasets/prueba2.txt",paragraphSize);

	int bookSize1 = book1.NumberOfParagraphs();
	int bookSize2 = book2.NumberOfParagraphs();

	vector<Paragraph> s1(bookSize1);
	vector<Paragraph> s2(bookSize2);

        cerr << "Parrafos en A: " << bookSize1 << endl;
        cerr << "Parrafos en B: " << bookSize2 << endl << endl;

        s1 = book1.GetParagraphs();
        s2 = book2.GetParagraphs();
        
	vector<vector<int> > d(s1.size()+1,vector<int>(s2.size()+1));
 	clock_t inicio = clock();

 	clock_t fin = clock();
 	double timeString = static_cast<double>(fin - inicio)/CLOCKS_PER_SEC;
    
 	inicio = clock();

 	vector<Signature> m1(s1.size());
 	for (unsigned int cont1 = 0; cont1 < s1.size(); cont1++) {
 		md5_csum(reinterpret_cast<unsigned char *>(const_cast<char *>(s1[cont1].to_str().c_str())),s1[cont1].size(), 
                        m1[cont1].GetBuffer());
 	}
 	vector<Signature> m2(s2.size());
 	for (unsigned int cont1 = 0; cont1 < s2.size(); cont1++) {
 		md5_csum(reinterpret_cast<unsigned char *>(const_cast<char *>(s2[cont1].to_str().c_str())),s2[cont1].size(),
                        m2[cont1].GetBuffer());
 	}

        //Levenshtein Backtracking Matrix
        vector<vector<int> > matrizOperaciones;
        int distance = LevenshteinDistance(m1,m2, d, matrizOperaciones);
        
        for(int i = 0; i < matrizOperaciones.size(); ++i)
        {
            if(matrizOperaciones[i][0] == 1)
                cout << "se elimino \"" << s1[matrizOperaciones[i][1]] << "\""<<endl;
            else if(matrizOperaciones[i][0] == 2)
                cout << "Se inserto \"" << s2[matrizOperaciones[i][1]] << "\"" << endl;
            //Splits the paragraph into phrases, and call levenshtein
            else if(matrizOperaciones[i][0] == 3)
            {
                s1[matrizOperaciones[i][1]].create_phrases();
                s2[matrizOperaciones[i][2]].create_phrases();
                
                vector<string> f1 = s1[matrizOperaciones[i][1]].get_phrases();
                vector<string> f2 = s2[matrizOperaciones[i][2]].get_phrases();

                m1 = vector<Signature>(f1.size());
                m2 = vector<Signature>(f2.size());
                
                for (unsigned int cont1 = 0; cont1 < f1.size(); cont1++) {
                    md5_csum(reinterpret_cast<unsigned char *>(const_cast<char *>(f1[cont1].c_str())),f1[cont1].length(), 
 				 m1[cont1].GetBuffer());
                }
                for (unsigned int cont1 = 0; cont1 < f2.size(); cont1++) {
                    md5_csum(reinterpret_cast<unsigned char *>(const_cast<char *>(f2[cont1].c_str())),f2[cont1].length(), 
 				 m2[cont1].GetBuffer());
                }
                
                vector<vector<int> > matrizOperaciones2;
                d = vector<vector<int> > (f1.size()+1,vector<int>(f2.size()+1));
                distance = LevenshteinDistance(m1,m2, d, matrizOperaciones2);
               
                for(int j = 0; j < matrizOperaciones2.size(); ++j)
                {
//                    cerr << "OPERACION, con j= "<<j<<" tengo "<<matrizOperaciones2[j][0]<<endl;
//                    cerr << "En F1, con j= "<<j<<" tengo en 1 "<<f1[matrizOperaciones2[j][1]]<<endl;
//                    cerr << "En F1, con j= "<<j<<" tengo en 2 "<<f1[matrizOperaciones2[j][2]]<<endl;
//                    cerr << "En F2, con j= "<<j<<" tengo en 1 "<<f2[matrizOperaciones2[j][1]]<<endl;
//                    cerr << "En F2, con j= "<<j<<" tengo en 2 "<<f2[matrizOperaciones2[j][2]]<<endl;
                    
                    if(matrizOperaciones2[j][0] == 1)
                        cout << "se elimino en el parrafo "<<matrizOperaciones.size()-i<<" \"" << f1[matrizOperaciones2[j][1]] << "\""<<endl;
                    else if(matrizOperaciones2[j][0] == 2)
                        cout << "Se inserto en el parrafo "<<matrizOperaciones.size()-i<<" \"" << f2[matrizOperaciones2[j][2]] << "\"" << endl;
                    else if(matrizOperaciones2[j][0]==3){
                        //TODO separacion de frases y la última distancia pero SIN md5.   <========= TODO
                        vector<string> w1=get_words(f1[matrizOperaciones2[j][1]]), w2 = get_words(f2[matrizOperaciones2[j][2]]);
                        cout << "se reemplazó en el parrafo "<<matrizOperaciones.size()-i<<" \"" << f1[matrizOperaciones2[j][1]] << "\" por \"";
                        cout<< f2[matrizOperaciones2[j][2]]<<"\" " <<endl;
                    }
                }
            }
        }
        
 	fin = clock();
 	double timeMD5 = static_cast<double>(fin - inicio)/CLOCKS_PER_SEC;

        cerr << endl << "Tamano de parrafo: " << paragraphSize << endl;
//                cerr << "Tiempo para hallar distancias: " << timeString << endl;
        //        cerr << "Tiempo MD5: " << timeMD5 << endl;
	return 0;
};




