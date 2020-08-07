% rol(Persona, Rol).
rol(homero, civil).
rol(burns, civil).
rol(bart, mafia).
rol(tony, mafia).
rol(maggie, mafia).
rol(nick, medico).
rol(hibbert, medico).
rol(lisa, detective).
rol(rafa, detective).

% Acciones:
atacarPersona(PersonaAtacada).
salvarPersona(Medico,PersonaSalvada).
investigarPersona(Detective, Persona).
eliminarPersona(PersonaEliminada).

% ronda (num de ronda, accion)
ronda(1,atacarPersona(lisa)).
ronda(1,salvarPersona(nick,nick)).
ronda(1,salvarPersona(hibbert,lisa)).
ronda(1,investigarPersona(lisa,tony)).
ronda(1,investigarPersona(rafa,lisa)).
ronda(1,eliminarPersona(nick)).
ronda(1,eliminarPersona(nick)).

ronda(2,atacarPersona(rafa)).
ronda(2,salvarPersona(hibbert,rafa)).
ronda(2,investigarPersona(lisa,bart)).
ronda(2,investigarPersona(rafa,maggie)).
ronda(2,eliminarPersona(rafa)).

ronda(3,atacarPersona(lisa)).
ronda(3,salvarPersona(hibbert,lisa)).
ronda(3,investigarPersona(lisa,burns)).
ronda(3,eliminarPersona(hibbert)).

ronda(4,atacarPersona(homero)).
ronda(4,investigarPersona(lisa,homero)).
ronda(4,eliminarPersona(tony)).

ronda(5,atacarPersona(lisa)).
ronda(5,investigarPersona(lisa,maggie)).
ronda(5,eliminarPersona(bart)).

ronda(6,atacarPersona(burns)).

%Parte B
perdieronLaRonda(Persona,Ronda) :-
    ronda(Ronda,eliminarPersona(Persona)).

perdieronLaRonda(Persona,Ronda) :-
    ronda(Ronda,atacarPersona(Persona)),
    not(ronda(Ronda,salvarPersona(_,Persona))).

% Explicar qué conceptos permiten resolver este requerimiento sin la necesidad de armar listas.


% %Caso de prueba
:- begin_tests(perdieron_la_ronda).
test(jugador_eliminado_pierde_esa_ronda,nondet) :- 
    perdieronLaRonda(nick,1).
test(jugador_atacado_y_no_salvado_pierde_esa_ronda,nondet) :- 
    perdieronLaRonda(homero,4).
test(jugador_atacado_y_salvado_no_pierde_esa_ronda,fail) :- 
    perdieronLaRonda(lisa,1).
test(jugador_salvado_pero_eliminado_pierde_esa_ronda,nondet) :- 
    perdieronLaRonda(rafa,2).
test(jugador_no_eliminado_ni_atacado_no_pierde_esa_ronda,fail) :- 
    perdieronLaRonda(maggie,_).
test(jugadores_que_pierden_la_ronda,set(Persona==[bart,lisa])) :- 
    perdieronLaRonda(Persona,5).
:- end_tests(perdieron_la_ronda).


