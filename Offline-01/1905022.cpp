#include<bits/stdc++.h>

using namespace std;

ofstream out;
bool flag=false;
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


class ScopeTable{
    SymbolInfo **array;
    int size;
    int id;
    ScopeTable *parent_scope;

public:
    ScopeTable(int n)
    {
        size=n;
        array=new SymbolInfo*[n];

        for(int i=0;i<size;i++)
            array[i]=new SymbolInfo();

        parent_scope=NULL;
    }

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
            out<<"	Inserted in ScopeTable# "<<id<<" at position "<<idx+1<<", "<<pos<<endl;
            //cout<<"	Inserted in ScopeTable# "<<id<<" at position "<<idx+1<<", "<<pos<<endl;
            return 1;
        }


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
                out<<"	'"<<name<<"' found in ScopeTable# "<<id<<" at position "<<SDBMHash(name)+1<<", "<<cnt<<endl;
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
                out<<"	Deleted '"<<name<<"' from ScopeTable# "<<id<<" at position "<<SDBMHash(name)+1<<","<<cnt<<endl;
                //cout<<"	Deleted '"<<name<<"' from ScopeTable# "<<id<<" at position "<<SDBMHash(name)+1<<","<<cnt<<endl;
                return head;
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
            out<<"	ScopeTable# "<<id<<endl;
            //cout<<"	ScopeTable# "<<id<<endl;

            for(int i=0;i<size;i++)
            {
                SymbolInfo* tem=array[i];
                out<<"	"<< i+1<< "--> ";
                //cout<<"	"<< i+1<< "--> ";
                while(tem)
                {
                    if(tem->getName().length()>0)
                    {
                         out<<"<"<<tem->getName()<<","<<tem->getType()<<"> ";
                         //cout<<"<"<<tem->getName()<<","<<tem->getType()<<"> ";
                    }
                    tem=tem->getNext();
                }
                out<<endl;
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

        out<<"	ScopeTable# "<<total<<" created"<<endl;
        //cout<<"	ScopeTable# "<<total<<" created"<<endl;
    }

    void ExitScope()
    {
        ScopeTable* tem=cur;

        if(tem->getId()==1 &!flag)
        {
            out<<"	ScopeTable# "<<tem->getId()<<" cannot be removed"<<endl;
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
            out<<"	ScopeTable# "<<tem->getId()<<" removed"<<endl;
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
            out<<"	'"<<name<<"' already exists in the current ScopeTable\n";
            //cout<<"	'"<<name<<"' already exists in the current ScopeTable\n";
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
            out<<"	Not found in the current ScopeTable\n";
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
        out<<"	'"<<name<<"' not found in any of the ScopeTables "<<endl;
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

int main()
{

    ifstream in;
    in.open("sample_input.txt");
    out.open("out.txt");


    int n;
    int i=1;

    string line;
    string token[3];

    string s;


    string myline;
    in>>(myline,n);
    SymbolTable st(n);
    st.EnterScope();

    in.ignore(100,'\n');
    if(in.is_open())
    {
        while(in )
        {
            out<<"Cmd "<<i<<": ";
            //cout<<"Cmd "<<i<<": ";
            i++;
            getline (in, myline);
           // //cout << myline << ": " << in.tellg() << endl;
            stringstream X(myline);
            int cnt=0;

            while (getline(X, s, ' ') )
            {
                if(cnt<3)
                    token[cnt++]=s;
                else
                    cnt++;
            }
            for(int i=0;i<3;i++)
            {
                out<<token[i]<<" ";
                //cout<<token[i]<<" ";
            }
            out<<endl;
            //cout<<endl;

            if(cnt>3)
            {
                //if one of them
                out<<"	Number of parameters mismatch for the command "<<token[0]<<endl;
                //cout<<"	Number of parameters mismatch for the command "<<token[0]<<endl;
            }

            else
            {
                if(token[0]=="I")
                {
                //SymbolInfo* symbolInfo=new SymbolInfo(token[1],token[2]);
                    if(token[2].length() && token[1].length())
                        st.Insert(token[1],token[2]);
                    else
                    {
                        out<<"	Number of parameters mismatch for the command I\n";
                        //cout<<"	Number of parameters mismatch for the command I\n";
                    }
                }

                else if(token[0]=="L")
                {
                    if(!token[1].length())
                    {
                        out<<"	Number of parameters mismatch for the command L\n";
                        //cout<<"	Number of parameters mismatch for the command L\n";
                    }
                    else if(!token[2].length())
                        st.LookUp(token[1]);
                    else
                    {
                        out<<"	Number of parameters mismatch for the command L\n";
                        //cout<<"	Number of parameters mismatch for the command L\n";
                    }
                }
            //

                else if(token[0]=="D")
                {
                    if(!token[1].length())
                    {
                        out<<"	Number of parameters mismatch for the command D\n";
                        //cout<<"	Number of parameters mismatch for the command D\n";
                    }
                    else if(!token[2].length())
                        st.Remove(token[1]);
                }

                else if(token[0]=="S")
                {
                    if(!token[1].length())
                        st.EnterScope();
                    else
                    {
                       out<<"	Number of parameters mismatch for the command S\n";
                       //cout<<"	Number of parameters mismatch for the command S\n";
                    }

                }

                else if(token[0]=="E")
                {
                    if(!token[1].length())
                        st.ExitScope();
                    else
                    {
                        out<<"	Number of parameters mismatch for the command E\n";
                        //cout<<"	Number of parameters mismatch for the command E\n";
                    }

                }

                else if(token[0]=="P")
                {
                    if(!token[2].length())
                    {
                        if(token[1]=="A")
                            st.printAllScopeTable();
                        else if(token[1]=="C")
                            st.printCurrentScopeTable();
                    }
                    else if(!token[1].length())
                    {
                         out<<"	Number of parameters mismatch for the command P\n";
                         //cout<<"	Number of parameters mismatch for the command P\n";

                    }
                }

                else if(token[0]=="Q")
                {
                    while(st.getTotalScopeTable())
                    {
                        flag=true;
                        st.ExitScope();
                    }
                    break;
                }
            }

            for(int i=0;i<3;i++)
                token[i]="";

            //out<<myline<<endl;
        }
    }



    out.close();
    in.close();

    return 0;
}

