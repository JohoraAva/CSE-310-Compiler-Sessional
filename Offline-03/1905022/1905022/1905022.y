%{
#include<iostream>
#include<cstdlib>
#include<cstdio>
#include<cstring>
#include<cmath>
#include "SymbolTable.h"
//#define YYSTYPE SymbolInfo*

using namespace std;

/*int start_line;
string str;
string str2;
string com_str;*/

 FILE *logout;
 FILE *parseout;
 FILE* errorout;



int yyparse(void);
int yylex(void);
extern FILE *yyin;



 SymbolTable *table;
 int line_count=1;
 int error=0;
string type;
string type_final;
string name,name_final;
SymbolInfo* si;


void yyerror(string s)
{
	cout<<"error khaisiiiii";
	//line_count++;
	//error++;
}

struct variables{
	string name;
	int size;
}var;
struct parameter{
	string type;
	string name;
};

vector<variables> var_list;
vector<parameter> par_list; //for parameters of a function
vector<SymbolInfo*> arg_list; //for arguments of a function
int arraySize=0;
bool isArrayInsertable;
int value;

%}
%union{
	SymbolInfo *sym;
}

%token<sym> IF ELSE FOR WHILE DOUBLE CHAR RETURN VOID MAIN PRINTLN ASSIGNOP NOT SEMICOLON COMMA LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD INCOP DECOP ID INT FLOAT CONST_INT LOGICOP ADDOP MULOP CONST_FLOAT RELOP
%type<sym> start program unit var_declaration declaration_list func_declaration func_definition type_specifier compound_statement parameter_list lcurl statements statement variable expression_statement logic_expression arguments argument_list expression simple_expression unary_expression factor term rel_expression 

%left '+' '-' 
%left '*' '%'

%nonassoc RPAREN
%nonassoc ELSE


%%

start : program {
		$$=new SymbolInfo("program","start");
		fprintf(logout,"start : program \n");
		//write your code in this block in all the similar blocks below 

			$$->start=$1->start;
			$$->end=$1->end;
			$$->child.push_back($1);

		//	cout<<"blabla"<<$$->child.size()<<"chk: "<<$$->isLeaf<<endl;
			$$->printParseTree(1);

		
	}
	;

program : program unit 
		{
			$$=new SymbolInfo("program unit","program");
			fprintf(logout,"program : program unit \n");

			$$->start=$1->start;
			$$->end=$2->end;

			$$->child.push_back($1);
			$$->child.push_back($2);

			// cout<<"blaba\n";
		}
	| unit {
			$$=new SymbolInfo("unit","program");
			fprintf(logout,"program : unit \n");


			$$->start=$1->start;
			$$->end=$1->end;
			$$->child.push_back($1);

			// cout<<"blaba\n";
			
			}

	;
	
