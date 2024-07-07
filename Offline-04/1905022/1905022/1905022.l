%option noyywrap

%{
#include<iostream>
#include<stdlib.h>
#include<string.h>
#include "SymbolTable.h"
#include "y.tab.h"


using namespace std;

 int start_line;
 string str;
  string str2;
  string com_str;




extern FILE *logout;
extern FILE *tokenout;
extern FILE* errorout;
extern int line_count;
extern int error;

extern YYSTYPE yylval;
extern SymbolTable *table;// = new SymbolTable(10);

void yyerror(char *);


 


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

ADDOP [+-] 
MULOP [*/%]

%%

{WHITESPACE}+	{ }
{NEWLINE} {line_count++;}


"if"	{
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"IF");
			yylval.sym=s;
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
			fprintf(logout,"Line# %d: Token <IF> Lexeme %s found\n",line_count,yytext);

			return IF;
		}
		
"else"	{
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"ELSE");
			yylval.sym=s;
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
			
			fprintf(logout,"Line# %d: Token <ELSE> Lexeme %s found\n",line_count,yytext);
			return ELSE;
		}
"for"  {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"FOR");
			yylval.sym=s;
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
          
		    fprintf(logout,"Line# %d: Token <FOR> Lexeme %s found\n",line_count,yytext);
			return FOR;

		 
}

"while"  {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"WHILE");
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;

			yylval.sym=s;
            
		    fprintf(logout,"Line# %d: Token <WHILE> Lexeme %s found\n",line_count,yytext);
		 	return WHILE;
}
"int"  {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"INT");
			
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
           	yylval.sym=s;
		    fprintf(logout,"Line# %d: Token <INT> Lexeme %s found\n",line_count,yytext);
			return INT;
		 
}

"char"  {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"CHAR");
			yylval.sym=s;
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
            
		    fprintf(logout,"Line# %d: Token <CHAR> Lexeme %s found\n",line_count,yytext);
			return CHAR;
		 
}
"float"  {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"FLOAT");
			yylval.sym=s;
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
           
		    fprintf(logout,"Line# %d: Token <FLOAT> Lexeme %s found\n",line_count,yytext);
		 	return FLOAT;
}

"double"  {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"DOUBLE");
			yylval.sym=s;
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
            
		    fprintf(logout,"Line# %d: Token <DOUBLE> Lexeme %s found\n",line_count,yytext);
			return DOUBLE;
		 
}

"void"  {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"VOID");
			yylval.sym=s;
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
           
		    fprintf(logout,"Line# %d: Token <VOID> Lexeme %s found\n",line_count,yytext);
			return VOID;
		 
}

"return"  {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RETURN");
			yylval.sym=s;
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
            
		    fprintf(logout,"Line# %d: Token <RETURN> Lexeme %s found\n",line_count,yytext);
			return RETURN;
		 
}
"println"	{
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"PRINTLN");
			yylval.sym=s;
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
			fprintf(logout,"Line# %d: Token <PRNTLN> Lexeme %s found\n",line_count,yytext);
			return PRINTLN;
			}

{ADDOP} { 
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"ADDOP");
			yylval.sym=s;
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
			fprintf(logout,"Line# %d: Token <ADDOP> Lexeme %s found\n",line_count,yytext);
			return ADDOP;
		}



{MULOP}	{
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"MULOP");
			yylval.sym=s;
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
			fprintf(logout,"Line# %d: Token <MULOP> Lexeme %s found\n",line_count,yytext);
			return MULOP;
		}


"=" 	{
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"ASSIGNOP");
			yylval.sym=s;
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
			fprintf(logout,"Line# %d: Token <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
			return ASSIGNOP;

	}

">" |
"<" |
">=" |
"<=" |
"==" |
"!=" {
		SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RELOP");
		yylval.sym=s;
		s->start=line_count;
		s->end=line_count;
		s->isLeaf=true;
		fprintf(logout,"Line# %d: Token <RELOP> Lexeme %s found\n",line_count,yytext);
		return RELOP;
	}

"&&"	|
"||"	{
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"LOGICOP");
			yylval.sym=s;
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
			fprintf(logout,"Line# %d: Token <LOGICOP> Lexeme %s found\n",line_count,yytext);
			return LOGICOP;
		}

