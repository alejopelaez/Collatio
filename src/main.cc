#ifndef __MD5_H
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

template <class T, class K>

void print_diff(const vector<T>& s1, const vector<T>& t1, vector<vector<int> >& d,const vector<K>& s, const vector<K>& t) {
    
    int distance = LevenshteinDistance(s1, t1, d);
    
    int n = d.size()-1;
    int m = d[0].size()-1;
    
    for(int i=0;i<=n;i++){
        for(int j=0;j<=m;j++){
            //cerr << d[i][j] <<"\t";
            cout << d[i][j] <<"\t";
        }
        //cerr<<endl;
        cout<<endl;
    }
    int tamop = d[n][m]; //Levenshtein distance = number of operations
    vector<vector<int> > matrizOperaciones(tamop+1,vector<int>(3,0));
    cout<<"*****" << endl;
    int n2=n;
    int m2=m; 
    int cont= 0;

    while (n2 != 0 && m2!= 0){
        //Si son iguales
        if (d[n2][m2] == d[n2-1][m2-1] && s[n2-1]==t[m2-1]) { 
            n2--;
            m2--;
        } else if ((d[n2][m2] - d[n2-1][m2]) == 1) {
            n2--;
            matrizOperaciones[cont][0] = 1;
            matrizOperaciones[cont][1] = n2; //estaba n2-1
            matrizOperaciones[cont][2] = n2-1; //estaba n2-2
            //cerr << "se elimino \"" << s[matrizOperaciones[cont][1]] << "\""<<endl;
            cout << "se elimino \"" << s[matrizOperaciones[cont][1]] << "\""<<endl;
            //aca si se elimina del vector 1 entonces que indice seria en el vector 2
            cont++;
        } else if ((d[n2][m2] - d[n2][m2-1]) == 1) {
            m2--;
            matrizOperaciones[cont][0] = 2;
            matrizOperaciones[cont][1] = m2; //estaba N2-1
            matrizOperaciones[cont][2] = m2-1; //estaba N2-2
            //cerr << "Se inserto \"" << t[matrizOperaciones[cont][1]] << "\"" << endl; //imprimia m2-1
            cout << "Se inserto \"" << t[matrizOperaciones[cont][1]] << "\"" << endl; //imprimia m2-1
            //aca si se inserta en el vector 2 entonces que indice sera en el vector 1
            cont++;
        } else {
            //Reemplazos!
            n2--;
            m2--;
            matrizOperaciones[cont][0] = 3;
            matrizOperaciones[cont][1] = n2; //tenian -1
            matrizOperaciones[cont][2] = m2;
            //cerr << "Se reemplaza \"" << s[matrizOperaciones[cont][1]] << "\" ";
            //cerr << "por \"" << t[matrizOperaciones[cont][2]] << "\"" << endl;
            //print_diff(s[matrizOperaciones[cont][1]].get_phrases(), t[matrizOperaciones[cont][2]].get_phrases(),
            //        s[matrizOperaciones[cont][1]].get_phrases(), t[matrizOperaciones[cont][2]].get_phrases());
            cout << "Se reemplaza \"" << s[matrizOperaciones[cont][1]] << "\" ";
            cout << "por \"" << t[matrizOperaciones[cont][2]] << "\"" << endl;
            cont++;
        }
    }
		
    while (n2 != 0) {
        n2--;
        matrizOperaciones[cont][0] = 2;
        matrizOperaciones[cont][1] = n2;
        matrizOperaciones[cont][2] = n2-1; //estaba n2-2
        //cerr<<"Se inserta \""<< s[matrizOperaciones[cont][1]] << "\"" << endl;
        cout<<"Se inserta \""<< s[matrizOperaciones[cont][1]] << "\"" << endl;
        cont++;
    }

    while (m2 != 0) {
        m2--;
        matrizOperaciones[cont][0] = 1;
        matrizOperaciones[cont][1] = m2; //estaba n2 - 1 (OJO, N y no M)
        matrizOperaciones[cont][2] = m2-1;//estaba m2-2
        cont++;
        //cerr << "Se elimino \"" << t[matrizOperaciones[cont][2]] << "\"" << endl;
        cout << "Se elimino \"" << t[matrizOperaciones[cont][2]] << "\"" << endl;
    }
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

        //int distance = LevenshteinDistance(s1, s2, d);
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

        //Levenshtein Matrix
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
                //vector<string> f1(s1[matrizOperaciones[i][1]].NumberOfPhrases());
                //vector<string> f2(s2[matrizOperaciones[i][2]].NumberOfPhrases());
                
//                puts("Primer parrafo ***");
//                cout<<s1[matrizOperaciones[i][1]]<<endl;
                
//                puts("Segundo parrafo ***");
//                cout<<s2[matrizOperaciones[i][2]]<<endl;
                s1[matrizOperaciones[i][1]].create_phrases();
                s2[matrizOperaciones[i][2]].create_phrases();
                
                vector<string> f1 = s1[matrizOperaciones[i][1]].get_phrases();
                vector<string> f2 = s2[matrizOperaciones[i][2]].get_phrases();
//                
//                printf("Frases 1.size = %d\n",f1.size());
//                printf("Frases 2.size = %d\n",f2.size());
//                
//                for(int k = 0; k<f1.size();++k){
//                    cout<<f1[k]<<endl;
//                }
//                puts("********************** EL OTRO ****************");
//                for(int k = 0; k<f2.size();++k){
//                    cout<<f2[k]<<endl;
//                }
                
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
//                    cerr << "En F1, con j= "<<j<<" tengo "<<f1[matrizOperaciones2[j][1]]<<endl;
//                    cerr << "En F1, con j= "<<j<<" tengo "<<f1[matrizOperaciones2[j][2]]<<endl;
//                    cerr << "En F2, con j= "<<j<<" tengo "<<f2[matrizOperaciones2[j][1]]<<endl;
//                    cerr << "En F2, con j= "<<j<<" tengo "<<f2[matrizOperaciones2[j][2]]<<endl;
                    
                    if(matrizOperaciones2[j][0] == 1)
                        cout << "se elimino \"" << f1[matrizOperaciones2[j][1]] << "\""<<endl;
                    else if(matrizOperaciones2[j][0] == 2)
                        cout << "Se inserto \"" << f2[matrizOperaciones2[j][1]] << "\"" << endl;
                    else if(matrizOperaciones2[j][0]==3){
                        cout << "se reemplazó \"" << f1[matrizOperaciones2[j][1]] << "\" por \"";
                        cout<< f2[matrizOperaciones2[j][2]]<<"\" " <<endl;
                    }
                }
            }
                
        }
        
        //print_diff(m1,m2,d,s1,s2);
 	fin = clock();
 	double timeMD5 = static_cast<double>(fin - inicio)/CLOCKS_PER_SEC;

        cerr << endl << "Tamano de parrafo: " << paragraphSize << endl;
//                cerr << "Tiempo para hallar distancias: " << timeString << endl;
        //        cerr << "Tiempo MD5: " << timeMD5 << endl;
	return 0;
};