unit : var_declaration
		{
			$$=new SymbolInfo("var_declaration","unit");
			fprintf(logout,"unit : var_declaration \n");

			$$->start=$1->start;
			$$->end=$1->end;

			$$->child.push_back($1);

		//	cout<<"chk 2: "<<$$->isLeaf<<endl;
		}
     | func_declaration
	 	{
			$$=new SymbolInfo("func_declaration","unit");
			fprintf(logout,"unit : func_declaration \n");

			$$->start=$1->start;
			$$->end=$1->end;
			$$->child.push_back($1);
		}
     | func_definition
	 	{
			$$=new SymbolInfo("func_definition","unit");
			fprintf(logout,"unit : func_definition \n");

			$$->start=$1->start;
			$$->end=$1->end;
			$$->child.push_back($1);
		}
     ;
     
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
			$$=new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN SEMICOLON","func_declaration");
			fprintf(logout,"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON \n");
			 


			$$->start=$1->start;
			$$->end=$6->end;
			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);
			$$->child.push_back($4);
			$$->child.push_back($5);
			$$->child.push_back($6);


			for(int i=0;i<$5->para_list.size();i++)
			{
				$2->para_list.push_back($4->para_list[i]);
			}
			
			$2->isDec=true; 
			table->Insert($2->getName(),$2->getType());
			SymbolInfo* tempp=table->LookUp($2->getName());
			tempp->isDec=true;
			tempp->varType=$1->varType;
			for(int i=0;i<$4->para_list.size();i++)
			{
				tempp->para_list.push_back($4->para_list[i]);

			}
			
			 par_list.clear();

			



			
}
		| type_specifier ID LPAREN RPAREN SEMICOLON {
			$$=new SymbolInfo("type_specifier ID LPAREN RPAREN SEMICOLON","func_declaration");
			fprintf(logout,"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON \n");
			

			$$->start=$1->start;
			$$->end=$5->end;

			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);
			$$->child.push_back($4);
			$$->child.push_back($5);
	

			$2->isDec=true; 
			table->Insert($2->getName(),$2->getType());
			SymbolInfo* tempp=table->LookUp($2->getName());
			tempp->isDec=true;
		
			par_list.clear();
		}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement {
			$$=new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN compound_statement","func_definition");
			fprintf(logout,"func_definition: type_specifier ID LPAREN PARAMETER_LIST RPAREN COMPOUND_STATEMENT \n");

			$$->start=$1->start;
			$$->end=$6->end;
			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);
			$$->child.push_back($4);
			$$->child.push_back($5);
			$$->child.push_back($6);
		


			//isDEc?? 

			 SymbolInfo* tem=table->LookUp($2->getName());
			
			if(!tem)
			{
				//the func does not exist , create a new one
					// cout<<" chk fun1:"<<" "<<$4->para_list.size()<<endl;
					SymbolInfo* si=new SymbolInfo($2->getName(),$1->getType());
					// set para list
					for(int i=0;i<$4->para_list.size();i++)
					{
						$2->para_list.push_back($4->para_list[i]);
						table->Insert($4->para_list[i]->getName(),$4->para_list[i]->getType());
						// cout<<"chk: "<<$5->para_list[i]->getName()<<" "<<$5->para_list[i]->varType<<endl;
					}

					
					
					table->Insert(si->getName(),si->getType());
					SymbolInfo* tempp=table->LookUp(si->getName());
					$2->isDef=true;
					tempp->isDef=true;
					for(int i=0;i<$4->para_list.size();i++)
					{
						tempp->para_list.push_back($4->para_list[i]);
					}

					tempp->varType=$1->varType;
				
			}
			

			else
			{
				SymbolInfo* tempp=table->LookUp($2->getName());
				
				// cout<<" chk fun:"<<$2->getName()<<" ::"<<tempp->para_list.size()<<" "<<$4->para_list.size()<<endl;
				//  cout<<" chk:2 "<<$2->getName()<<" isDEf and dec: "<<tempp->isDec<<" "<<tempp->isDef<<endl;
				if(tempp->isDef || tempp->isDec)
				{
					// cout<<" chk: "<<$2->getName()<<" isDEf and dec: "<<$2->isDec<<endl;
					if($1->varType!=tempp->varType)
					{
						fprintf(errorout,"Line# %d: Conflicting types for '%s'\n",$2->end,$2->getName().c_str());
						error++;
					}
					// matching parameter size 
					// SymbolInfo* tem=table->LookUp($2->getName());
					if(tem->para_list.size()>$4->para_list.size())
					{
					//	cout<<" few check1:"<<tem->para_list.size()<<" :::"<<$4->para_list.size()<<endl;
						fprintf(errorout,"Line# %d: Too few arguments to function '%s'\n",line_count,$2->getName().c_str());
						error++;
					}
					else if(tem->para_list.size()<$4->para_list.size())
					{
						fprintf(errorout,"Line# %d: Too many arguments to function '%s'\n",line_count,$2->getName().c_str());
						error++;
					}
					// matches size 
					else 
					{
						bool doesNotMatch=false;
						for(int i=0;i<par_list.size();i++)
						{
							if(($4->para_list[i]->varType!= tem->para_list[i]->varType))
							{
								fprintf(errorout,"Line# %d: Type mismatch for argument %d of '%s'\n",line_count,(i+1),$1->getName().c_str());
								error++;
								doesNotMatch=true;
								
							}
						}

						if(!doesNotMatch)
						{
							$2->isDef=true; // defined now
						}
					
				}
			
			}

			else
			{
				fprintf(errorout,"Line# %d: '%s' redeclared as different kind of symbol\n",$2->start,$2->getName().c_str());
				error++;
			}
				
		} 
		}
		| type_specifier ID LPAREN RPAREN compound_statement{
			$$=new SymbolInfo("type_specifier ID LPAREN RPAREN compound_statement","func_definition");
			fprintf(logout,"func_definition: type_specifier ID LPAREN RPAREN COMPOUND_STATEMENT \n");
		
			$$->start=$1->start;
			$$->end=$5->end;
			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);
			$$->child.push_back($4);
			$$->child.push_back($5);
			


			SymbolInfo* tem=table->LookUp($2->getName());
			// type specifier check

			if(!tem)
			{
				//the func does not exist , create a new one

					SymbolInfo* si=new SymbolInfo($2->getName(),$1->getType());
					// si->isDef=true;
					table->Insert(si->getName(),si->getType());
					SymbolInfo* tempp=table->LookUp(si->getName());
					tempp->isDef=true;
					tempp->varType=$1->varType;
				
			}

			
		
		}
 		;			


