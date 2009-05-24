#ifndef _RTFDECL_H
#define _RTFDECL_H 1

/* RTF parser declarations */

int ParseRTF(FILE *fp);
int PushRTFState(void);
int PopRTFState(void);
int ParseRTFKeyword(FILE *fp);
int ParseChar(int c);
int ecTranslateKeyword(char *szKeyword, int param, bool fParam);
int PrintChar(int ch);
int ecEndGroupAction(RDS rds);
int ecApplyPropChange(IPROP iprop, int val);
int ecChangeDest(IDEST idest);
int ecParseSpecialKeyword(IPFN ipfn);
int ecParseSpecialProperty(IPROP iprop, int val);
int ecParseHexByte(void);

/* RTF variable declarations */

extern int cGroup;
extern RDS rds;
extern RIS ris;

extern CHP chp;
extern PAP pap;
extern SEP sep;
extern DOP dop;

extern SAVE *psave;
extern long cbBin;
extern long lParam;
extern bool fSkipDestIfUnk;
extern FILE *fp_dest_file;

/* RTF parser error codes */

#define ecOK 0                      /* Everything's fine! */
#define errStackUnderflow   1       /* Unmatched '}' */
#define ecStackOverflow     2       /* Too many '{' -- memory exhausted */
#define errUnmatchedBrace   3       /* RTF ended during an open group.  */
#define ecInvalidHex        4       /* invalid hex character found in data */
#define ecBadTable          5       /* RTF table (sym or prop) invalid */
#define ecEndOfFile         6       /* End of file reached while reading RTF */

#endif 
