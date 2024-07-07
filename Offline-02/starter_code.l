%option noyywrap

%x COMMENT
%x STRINGS
%x MYSTATE
%{
#include<cstdio>
#include<cstdlib>
#include<string>
#include<vector>
#include<bits/stdc++.h>

using namespace std;

int line_count=1;
int error=0;

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
            fprintf(logout,"	ScopeTable# \n");
            //out<<"	ScopeTable# "<<id<<endl;
            //cout<<"	ScopeTable# "<<id<<endl;

            for(int i=0;i<size;i++)
            {
                SymbolInfo* tem=array[i];
                fprintf(logout,"	%s",i+1);
               // out<<"	"<< i+1<< "--> ";
                //cout<<"	"<< i+1<< "--> ";
                while(tem)
                {
                    if(tem->getName().length()>0)
                    {
                        fprintf(logout,"%n,%t> ",tem->getName(),tem->getType());
                        // out<<"<"<<tem->getName()<<","<<tem->getType()<<"> ";
                         //cout<<"<"<<tem->getName()<<","<<tem->getType()<<"> ";
                    }
                    tem=tem->getNext();
                }
                fprintf(logout,"\n");
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
           // fprintf(logout,"	'",name,"' already exists in the current ScopeTable\n");
            //out<<"	'"<<name<<"' already exists in the current ScopeTable\n";
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

        while(top->getParentScop())
        {
            top->Print();
            ////cout<<endl<<endl;
            top=top->getParentScop();
        }
        if(!top->getParentScop())
            top->Print();
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
CHAR [-~]{-}[']
CHARS {CHAR}+
CHARACTER '[a-z0-9A-Z]' 
CHAR_TEXT '\\[ntabf\\v0r"v]
MAUTI_CHAR ('[a-z0-9A-Z][a-z0-9A-Z]+')


DIGIT [0-9]
ID ([a-z0-9A-Z_]([a-z0-9A-Z_]*)?)
NUMBER {DIGIT}+(\.{DIGIT}+)(E[+-]?{DIGIT}+)?

STR_NEWLINE \\\n
COMMENT "//"
EXTEND "\\\n"
NEWLINE \n

NOT_ID [0-9]+(\.)?[A-Z0-9a-z_]+
DECI_ERROR [0-9]*[.][0-9]*([.]+[0-9]*)*
ILL_NUMBER [0-9]*((E[+-]?[0-9]+)([.][0-9]+)*)(E[+-]?[0-9]+)?([.][0-9]+)*

%%

{NEWLINE} {line_count++;}

"if"	{
			fprintf(tokenout,"<IF, if>");
             fprintf(tokenout,"\n");
			fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s found\n",line_count,yytext);
		}
		
"else"	{
			fprintf(tokenout,"<ELSE, else>");
             fprintf(tokenout,"\n");
			fprintf(logout,"Line no %d: TOKEN <ELSE> Lexeme %s found\n",line_count,yytext);
		}
"for"  {
            fprintf(tokenout,"<FOR, for>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line no %d: TOKEN <FOR> Lexeme %s found\n",line_count,yytext);
		 
}

"while"  {
            fprintf(tokenout,"<WHILE, while>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line no %d: TOKEN <WHILE> Lexeme %s found\n",line_count,yytext);
		 
}

"do"  {
            fprintf(tokenout,"<DO, do>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line no %d: TOKEN <DO> Lexeme %s found\n",line_count,yytext);
		 
}
"break"  {
            fprintf(tokenout,"<BREAK, break>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line no %d: TOKEN <BREAK> Lexeme %s found\n",line_count,yytext);
		 
}

"int"  {
            fprintf(tokenout,"<INT, int>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line no %d: TOKEN <INT> Lexeme %s found\n",line_count,yytext);
		 
}

"char"  {
            fprintf(tokenout,"<CHAR, char>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line no %d: TOKEN <CHAR> Lexeme %s found\n",line_count,yytext);
		 
}
"float"  {
            fprintf(tokenout,"<FLOAT, flaot>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line no %d: TOKEN <FLOAT> Lexeme %s found\n",line_count,yytext);
		 
}

"double"  {
            fprintf(tokenout,"<DOUBLE, double>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line no %d: TOKEN <DOUBLE> Lexeme %s found\n",line_count,yytext);
		 
}

"void"  {
            fprintf(tokenout,"<VOID, void>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line no %d: TOKEN <VOID> Lexeme %s found\n",line_count,yytext);
		 
}

"return"  {
            fprintf(tokenout,"<RETURN, return>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line no %d: TOKEN <RETURN> Lexeme %s found\n",line_count,yytext);
		 
}
"switch"  {
            fprintf(tokenout,"<SWITCH, switch>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line no %d: TOKEN <SWITCH> Lexeme %s found\n",line_count,yytext);
		 
}
"case"  {
            fprintf(tokenout,"<CASE, case>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line no %d: TOKEN <CASE> Lexeme %s found\n",line_count,yytext);
		 
}
"default"  {
            fprintf(tokenout,"<DEFAULT, default>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line no %d: TOKEN <DEFAULT> Lexeme %s found\n",line_count,yytext);
		 
}

"continue"  {
            fprintf(tokenout,"<CONTINUE, continue>");
             fprintf(tokenout,"\n");
		    fprintf(logout,"Line no %d: TOKEN <CONTINUE> Lexeme %s found\n",line_count,yytext);
		 
}






"+"		|

"-"		{
			fprintf(tokenout,"<ADDOP, %s>",yytext);
             fprintf(tokenout,"\n");
			fprintf(logout,"Line no %d: TOKEN <ADDOP> Lexeme %s found\n",line_count,yytext);
			//insert in symbol table and print symbol table content(only non empty buckets)
			// There is a '|' in "+"'s rule, this means match execute the action for following rule
		}

[*/%]   {
            fprintf(tokenout,"<MULOP, %s>",yytext);
             fprintf(tokenout,"\n");
			fprintf(logout,"Line no %d: TOKEN <MULOP> Lexeme %s found\n",line_count,yytext);
			

        }
"++"		|

"--"	{
			fprintf(tokenout,"<INCOP, %s>",yytext);
             fprintf(tokenout,"\n");
			fprintf(logout,"Line no %d: TOKEN <INCOP> Lexeme %s found\n",line_count,yytext);
		}

 "<"|"<="|">"|">="|"=="|"!=" {
			fprintf(tokenout,"<RELOP, %s>\n",yytext);
			fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s found\n",line_count,yytext);
		}

 "=" {
			fprintf(tokenout,"<ASSIGNOP, %s>\n",yytext);
			fprintf(logout,"Line no %d: TOKEN <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
        }
 "&&"|"||"
        {
			fprintf(tokenout,"<LOGICOP, %s>\n",yytext);
			fprintf(logout,"Line no %d: TOKEN <LOGICOP> Lexeme %s found\n",line_count,yytext);
        }

"&"|"|"|"^"|"<<"|">>" {
			fprintf(tokenout,"<BITOP, %s>\n",yytext);
			fprintf(logout,"Line no %d: TOKEN <BITOP> Lexeme %s found\n",line_count,yytext);
        }
 "!" {
			fprintf(tokenout,"<NOT, %s>\n",yytext);
			fprintf(logout,"Line no %d: TOKEN <NOT> Lexeme %s found\n",line_count,yytext);
        }

 "(" {
			fprintf(tokenout,"LPAREN, %s>\n",yytext);
			fprintf(logout,"Line no %d: TOKEN <LPAREN> Lexeme %s found\n",line_count,yytext);
        }
 ")" {
			fprintf(tokenout,"RPAREN, %s>\n",yytext);
			fprintf(logout,"Line no %d: TOKEN <RPAREN> Lexeme %s found\n",line_count,yytext);
        }

 "{"    {
			fprintf(tokenout,"LCURL, %s>\n",yytext);
			fprintf(logout,"Line no %d: TOKEN <LCURL> Lexeme %s found\n",line_count,yytext);
        }

 "}" {
			fprintf(tokenout,"RCURL, %s>\n",yytext);
			fprintf(logout,"Line no %d: TOKEN <RCURL> Lexeme %s found\n",line_count,yytext);
        }

 "[" {
			fprintf(tokenout,"LSQUARE, %s>\n",yytext);
			fprintf(logout,"Line no %d: TOKEN <LSQUARE> Lexeme %s found\n",line_count,yytext);
        }
  
 "]" {
			fprintf(tokenout,"RSQUARE, %s>\n",yytext);
			fprintf(logout,"Line no %d: TOKEN <RSQUARE> Lexeme %s found\n",line_count,yytext);
        }

 "," {
			fprintf(tokenout,"COMMA, %s>\n",yytext);
			fprintf(logout,"Line no %d: TOKEN <COMMA> Lexeme %s found\n",line_count,yytext);
        }

 ";" {
			fprintf(tokenout,"SEMICOLON, %s>\n",yytext);
			fprintf(logout,"Line no %d: TOKEN <SEMICOLON> Lexeme %s found\n",line_count,yytext);
        }
  
    
    
    
        
		
{DIGIT}+ 	{
				fprintf(tokenout,"<CONST_INT, %s>\n",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_INT> Lexeme %s found\n",line_count,yytext);
				
			}

{NUMBER} 	{
				fprintf(tokenout,"<CONST_FLOAT, %s>\n",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
				
			}

{NOT_ID} 	{
				//fprintf(tokenout,"<IDENTIFIER, %s>\n",yytext);
				fprintf(logout,"Error at Line no %d: Invalid prefix on ID or invalid suffix on number %s \n\n",line_count,yytext);
				error++;
			}
{ID} 	{
				fprintf(tokenout,"<IDENTIFIER, %s>\n",yytext);
				fprintf(logout,"Line no %d: TOKEN <IDENTIFIER> Lexeme %s found\n",line_count,yytext);
				st.Insert("ID",yytext);
                st.printAllScopeTable();
			}
{DECI_ERROR} 	{
				//fprintf(tokenout,"<IDENTIFIER, %s>\n",yytext);
				fprintf(logout,"Error at Line no %d: too many decimal point %s\n\n",line_count,yytext);
				error++;
			}
{ILL_NUMBER} 	{
				//fprintf(tokenout,"<IDENTIFIER, %s>\n",yytext);
				fprintf(logout,"Error at Line no %d: Ill formed number %s\n\n",line_count,yytext);
				error++;
			}

\"  {
    BEGIN(STRINGS);
    str2=str2+yytext;

    int c=line_count;

}



"/*" {
    BEGIN(COMMENT);
}

<COMMENT> "*/" {
    BEGIN(INITIAL);
}

<COMMENT> ([^*]| \n)+ | .
<COMMENT><<EOF>> {
   fprintf(logout,"Error at Line no %d: Unterminated comment %s\n\n",line_count,yytext);
	error++;
    BEGIN 0;
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

	yyin= fin;
	yylex();
	st.printAllScopeTable();
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}