parameter_list  : parameter_list COMMA type_specifier ID{
			$$=new SymbolInfo("parameter_list COMMA type_specifier ID","parameter_list");
			fprintf(logout,"parameter_list  : parameter_list COMMA type_specifier ID \n");

			parameter tem;
			tem.type=(string)$3->varType;
			tem.name=(string)$4->getName();

			par_list.push_back(tem);

			// push to si

			for(int i=0;i<$1->para_list.size();i++)
			{
				$$->para_list.push_back($1->para_list[i]);
			}
			$$->para_list.push_back($4);
			$4->varType=$3->varType;

			// n^2 
			for(int i=0;i<$1->para_list.size();i++)
			{
				for(int j=i+1;j<$1->para_list.size();j++)
				{
					if($1->para_list[i]->getName()==$1->para_list[j]->getName())
					{
						fprintf(errorout,"Line# %d: Redefinition of parameter '%s'\n",line_count,$1->para_list[i]->getName().c_str());
						error++;
					}
				}
			}


			$$->start=$1->start;
			$$->end=$4->end;
			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);
			$$->child.push_back($4); }
			
		| parameter_list COMMA type_specifier {
			$$=new SymbolInfo("parameter_list COMMA type_specifier","parameter_list");
			fprintf(logout,"parameter_list  : parameter_list COMMA type_specifier ID \n");

			parameter tem;
			tem.type=(string)$3->varType;
			tem.name="";

			SymbolInfo* si=new SymbolInfo("","ID");

			par_list.push_back(tem);

			for(int i=0;i<$1->para_list.size();i++)
			{
				$$->para_list.push_back($1->para_list[i]);
			}
			$$->para_list.push_back(si);

			$$->start=$1->start;
			$$->end=$3->end;
			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3); }
			
 		| type_specifier ID {
			$$=new SymbolInfo("type_specifier ID","parameter_list");
			fprintf(logout,"parameter_list  :  type_specifier ID \n");

			parameter tem;
			tem.type=(string)$1->getType();
			tem.name=$2->getName();
			$2->varType=$1->varType;

			par_list.push_back(tem);

			$$->para_list.push_back($2);

			$$->start=$1->start;
			$$->end=$2->end;
			$$->child.push_back($1);
			$$->child.push_back($2);
		}
		| type_specifier {
			$$=new SymbolInfo("type_specifier","parameter_list");
			fprintf(logout,"parameter_list  :type_specifier ID \n");

			parameter tem;
			tem.type=(string)$1->getType();
			tem.name="";

			par_list.push_back(tem);
			SymbolInfo* si=new SymbolInfo("","ID");
			si->varType=$1->getName();
			$$->para_list.push_back(si);

			$$->start=$1->start;
			$$->end=$1->end;
			$$->child.push_back($1);
		}
 		;

 		
compound_statement : lcurl statements RCURL { // ?!
			$$=new SymbolInfo("LCURL statements RCURL","compound_statement");
			fprintf(logout,"compound_statement : LCURL statements RCURL \n");

			table->printAllScopeTable();
			table->ExitScope();

			$$->start=$1->start;
			$$->end=$3->end;
			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);
		}
 		    | lcurl RCURL {
			$$=new SymbolInfo("LCURL RCURL","compound_statement");
			fprintf(logout,"compound_statement : Lcurl RCURL \n");
			
			table->printAllScopeTable();
			table->ExitScope();


			$$->start=$1->start;
			$$->end=$2->end;
			$$->child.push_back($1);
			$$->child.push_back($2);
			
			
		}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {
			$$=new SymbolInfo("type_specifier declaration_list SEMICOLON","var_declaration");
			fprintf(logout,"var_declaration : type_specifier declaration_list SEMICOLON \n");

			SymbolInfo* si;
			if($1->varType=="void")
			{
				// fprintf(errorout,"Error at line# %d: Variable or field 'e' declared void \n ",line_count);
				error++;
				

				for(int i=0;i<var_list.size();i++)
				{
					si=new SymbolInfo(var_list[i].name,"ID");
					// table->Insert(si->getName(),si->getType());
					SymbolInfo* temp=table->LookUp(si->getName());
					if(temp->isInserted)
						temp->varType=$1->varType;
					fprintf(errorout,"Line# %d: Variable or field '%s' declared void\n",line_count,var_list[i].name.c_str());
				}
			}
			else
			{
				for(int i=0;i<var_list.size();i++)
				{
					
					SymbolInfo* temp=table->LookUp(var_list[i].name);
					
					
					
					// 	// type does not match 
					if($1->varType!=type)
					{
						///	cout<<"finbal: "<<$1->varType<<" ::"<<temp->varType<<endl;
							fprintf(errorout,"Line# %d: Conflicting types for'%s'\n",line_count,var_list[i].name.c_str());
					}
					if(temp->isInserted)
						temp->varType=$1->varType;
					
					// cout<<" valo lage na: "<<temp->varType<<endl;
				}
			}
			for(int i=0;i<$2->dec_list.size();i++)
			{
				
				$2->dec_list[i]->varType=$1->varType;
				
			}

			// cout<<"type chk:"<<$2->getName()<<" "<<$2->dec_list[0]->varType<<endl;

			var_list.clear();

			$$->start=$1->start;
			$$->end=$3->end;
			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);
		
		}
 		 ;
 		 
type_specifier	: INT {
		$$=new SymbolInfo("INT","type_specifier");
		fprintf(logout,"type_specifier	: INT \n");

		$$->varType="int";
		type="int";

		$$->start=$1->start;
		$$->end=$1->end;
		$$->child.push_back($1); 
	}
 		| FLOAT {
			$$=new SymbolInfo("FLOAT","type_specifier");
			fprintf(logout,"type_specifier	: FLOAT \n");

			$$->varType="float";
			type="float";

			$$->start=$1->start;
			$$->end=$1->end;
			$$->child.push_back($1); 
		}
 		| VOID {
			$$=new SymbolInfo("VOID","type_specifier");
			fprintf(logout,"type_specifier	: VOID \n");

			$$->varType="void";
			type="void";

			$$->start=$1->start;
			$$->end=$1->end;
			$$->child.push_back($1); 
		}
		
	
		
		
 		;