"!"		{	
		SymbolInfo *s= new  SymbolInfo(yytext, (char *)"NOT");
		yylval.sym=s;
		s->start=line_count;
		s->end=line_count;
		s->isLeaf=true;
		fprintf(logout,"Line# %d: Token <NOT> Lexeme %s found\n",line_count,yytext);
		return NOT; 
	}



 "," {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"COMMA");
			yylval.sym=s;
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
			fprintf(logout,"Line# %d: Token <COMMA> Lexeme %s found\n",line_count,yytext);
			return COMMA;
        }

 ";" {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"SEMICOLON");
			yylval.sym=s;
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
			fprintf(logout,"Line# %d: Token <SEMICOLON> Lexeme %s found\n",line_count,yytext);
			return SEMICOLON;
        }
 "(" {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"LPAREN");
			yylval.sym=s;
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
			
			fprintf(logout,"Line# %d: Token <LPAREN> Lexeme %s found\n",line_count,yytext);
			return LPAREN;
        }
 ")" {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RPAREN");
			yylval.sym=s;
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
			//fprintf(tokenout,"<RPAREN, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RPAREN> Lexeme %s found\n",line_count,yytext);
			return RPAREN;
        }

 "{"    {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"LCURL");
			yylval.sym=s;
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
			fprintf(logout,"Line# %d: Token <LCURL> Lexeme %s found\n",line_count,yytext);
			return LCURL;
        }

 "}" {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RCURL");
			yylval.sym=s;
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
			//fprintf(tokenout,"<RCURL, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RCURL> Lexeme %s found\n",line_count,yytext);
			return RCURL;
        }
"[" 	{
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"LTHIRD");
			yylval.sym=s;
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
			
			fprintf(logout,"Line# %d: Token <LTHIRD> Lexeme %s found\n",line_count,yytext);
			return LTHIRD;
		}
"]" 	{
		SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RTHIRD");
		yylval.sym=s;
		s->start=line_count;
		s->end=line_count;
		s->isLeaf=true;
		fprintf(logout,"Line# %d: Token <RTHIRD> Lexeme %s found\n",line_count,yytext);
		return RTHIRD;
		}
"++" 	{
		SymbolInfo *s= new  SymbolInfo(yytext, (char *)"INCOP");
			yylval.sym=s;
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
		fprintf(logout,"Line# %d: Token <INCOP> Lexeme %s found\n",line_count,yytext);
			return INCOP;
		}
"--" 	{
		SymbolInfo *s= new  SymbolInfo(yytext, (char *)"DECOP");
			yylval.sym=s;
			s->start=line_count;
			s->end=line_count;
			s->isLeaf=true;
		fprintf(logout,"Line# %d: Token <DECOP> Lexeme %s found\n",line_count,yytext);
		return DECOP;
		}




{DIGIT}+ 	{
				SymbolInfo *s= new  SymbolInfo(yytext, (char *)"CONST_INT");
				//s->setName
				
				
				yylval.sym=s;
				s->start=line_count;
				s->end=line_count;
				s->isLeaf=true;

			//	cout<<"from lex: "<<yytext<<endl;
				fprintf(logout,"Line# %d: Token <CONST_INT> Lexeme %s found\n",line_count,yytext);
				return CONST_INT;
			}

{NUMBER}	{	
				SymbolInfo *s= new  SymbolInfo(yytext, (char *)"CONST_FLOAT");
				s->start=line_count;
				s->end=line_count;
				s->isLeaf=true;
				
				yylval.sym=s;
				fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
				return CONST_FLOAT; 
			}


{NOT_ID} 	{
				SymbolInfo *s= new  SymbolInfo(yytext, (char *)"NOT_ID");
				s->start=line_count;
				s->end=line_count;
				s->isLeaf=true;
				
				yylval.sym=s;

				fprintf(errorout,"Error at line# %d: INVALID_ID_SUFFIX_NUM_PREFIX \n ",line_count);
				error++;
			}
{ID} 		{	 
				
				SymbolInfo *s= table->LookUp(yytext);
				string st="ID";
				//if(s==NULL)
				//{					
					s= new SymbolInfo(yytext, st);
				//}
				
				s->start=line_count;
				s->end=line_count;
				s->isLeaf=true;

				yylval.sym=s;
				fprintf(logout,"Line# %d: Token <ID> Lexeme %s found\n",line_count,yytext);
				return ID;
			}

{DECI_ERROR} 	{
				//fprintf(tokenout,"<IDENTIFIER, %s>\n",yytext);
				SymbolInfo *s= new  SymbolInfo(yytext, (char *)"DECI_ERROR");
				s->start=line_count;
				s->end=line_count;
				s->isLeaf=true;
				
				yylval.sym=s;
				fprintf(errorout,"Error at line# %d: TOO_MANY_DECIMAL_POINTS\n ",line_count);
				error++;
			}
{ILL_NUMBER} 	{
				//fprintf(tokenout,"<IDENTIFIER, %s>\n",yytext);
				SymbolInfo *s= new  SymbolInfo(yytext, (char *)"ILL_NUMBER");
				s->start=line_count;
				s->end=line_count;
				s->isLeaf=true;
				
				yylval.sym=s;
				fprintf(errorout,"Error at line# %d: ILLFORMED_NUMBER\n ",line_count);
				error++;
			}



%%







