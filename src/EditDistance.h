#ifndef __EDITDISTANCE_H
#define __EDITDISTANCE_H

#ifndef __VECTOR_
#include <vector>
#define __VECTOR_
#endif

#ifndef __IOSTREAM_
#include <iostream>
#define __IOSTREAM_
#endif

#include <string>

using std::vector;
//using std::cerr;

using namespace std;

template <class T>
class EditOperation {
    enum operation {ins, del, replace};
};

//****************************
// Get minimum of three values
//****************************
template  <class T> inline T Minimum (T a, T b, T c) {
    T min = a;
    if (b < min) {
        min = b;
    }
    if (c < min) {
        min = c;
    }
    return min;
}

//**********************************************
// Compute Levenshtein distance 
//**********************************************


template <class T>
int LevenshteinDistance(const vector<T>& s, const vector<T>& t, vector<vector<int> >& d, vector<vector<int> >& matrizOperaciones) {
    
    //Starts Levenshtein Distance
    int n = d.size()-1;
    int m = d[0].size()-1;
    for (int i = 0; i <= n; i++) {
        d[i][0] = i;
    }
    for (int j = 0; j <= m; j++) {
        d[0][j] = j;
    }

    // Step 3
    for (int i = 1; i <= n; i++) {
        // Step 4
        for (int j = 1; j <= m; j++) {
            // Step 5
            int cost = (s[i-1] == t[j-1] ? 0 : 1);
            // Step 6
            d[i][j] = Minimum (d[i-1][j]+1, d[i][j-1]+1, d[i-1][j-1] + cost);
        }
    }
    
    
    //Prints the distance matrix
//    for(int i=0;i<=n;i++){
//        for(int j=0;j<=m;j++){
//            //cerr << d[i][j] <<"\t";
//            cout << d[i][j] <<"\t";
//        }
//        //cerr<<endl;
//        cout<<endl;
//    }
    //End of Levenshtein Distance
    
    /**
     * Matrix created to have the change made, vector1 index and vector 2 index.
     * Each operation has an index,
     * Elimination -> 1
     * Insertion -> 2
     * Replacing -> 3
     */
    
    int tamop = d[n][m]; //Levenshtein distance = number of operations
    matrizOperaciones = vector<vector<int> >(tamop,vector<int>(3,0));
    
//    for(int i=0;i<tamop;i++){
//        for(int j=0;j<3;j++){
//            matrizOperaciones[i][j]= 0;
//        }
//    }
    
  //  puts("TEST!");
//    cout<<tamop<<endl;
    //cout<<matrizOperaciones[tamop-1][0]<<endl;
    //cout<<matrizOperaciones[3][0]<<endl;

     //Step 7
    int diago;
    bool  replace = false;

//    cerr<<"*****" << endl;
//    cout<<"*****" << endl;
    int n2=n;
    int m2=m; 
    int cont= 0;

    while (n2 != 0 && m2!= 0){
        /*Si son iguales*/
        if (d[n2][m2] == d[n2-1][m2-1] && s[n2-1]==t[m2-1]) { 
            n2--;
            m2--;
        } else if ((d[n2][m2] - d[n2-1][m2]) == 1) {
            n2--;
            matrizOperaciones[cont][0] = 1;
            matrizOperaciones[cont][1] = n2; //estaba n2-1
            matrizOperaciones[cont][2] = n2-1; //estaba n2-2
//            cerr << "se elimino \"" << s[matrizOperaciones[cont][1]] << "\""<<endl;
//            cout << "se elimino \"" << s[matrizOperaciones[cont][1]] << "\""<<endl;
            //aca si se elimina del vector 1 entonces que indice seria en el vector 2
            cont++;
        } else if ((d[n2][m2] - d[n2][m2-1]) == 1) {
            m2--;
            matrizOperaciones[cont][0] = 2;
            matrizOperaciones[cont][1] = m2; //estaba N2-1
            matrizOperaciones[cont][2] = m2-1; //estaba N2-2
//            cerr << "Se inserto \"" << t[matrizOperaciones[cont][1]] << "\"" << endl; //imprimia m2-1
//            cout << "Se inserto \"" << t[matrizOperaciones[cont][1]] << "\"" << endl; //imprimia m2-1
            /*aca si se inserta en el vector 2 entonces que indice sera en el vector 1*/
            cont++;
        } else {
            /*Reemplazos!*/
            n2--;
            m2--;
            matrizOperaciones[cont][0] = 3;
            matrizOperaciones[cont][1] = n2; //tenian -1
            matrizOperaciones[cont][2] = m2;
//            cerr << "Se reemplaza \"" << s[matrizOperaciones[cont][1]] << "\" ";
//            cerr << "por \"" << t[matrizOperaciones[cont][2]] << "\"" << endl;
//            cout << "Se reemplaza \"" << s[matrizOperaciones[cont][1]] << "\" ";
//            cout << "por \"" << t[matrizOperaciones[cont][2]] << "\"" << endl;
            cont++;
        }
    }
		
    while (n2 != 0) {
        n2--;
        matrizOperaciones[cont][0] = 2;
        matrizOperaciones[cont][1] = n2; //estaba n2-1
        matrizOperaciones[cont][2] = n2-1; //estaba n2-2
//        cerr<<"Se inserta \""<< s[matrizOperaciones[cont][1]] << "\"" << endl;
//        cout<<"Se inserta \""<< s[matrizOperaciones[cont][1]] << "\"" << endl;
        cont++;
    }

    while (m2 != 0) {
        m2--;
        matrizOperaciones[cont][0] = 1;
        matrizOperaciones[cont][1] = m2; //estaba n2 - 1 (OJO, N y no M)
        matrizOperaciones[cont][2] = m2-1;//estaba m2-2
        cont++;
//        cerr << "Se elimino \"" << t[matrizOperaciones[cont][2]] << "\"" << endl;
//        cout << "Se elimino \"" << t[matrizOperaciones[cont][2]] << "\"" << endl;
    }

    int distance = d[n][m];
    //        for (int cont1 = 0; cont1 < n+1; cont1++) {
    //          delete []d[cont1];
    //   }
    //        delete d;
    return distance;
}


#endif
