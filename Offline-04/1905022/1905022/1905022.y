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
int varCount=0;
string name;
SymbolInfo* si;
int stack_decremented=0;
int stack_incremented=-2;
int internal_label_count=0;
int retSize=0;
int offsetVal=0;
string cur_func;
// vector<int> if_label;
// vector<int> while_label;
// vector<int> for_label;
int if_label_count=0;
int tempLabelCount=0;
int temWhileLabel=0;
int while_label_count=0;
int for_label_count=0;
int temForLabel=0;



void yyerror(string s)
{
	//// cout<<"error khaisiiiii";
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



int labelCount=1;
int tempCount=0;
string varName;
string temVarName;
bool istemVal=false;
stringstream varValCheck; 
string varVal;
fstream code_asm;
vector<SymbolInfo*> global_vars;


char *newLabel()
{
	char *lb= new char[4];
	strcpy(lb,"L");
	char b[3];
	sprintf(b,"%d", labelCount);
	labelCount++;
	strcat(lb,b);
	return lb;
}

char *newTemp()
{
	char *t= new char[4];
	strcpy(t,"t");
	char b[3];
	 sprintf(b,"%d", tempCount);
	tempCount++;
	strcat(t,b);
	return t;
}


void generateCode(SymbolInfo* si)
{
     cout<<"start :"<<si->getName()<<" type="<<si->getType()<<endl;
	
	// fout.close();
	// code_asm.close();

	if(si->getName()=="program" && si->getType()=="start")
	{
		code_asm<<".MODEL SMALL\n.STACK 1000H\n.Data\n";
		code_asm<<"\tCR EQU 0DH\n\tLF EQU 0AH\n\t number DB \"00000$\"\n";

		for(int i=0;i<global_vars.size();i++)
		{
			code_asm<<global_vars[i]->getName()<<" DW 1 DUP (0000H)\n";
		}
		code_asm<<".CODE\n";
		generateCode(si->child[0]);
		cout<<"start :"<<si->child.size()<<endl;
		code_asm<<"new_line proc\n\tpush ax\n\tpush dx\n\tmov ah,2\n\tmov dl,cr\n\tint 21h\n\tmov ah,2\n\tmov dl,lf\n\tint 21h\n\tpop dx\n\tpop ax\n\tret\nnew_line endp\n";
		code_asm<<"print_output proc  ;print what is in ax\n\tpush ax\n\tpush bx\n\tpush cx\n\tpush dx\n\tpush si\n\tlea si,number\n\tmov bx,10\n\tadd si,4\n\tcmp ax,0\n";
		code_asm<<"\tjnge negate\n\tprint:\n\txor dx,dx\n\tdiv bx\n\tmov [si],dl\n\tadd [si],'0'\n\tdec si\n\tcmp ax,0\n\tjne print\n\tinc si\n\tlea dx,si\n\tmov ah,9\n";
		code_asm<<"\tint 21h\n\tpop si\n\tpop dx\n\tpop cx\n\tpop bx\n\tpop ax\n\tret\n\tnegate:\n\tpush ax\n\tmov ah,2\n\tmov dl,'-'\n\tint 21h\n\tpop ax\n\tneg ax\n\tjmp print\n\tprint_output endp\n";
	
		code_asm<<"END MAIN\n";
	}
	else if(si->getName()=="program unit" && si->getType()=="program")
	{
		generateCode(si->child[0]);
		generateCode(si->child[1]);
	}
	else if(si->getName()=="unit" && si->getType()=="program")
	{
		generateCode(si->child[0]);
	}
	else if(si->getName()=="var_declaration" && si->getType()=="unit")
	{
		generateCode(si->child[0]);
	}
	else if(si->getName()=="func_declaration" && si->getType()=="unit")
	{
		generateCode(si->child[0]);
	}
	else if(si->getName()=="func_definition" && si->getType()=="unit")
	{
		generateCode(si->child[0]);
	}
	else if(si->getName()=="type_specifier ID LPAREN parameter_list RPAREN SEMICOLON" && si->getType()=="func_declaration")
	{
		generateCode(si->child[0]);
		generateCode(si->child[1]);
		generateCode(si->child[2]);
		generateCode(si->child[3]);
		generateCode(si->child[4]);
		generateCode(si->child[5]);
	}
	else if(si->getName()=="type_specifier ID LPAREN RPAREN SEMICOLON" && si->getType()=="func_declaration")
	{
		generateCode(si->child[0]);
		generateCode(si->child[1]);
		generateCode(si->child[2]);
		generateCode(si->child[3]);
		generateCode(si->child[4]);
	}
	else if(si->getType()=="func_definition" && si->getName()=="type_specifier ID LPAREN parameter_list RPAREN compound_statement" )
	{

		cur_func=si->child[1]->getName();
		code_asm<<" ;"<<cur_func<<" function is defined"<<endl;
		generateCode(si->child[0]);
		generateCode(si->child[3]);


		code_asm<<si->child[1]->getName()<<" PROC\n";
			// cout<<"chk fun1:"<<" "<<$2->getName()<<endl;
		if(si->child[1]->getName()=="main")
		{
				code_asm<<"\tMOV AX, @DATA\n\tMOV DS, AX"<<endl;
		}

		code_asm<<"\tPUSH BP\n\tMOV BP, SP"<<endl;
		cout<<"func deff :"<<si->child.size()<<endl;
		cout<<si->child[1]->getName()<<"= name ::"<<endl;
		generateCode(si->child[5]);

		
		if(si->child[1]->getName()=="main")
		{		
				code_asm<<"EXIT:"<<endl;
				code_asm<<"\tMOV AX,4CH\n\tINT 21H"<<endl;
		}
		code_asm<<"\tADD SP, "<<si->child[5]->offset<<endl;
		code_asm<<"\tPOP BP\n";
		if(si->child[1]->getName()!="main")
		{
				code_asm<<"\tRET"<<endl;
		}
		code_asm<<si->child[1]->getName()<<" ENDP\n";


	}
	else if(si->getType()=="func_definition" && si->getName()=="type_specifier ID LPAREN RPAREN compound_statement" )
	{
		cur_func=si->child[1]->getName();
		code_asm<<" ;"<<cur_func<<" function is defined at line no="<<si->start<<endl;
		generateCode(si->child[0]);
	//	generateCode(si->child[3]);
		cout<<"vallage na r "<<si->child[1]->getName()<<endl;

		code_asm<<si->child[1]->getName()<<" PROC\n";
			// cout<<"chk fun1:"<<" "<<$2->getName()<<endl;
		if(si->child[1]->getName()=="main")
		{
			//	cout<<"error= "<<si->child[1]->getName()<<endl;
				code_asm<<"\tMOV AX, @DATA\n\tMOV DS, AX"<<endl;
		}

		 code_asm<<"\tPUSH BP\n\tMOV BP, SP"<<endl;
		// cout<<"func dec :"<<si->child.size()<<endl;
		// cout<<si->child[1]->getName()<<"= name ::"<<endl;
		 generateCode(si->child[4]);

		// code_asm<<"EXIT:"<<endl;
		if(si->child[1]->getName()=="main")
		{
				cout<<"error2= "<<si->child[1]->getName()<<endl;
				if(code_asm.is_open())
				{
					
				 	code_asm<<"\tMOV AX,4CH\n\tINT 21H"<<endl;

				} 
		}
		if(code_asm.is_open())
		{

			cout<< "jjjjjjj\n";
			 code_asm<<"\tADD SP, "<<si->child[4]->offset<<endl;
			code_asm<<"\tPOP BP\n";
			if(si->child[1]->getName()!="main")
			{
					code_asm<<"\tRET"<<endl;
			}
			code_asm<<si->child[1]->getName()<<" ENDP\n";
		}
		
	}
	else if(si->getType()=="parameter_list" && si->getName()=="parameter_list COMMA type_specifier ID" )
	{
		// parameter_list  : parameter_list COMMA type_specifier ID
		generateCode(si->child[0]);
		generateCode(si->child[2]);
		
		// cout<<"par list: "<<si->child.size()<<endl;
		cout<<si->child[1]->getName()<<"= name ::"<<endl;
	}
	else if(si->getType()=="parameter_list" && si->getName()=="parameter_list COMMA type_specifier" )
	{
		generateCode(si->child[0]);
		generateCode(si->child[2]);		
	}

	else if(si->getType()=="parameter_list" && si->getName()=="type_specifier ID" )
	{
		generateCode(si->child[0]);
		// generateCode(si->child[2]);		
	}
	else if(si->getType()=="parameter_list" && si->getName()=="type_specifier" )
	{
		generateCode(si->child[0]);
		// generateCode(si->child[2]);		
	}
	else if(si->getType()=="compound_statement" && si->getName()=="LCURL statements RCURL" )
	{
		if(si->isEnd=="")
			si->isEnd=newLabel();
		si->child[1]->isEnd=si->isEnd;
		generateCode(si->child[1]);
		// generateCode(si->child[2]);		
	}

	else if(si->getType()=="var_declaration" && si->getName()=="type_specifier declaration_list SEMICOLON" )
	{
		generateCode(si->child[1]);
		cout<<" dec list size= "<<si->child[1]->dec_list.size()<<endl;
		for(int i=0;i<si->child[1]->dec_list.size();i++)
		{
			if(! si->child[1]->dec_list[i]->isGlobal)
			{
				cout<<"inside : "<<si->child[1]->dec_list[i]->getName()<<" isG: "<<si->child[1]->isGlobal<<endl;
				code_asm<<"\tSUB SP, 2"<<endl;
			}
		}		
	}
	
	else if(si->getType()=="statements" && si->getName()=="statement" )
	{

		si->child[0]->isEnd=si->isEnd;
		generateCode(si->child[0]);
		// generateCode(si->child[2]);	
		code_asm<<si->child[0]->isEnd<<":\n";
	}
	else if(si->getType()=="statements" && si->getName()=="statements statement" )
	{
		si->child[0]->isEnd=newLabel();
		si->child[1]->isEnd=si->isEnd;

		generateCode(si->child[0]);
		generateCode(si->child[1]);	

		code_asm<<si->isEnd<<":\n";	
	}
	else if(si->getType()=="statement" && si->getName()=="var_declaration" )
	{
		generateCode(si->child[0]);
		// generateCode(si->child[1]);		
	}
	else if(si->getType()=="statement" && si->getName()=="expression_statement" )
	{
		//  si->child[1]->isEnd=si->isEnd;
		generateCode(si->child[0]);
			
	}
	else if(si->getType()=="statement" && si->getName()=="compound_statement" )
	{
		si->child[0]->isEnd=newLabel();

		generateCode(si->child[0]);
			
	}
	else if(si->getType()=="statement" && si->getName()=="FOR LPAREN expression_statement expression_statement expression RPAREN statement" )
	{

        code_asm<<" ;for loop at line no="<<si->start<<endl;
		generateCode(si->child[2]);
		string forLoop=newLabel();
		code_asm<<forLoop<<":\n";

		si->child[3]->isCond=true;
		si->child[3]->isTrue=newLabel();
		si->child[3]->isFalse=si->isEnd;
		si->child[6]->isEnd=newLabel();
	
        generateCode(si->child[3]);
		code_asm<<si->child[3]->isTrue<<":\n";
        
        generateCode(si->child[6]);
       
		generateCode(si->child[4]);

		
		code_asm<<"\tJMP "<<forLoop<<endl;
		         	
			
	}

	else if(si->getType()=="statement" && si->getName()=="IF LPAREN expression RPAREN statement" )
	{
		code_asm<<" ;if condition at line no="<<si->start<<endl;
		si->child[2]->isCond=true;
		si->child[2]->isTrue=newLabel();
        si->child[2]->isFalse=si->isEnd;
		si->child[4]->isEnd=si->isEnd;

        generateCode(si->child[2]);
		code_asm<<si->child[2]->isTrue<<":\n";

       
		generateCode(si->child[4]);
			
			
	}
	else if(si->getType()=="statement" && si->getName()=="IF LPAREN expression RPAREN statement ELSE statement" )
	{

		si->child[2]->isCond=true;
		si->child[2]->isTrue=newLabel();
		si->child[2]->isFalse=newLabel();
		si->child[4]->isEnd=si->child[2]->isFalse;
		si->child[6]->isEnd=si->isEnd;

       	generateCode(si->child[2]);
		code_asm<<si->child[2]->isTrue<<":\n";
       
		generateCode(si->child[4]);

		code_asm<<"\tJMP "<<si->isEnd<<endl;
        code_asm<<si->child[2]->isFalse<<":\n";
        
		generateCode(si->child[6]);
	
			
	}
	else if(si->getType()=="statement" && si->getName()=="WHILE LPAREN expression RPAREN statement" )
	{
		 code_asm<<" ;while loop at line no="<<si->start<<endl;
		string whileLoop=newLabel();
		si->child[2]->isCond=true;
		si->child[2]->isTrue=newLabel();
		si->child[2]->isFalse=si->isEnd;
		si->child[4]->isEnd=si->isEnd;

		code_asm<<whileLoop<<":\n";

		generateCode(si->child[2]);
		code_asm<<si->child[2]->isTrue<<":\n";
			
		generateCode(si->child[4]);

		code_asm<<"\tJMP "<<whileLoop<<endl;
			
			
	}
	else if(si->getType()=="statement" && si->getName()=="PRINTLN LPAREN ID RPAREN SEMICOLON" )
	{
		
		if(si->isGlobal)
			code_asm<<"\tMOV CX, "<<si->child[2]->getName()<<"\n\tPUSH CX\n\tMOV AX,CX\n\tCALL print_output\n\tCALL new_line"<<endl;
		else
			code_asm<<"\tMOV CX, [BP-"<<si->offset<<"]\n\tPUSH CX\n\tMOV AX,CX\n\tCALL print_output\n\tCALL new_line"<<endl;

	}
	else if(si->getType()=="statement" && si->getName()=="RETURN expression SEMICOLON" )
	{
		generateCode(si->child[1]);
	}

	else if(si->getType()=="expression_statement" && si->getName()=="expression SEMICOLON" )
	{
		si->child[0]->isCond=si->isCond;
		si->child[0]->isTrue=si->isTrue;
		si->child[0]->isFalse=si->isFalse;

		generateCode(si->child[0]);
	}
	else if(si->getType()=="expression" && si->getName()=="logic_expression" )
	{
		si->child[0]->isCond=si->isCond;
		si->child[0]->isTrue=si->isTrue;
		si->child[0]->isFalse=si->isFalse;

		generateCode(si->child[0]);
	}
	else if(si->getType()=="expression" && si->getName()=="variable ASSIGNOP logic_expression" )
	{
		
		generateCode(si->child[0]);
		code_asm<<"; line no="<<si->start<<endl;
		generateCode(si->child[2]);
	//	code_asm<<"\tPUSH CX1"<<endl;
		

		// cout
		
		if(si->child[0]->isGlobal)
		{
				cout<<"is Global check="<<si->child[0]->varName<<endl;
				code_asm<<"\tMOV "<<si->child[0]->varName<<", CX"<<endl;
				// code_asm<<"\tMOV AX, CX"<<endl;
		}
		else
		{
				cout<<"wrong var?"<<si->child[0]->varName<<endl;
				if(cur_func=="main")
					code_asm<<"\tMOV [BP-"<<si->child[0]->offset<<"], CX"<<endl;
				else
					code_asm<<"\tMOV [BP+"<<si->child[0]->offset<<"], CX"<<endl;
			//	code_asm<<"MOV CX, [BP-"<<si->child[0]->offset<<"]"<<endl;
				// code_asm<<"\tPUSH CX"<<endl;
		}
		if(si->isCond)
			code_asm<<"\tJMP "<<si->isTrue<<endl;
		

	}

	else if(si->getType()=="logic_expression" && si->getName()=="rel_expression" )
	{
		si->child[0]->isCond=si->isCond;
		si->child[0]->isTrue=si->isTrue;
		si->child[0]->isFalse=si->isFalse;

		generateCode(si->child[0]);
	}

	else if(si->getType()=="logic_expression" && si->getName()=="rel_expression LOGICOP rel_expression" )
	{
		si->child[0]->isCond=si->isCond;
		si->child[2]->isCond=si->isCond;

		if(si->child[1]->getName()=="&&")
		{
			string temp=newLabel();
			temp+="jmpTrue";
			si->child[0]->isTrue=temp;
			si->child[0]->isFalse=si->isFalse;
			si->child[2]->isTrue=si->isTrue;
			si->child[2]->isFalse=si->isFalse;
		}
		else
		{
			string temp=newLabel();
			temp+="jmpFalse";
			si->child[0]->isTrue=si->isTrue;
			si->child[0]->isFalse=temp;
			si->child[2]->isTrue=si->isTrue;
			si->child[2]->isFalse=si->isFalse;

		}
		generateCode(si->child[0]);
		if(si->isCond)
		{
			if(si->child[1]->getName()=="&&")
			{
				code_asm<<si->child[0]->isTrue<<":\n";
			}
			else
			{
				code_asm<<si->child[0]->isFalse<<":\n";
			}
		}
		else
		{
			code_asm<<"\tPUSH CX\n";
		}
		generateCode(si->child[2]);

		if(!si->isCond)
		{
			code_asm<<"\tPOP AX\n";
			// ...
			if(si->child[1]->getName()=="&&")
			{
				string label1=newLabel();
				string label2=newLabel();
				string label3=newLabel();

				code_asm<<"\tCMP AX,0\n";
				code_asm<<"\tJE "<<label1<<endl;
				code_asm<<"\tJCXZ "<<label1<<endl;
				code_asm<<"\tJMP "<<label2<<endl;
				code_asm<<label1<<":\n";

				code_asm<<"\tMOV CX,0\n";
				code_asm<<"\tJMP "<<label3<<endl;
				code_asm<<label2<<":\n";

				code_asm<<"\tMOV CX,1\n";
				code_asm<<label3<<":\n";

			}

			else
			{
				string label1=newLabel();
				string label2=newLabel();
				string label3=newLabel();
				string label4=newLabel();

				code_asm<<"\tCMP AX,0\n";
				code_asm<<"\tJE "<<label1<<endl;
				code_asm<<"\tJMP "<<label2<<endl;
				code_asm<<label1<<":\n";
				code_asm<<"\tJCXZ "<<label3<<endl;
				code_asm<<label2<<":\n";

				code_asm<<"\tMOV CX,1\n";
				code_asm<<"\tJMP "<<label4<<":"<<endl;
				code_asm<<label3<<":\n";

				code_asm<<"\tMOV CX,0\n";
				code_asm<<label4<<":\n";


				

			}
		}
		
	}
	else if(si->getType()=="rel_expression" && si->getName()=="simple_expression" )
	{
		si->child[0]->isCond=si->isCond;
		si->child[0]->isTrue=si->isTrue;
		si->child[0]->isFalse=si->isFalse;

		generateCode(si->child[0]);
	}

	else if(si->getType()=="rel_expression" && si->getName()=="simple_expression RELOP simple_expression" )
	{
		generateCode(si->child[0]);
		code_asm<<"\tPUSH CX\n";
		generateCode(si->child[2]);

		code_asm<<"\tPOP AX\n\tCMP AX,CX\n";
		if(si->isTrue=="")
			si->isTrue=newLabel();
		if(si->isFalse=="")
			si->isFalse=newLabel();

		if(si->child[1]->getName()=="<")
			code_asm<<"\tJL ";
		else if(si->child[1]->getName()=="<=")
			code_asm<<"\tJLE ";
		else if(si->child[1]->getName()==">")
			code_asm<<"\tJG ";
		else if(si->child[1]->getName()=="=>")
			code_asm<<"\tJGE ";
		else if(si->child[1]->getName()=="==")
			code_asm<<"\tJE ";
		else if(si->child[1]->getName()=="!=")
			code_asm<<"\tJNE ";

		code_asm<<si->isTrue<<"\n";
		code_asm<<"\tJMP "<<si->isFalse<<endl;

		if(!si->isCond)
		{
			code_asm<<si->isTrue<<":\n";
			code_asm<<"\tMOV CX,1\n";
			string labelOut=newLabel();

			code_asm<<"\tJMP "<<labelOut<<endl;
			code_asm<<si->isFalse<<":\n";
			code_asm<<"\tMOV CX,0\n";
			code_asm<<labelOut<<":\n";
		}

	
	}
	else if(si->getType()=="simple_expression" && si->getName()=="term" )
	{
		si->child[0]->isCond=si->isCond;
		si->child[0]->isTrue=si->isTrue;
		si->child[0]->isFalse=si->isFalse;

		generateCode(si->child[0]);
	}

	else if(si->getType()=="simple_expression" && si->getName()=="simple_expression ADDOP term" )
	{
		// cout<<"is zero="<<si->child[0]->varVal<<" ,"<<si->child[2]->varVal<<endl;

		if(si->child[1]->getName()=="+")
			code_asm<<" ;add operation="<<si->start<<endl;
		else
			code_asm<<" ;sub operation="<<si->start<<endl;
		if(si->child[0]->varVal !="0" && si->child[2]->varVal =="0")
		{
			// cout<<"opdone\n";
			generateCode(si->child[0]);
		}

		else if(si->child[0]->varVal =="0" && si->child[2]->varVal !="0" )
		{
			generateCode(si->child[2]);
		}
		else
		{
			generateCode(si->child[0]);
			code_asm<<"\tPUSH CX\n";
			generateCode(si->child[2]);
			code_asm<<"\tPOP AX\n";

			if(si->child[1]->getName()=="+")
			{
				code_asm<<"\tADD AX,CX\n\tMOV CX,AX\n";
			}
			else {

			code_asm<<"\tSUB AX,CX\n\tMOV CX,AX\n";
			}
		}
		
		

		if(si->isCond)
		{
			code_asm<<"\tJCXZ "<<si->isFalse<<endl;
			code_asm<<"\t JMP "<<si->isTrue<<endl;
		}
	}
	else if(si->getType()=="term" && si->getName()=="unary_expression" )
	{
		si->child[0]->isCond=si->isCond;
		si->child[0]->isTrue=si->isTrue;
		si->child[0]->isFalse=si->isFalse;

		generateCode(si->child[0]);
	}

	else if(si->getType()=="term" && si->getName()=="term MULOP unary_expression" )
	{

		if(si->child[1]->getName()=="*")
			code_asm<<" ;multiplication operation="<<si->start<<endl;
		else
			code_asm<<" ;division operation="<<si->start<<endl;

		if(si->child[0]->varVal !="1" && si->child[2]->varVal =="1")
		{
			cout<<"opdone\n";
			generateCode(si->child[0]);
		}

		else if(si->child[0]->varVal =="1" && si->child[2]->varVal !="1" )
		{
			generateCode(si->child[2]);
		}

		else
		{
			generateCode(si->child[0]);
			code_asm<<"\tPUSH CX\n";
			generateCode(si->child[2]);

			if(si->child[1]->getName()=="*")
			{

				code_asm<<"\n\tPOP AX\n\tIMUL CX\n\tMOV CX,AX\n";
			}
			else if(si->child[1]->getName()=="/")
			{
				code_asm<<"\n\tPOP AX\n\tCWD\n\tIDIV CX\n\tMOV CX,AX\n";
			}
			else
			{
				code_asm<<"\n\tPOP AX\n\tCWD\n\tIDIV CX\n\tMOV CX,DX\n";
			}
		}
		

		if(si->isCond)
		{
			code_asm<<"\tJCXZ "<<si->isFalse<<endl;
			code_asm<<"\tJMP "<<si->isTrue<<endl;
		}
	}
	else if(si->getType()=="unary_expression" && si->getName()=="ADDOP unary_expression" )
	{
		si->child[1]->isCond=si->isCond;
		si->child[1]->isTrue=si->isTrue;
		si->child[1]->isFalse=si->isFalse;

		generateCode(si->child[1]);
		code_asm<<"\n\tPOP CX\n\tNEG CX\nPUSH CX\n";
	}

	else if(si->getType()=="unary_expression" && si->getName()=="NOT unary_expression" )
	{
		si->child[0]->isCond=si->isCond;
		si->child[0]->isTrue=si->isFalse;
		si->child[0]->isFalse=si->isTrue;


		generateCode(si->child[1]);

		if(!si->isCond)
		{
			string temp1=newLabel();
			string temp2=newLabel();

			code_asm<<"\tJCXZ "<<temp2<<"\n";
			code_asm<<"\tMOV CX,0\n";
			code_asm<<"\tJMP "<<temp1<<endl;
			code_asm<<temp2<<":\n";
			code_asm<<"\tMOV CX,1\n";
			code_asm<<temp1<<":\n";

		}
	}
	else if(si->getType()=="unary_expression" && si->getName()=="factor" )
	{
		si->child[0]->isCond=si->isCond;
		si->child[0]->isTrue=si->isTrue;
		si->child[0]->isFalse=si->isFalse;

		generateCode(si->child[0]);
	}
	else if(si->getType()=="factor" && si->getName()=="variable" )
	{

		generateCode(si->child[0]);
		cout<<"CUR FUNC="<<cur_func<<" variable = "<<si->child[0]->varName<<" check global="<<si->child[0]->isGlobal<<endl;

		if(si->isGlobal)
			code_asm<<"\tMOV CX, "<<si->child[0]->varName<<endl;
		else 
		{
			// cout<<"print cur func name="<<cur_func<<endl;
			// code_asm<<cur_func<<endl;
			if(cur_func=="main")
				code_asm<<"\tMOV CX,[BP-"<<si->child[0]->offset<<"]\n";  //!!
			else
				code_asm<<"\tMOV CX,[BP+"<<si->child[0]->offset<<"]\n";
		}

		if(si->isCond)
		{
			code_asm<<"\tJCXZ "<<si->isFalse<<endl;
			code_asm<<"\tJMP "<<si->isTrue<<endl;
		}
			
	}
	else if(si->getType()=="factor" && si->getName()=="ID LPAREN argument_list RPAREN" )
	{
		generateCode(si->child[2]);
		code_asm<<"\n\tMOV AX,CX\nCALL "<<si->child[0]->getName()<<endl;

		if(si->isCond)
		{
			code_asm<<"\tJCXZ "<<si->isFalse<<endl;
			code_asm<<"\tJMP "<<si->isTrue<<endl;
		}
	}
	else if(si->getType()=="factor" && si->getName()=="LPAREN expression RPAREN" )
	{
		generateCode(si->child[1]);

		if(si->isCond)
		{
			code_asm<<"\tJCXZ "<<si->isFalse<<endl;
			code_asm<<"\tJMP "<<si->isTrue<<endl;
		}
		
	}
	else if(si->getType()=="factor" && si->getName()=="CONST_INT" )
	{
		generateCode(si->child[0]);
		code_asm<<"\tMOV CX,"<<si->child[0]->getName()<<endl;

		if(si->isCond)
		{
			code_asm<<"\tJCXZ "<<si->isFalse<<endl;
			code_asm<<"\tJMP "<<si->isTrue<<endl;
		}
	}
	else if(si->getType()=="factor" && si->getName()=="CONST_FLOAT" )
	{
		generateCode(si->child[0]);
		code_asm<<"\tMOV CX,"<<si->child[0]->getName()<<endl;

		if(si->isCond)
		{
			code_asm<<"\tJCXZ "<<si->isFalse<<endl;
			code_asm<<"\tJMP "<<si->isTrue<<endl;
		}
	}
	else if(si->getType()=="factor" && si->getName()=="variable INCOP" )
	{
		code_asm<<" ;increase (++) operation="<<si->start<<endl;
		
		generateCode(si->child[0]);
		if(si->child[0]->isGlobal)
		{
            code_asm<<"\tMOV CX,"<<si->child[0]->varName<<endl;
			code_asm<<"\tMOV AX,CX\n";
            code_asm<<"\tINC CX\n\tMOV "<<si->child[0]->varName<<",CX\n";
		}
		else
		{
            code_asm<<"\tMOV CX,[BP-"<<si->child[0]->offset<<"]"<<endl;
			code_asm<<"\tMOV AX,CX\n";
            code_asm<<"\tINC CX\n\tMOV [BP-"<<si->child[0]->offset<<"],CX\n";
		}
		code_asm<<"\tMOV CX,AX\n";
		if(si->isCond)
		{
			code_asm<<"\tJCXZ "<<si->isFalse<<endl;
			code_asm<<"\tJMP "<<si->isTrue<<endl;
		}
		
		
	}
	else if(si->getType()=="factor" && si->getName()=="variable DECOP" )
	{
		code_asm<<" ;decrease (--) operation="<<si->start<<endl;
		generateCode(si->child[0]);
		if(si->child[0]->isGlobal)
		{
            code_asm<<"\tMOV CX,"<<si->child[0]->varName<<endl;
			code_asm<<"\tMOV AX,CX\n";
			code_asm<<"\tSUB CX,1\n\tMOV "<<si->child[0]->varName<<",CX\n";
		}
		else
		{
			code_asm<<"\tMOV CX,[BP-"<<si->child[0]->offset<<"]"<<endl;
			code_asm<<"\tMOV AX,CX\n";
            code_asm<<"\tDEC CX\n\tMOV [BP-"<<si->child[0]->offset<<"],CX\n";
		}
		code_asm<<"\tMOV CX,AX\n";
		if(si->isCond)
		{
			code_asm<<"\tJCXZ "<<si->isFalse<<endl;
			code_asm<<"\tJMP "<<si->isTrue<<endl;
		}
		
	}
	else if(si->getType()=="argument_list" && si->getName()=="arguments" )
	{
		generateCode(si->child[0]);
		code_asm<<"\tPUSH CX\n";
	}

	else if(si->getType()=="arguments" && si->getName()=="arguments COMMA logic_expression" )
	{
		generateCode(si->child[0]);
		code_asm<<"\tPUSH CX\n";
		generateCode(si->child[2]);
		
	}

	else if(si->getType()=="arguments" && si->getName()=="logic_expression" )
	{
		generateCode(si->child[0]);
		code_asm<<"\tPUSH CX\n";
	}


	

	
}
%}
%union{
	SymbolInfo *sym;
}

