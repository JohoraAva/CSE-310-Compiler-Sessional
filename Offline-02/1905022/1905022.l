%option noyywrap

%x COMMENT
%x STRINGS
%x MYSTATE
%x MULTI_LINE_COMMENT
%x MULTI_LINE_STRING
%{
#include<cstdio>
#include<cstdlib>
#include<string>
#include<vector>
#include<bits/stdc++.h>

using namespace std;

int line_count=1;
int error=0;
int start_line;
string str="";
string str2="";
string com_str="";

FILE *logout;
FILE *tokenout;

class SymbolInfo{
string name;
    string type;
    SymbolInfo *si;
public:
    SymbolInfo()
    {
        si=NULL;
    }
    SymbolInfo(string s, string t)
    {
        name=s;
        type=t;
        si=NULL;
    }
    void setName(string s)
    {

        name=s;
    }
    string getName()
    {
        return name;
    }

    void setType(string t)
    {
        type=t;
    }

    string getType()
    {
        return type;
    }

    void setNext(SymbolInfo* s)
    {
        si=s;
    }
    SymbolInfo* getNext()
    {
        return si;
    }

};


//



class ScopeTable{
	SymbolInfo **array;
    int size;
    int id;
    ScopeTable *parent_scope;


	    unsigned int SDBMHash(string str) {
        unsigned long long int hash = 0;
        unsigned long long int i = 0;
        unsigned long long int len = str.length();

        for (i = 0; i < len; i++)
        {
            hash = (str[i]) + (hash << 6) + (hash << 16) - hash;
        }

        return (hash%size);
    }

public:
    ScopeTable(int n)
    {
        size=n;
        array=new SymbolInfo*[n];

        for(int i=0;i<size;i++)
            array[i]=new SymbolInfo();

        parent_scope=NULL;
    }

    bool Insert(string name,string type)
    {

        int idx=SDBMHash(name);
        SymbolInfo* tem=array[idx]->getNext();


        while(tem)
        {
            if(tem->getName()==name)
            {
                return false;
            }
            tem=tem->getNext();
        }

        tem=array[idx];
        int pos=1;

        while(tem->getNext())
        {
            tem=tem->getNext();
            pos++;
        }

        if(!tem->getNext())
        {
            tem->setNext(new SymbolInfo(name,type));
                ////cout<<"hoiche\n
           
          //  out<<"	Inserted in ScopeTable# "<<id<<" at position "<<idx+1<<", "<<pos<<endl;
            //cout<<"	Inserted in ScopeTable# "<<id<<" at position "<<idx+1<<", "<<pos<<endl;
            return true;
        }

        return false;


    }

    SymbolInfo* Look_Up(string name)
    {
        int idx=SDBMHash(name);
        SymbolInfo* head=array[idx];
        int cnt=0;

        while(head)
        {
            if(head->getName()==name)
            {
               // out<<"	'"<<name<<"' found in ScopeTable# "<<id<<" at position "<<SDBMHash(name)+1<<", "<<cnt<<endl;
                //cout<<"	'"<<name<<"' found in ScopeTable# "<<id<<" at position "<<SDBMHash(name)+1<<", "<<cnt<<endl;
                return head;
            }
            cnt++;
            head=head->getNext();
        }
        return NULL;
    }



    bool Delete(string name)
    {
        int idx=SDBMHash(name);

        SymbolInfo* head=array[idx];
        SymbolInfo* prev=array[idx];

        if(!head) //no element
        {
             return false;
        }

        int cnt=0;

        while(head)
        {
            ////cout<<head->getName()<<" "<<name<<endl;
            if(head->getName()==name)
            {
                prev->setNext(head->getNext());
              //  delete head;//???
               // out<<"	Deleted '"<<name<<"' from ScopeTable# "<<id<<" at position "<<SDBMHash(name)+1<<", "<<cnt<<endl;
                //cout<<"	Deleted '"<<name<<"' from ScopeTable# "<<id<<" at position "<<SDBMHash(name)+1<<","<<cnt<<endl;
                delete head;
                return true;
            }
            cnt++;
            prev=head;
            head=head->getNext();
        }

        return false;


    }

    int getSize()
    {
        return size;
    }

    void setId(int i)
    {
        id=i;
    }

    int getId()
    {
        return id;
    }

    void Print()
    {
        if(id>0)
        {
            fprintf(logout,"\tScopeTable# %d\n",id);
            //out<<"	ScopeTable# "<<id<<endl;
            //cout<<"	ScopeTable# "<<id<<endl;

            for(int i=0;i<size;i++)
            {
                SymbolInfo* tem=array[i];
                // if(tem->getTotalElement()==i+1)
                //     break;
               
                //cout<<"	"<< i+1<< "--> ";
                while(tem)
                {
                    // fprintf(logout,"\t%d-> ",i+1);
               // out<<"	"<< i+1<< "--> ";
                    if(tem->getName().length()>0)
                    {
                        fprintf(logout,"\t%d--> ",i+1);
                        string name(tem->getName());
                        string type(tem->getType());
                        fprintf(logout,"<%s,%s> ",name.c_str(),type.c_str());
                       // fprintf(logout,"check bla: %d",name.length());
                        // out<<"<"<<tem->getName()<<","<<tem->getType()<<"> ";
                         //cout<<"<"<<tem->getName()<<","<<tem->getType()<<"> ";
                          fprintf(logout,"\n");
                    }

                    tem=tem->getNext();
        
                }
                
               // out<<endl;
                //cout<< endl;

            }
        }

    }


    void setParentScop(ScopeTable* st)
    {
        parent_scope=st;
    }

    ScopeTable* getParentScop()
    {
        return parent_scope;
    }

    ~ScopeTable()
    {
        for(int i=0;i<size;i++)
        {
            SymbolInfo* top=array[i];
            while(top)
            {
                SymbolInfo* par=top;
                top=top->getNext();
                delete par;
            }
        }
        delete[] array;
    }


};
class SymbolTable{

    ScopeTable *cur;
    int total=0;  //set id of scopetable
    int len; //total bucket number
public:
    SymbolTable(int n)
    {
        len=n;
        cur=new ScopeTable(len);
    }
    void EnterScope()
    {
        ScopeTable* tem=new ScopeTable(len);
        tem->setParentScop(cur);

        cur=tem;

        cur->setId(++total);

       // out<<"	ScopeTable# "<<total<<" created"<<endl;
        //cout<<"	ScopeTable# "<<total<<" created"<<endl;
    }

    void ExitScope()
    {
        ScopeTable* tem=cur;

        if(tem->getId()==1 )//&!flag)
        {
           // out<<"	ScopeTable# "<<tem->getId()<<" cannot be removed"<<endl;
            //cout<<"	ScopeTable# "<<tem->getId()<<" cannot be removed"<<endl;
            return;
        }
        else
        {
            cur=cur->getParentScop();

        }

        if(tem->getId()>0)
        {
            //cout<<"	ScopeTable# "<<tem->getId()<<" removed"<<endl;
           // out<<"	ScopeTable# "<<tem->getId()<<" removed"<<endl;
            delete tem;
        }
    }

    bool Insert(string name,string type)
    {
        if(cur->Insert(name,type))
        {
            ////cout<<"	Inserted in ScopeTable# "<<total<<" at position "<<cur->SDBMHash(name)<<", "<<cur->getElementNumber()<<endl;
            return true;
        }

        else
        {
            fprintf(logout,"	%s already exists in the current ScopeTable\n",name.c_str());
            //logout<<"	'"<<name<<"' already exists in the current ScopeTable\n";
            //cout<<"	'"<<name<<"' already exists in the current ScopeTable\n";
            return false;
        }
    }

    bool Remove(string name)
    {
        if(cur->Delete(name))
        {
           // //cout<<"	Deleted '"<<name<<"' from ScopeTable# "<<cur->getId()<<" at position "<<cur->SDBMHash(name)<<", 1"<<endl;
            return true;
        }
        else
        {
            //out<<"	Not found in the current ScopeTable\n";
            //cout<<"	Not found in the current ScopeTable\n";
            return false;
        }
    }

    SymbolInfo* LookUp(string name )
    {
       ScopeTable * tem=cur;
       SymbolInfo* res;
       while(tem)
       {

            res=tem->Look_Up(name);
            if(res)
                return res;
            tem=tem->getParentScop();

       }
      //  out<<"	'"<<name<<"' not found in any of the ScopeTables"<<endl;
        //cout<<"	'"<<name<<"' not found in any of the ScopeTables "<<endl;
        return NULL;
    }

    void printCurrentScopeTable()
    {
            cur->Print();
           // //cout<<endl;

    }

    void printAllScopeTable()
    {
        ScopeTable* top=cur;

        while(top)
        {
            top->Print();
            ////cout<<endl<<endl;
            top=top->getParentScop();
        }
        // if(!top->getParentScop())
        //     top->Print();
    }

    int getTotalScopeTable()
    {
        return total;
    }


};

SymbolTable st(10);


%}


WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
CHAR [ -~]{-}[']
CHARS {CHAR}+
EMPTY_CHAR ('')
CHARACTER '[a-z0-9A-Z]' 
CHAR_TEXT '\\[ntabf\\v0r"v]
MULTI_CHAR ('[a-z0-9A-Z][a-z0-9A-Z]+')
UNFINISHED_CHAR '[a-z0-9A-Z]

DIGIT [0-9]
ID ([a-zA-Z_]([a-z0-9A-Z_]*)?)
NUMBER {DIGIT}+(\.{DIGIT}+)(E[+-]?{DIGIT}+)?

STR_NEWLINE \\\n
COMMENT "//"
EXTEND "\\\n"
NEWLINE \n
STRING \"([^"\\]| \\['"?\\abfnrtv])

NOT_ID [0-9]+(\.)?[A-Z0-9a-z_]+
DECI_ERROR [0-9]*[.][0-9]*([.]+[0-9]*)*
ILL_NUMBER [0-9]*((E[+-]?[0-9]+)([.][0-9]+)*)(E[+-]?[0-9]+)?([.][0-9]+)*

%%

{NEWLINE} {line_count++;}

"if"	{
			fprintf(tokenout,"<IF, if>");
             fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <IF> Lexeme %s found\n",line_count,yytext);
		}
		
"else"	{
			fprintf(tokenout,"<ELSE, else>");
             fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <ELSE> Lexeme %s found\n",line_count,yytext);
		}
"for"  {
            fprintf(tokenout,"<FOR, for>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line# %d: Token <FOR> Lexeme %s found\n",line_count,yytext);
		 
}

"while"  {
            fprintf(tokenout,"<WHILE, while>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line# %d: Token <WHILE> Lexeme %s found\n",line_count,yytext);
		 
}

"do"  {
            fprintf(tokenout,"<DO, do>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line# %d: Token <DO> Lexeme %s found\n",line_count,yytext);
		 
}
"break"  {
            fprintf(tokenout,"<BREAK, break>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line# %d: Token <BREAK> Lexeme %s found\n",line_count,yytext);
		 
}

"int"  {
            fprintf(tokenout,"<INT, int>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line# %d: Token <INT> Lexeme %s found\n",line_count,yytext);
		 
}

"char"  {
            fprintf(tokenout,"<CHAR, char>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line# %d: Token <CHAR> Lexeme %s found\n",line_count,yytext);
		 
}
"float"  {
            fprintf(tokenout,"<FLOAT, float>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line# %d: Token <FLOAT> Lexeme %s found\n",line_count,yytext);
		 
}

"double"  {
            fprintf(tokenout,"<DOUBLE, double>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line# %d: Token <DOUBLE> Lexeme %s found\n",line_count,yytext);
		 
}

"void"  {
            fprintf(tokenout,"<VOID, void>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line# %d: Token <VOID> Lexeme %s found\n",line_count,yytext);
		 
}

"return"  {
            fprintf(tokenout,"<RETURN, return>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line# %d: Token <RETURN> Lexeme %s found\n",line_count,yytext);
		 
}
"switch"  {
            fprintf(tokenout,"<SWITCH, switch>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line# %d: Token <SWITCH> Lexeme %s found\n",line_count,yytext);
		 
}
"case"  {
            fprintf(tokenout,"<CASE, case>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line# %d: Token <CASE> Lexeme %s found\n",line_count,yytext);
		 
}
"default"  {
            fprintf(tokenout,"<DEFAULT, default>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line# %d: Token <DEFAULT> Lexeme %s found\n",line_count,yytext);
		 
}

"continue"  {
            fprintf(tokenout,"<CONTINUE, continue>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line# %d: Token <CONTINUE> Lexeme %s found\n",line_count,yytext);
		 
}






"+"		|

"-"		{
			fprintf(tokenout,"<ADDOP, %s>",yytext);
             fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <ADDOP> Lexeme %s found\n",line_count,yytext);
			//insert in symbol table and print symbol table content(only non empty buckets)
			// There is a '|' in "+"'s rule, this means match execute the action for following rule
		}

[*/%]   {
            fprintf(tokenout,"<MULOP, %s>",yytext);
             fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <MULOP> Lexeme %s found\n",line_count,yytext);
			

        }
"++"		|

"--"	{
			fprintf(tokenout,"<INCOP, %s>",yytext);
             fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <INCOP> Lexeme %s found\n",line_count,yytext);
		}

 "<"|"<="|">"|">="|"=="|"!=" {
			fprintf(tokenout,"<RELOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RELOP> Lexeme %s found\n",line_count,yytext);
		}

 "=" {
			fprintf(tokenout,"<ASSIGNOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
        }
 "&&"|"||"
        {
			fprintf(tokenout,"<LOGICOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LOGICOP> Lexeme %s found\n",line_count,yytext);
        }

"&"|"|"|"^"|"<<"|">>" {
			fprintf(tokenout,"<BITOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <BITOP> Lexeme %s found\n",line_count,yytext);
        }
 "!" {
			fprintf(tokenout,"<NOT, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <NOT> Lexeme %s found\n",line_count,yytext);
        }

 "(" {
			fprintf(tokenout,"<LPAREN, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LPAREN> Lexeme %s found\n",line_count,yytext);
        }
 ")" {
			fprintf(tokenout,"<RPAREN, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RPAREN> Lexeme %s found\n",line_count,yytext);
        }

 "{"    {
			fprintf(tokenout,"<LCURL, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LCURL> Lexeme %s found\n",line_count,yytext);
            st.EnterScope();
        }

 "}" {
			fprintf(tokenout,"<RCURL, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RCURL> Lexeme %s found\n",line_count,yytext);
            st.ExitScope();
           // st.printAllScopeTable();
        }

 "[" {
			fprintf(tokenout,"<LSQUARE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LSQUARE> Lexeme %s found\n",line_count,yytext);
        }
  
 "]" {
			fprintf(tokenout,"<RSQUARE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RSQUARE> Lexeme %s found\n",line_count,yytext);
        }

 "," {
			fprintf(tokenout,"<COMMA, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <COMMA> Lexeme %s found\n",line_count,yytext);
        }

 ";" {
			fprintf(tokenout,"<SEMICOLON, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <SEMICOLON> Lexeme %s found\n",line_count,yytext);
        }
  
    
    
    
        
		
{DIGIT}+ 	{
				fprintf(tokenout,"<CONST_INT, %s>\n",yytext);
				fprintf(logout,"Line# %d: Token <CONST_INT> Lexeme %s found\n",line_count,yytext);
				
			}

{NUMBER} 	{
				fprintf(tokenout,"<CONST_FLOAT, %s>\n",yytext);
				fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
				
			}
{CHARACTER} {
                
                
				fprintf(tokenout,"<CONST_CHAR, %c>\n",yytext[1]);
				fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %c found\n",line_count,yytext[1]);
			}
{CHAR_TEXT} {
                char c;
                if(yytext[2]=='t')
                    c='\t';
                if(yytext[2]=='n')
				     c='\n';
                if(yytext[2]=='a')
				    c='\a';
                if(yytext[2]=='f')
				     c='\f';
                if(yytext[2]=='r')
				    c='\r';
                if(yytext[2]=='b')
				    c='\b';
                if(yytext[2]=='v')
				     c='\v';
                if(yytext[2]=='0')
				     c='\0';
                if(yytext[2]=='"')
				     c='"';
                if(yytext[2]=='\\')
				    c='\\';
                
                fprintf(tokenout,"<CONST_CHAR, %c>\n",c);
				fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %c found\n",line_count,c);
               
			
            }
{EMPTY_CHAR} {
                fprintf(logout,"Error at line# %d: EMPTY_CONST_CHAR %s \n ",line_count,yytext);
				error++;

}

{MULTI_CHAR} 	{
				//fprintf(tokenout,"<IDENTIFIER, %s>\n",yytext);
				fprintf(logout,"Error at line# %d: MULTICHAR_CONST_CHAR %s \n ",line_count,yytext);
				error++;
			}
{UNFINISHED_CHAR} 	{
				//fprintf(tokenout,"<IDENTIFIER, %s>\n",yytext);
				fprintf(logout,"Error at line# %d: UNFINISHED_CONST_CHAR %s \n ",line_count,yytext);
				error++;
			}



{NOT_ID} 	{
				//fprintf(tokenout,"<IDENTIFIER, %s>\n",yytext);
				fprintf(logout,"Error at line# %d: INVALID_ID_SUFFIX_NUM_PREFIX %s \n ",line_count,yytext);
				error++;
			}
{ID} 	{
				fprintf(tokenout,"<ID, %s>\n",yytext);
				fprintf(logout,"Line# %d: Token <ID> Lexeme %s found\n",line_count,yytext);
                string name(yytext);
				bool flag=st.Insert(name,"ID");
                if(flag)
                    st.printAllScopeTable();
			}
{DECI_ERROR} 	{
				//fprintf(tokenout,"<IDENTIFIER, %s>\n",yytext);
				fprintf(logout,"Error at line# %d: TOO_MANY_DECIMAL_POINTS %s\n ",line_count,yytext);
				error++;
			}
{ILL_NUMBER} 	{
				//fprintf(tokenout,"<IDENTIFIER, %s>\n",yytext);
				fprintf(logout,"Error at line# %d: ILLFORMED_NUMBER %s\n ",line_count,yytext);
				error++;
			}

\"       {
    BEGIN(STRINGS);
    str2+=yytext;
    start_line=line_count;
  

}
<STRINGS>[^\"\n] {

        str2+=yytext;
        str+=yytext;
    
}

<STRINGS>"\"" {
        str2+=yytext;
        fprintf(tokenout,"<SINGLE LINE STRING, %s>\n",str.c_str());
        fprintf(logout,"Line# %d: Token <SINGLE LINE STRING> Lexeme %s found\n",start_line,str2.c_str());
                
        BEGIN(INITIAL);
        str="";
        str2="";
}


<STRINGS>\\\n {
     line_count++;
     str2+=yytext;
     BEGIN(MULTI_LINE_STRING);

}

<STRINGS>\\[ntabfv0\\r"v] {
        if(yytext[1]=='n')
            str+='\n';
        if(yytext[1]=='t')
            str+='\t';   
        if(yytext[1]=='a')
            str+='\a';
        if(yytext[1]=='f')
            str+='\f';
        if(yytext[1]=='r')
            str+='\r';
        if(yytext[1]=='b')
            str+='\b';
        if(yytext[1]=='v')
            str+='\v';
        if(yytext[1]=='0')
            str+='\0';
        if(yytext[1]=='"')
            str+='\"';
        if(yytext[1]=='\\')
            str+='\\';

        str2+=yytext;

}



<MULTI_LINE_STRING>"\"" {
    
    str2+=yytext;
    fprintf(tokenout,"<MULTI LINE STRING, %s>\n",str.c_str());
    fprintf(logout,"Line# %d: Token <MULTI LINE STRING> Lexeme %s found\n",start_line,str2.c_str());
    BEGIN(INITIAL);
    str="";
    str2="";
}


<MULTI_LINE_STRING>\\[ntabfv0\\r"v] {
        if(yytext[1]=='n')
            str+='\n';
        if(yytext[1]=='t')
            str+='\t';   
        if(yytext[1]=='a')
            str+='\a';
        if(yytext[1]=='f')
            str+='\f';
        if(yytext[1]=='r')
            str+='\r';
        if(yytext[1]=='b')
            str+='\b';
        if(yytext[1]=='v')
            str+='\v';
        if(yytext[1]=='0')
            str+='\0';
        if(yytext[1]=='"')
            str+='\"';
        if(yytext[1]=='\\')
            str+='\\';

        str2+=yytext;

}
<MULTI_LINE_STRING>\\\n  {
    
    line_count++;
    str2+=yytext;
}

<MULTI_LINE_STRING>[^\"\n] {
    
    str+=yytext;
    str2+=yytext;
}


<MULTI_LINE_STRING>{NEWLINE}  {
    
    line_count++;
    str+=yytext;
    str2+=yytext;
}

<MULTI_LINE_STRING><<EOF>> {

        fprintf(logout,"Error at line# %d: UNFINISHED_STRING %s\n ",start_line,str2.c_str());		
        error++;
        BEGIN(INITIAL);
}

"//" {
    BEGIN(COMMENT);
    com_str+=yytext;
    start_line=line_count;
}

<COMMENT>[^\n]   {
    
    com_str+=yytext;
}
<COMMENT>"\\\n"   {
    
    line_count++;
    com_str+=yytext;
}

<COMMENT>{NEWLINE}  {
    
    line_count++;
    fprintf(logout,"Line# %d: Token <SINGLE LINE COMMENT> Lexeme %s found\n",start_line,com_str.c_str());
    BEGIN(INITIAL);
    com_str="";
}

"/*"  {
    BEGIN(MULTI_LINE_COMMENT);
    str+=yytext;
    start_line=line_count;
}

<MULTI_LINE_COMMENT>"*/" {
    
    str+=yytext;
    fprintf(logout,"Line# %d: Token <MULTI LINE COMMENT> Lexeme %s found\n",start_line,str.c_str());
    BEGIN(INITIAL);
    str="";
}
<MULTI_LINE_COMMENT>[^\n] {
    
    str+=yytext;
}

<MULTI_LINE_COMMENT>{NEWLINE}  {
    
    line_count++;
    str+=yytext;
}

<MULTI_LINE_COMMENT><<EOF>> {
    
        fprintf(logout,"Error at line# %d: UNFINISHED_COMMENT %s\n ",start_line,str.c_str());		
        error++;
        fprintf(logout,"Total lines: %d\n",line_count-1);
        fprintf(logout,"Total errors: %d\n",error);
        return 0;
}




    


			

%%

int main(int argc, char** argv) {
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("log.txt","w");
	tokenout= fopen("token.txt","w");

    st.EnterScope();
	yyin= fin;
	yylex();
	st.printAllScopeTable();
    fprintf(logout,"Total lines: %d\n",line_count-1);
    fprintf(logout,"Total errors: %d\n",error);
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}