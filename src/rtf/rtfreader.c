#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <assert.h>
#include "rtftype.h"
#include "rtfdecl.h"

int group_count;                /* +1 for '{', -1 for '}' */
                                   
bool fSkipDestIfUnk;
long cbBin;
long lParam;

RDS rds;
RIS ris;

CHP chp;
PAP pap;
SEP sep;
DOP dop;
FILE *fp_dest_file;
SAVE *psave;


int main(int argc, char *argv[])
{
    FILE *fp;
    int ec;

    if (argc)
        fp = fopen(argv[1], "r");
    if (!fp)
    {
        fp = fopen("test.rtf", "r");
    }

    fp_dest_file = fopen("output.xml", "w");
    if (!fp_dest_file)
        fprintf(stderr, "Error creating destination document");
    
    ec = ParseRTF(fp);
    fclose(fp);
    fclose(fp_dest_file);
    return ec;
}

/* 
* Step 1: 
* Isolate RTF keywords and send them to ParseRTFKeyword; 
* Push and pop state at the start and end of RTF groups; 
* Send text to ParseChar for further processing
*/

int
ParseRTF(FILE *fp)
{
    int ch;
    int ec;
    int nibble = 2;             /* nibble = 4 bits = hex digit */
    int b = 0;
        
    while ((ch = getc(fp)) != EOF)
    {
        if (group_count < 0)
            return errStackUnderflow;
        if (ris == risBin)                      /* if we're parsing binary data, handle it directly */
        {
            if ((ec = ParseChar(ch)) != ecOK)
                return ec;
        }
        else
        {
            switch (ch)
            {
            case '{':
                if (group_count == 0) /* beginning document */
                    fprintf(fp_dest_file, "<begin>");
                if ((ec = PushRTFState()) != ecOK)
                    return ec;
                break;
            case '}':
                if ((ec = PopRTFState()) != ecOK)
                    return ec;
                if (group_count == 0) /* end of document */
                    fprintf(fp_dest_file, "<end>");
                break;
            case '\\':
                if ((ec = ParseRTFKeyword(fp)) != ecOK)
                    return ec;
                break;
            case 0x0d:
            case 0x0a:          /* cr and lf are noise characters... */
                break;
            default:
                if (ris == risNorm)
                {
                    if ((ec = ParseChar(ch)) != ecOK)
                        return ec;
                }
                else
                {               /* parsing hex data */
                    assert(ris == risHex); /* make sure we're reading hex */

                    b = b << 4;
                    if (isdigit(ch))
                        b += (char) ch - '0';    /* dirty atoi */
                    else
                    {
                        if (islower(ch))
                        {
                            if (ch < 'a' || ch > 'f')
                                return ecInvalidHex;
                            b += (char) ch - 'a';
                        }
                        else
                        {
                            if (ch < 'A' || ch > 'F')
                                return ecInvalidHex;
                            b += (char) ch - 'A';
                        }
                    }
                    nibble--;
                    if (!nibble)
                    {
                        if ((ec = ParseChar(ch)) != ecOK)
                            return ec;
                        nibble = 2;
                        b = 0;
                        ris = risNorm;
                    }
                }                   /* end else (ris != risNorm) */
                break;
            }       /* switch */
        }           /* else (ris != risBin) */
    }               /* while */
    if (group_count < 0)
        return errStackUnderflow;
    if (group_count > 0)
        return errUnmatchedBrace;
    return ecOK;
}

/* */
/* %%Function: PushRTFState */
/* */
/* Save relevant info on a linked list of SAVE structures. */
/* */

int
PushRTFState(void)
{
    SAVE *psaveNew = malloc(sizeof(SAVE));
    if (!psaveNew)
        return ecStackOverflow;

    psaveNew -> pNext = psave;
    psaveNew -> chp = chp;
    psaveNew -> pap = pap;
    psaveNew -> sep = sep;
    psaveNew -> dop = dop;
    psaveNew -> rds = rds;
    psaveNew -> ris = ris;
    ris = risNorm;
    psave = psaveNew;
    group_count++;
    return ecOK;
}

/* */
/* %%Function: PopRTFState */
/* */
/* If we're ending a destination (that is, the destination is changing), */
/* call ecEndGroupAction. */
/* Always restore relevant info from the top of the SAVE list. */
/* */

int
PopRTFState(void)
{
    SAVE *psaveOld;
    int ec;

    if (!psave)
        return errStackUnderflow;

    if (rds != psave->rds)
    {
        if ((ec = ecEndGroupAction(rds)) != ecOK)
            return ec;
    }
    chp = psave->chp;
    pap = psave->pap;
    sep = psave->sep;
    dop = psave->dop;
    rds = psave->rds;
    ris = psave->ris;

    psaveOld = psave;
    psave = psave->pNext;
    group_count--;
    free(psaveOld);
    return ecOK;
}

/*
* Step 2: 
* get a control word (and its associated value) and 
* call ecTranslateKeyword to dispatch the control. 
*/

int
ParseRTFKeyword(FILE *fp)
{
    int ch;
    char fParam = fFalse;
    char fNeg = fFalse;
    int param = 0;
    char *pch;
    char szKeyword[30];
    char szParameter[20];

    szKeyword[0] = '\0';
    szParameter[0] = '\0';
    if ((ch = getc(fp)) == EOF)
        return ecEndOfFile;
    if (!isalpha(ch))           /* a control symbol; no delimiter. */
    {
        szKeyword[0] = (char) ch;
        szKeyword[1] = '\0';
        return ecTranslateKeyword(szKeyword, 0, fParam);
    }
    for (pch = szKeyword; isalpha(ch); ch = getc(fp))
        *pch++ = (char) ch;
    *pch = '\0';
    if (ch == '-')
    {
        fNeg  = fTrue;
        if ((ch = getc(fp)) == EOF)
            return ecEndOfFile;
    }
    if (isdigit(ch))
    {
        fParam = fTrue;         /* a digit after the control means we have a parameter */
        for (pch = szParameter; isdigit(ch); ch = getc(fp))
            *pch++ = (char) ch;
        *pch = '\0';
        param = atoi(szParameter);
        if (fNeg)
            param = -param;
        lParam = atol(szParameter);
        if (fNeg)
            param = -param;
    }
    if (ch != ' ')
        ungetc(ch, fp);
    return ecTranslateKeyword(szKeyword, param, fParam);
}

/* */
/* %%Function: ParseChar */
/* */
/* Route the character to the appropriate destination stream. */
/* */

int
ParseChar(int ch)
{
    if (ris == risBin && --cbBin <= 0)
        ris = risNorm;
    switch (rds)
    {
    case rdsSkip:
        /* Toss this character. */
        return PrintChar(ch);

        return ecOK;
    case rdsNorm:
        /* Output a character. Properties are valid at this point. */
        return PrintChar(ch);
    default:
    /* handle other destinations.... */
        return PrintChar(ch);

        return ecOK;
    }
}

/* */
/* %%Function: PrintChar */
/* */
/* Send a character to the output file. */
/* */

int
PrintChar(int ch)
{
    /* unfortunately, we don't do a whole lot here as far as layout goes... */
    fprintf(fp_dest_file, "%c", ch);
    return ecOK;
}