declaration_list : declaration_list COMMA ID{
			string name=$3->getName();
			$$=new SymbolInfo("declaration_list COMMA ID","declaration_list");
			fprintf(logout,"declaration_list : declaration_list COMMA ID \n");
		//	fprintf(logout,"Line# %d: Token <id> Lexeme %s found\n",line_count,name.c_str());



			// push to si

			for(int i=0;i<$1->dec_list.size();i++)
			{
				$$->dec_list.push_back($1->dec_list[i]);
			}
			$$->dec_list.push_back($3);

			

			 bool isInsertable=table->Insert($3->getName(),$3->getType());
			

		//	 cout<<" check var:2 "<<isArrayInsertable<<endl;

			if(isInsertable)
			{
				SymbolInfo* t=table->LookUp($3->getName());
				t->arraySize=var.size;
				t->isInserted=true;

				var.name=(string)$3->getName();
				var.size=0;

				var_list.push_back(var);
			}
			else
			{
				fprintf(errorout,"Line# %d: Redefinition of parameter '%s'\n",line_count,$3->getName().c_str());
				error++;

			}

			$$->start=$1->start;
			$$->end=$3->end;
			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);
			
			}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
			$$=new SymbolInfo("declaration_list COMMA ID LTHIRD CONST_INT RTHIRD","declaration_list"); //505 TILL
			fprintf(logout,"declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD \n");
		//	fprintf(logout,"Line# %d: Token <id> Lexeme %s found\n",line_count,(string)$3->getType().c_str());

			var.name=(string)$3->getName();
			var.size=stoi($5->getName());
			$3->arraySize=var.size;



			// push to si

			for(int i=0;i<$1->dec_list.size();i++)
			{
				$$->dec_list.push_back($1->dec_list[i]);
			}
			$$->dec_list.push_back($3);

			

			 bool isInsertable=table->Insert($3->getName(),$3->getType());
			 isArrayInsertable=isInsertable;


			if(isInsertable)
			{
				SymbolInfo* t=table->LookUp($3->getName());
				

				if($5->varType=="float")
				{
					fprintf(errorout,"Error at line# %d: array size cannot be float '%s'\n",line_count,$3->getType().c_str());
					error++;
				}
				else 
					$3->arraySize=stoi($5->getName());

				var_list.push_back(var);
				t->arraySize=var.size;
				t->isInserted=true;
			}
			else
			{
				fprintf(errorout,"Line# %d: Conflicting types for'%s'\n",line_count,$3->getName().c_str());
				error++;
			}

			arraySize=var.size;
			

			$$->start=$1->start;
			$$->end=$6->end;
			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);
			$$->child.push_back($4);
			$$->child.push_back($5);
			$$->child.push_back($6);
			
			}
 		  | ID {
			$$=new SymbolInfo("ID","declaration_list");
			fprintf(logout,"declaration_list : ID \n");
		//	fprintf(logout,"Line# %d: Token <id> Lexeme %s found\n",line_count,(string)$1->getType().c_str());

			
			$$->dec_list.push_back($1);
			

			bool isInsertable=table->Insert($1->getName(),$1->getType());
	

			if(isInsertable)
			{
				SymbolInfo* t=table->LookUp($1->getName());
				t->arraySize=var.size;
				t->isInserted=true;

				var.name=(string)$1->getName();
				var.size=0;

				var_list.push_back(var);
			}
			else
			{
				fprintf(errorout,"Line# %d: Conflicting types for'%s'\n",line_count,$1->getName().c_str());
				error++;
			}

			$$->start=$1->start;
			$$->end=$1->end;
			$$->child.push_back($1);
		
			}
 		  | ID LTHIRD CONST_INT RTHIRD {
			$$=new SymbolInfo("ID LTHIRD CONST_INT RTHIRD ","declaration_list");
			fprintf(logout,"declaration_list : declaration_list ID LTHIRD CONST_INT RTHIRD \n");
		//	fprintf(logout,"Line# %d: Token <id> Lexeme %s found\n",line_count,(string)$1->getType().c_str());

			

			if($3->varType=="float")
			{
				fprintf(errorout,"Line# %d: array size cannot be float '%s'\n",line_count,$3->getType().c_str());
				error++;
			}

			$1->arraySize=stoi($3->getName());

			
			$$->dec_list.push_back($1);
			arraySize=var.size;

			bool isInsertable=table->Insert($1->getName(),$1->getType());
			isArrayInsertable=isInsertable;

			if(isInsertable)
			{
				SymbolInfo* t=table->LookUp($1->getName());
				

				var.name=(string)$1->getName();
				var.size=stoi($3->getName());
				var_list.push_back(var);
				t->arraySize=var.size;
				t->isInserted=true;
			}
			else
			{
				fprintf(errorout,"Line# %d: Conflicting types for'%s'\n",line_count,$1->getName().c_str());
				error++;
			}
			arraySize=var.size;

			$$->start=$1->start;
			$$->end=$4->end;
			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);
			$$->child.push_back($4);
		
			}
 		  ;
 		  
statements : statement {
			$$=new SymbolInfo("statement","statements");
			fprintf(logout,"statements : statement \n");

			$$->start=$1->start;
			$$->end=$1->end;
			$$->child.push_back($1);
			

		}
	   | statements statement {
			$$=new SymbolInfo("statements statement","statements");
			fprintf(logout,"statements : statements statement \n");


			$$->start=$1->start;
			$$->end=$2->end;
			$$->child.push_back($1);
			$$->child.push_back($2);

		}
	   ;
	   
