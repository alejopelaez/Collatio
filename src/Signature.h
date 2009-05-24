#ifndef SIGNATURE_H_
#define SIGNATURE_H_

#ifndef __IOSTREAM_
#include <iostream>
#define __IOSTREAM_
#endif

using namespace std;

class Signature {
    
    static const int size = 16; // 16 bytes 128 bits
    unsigned char signature[size];

public:
	Signature(){};
	~Signature(){};
    
    bool operator == (const Signature &s) const {
        int cont1 = 0; 
        while (cont1 < size && signature[cont1] == s.signature[cont1]) {
            cont1++;
        }
        return cont1 == size;
    };
    
    unsigned char *GetBuffer() {
        return signature;
    }

    friend ostream &operator <<(ostream &out, const Signature &s) {
//           ios::fmtflags flags = out.setf(ios::hex);
//           for (int cont = 0; cont < s.size; cont++) {
//               out << s.signature[cont];
//           }
//           out.setf(flags);
		static const char digits[] = "0123456789ABCDEF";
		for (int cont = 0; cont < s.size; cont++) {
			char firstDigit = digits[(s.signature[cont] & 0xF0) >> 4];
			char secondDigit = digits[s.signature[cont] & 0x0F];
			out << firstDigit << secondDigit;
		}
        return out;
    }
};

#endif /*SIGNATURE_H_*/
