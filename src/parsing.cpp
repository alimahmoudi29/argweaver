
#include <string.h>

#include "parsing.h"

namespace arghmm {

const int DEFAULT_LINE_SIZE = 4 * 1024;


// similar to libc readline except line is allocated with new/delete
int fgetline(char **lineptr, int *linesize, FILE *stream)
{
    char *line;
    int readsize = 0;

    if (*lineptr == NULL) {
        // allocate line buffer if it is not given
        line = new char [*linesize];
    } else{
        // use existing line buffer
        line = *lineptr;
    }
    
    char *start = line;
    int capacity = *linesize;

    while (true) {
        // place null char in last position
        char *end = &start[capacity - 2];
        *end = '\0';

        // read line
        if (!fgets(start, capacity, stream)) {
            // ensure eol is present
            start[0] = '\0';
        }
        
        // check to see if line is longer than buffer
        if (*end != '\0' && *end != '\n') {
            readsize += capacity - 1;
            
            // resize buffer
            int newsize = *linesize * 2;
            char *tmp = new char [newsize];
    
            // failed to get memory
            if (!tmp)
                return -1;
            
            // copy over line read so far
            memcpy(tmp, line, *linesize);

            // update sizes
            capacity = newsize - *linesize;
            *linesize = newsize;
            
            // update pointers
            delete [] line;
            line = tmp;
            start = &line[readsize];
            
            continue;
        }
        break;
    } 

    // line is shorter than buffer, return it

    // determine how much was read
    readsize += strlen(start);
    
    *lineptr = line;
    return readsize;
}


// read a line from a file
// return NULL pointer on eof
char *fgetline(FILE *stream)
{
    int linesize = DEFAULT_LINE_SIZE;
    char *line = NULL;
    fgetline(&line, &linesize, stream);
    
    // detect eof
    if (line[0] == '\0' && feof(stream)) {
        delete [] line;
        return NULL;
    }

    return line;
}


vector<string> split(const char *str, const char *delim, bool multiDelim)
{
    vector<string> tokens;   
    int i=0, j=0;
   
    while (str[i]) {
        // walk to end of next token
        for (; str[j] && !inChars(str[j], delim); j++);
        
        if (i == j)
            break;

        // save token
        tokens.push_back(string(&str[i], j-i));
        
        if (!str[j])
            break;
        j++;
        i = j;
    }
    
    return tokens;
}



} // namespace arghmm