statement : var_declaration {
			$$=new SymbolInfo("var_declaration","statement");
			fprintf(logout,"statement : var_declaration \n");

			$$->start=$1->start;
			$$->end=$1->end;
			$$->child.push_back($1);
			
		}
	  | expression_statement {
			$$=new SymbolInfo("expression_statement","statement");
			fprintf(logout,"statement : expression_statement \n");

			$$->start=$1->start;
			$$->end=$1->end;
			$$->child.push_back($1);
		

		}
	  | compound_statement {
			$$=new SymbolInfo("compound_statement","statement");
			fprintf(logout,"statement : compound_statement \n");

			$$->start=$1->start;
			$$->end=$1->end;
			$$->child.push_back($1);
			

		}
	  | FOR LPAREN expression_statement embedded_exp embedded_void expression_statement embedded_exp embedded_void expression embedded_exp embedded_void RPAREN statement {
			$$=new SymbolInfo("FOR LPAREN expression_statement expression RPAREN statement","statement");
			fprintf(logout,"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement \n");

		
		$$->start=$1->start;
		$$->end=$13->end;
		$$->child.push_back($1);
		$$->child.push_back($2);
		$$->child.push_back($3);
		$$->child.push_back($12);
		$$->child.push_back($13);
		$$->child.push_back($6);
		$$->child.push_back($9);
		}
	  | IF LPAREN expression embedded_exp RPAREN embedded_void statement {
			$$=new SymbolInfo("IF LPAREN expression RPAREN statement","statement");
			fprintf(logout,"statement : IF LPAREN expression RPAREN statement ELSE statement \n");

		
		$$->start=$1->start;
		$$->end=$7->end;
		$$->child.push_back($1);
		$$->child.push_back($2);
		$$->child.push_back($3);
		$$->child.push_back($5);
		$$->child.push_back($7);
		}
	  | IF LPAREN expression embedded_exp RPAREN embedded_void statement ELSE statement {
			$$=new SymbolInfo("IF LPAREN expression RPAREN statement ELSE statement","statement");
			fprintf(logout,"statement : IF LPAREN expression RPAREN statement ELSE statement \n");

		$$->start=$1->start;
		$$->end=$9->end;

			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);
			$$->child.push_back($8);
			$$->child.push_back($5);
			$$->child.push_back($9);
			$$->child.push_back($7);
		
		}
	  | WHILE LPAREN expression embedded_exp RPAREN embedded_void statement {
			$$=new SymbolInfo("WHILE LPAREN expression RPAREN statement","statement");
			fprintf(logout,"statement : WHILE LPAREN expression RPAREN statement \n");

			$$->start=$1->start;
			$$->end=$7->end;


			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);
		
			$$->child.push_back($5);
			
			$$->child.push_back($7);
		
		}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {
			$$=new SymbolInfo("PRINTLN LPAREN ID RPAREN SEMICOLON","statement");
			fprintf(logout,"statement : PRINTLN LPAREN ID RPAREN SEMICOLON \n");


			$$->start=$1->start;
			$$->end=$5->end;
			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);
			$$->child.push_back($4);
			$$->child.push_back($5);
				
		
		}
	  | RETURN expression SEMICOLON {
			$$=new SymbolInfo("RETURN expression SEMICOLON","statement");
			fprintf(logout,"statement : RETURN expression SEMICOLON \n");

			$$->start=$1->start;
			$$->end=$3->end;	
			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);
			
		
		}
	  ;
embedded_exp: {
	 type_final=type;
};
embedded_void: {
	if(type_final=="void")
	{
		fprintf(errorout,"Line# %d: void function called within expression\n",line_count);
		error++;
	}
};
expression_statement 	: SEMICOLON	{
			$$=new SymbolInfo("SEMICOLON","expression_statement");
			fprintf(logout,"expression_statement 	: SEMICOLON \n");

			$$->varType="int";
			 type="int";

			$$->start=$1->start;
			$$->end=$1->end;	
			$$->child.push_back($1);

		}	
			| expression SEMICOLON {
			$$=new SymbolInfo("expression SEMICOLON","expression_statement");
			fprintf(logout,"expression_statement 	: expression SEMICOLON \n");

			$$->varType=$1->varType;
			 type=$1->varType;

			$$->start=$1->start;
			$$->end=$1->end;
			$$->child.push_back($1);
			$$->child.push_back($2);

		}	
			;
	  
