#ifndef SymbolTable_h
#define SymbolTable_h
extern FILE *logout;


#include<bits/stdc++.h>

using namespace std;

// int line_count=1;
// int error=0;
extern int start_line;
extern string str;
extern  string str2;
extern  string com_str;

extern FILE *logout;
extern FILE *parseout;
extern FILE* errorout;

class SymbolInfo{
string name;
    string type;
    SymbolInfo *si;
public:
   string varType; //variable type specifier
   int arraySize=0; //array size (), if zero,then no array

   bool isDec; //is func declared
   bool isDef; //is func defined
   bool isLeaf;


   vector<SymbolInfo*> para_list; //parameter list
   vector<SymbolInfo*> dec_list; //declaration list
   vector<SymbolInfo*> arg_list; //arguments of functions

   int start; //start line
   int end;     //end line
   bool isInserted; //to check multiple times declared or not
   vector<SymbolInfo*> child;

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


    void printParseTree(int count)
    {
       
        for(int i=0;i<count-1;i++){
            fprintf(parseout, " ");
            // cout<<" ";
        }
            //print space
        if(isLeaf)
        {
            //cout<<type<<" : "<<name<<" start:"<<start<<" - "<<end<<endl;
            fprintf(parseout,"%s : %s\t<Line: %d>\n",type.c_str(),name.c_str(),start);
        }
        else
        {
           // cout<<type<<" : "<<name<<" start:"<<start<<" - "<<end<<endl;
            fprintf(parseout,"%s : %s \t<Line: %d-%d>\n",type.c_str(),name.c_str(),start,end);
            for(SymbolInfo* si:child)
            {
                si->printParseTree(count+1);
            }
        }

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

            int temp=1;
            for(int i=0;i<size;i++)
            {
                SymbolInfo* tem=array[i];
                temp=i;
                // if(tem->getTotalElement()==i+1)
                //     break;
               
                //cout<<"	"<< i+1<< "--> ";
                while(tem)
                {
                    // fprintf(logout,"\t%d-> ",i+1);
               // out<<"	"<< i+1<< "--> ";
                    if(tem->getName().length()>0)
                    {
                        //fprintf(logout,"check %d %d  ",temp,i);
                      //  if(temp!=i+1)
                            fprintf(logout,"\t%d--> ",i+1);
                        string name(tem->getName());
                        string type(tem->getType());
                        fprintf(logout,"<%s,%s> ",name.c_str(),type.c_str());
                       // fprintf(logout,"check bla: %d",name.length());
                        // out<<"<"<<tem->getName()<<","<<tem->getType()<<"> ";
                         //cout<<"<"<<tem->getName()<<","<<tem->getType()<<"> ";
                      //  if(temp!=i+1)
                          fprintf(logout,"\n");

                         temp=i+1;
                    }
                 
                    tem=tem->getNext();
                
        
                }
                // if(tem)
                //  fprintf(logout,"\n");
                
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
       ScopeTable* tem=cur;
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


#endif 