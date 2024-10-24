%{
    #include "../ast/ast.h"
    #include "avial.tab.h"
%}

%%

"function"              {return FUNCTION;}
"return"                {return RETURN;}        
"int"                   {return INT;}
"if"                    {return IF;}
"forall"                {return FORALL;}
"for"                   {return FOR;}
"Graph"                 {return GRAPH;}


"{"                     {return LCURLY;}
"}"                     {return RCURLY;}
"("                     {return LPAREN;}
")"                     {return RPAREN;} 
"<"                     {return LT;}
">"                     {return GT;}
"="                     {return EQUAL;}
";"                     {return SEMICLN;}
"."                     {return DOT;}
"in"                    {return IN;}
","                     {return COMMA;}
"+="                    {return PLUSEQUAL;}

[ \t\n]+                ;

[a-zA-Z_][a-zA-Z0-9_]*  {return IDENTIFIER;}
[0-9]*                  {return NUMBER;}

%%

int yywrap(void)
{
    return 1;
}


void yyerror(const char* s) {
    fprintf(stderr, "Error: %s\n", s);
}