variable : ID {
			$$=new SymbolInfo("ID","variable");
			fprintf(logout,"variable : ID \n");

			SymbolInfo* temp=table->LookUp($1->getName());
			

			if(!temp)
			{
				
				fprintf(errorout,"Line# %d: Undeclared variable '%s'\n",line_count,$1->getName().c_str());
				error++;
				 $$->varType="error";
			}
			
			else
			{
				$1->varType=temp->varType;
				if($1->varType!="void")
					 $$->varType=$1->varType;
	
				else
					 $$->varType="float";
			}

			// $$->varType=$1->varType;


			
			// if(temp && temp->arraySize==0) //type checking
			// {
			// 	fprintf(errorout,"Line# %d: type mismatch(not variable1)\n",line_count,$1->getType().c_str());
			// 	error++;
			// }

			$$->start=$1->start;
			$$->end=$1->end;
			$$->child.push_back($1);
			

		}		
	 | ID LTHIRD expression RTHIRD {
			$$=new SymbolInfo("ID LTHIRD expression RTHIRD","variable");
			fprintf(logout,"variable: ID LTHIRD expression RTHIRD \n");

			SymbolInfo* temp=table->LookUp($1->getName());
			$$->varType=temp->varType;
			$1->varType=temp->varType;

			$$->arraySize=$3->arraySize;

		//	cout<<"chk vartype :"<<$1->getName()<<" : "<<temp->varType<<endl;

			if(!temp)
			{
				fprintf(errorout,"Line# %d: undeclared variable %s\n",line_count);
				error++;

				$$->varType="float";
			}
			else if(temp->arraySize==0)
			{
			//	cout<<"chk b 2:"<<$1->getName()<<" : "<<temp->arraySize<<endl;
				fprintf(errorout,"Line# %d: '%s' is not an array\n",line_count,$1->getName().c_str());
				error++;
			}
			else
			{
				$1->varType=temp->varType;
				if($1->varType!="void")
					 $$->varType=$1->varType;
	
				else
					 $$->varType="float";
			}


			if($3->varType!="int")
			{
				fprintf(errorout,"Line# %d: Array subscript is not an integer\n",line_count);
				error++;
			}
			$$->start=$1->start;
			$$->end=$4->end;
			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);
			$$->child.push_back($4);


		}	
	 ;
	 
 expression : logic_expression	{
	$$=new SymbolInfo("logic_expression","expression");
	fprintf(logout,"expression : logic_expression \n");
	$$->varType=$1->varType;
	type=$1->varType;

	$$->start=$1->start;
	$$->end=$1->end;
	$$->child.push_back($1);
			

} 
	   | variable ASSIGNOP logic_expression {
		$$=new SymbolInfo("variable ASSIGNOP logic_expression","expression");
		fprintf(logout,"expression : variable ASSIGNOP logic_expression \n");
		
		
		

		if($1->varType=="float" && type=="int")
		{
			$3->varType="float";
		}
		else if($1->varType=="void" || $3->varType=="void")
		{
			fprintf(errorout,"Line# %d: Void cannot be used in expression \n",line_count);
			error++;
		}
		else if($3->varType=="float" && $1->varType=="int")
		{
			 fprintf(errorout,"Line# %d: Warning: possible loss of data in assignment of FLOAT to INT\n",line_count);
			// cout<<"from assign: "<<$1->varType<<" : "<<$3->varType<<endl;
			 error++;
		}
		else if($1->varType!=$3->varType)
		{
			// fprintf(errorout,"Line# %d: type mismatch(not array2)\n",line_count);
			// cout<<"from assign: "<<$1->varType<<" : "<<$3->varType<<endl;
			// error++;
		}
		else 
		{
			$$->varType=$1->varType;
			type=$1->varType;
		}

		$$->start=$1->start;
		$$->end=$3->end;

		$$->child.push_back($1);
		$$->child.push_back($2);
		$$->child.push_back($3);
			

} 	
	   ;
			
logic_expression : rel_expression 	{
	$$=new SymbolInfo("rel_expression","logic_expression");
	fprintf(logout,"logic_expression : rel_expression \n");
	

	
	$$->varType=$1->varType;

//	cout<<"chkkkk:::"<<$$->varType<<endl;

	$$->start=$1->start;
	$$->end=$1->end;
	$$->child.push_back($1);
	$$->arraySize=$1->arraySize;
		
			

} 
		 | rel_expression LOGICOP rel_expression {
			$$=new SymbolInfo("rel_expression LOGICOP rel_expression","logic_expression");
			fprintf(logout,"logic_expression : rel_expression LOGICOP rel_expression \n");
			
			//khali
			
			$$->varType="int";

			$$->start=$1->start;
			$$->end=$3->end;
			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);
				

} 	
		 ;
			
rel_expression	: simple_expression {
			$$=new SymbolInfo("simple_expression","rel_expression");
			fprintf(logout,"rel_expression	: simple_expression \n");
			
			//khali
			
			$$->varType=$1->varType;

			$$->start=$1->start;
			$$->end=$1->end;
			$$->child.push_back($1);
			$$->arraySize=$1->arraySize;
		
			

} 	
		| simple_expression RELOP simple_expression	{
			$$=new SymbolInfo("simple_expression RELOP simple_expression","rel_expression");
			fprintf(logout,"rel_expression	: simple_expression RELOP simple_expression \n");
			
			//khali
			
			$$->varType="int";

			$$->start=$1->start;
			$$->end=$3->end;
			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);
				

} 	
		;
				
simple_expression : term {
	$$=new SymbolInfo("term","simple_expression");
	fprintf(logout,"simple_expression : term \n");
//	$$->retType=$1->retType;

	$$->start=$1->start;
	$$->end=$1->end;
	$$->child.push_back($1);

	$$->varType=$1->varType;
	$$->arraySize=$1->arraySize;
		
			

} 
		| simple_expression ADDOP term {
				$$=new SymbolInfo("simple_expression ADDOP term","simple_expression");
				fprintf(logout,"simple_expression : simple_expression ADDOP term \n");
				

				if($1->varType=="float" || $3->varType=="float")
				{
					$$->varType="float";
				}
				else 
				{
					$$->varType=$1->varType;
				}


				$$->start=$1->start;
				$$->end=$3->end;
				$$->child.push_back($1);
				$$->child.push_back($2);
				$$->child.push_back($3);
					

} 
		  ;
					