%token<sym> IF ELSE FOR WHILE DOUBLE CHAR RETURN VOID PRINTLN ASSIGNOP NOT SEMICOLON COMMA LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD INCOP DECOP ID INT FLOAT CONST_INT LOGICOP ADDOP MULOP CONST_FLOAT RELOP
%type<sym> start program unit var_declaration declaration_list func_declaration func_definition type_specifier RCURL_ compound_statement parameter_list lcurl statements statement variable expression_statement logic_expression arguments argument_list expression simple_expression unary_expression factor term rel_expression 

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

		//	// cout<<"blabla"<<$$->child.size()<<"chk: "<<$$->isLeaf<<endl;
			$$->printParseTree(1);
			code_asm.open("code_asm.asm", ios::out );
			generateCode($$);
			

		
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

			

			
		}
	| unit {
			$$=new SymbolInfo("unit","program");
			fprintf(logout,"program : unit \n");


			$$->start=$1->start;
			$$->end=$1->end;
			$$->child.push_back($1);

			// // cout<<"blaba\n";
			
			}

	;
	
unit : var_declaration
		{
			$$=new SymbolInfo("var_declaration","unit");
			fprintf(logout,"unit : var_declaration \n");

			$$->start=$1->start;
			$$->end=$1->end;

			$$->child.push_back($1);

		//	// cout<<"chk 2: "<<$$->isLeaf<<endl;
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
			 


			


			for(int i=0;i<$4->para_list.size();i++)
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

			 $$->start=$1->start;
			$$->end=$6->end;
			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);
			$$->child.push_back($4);
			$$->child.push_back($5);
			$$->child.push_back($6);

			



			
}
		| type_specifier ID LPAREN RPAREN SEMICOLON {
			$$=new SymbolInfo("type_specifier ID LPAREN RPAREN SEMICOLON","func_declaration");
			fprintf(logout,"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON \n");
			

			
	

			$2->isDec=true; 
			table->Insert($2->getName(),$2->getType());
			SymbolInfo* tempp=table->LookUp($2->getName());
			tempp->isDec=true;
		
			par_list.clear();

			$$->start=$1->start;
			$$->end=$5->end;

			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);
			$$->child.push_back($4);
			$$->child.push_back($5);
		}
		;
		 
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN {
			// $$=new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN compound_statement","func_definition");
			fprintf(logout,"func_definition: type_specifier ID LPAREN PARAMETER_LIST RPAREN COMPOUND_STATEMENT \n");
		


			//isDEc?? 

			 SymbolInfo* tem=table->LookUp($2->getName());
			
			if(!tem)
			{
				//the func does not exist , create a new one
					// // cout<<" chk fun1:"<<" "<<$4->para_list.size()<<endl;
					SymbolInfo* si=new SymbolInfo($2->getName(),$1->getType());
					// set para list
					for(int i=0;i<$4->para_list.size();i++)
					{
						$2->para_list.push_back($4->para_list[i]);
						table->Insert($4->para_list[i]->getName(),$4->para_list[i]->getType());
						// // cout<<"chk: "<<$5->para_list[i]->getName()<<" "<<$5->para_list[i]->varType<<endl;
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
				
				// // cout<<" chk fun:"<<$2->getName()<<" ::"<<tempp->para_list.size()<<" "<<$4->para_list.size()<<endl;
				//  // cout<<" chk:2 "<<$2->getName()<<" isDEf and dec: "<<tempp->isDec<<" "<<tempp->isDef<<endl;
				if(tempp->isDef || tempp->isDec)
				{
					// // cout<<" chk: "<<$2->getName()<<" isDEf and dec: "<<$2->isDec<<endl;
					if($1->varType!=tempp->varType)
					{
						fprintf(errorout,"Line# %d: Conflicting types for '%s'\n",$2->end,$2->getName().c_str());
						error++;
					}
					// matching parameter size 
					// SymbolInfo* tem=table->LookUp($2->getName());
					if(tem->para_list.size()>$4->para_list.size())
					{
					//	// cout<<" few check1:"<<tem->para_list.size()<<" :::"<<$4->para_list.size()<<endl;
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
		int off=4;

		for(int i=$4->para_list.size()-1;i>0;i--)
			{
				SymbolInfo* chk=table->LookUp(par_list[i].name);
				cout<<"total table="<<table->getTotalScopeTable()<<endl;
				chk->offset=off;
				off+=2;
				chk->isGlobal=false;
			}

		
		} compound_statement {
			 $$=new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN compound_statement","func_definition");
			$$->start=$1->start;
			$$->end=$7->end;
			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);
			$$->child.push_back($4);
			$$->child.push_back($5);
			$$->child.push_back($7);

			for(int i=0;i<$4->para_list.size();i++)
			{
				$$->para_list.push_back($4->para_list[i]);

			}

			cout<<"func name="<<$2->getName()<<endl;
			cout<<"table!="<<table->getTotalScopeTable()<<endl;
			for(int i=0;i<$4->para_list.size();i++)
			{
				cout<<"para name="<<$4->para_list[i]->getName()<<"global="<<$4->para_list[i]->isGlobal<<endl;

			}

			

		}
		| type_specifier ID LPAREN RPAREN {
		
			fprintf(logout,"func_definition: type_specifier ID LPAREN RPAREN COMPOUND_STATEMENT \n");
			


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

			cur_func=$2->getName();
			
		
		}
		compound_statement {
			$$=new SymbolInfo("type_specifier ID LPAREN RPAREN compound_statement","func_definition");
			$$->start=$1->start;
			$$->end=$6->end;
			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);
			$$->child.push_back($4);
			$$->child.push_back($6);
			
			

			
			par_list.clear();


		}
 		;		
parameter_list  : parameter_list COMMA type_specifier ID{
			$$=new SymbolInfo("parameter_list COMMA type_specifier ID","parameter_list");
			fprintf(logout,"parameter_list  : parameter_list COMMA type_specifier ID \n");

			parameter tem;
		//	cout<<" para="<<$3->varType<<endl;
			tem.type=(string)$3->varType;
			tem.name=(string)$4->getName();
			
			par_list.push_back(tem);

			if($3->varType!="void")
			{
				SymbolInfo* si=new SymbolInfo(tem.name,tem.type);
				table->Insert(si->getName(),tem.type);
				// SymbolInfo* temp=table->LookUp(tem.name);
				// stack_incremented-=2;
				// temp->offset=stack_incremented;
			}
			
		//	cout<<"para check ="<<temp->offset<<endl;
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

			if($1->varType!="void")
			{
				SymbolInfo* si=new SymbolInfo(tem.name,tem.type);
				table->Insert(si->getName(),tem.type);
				SymbolInfo* temp=table->LookUp(tem.name);
				stack_incremented-=2;
				temp->offset=stack_incremented;
			}


			//checking 
			// SymbolInfo* temp=table->LookUp(si->getName());
			// cout<<"offset valcheck:= "<<temp->getName()<<" "<<temp->offset<<endl;

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

 		
compound_statement : lcurl statements RCURL_ { // ?!
			$$=new SymbolInfo("LCURL statements RCURL","compound_statement");
			fprintf(logout,"compound_statement : LCURL statements RCURL \n");

			$$->start=$1->start;
			$$->end=$3->end;
			$$->child.push_back($1);
			$$->child.push_back($2);
			$$->child.push_back($3);


			
		}
 		    | lcurl RCURL_ {
			$$=new SymbolInfo("LCURL RCURL","compound_statement");
			fprintf(logout,"compound_statement : Lcurl RCURL \n");
			
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
						///	// cout<<"finbal: "<<$1->varType<<" ::"<<temp->varType<<endl;
							fprintf(errorout,"Line# %d: Conflicting types for'%s'\n",line_count,var_list[i].name.c_str());
					}
					if(temp->isInserted)
						temp->varType=$1->varType;
					
					// // cout<<" valo lage na: "<<temp->varType<<endl;
				}
			}
			// array not checked

			for(int i=0;i<$2->dec_list.size();i++)
			{
				
				
				$2->dec_list[i]->varType=$1->varType;
				
				SymbolInfo* temp=table->LookUp($2->dec_list[i]->getName());
				// tempOut<<$2->dec_list[i]->getName()<<" :: "<<table->getTotalScopeTable()<<endl;
				if(table->getTotalScopeTable()==1)
				{	$$->isGlobal=true;
					temp->isGlobal=true;
					$2->dec_list[i]->isGlobal=true;

					global_vars.push_back(temp);

				}
				else
				{
					temp->isGlobal=false;
					$2->dec_list[i]->isGlobal=false;
					stack_decremented+=2;
					temp->offset=stack_decremented;
				}
				
			}



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
			

		//	 // cout<<" check var:2 "<<isArrayInsertable<<endl;

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
	  | FOR LPAREN expression_statement expression_statement embedded_exp embedded_void embedded_exp embedded_void expression embedded_exp embedded_void RPAREN statement {
			$$=new SymbolInfo("FOR LPAREN expression_statement expression_statement expression RPAREN statement","statement");
			fprintf(logout,"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement \n");

		
		$$->start=$1->start;
		$$->end=$13->end;
		$$->child.push_back($1);
		$$->child.push_back($2);
		$$->child.push_back($3);
		$$->child.push_back($4);
		// $$->child.push_back($7);
		$$->child.push_back($9);
		$$->child.push_back($12);
		$$->child.push_back($13);
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
			$$->child.push_back($5);
			$$->child.push_back($7);
			$$->child.push_back($8);
			$$->child.push_back($9);
		
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
			// varName=$3->getName();
			SymbolInfo* temp=table->LookUp($3->getName());
			$$->isGlobal=temp->isGlobal;
			$$->offset=temp->offset;
			cout<<"offset check="<<temp->offset<<endl;
			// cout<<"var name chechK:: "<<$3->getName()<<"offset :"<<temp->offset<<endl;


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
	//
};
embedded_void: {
	//
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
			varName=$1->getName();
			$$->varName=$1->getName();
			// cout<<"varname ck:"<<varName<<endl;

			SymbolInfo* temp=table->LookUp($1->getName());
			$$->offset=temp->offset;
			$$->isGlobal=temp->isGlobal;
			

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

			// $$->varType=$1->varType
			

			$$->start=$1->start;
			$$->end=$1->end;
			$$->child.push_back($1);
			

		}		
	 | ID LTHIRD expression RTHIRD {
			$$=new SymbolInfo("ID LTHIRD expression RTHIRD","variable");
			fprintf(logout,"variable: ID LTHIRD expression RTHIRD \n");
			varName=$1->getName();
			// cout<<"varname ck:"<<varName<<endl;

			SymbolInfo* temp=table->LookUp($1->getName());
			$$->offset=temp->offset;
			$$->varType=temp->varType;
			$1->varType=temp->varType;

			$$->arraySize=$3->arraySize;

		//	// cout<<"chk vartype :"<<$1->getName()<<" : "<<temp->varType<<endl;

			if(!temp)
			{
				fprintf(errorout,"Line# %d: undeclared variable %s\n",line_count);
				error++;

				$$->varType="float";
			}
			else if(temp->arraySize==0)
			{
			//	// cout<<"chk b 2:"<<$1->getName()<<" : "<<temp->arraySize<<endl;
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
		$$->varName=$1->varName;
		$$->varVal=$1->varVal;

		SymbolInfo* temp=table->LookUp($1->varName);
		

	
		

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
			// // cout<<"from assign: "<<$1->varType<<" : "<<$3->varType<<endl;
			 error++;
		}
		else if($1->varType!=$3->varType)
		{
			// fprintf(errorout,"Line# %d: type mismatch(not array2)\n",line_count);
			// // cout<<"from assign: "<<$1->varType<<" : "<<$3->varType<<endl;
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

//	// cout<<"chkkkk:::"<<$$->varType<<endl;

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

	$$->start=$1->start;
	$$->end=$1->end;
	$$->child.push_back($1);
	$$->varName=$1->varName;
	$$->varVal=$1->varVal;

	$$->varType=$1->varType;
	$$->arraySize=$1->arraySize;

	// cout<<lue set2:"<<$$->varVal<<endl;
	// SymbolInfo* temp=table->LookUp($$->varName);
		
			

} 
		| simple_expression ADDOP term {
				$$=new SymbolInfo("simple_expression ADDOP term","simple_expression");
				fprintf(logout,"simple_expression : simple_expression ADDOP term \n");
				$$->varName=$1->varName;
				$$->varVal=$1->varVal;

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

				//set var value
				// cout<<lue set:"<<$$->varVal<<" ;"<<$3->varName<<endl;
				SymbolInfo* temp=table->LookUp($$->varName);
					

} 
		  ;
					
term :	unary_expression {
	$$=new SymbolInfo("unary_expression","term");
	fprintf(logout,"term :	unary_expression \n");
	// cout<<"unary : term\n";
	

	$$->start=$1->start;
	$$->end=$1->end;
	$$->child.push_back($1);

	$$->varType=$1->varType;
	$$->arraySize=$1->arraySize;
	$$->varVal=$1->varVal;
	$$->varName=$1->varName;

	// cout<<lue set3:"<<$$->varVal<<endl;
		
			

} 
     |  term MULOP unary_expression {

		$$=new SymbolInfo("term MULOP unary_expression","term");
		fprintf(logout,"term :	term MULOP unary_expression \n");
		$$->varVal=$1->varVal;

	// //type checking
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
	$$->varName=$2->varName;
	

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
			$$->varName=$2->varName;

		

}
		 | factor  {
			$$=new SymbolInfo("factor","unary_expression");
			fprintf(logout,"unary_expression : factor \n");
			

			$$->start=$1->start;
			$$->end=$1->end;
			$$->child.push_back($1);

			$$->varType=$1->varType;
			$$->arraySize=$1->arraySize;
			$$->varName=$1->varName;
			$$->varVal=$1->varVal;


}
		 ;
	
	factor	: variable {
	$$=new SymbolInfo("variable","factor");
	fprintf(logout,"factor	: variable \n");
	

	$$->start=$1->start;
	$$->end=$1->end;
	$$->child.push_back($1);
	$$->isGlobal=$1->isGlobal;
	$$->varName=$1->varName;

	$$->varType=$1->varType;

	$$->arraySize=$1->arraySize;


}
	| ID LPAREN argument_list RPAREN {
	$$=new SymbolInfo("ID LPAREN argument_list RPAREN","factor");
	fprintf(logout,"factor	: ID LPAREN argument_list RPAREN \n");

	 SymbolInfo* si=table->LookUp($1->getName());
	// type=si->varType;

	 arg_list.clear();
	 $$->varName=$1->varName;

	$$->start=$1->start;
	$$->end=$4->end;
	$$->child.push_back($1);
	$$->child.push_back($2);
	$$->child.push_back($3);
	$$->child.push_back($4);

	//check id with arg_list


	
	 SymbolInfo* tem=table->LookUp($1->getName());
	// // cout<<" arg check2 :"<<$1->getName()<<" : "<<tem->para_list.size()<<endl;

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
		$$->varType=tem->varType;
		if($3->arg_list.size()<tem->para_list.size())
		{
			fprintf(errorout,"Line# %d: Too few arguments to function '%s'\n",$2->start,$1->getName().c_str());

			error++;
		}
		else if($3->arg_list.size()>tem->para_list.size())
		{
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
	varVal=$1->getName();
	$$->varVal=$1->getName();
	

	$$->start=$1->start;
	$$->end=$1->end;
	$$->child.push_back($1);

	$$->varType="int";
	value=stoi($1->getName());

	// cout<<lue set4:"<<$$->varVal<<endl;

		

}
	| CONST_FLOAT {
	$$=new SymbolInfo("CONST_FLOAT","factor");
	fprintf(logout,"factor	: variable CONST_FLOAT \n");
	varVal=$1->getName();

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
	//  cout<<"decop check:= "<<$2->getName()<<endl;
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
	$$->offset=$1->offset;


	for(int i=0;i<$1->arg_list.size();i++)
	{
		$$->arg_list.push_back($1->arg_list[i]);
				
	}

	
	
		

}
			  | {
					$$=new SymbolInfo("","argument_list");
					fprintf(logout,"argument_list : \n");
					$$->start=line_count;
					$$->end=line_count;

}
			  ;
	
arguments : arguments COMMA logic_expression {
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
			$$->offset=$1->offset+2;

			arg_list.push_back($3);
			

		///	 // cout<<"chk arg1: "<<arg_list.size()<<endl;
			for(int i=0;i<arg_list.size();i++)
			{
				$$->arg_list.push_back(arg_list[i]);
			//	 // cout<<i<<" :1"<<arg_list[i]->varType<<endl;
			}

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
			$$->offset=2;
			
			arg_list.push_back($1);
			$$->arg_list.push_back($1);

			}
	      ;
lcurl : LCURL {
	$$->start=$1->start;
	$$->end=$1->end;
	table->EnterScope();
	 int offset=4;
	for(int i=par_list.size()-1;i>0;i--)
	{
		if(par_list[i].name!="")
		{
			if(par_list[i].name=="void")
			{

			}
			else
			{
				bool dhur= table->Insert(par_list[i].name,par_list[i].type);
				SymbolInfo* chk=table->LookUp(par_list[i].name);
				cout<<"total table="<<table->getTotalScopeTable()<<endl;
				chk->offset=offset;
				offset+=2;
				chk->isGlobal=false;
				

				
			 }
		}

	}


	$$->child.push_back($1);
	$$->start=$1->start;
	$$->end=$1->end;
			
} ;

RCURL_ : RCURL {
	
	table->printAllScopeTable();
	table->ExitScope();
}
		
		
%%


void yyerror(const char *s){
	//// // cout<< "Error at line no " << line_count << " : " << s << endl;
}

int main(int argc,char *argv[])
{

	
	table=new SymbolTable(10);
	logout= fopen("log.txt","w");
	errorout= fopen("error.txt","w");
	parseout=fopen("parse.txt","w");
	
	// tempOut.open("temp.txt");
	
	FILE *fp = fopen(argv[1],"r");

	yyin=fp;
	table->EnterScope();
	yyparse();
	

	fprintf(logout,"Total Lines: %d\n",line_count);
    fprintf(logout,"Total Errors: %d\n",error);

	fclose(logout);
	fclose(errorout);
	fclose(parseout);
	fclose(fp);
	
	return 0;
}

