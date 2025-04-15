:- use_module(library(http/thread_httpd)). 
:- use_module(library(http/http_dispatch)). 
:- use_module(library(http/http_parameters)). 
:- use_module(library(uri)). 
:- use_module(library(http/html_write)).
:- use_module(library(http/html_head)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_server_files)).

:- http_handler(root(processa_pedido), processa, []).
:- http_handler(root(remove_pedido), remove, []).
:- dynamic(nomeCliente/2).
:- dynamic(telCliente/2).

servidor(Porta) :-
    http_server(http_dispatch, [port(Porta)]).

lista_ingredientes([]) --> [].
lista_ingredientes([H|T]) -->
    html([H, br([])]),
    lista_ingredientes(T).

processa(R):- !,
    consult('pedidos.pl'),
    http_parameters(R,[nomeCliente(C,[]),
    telCliente(T,[]),
    emailCliente(E,[]),
    tamanho(S,[]),
    ing(Is, [list(multiple)]),
    tempo(H,[]),
    obs(O,[])
    ]),
    assertz(ped_cliente(C,T,E,S,Is,H,O)),
    tell('pedidos.pl'),
    listing(ped_cliente/7),
    told,
    reply_html_page(
    title('Registro Pizzaria'),
    [ h1('Pedido cadastrado com sucesso!'),
      p(['Nome: ', C]),
      p(['Telefone: ', T]),
      p(['Email: ', E]),
      p(['Tamanho: ', S]),
      p(['Ingredientes: ', \lista_ingredientes(Is)]),
      p(['Tempo de entrega: ', H]),
      p(['Observacoes: ', O])
    ]).

remove(R):- !,
    consult('pedidos.pl'),
    http_parameters(R,[nomeCliente(C,[]),
    telCliente(T,[])
    ]),
    retract(ped_cliente(C,T,_,_,_,_,_)),
    tell('pedidos.pl'),
    listing(ped_cliente/7),
    told,
    reply_html_page(title('Pedido Cancelado!'), 
    [h1('Pedido cancelado com sucesso!')]).

    