term :	unary_expression {
	$$=new SymbolInfo("unary_expression","term");
	fprintf(logout,"term :	unary_expression \n");
	

	$$->start=$1->start;
	$$->end=$1->end;
	$$->child.push_back($1);

	$$->varType=$1->varType;
	$$->arraySize=$1->arraySize;
		
			

} 
     |  term MULOP unary_expression {
	$$=new SymbolInfo("term MULOP unary_expression","term");
	fprintf(logout,"term :	term MULOP unary_expression \n");

	
		
			

	// //type checking
//	cout<<" name check: "<< $3->getName()<<" :: "<<$3->varType<<endl;
	if($1->varType=="void" || $3->varType=="void")
	{
		fprintf(errorout,"Line# %d: Void cannot be used in expression\n",line_count);
		error++;
	}
	else if(($2->getName()=="%"|| $2->getName()=="/") && !value) 
	{
		fprintf(errorout,"Line# %d: Warning: division by zero i=0f=1Const=0\n",line_count);
		error++;
		$$->varType="int";
	}
	else if($2->getName()=="%" && ($1->varType!="int" || $3->varType!="int")) 
	{
		fprintf(errorout,"Line# %d: Operands of modulus must be integers \n",line_count);
		error++;
		$$->varType="int";
	}
	else if($2->getName()!="%" && ($1->varType=="float" || $3->varType=="float")) 
	{
		$$->varType="float";
	}
	else{
		$$->varType=$1->varType;
	}

	$$->start=$1->start;
	$$->end=$3->end;
	$$->child.push_back($1);
	$$->child.push_back($2);
	$$->child.push_back($3);
	

} 
     ;

unary_expression : ADDOP unary_expression  {
	$$=new SymbolInfo("ADDOP unary_expression","unary_expression");
	fprintf(logout,"unary_expression : ADDOP unary_expression \n");
	

	$$->start=$1->start;
	$$->end=$2->end;
	$$->child.push_back($1);
	$$->child.push_back($2);

	$$->varType="int";
		

} 
		 | NOT unary_expression {
			$$=new SymbolInfo("NOT unary_expression","unary_expression");
			fprintf(logout,"unary_expression : NOT unary_expression \n");
			


			$$->start=$1->start;
			$$->end=$2->end;
			$$->child.push_back($1);
			$$->child.push_back($2);

			$$->varType="int";

		

}
		 | factor  {
			$$=new SymbolInfo("factor","unary_expression");
			fprintf(logout,"unary_expression : factor \n");
			

			$$->start=$1->start;
			$$->end=$1->end;
			$$->child.push_back($1);

			$$->varType=$1->varType;
			$$->arraySize=$1->arraySize;

}
		 ;
	
factor	: variable {
	$$=new SymbolInfo("variable","factor");
	fprintf(logout,"factor	: variable \n");
	

	$$->start=$1->start;
	$$->end=$1->end;
	$$->child.push_back($1);

	// SymbolInfo* temp=table->LookUp($1->getName());
	// cout<<" var chk:"<<temp->getName()<<" :: "<<endl;
	$$->varType=$1->varType;

	$$->arraySize=$1->arraySize;
		
		

}
	| ID LPAREN argument_list RPAREN {
	$$=new SymbolInfo("ID LPAREN argument_list RPAREN","factor");
	fprintf(logout,"factor	: ID LPAREN argument_list RPAREN \n");

	 SymbolInfo* si=table->LookUp($1->getName());
	// type=si->varType;

	 arg_list.clear();

	$$->start=$1->start;
	$$->end=$4->end;
	$$->child.push_back($1);
	$$->child.push_back($2);
	$$->child.push_back($3);
	$$->child.push_back($4);

	//check id with arg_list
	// SymbolInfo* ii=table->LookUp($1->getName());
	// cout<<" arg check :"<<$3->arg_list.size()<<" : "<<ii->para_list.size()<<endl;


	
	 SymbolInfo* tem=table->LookUp($1->getName());
	// cout<<" arg check2 :"<<$1->getName()<<" : "<<tem->para_list.size()<<endl;

	 if(!tem)
	{
		//the func does not exist 
		fprintf(errorout,"Line# %d: Undeclared function '%s'\n",line_count,$1->getName().c_str());
		error++;

		$$->varType="empty";
	}

	else
	{
		// func exists, matching parameter size 
	//	cout<<" bedona :("<<endl;
		$$->varType=tem->varType;
	//	cout<<"var chec k2:"<<tem->varType<<endl;
		if($3->arg_list.size()<tem->para_list.size())
		{
		//	cout<<" few check2:"<<arg_list.size()<<" :::"<<tem->para_list.size()<<endl;
			fprintf(errorout,"Line# %d: Too few arguments to function '%s'\n",$2->start,$1->getName().c_str());
		//	cout<<$1->para_list.size()<<" : "<<par_list.size()<<endl;
			error++;
		}
		else if($3->arg_list.size()>tem->para_list.size())
		{
		//	cout<<"here maybe"<<tem->para_list.size()<<" :: "<<$3->arg_list.size()<<endl;
			fprintf(errorout,"Line# %d: Too many arguments to function '%s'\n",$2->start,$1->getName().c_str());
			error++;
		}
	// matches size 
		else 
		{
			for(int i=0;i<tem->para_list.size();i++)
			{
				if((arg_list[i]->varType!= tem->para_list[i]->varType) || (arg_list[i]->arraySize!= tem->para_list[i]->arraySize) )
				{
					
					fprintf(errorout,"Line# %d: Type mismatch for argument %d of '%s'\n",$1->start,(i+1),$1->getName().c_str());
					error++;
					
				}
				
			}
			
		}
	}
		
	
	}

	| LPAREN expression RPAREN {
		
	$$=new SymbolInfo("LPAREN expression RPAREN","factor");
	fprintf(logout,"factor	: LPAREN expression RPAREN \n");
	
	SymbolInfo* tem=table->LookUp($1->getName());

	

		$$->start=$1->start;
		$$->end=$3->end;
		$$->child.push_back($1);
		$$->child.push_back($2);
		$$->child.push_back($3);

		$2->varType="float";
		$$->varType=$2->varType;
		


}
	| CONST_INT  {
	$$=new SymbolInfo("CONST_INT","factor");
	fprintf(logout,"factor	: CONST_INT \n");
	

	$$->start=$1->start;
	$$->end=$1->end;
	$$->child.push_back($1);

	$$->varType="int";
	value=stoi($1->getName());
		

}
	| CONST_FLOAT {
	$$=new SymbolInfo("CONST_FLOAT","factor");
	fprintf(logout,"factor	: variable CONST_FLOAT \n");
	

	$$->start=$1->start;
	$$->end=$1->end;
	$$->child.push_back($1);

	$$->varType="float";
		

}
	| variable INCOP {
	$$=new SymbolInfo("variable INCOP","factor");
	fprintf(logout,"factor	: variable INCOP \n");
	$$->varType=$1->varType;

	$$->start=$1->start;
	$$->end=$2->end;
	$$->child.push_back($1);
	$$->child.push_back($2);
		

}
	| variable DECOP {
	$$=new SymbolInfo("variable DECOP","factor");
	fprintf(logout,"factor	: variable DECOP \n");

	$$->varType=$1->varType;

	$$->start=$1->start;
	$$->end=$2->end;
	$$->child.push_back($1);
	$$->child.push_back($2);
		

}
	;
	
argument_list : arguments {
	$$=new SymbolInfo("arguments","argument_list");
	fprintf(logout,"argument_list : arguments \n");

	$$->start=$1->start;
	$$->end=$1->end;
	$$->child.push_back($1);


	for(int i=0;i<$1->arg_list.size();i++)
	{
		$$->arg_list.push_back($1->arg_list[i]);
	//	arg_list.push_back($1->arg_list[i]);
				
	}
	
		

}
			  | {
	$$=new SymbolInfo("","argument_list");
	fprintf(logout,"argument_list : \n");
	$$->start=line_count;
	$$->end=line_count;

}
			  ;
	
arguments : arguments COMMA logic_expression{
			$$=new SymbolInfo("arguments COMMA logic_expression ","arguments");
			fprintf(logout,"arguments : arguments COMMA logic_expression \n");


			if($3->varType=="void")
			{
				fprintf(errorout,"Line# %d: Void function cannot be called in argument of function \n",line_count);
				error++;
				$3->varType="float";
			}

			

			$$->start=$1->start;
			$$->end=$3->end;
			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);

			arg_list.push_back($3);
			

		///	 cout<<"chk arg1: "<<arg_list.size()<<endl;
			for(int i=0;i<arg_list.size();i++)
			{
				$$->arg_list.push_back(arg_list[i]);
			//	 cout<<i<<" :1"<<arg_list[i]->varType<<endl;
			}

			// cout<<"from a_l2: "<<$$->arg_list.size()<<endl;

			}



	      | logic_expression
		  {
			$$=new SymbolInfo("logic_expression","arguments");
			fprintf(logout,"arguments : logic_expression \n");


			if($1->varType=="void")
			{
				fprintf(errorout,"Line# %d: Void function cannot be called in argument of function \n",line_count);
				error++;
				$1->varType="float";
			}

			$$->start=$1->start;
			$$->end=$1->end;
			$$->child.push_back($1);
			
			arg_list.push_back($1);
			$$->arg_list.push_back($1);

			}
	      ;
lcurl : LCURL {
	$$->start=$1->start;
	$$->end=$1->end;
	table->EnterScope();

	for(int i=0;i<par_list.size();i++)
	{
		if(par_list[i].name!="")
		{
			if(par_list[i].name=="void")
			{

			}
			else
			{
				table->Insert(par_list[i].name,par_list[i].type);
			}
		}

	}

	par_list.clear();
	


	$$->child.push_back($1);
	$$->start=$1->start;
	$$->end=$1->end;
			
}
 

%%
int main(int argc,char *argv[])
{

	
	table=new SymbolTable(10);
	logout= fopen("log.txt","w");
	errorout= fopen("error.txt","w");
	parseout=fopen("parse.txt","w");
	
	FILE *fp = fopen(argv[1],"r");

	yyin=fp;
	yyparse();
	

	fprintf(logout,"Total Lines: %d\n",line_count);
    fprintf(logout,"Total Errors: %d\n",error);

	fclose(logout);
	fclose(errorout);
	fclose(parseout);
	fclose(fp);
	
	return 0;
}

