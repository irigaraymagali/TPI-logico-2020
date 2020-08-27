
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
% atacarPersona(persona atacada).
% salvarPersona(medico, persona salvada).
% investigarPersona(detective, persona).
% eliminarPersona(persona eliminada).

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

% PARTE B
perdieronLaRonda(Persona,Ronda) :-
    ronda(Ronda,eliminarPersona(Persona)).

perdieronLaRonda(Persona,Ronda) :-
    ronda(Ronda,atacarPersona(Persona)),
    not(ronda(Ronda,salvarPersona(_,Persona))).

% Los conceptos que permiten resolver este requerimiento sin la necesidad de armar listas,
% son pattern matching ya que se buscan todos los individuos que satisfacen un predicado, 
% inversibilidad ya que nos permite hacer consultas existenciales ademas de functores, que nos permite 
% agrupar informacion relacionada como las personas involucradas en las direfentes acciones de las rondas.

% Caso de prueba
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


%  PUNTO 2

% PARTE A
contrincantes(Persona,Contrincante) :-
        bandoContrario(Persona,Contrincante).
        
bandoContrario(Persona,Contrincante) :-
    rol(Persona,RolPersona),
    rol(Contrincante,RolContrincante),
    contrario(RolPersona,RolContrincante).

contrario(mafia,RolContrincante):-
    RolContrincante \= mafia.

contrario(RolPersona,mafia) :-
    RolPersona \= mafia.

% PARTE B
   gano(Persona) :-
    rol(Persona,_),
    not(perdieronLaRonda(Persona,_)),
    forall(contrincantes(Persona,Contrincante),perdieronLaRonda(Contrincante,_)).

% El predicado "gano" es inversible ya que admite consultas existenciales, es decir con variables libres para sus argumentos.
% Porque la persona esta ligada.
%     ?- gano(_).
%        true 
%     ?- gano(Persona).
%        Persona = maggie ;
%        false.
   

% Caso de prueba
:- begin_tests(jugadores_contrincantes).
test(contrincantes_de_la_mafia,set(Contrincante==[homero,burns,nick,hibbert,lisa,rafa])) :- 
    contrincantes(tony,Contrincante).
test(contrincantes_del_otro_bando,set(Contrincante==[bart,tony,maggie])) :- 
    contrincantes(homero,Contrincante).
:- end_tests(jugadores_contrincantes).

:- begin_tests(jugadores_ganadores).
test(maggie_es_la_unica_ganadora,nondet) :- 
    gano(maggie).
:- end_tests(jugadores_ganadores).

% Punto 3
% Parte A

esImbatible(Medico):-
    rol(Medico, medico),
    forall(ronda(Ronda, salvarUnaPersona(PersonaAtacada, Medico)),ronda(Ronda, atacarUnaPersona(PersonaAtacada))).

esImbatible(Detective):-
    rol(Detective, detective),
    forall(rol(Persona, mafia), ronda(_, investigarUnaPersona(Persona, Detective))).


% PUNTO 4

% PARTE A     
siguenEnJuego(Persona,1) :-
    rol(Persona,_).

siguenEnJuego(Persona,RondaNueva) :- 
    rol(Persona,_),
    RondaNueva > 1,
    RondaAnterior is RondaNueva - 1,
    not(perdieronLaRonda(Persona,RondaAnterior)),
    siguenEnJuego(Persona,RondaAnterior).
         
% Caso de prueba
:- begin_tests(jugadores_siguen_en_juego).
test(jugador_sigue_jugando_aunque_pierda_despues,nondet) :- 
    siguenEnJuego(rafa,2).
test(jugador_que_perdio_antes_no_sigue_jugando,fail) :- 
    siguenEnJuego(nick,4).
test(jugadores_que_llegan_a_la_ultima_ronda,set(Jugadores==[maggie,burns])) :- 
    siguenEnJuego(Jugadores,6).
test(todos_los_jugadores_juegan_la_primer_ronda,set(Jugadores==[maggie,burns,homero,bart,tony,nick,hibbert,lisa,rafa])) :- 
    siguenEnJuego(Jugadores,1).
:- end_tests(jugadores_siguen_en_juego).

% PARTE B
rondaInteresante(Ronda) :-
    ronda(Ronda,_),
    cantidadPersonasQueSiguen(Ronda,Cantidad),
    Cantidad > 7.

rondaInteresante(Ronda) :-
    ronda(Ronda,_),
    cantidadPersonasQueSiguen(Ronda,CantidadPersonas),
    cantidadMafiososInicial(_,CantidadInicialMafia),
    CantidadPersonas =< CantidadInicialMafia.

cantidadPersonasQueSiguen(Ronda,CantidadPersonas) :-
    findall(Persona,siguenEnJuego(Persona,Ronda), PersonasQueSiguen),
    length(PersonasQueSiguen, CantidadPersonas).

cantidadMafiososInicial(Persona,CantidadInicialMafia) :-
    findall(Persona,rol(Persona,mafia),Mafiosos),
    length(Mafiosos, CantidadInicialMafia).

% Caso de prueba.
:- begin_tests(rondas_interesantes).
test(ronda_con_mucha_gente_es_interesante,nondet) :- 
    rondaInteresante(1).
test(ronda_con_7_personas_en_juego_no_es_interesante,fail) :-
    rondaInteresante(3).
test(todas_las_rondas_interesantes,set(Rondas==[1,2,6])) :-
    rondaInteresante(Rondas).
:- end_tests(rondas_interesantes).

% Parte C

vivieronElPeligro(Persona):-
    jugoRondaPeligrosa(Persona,_).

jugoRondaPeligrosa(Persona, NumeroDeRonda):-
    siguenEnJuego(Persona, NumeroDeRonda),
    cantidadNoCiviles(CantidadNoCiviles, NumeroDeRonda),
    cantidadDeCiviles(CantidadCiviles),
    CantidadNoCiviles is CantidadCiviles * 3.

cantidadNoCiviles(CantidadNoCiviles, NumeroDeRonda):-
  findall(Persona, (siguenEnJuego(Persona, NumeroDeRonda), noEsCivil(Persona)), PersonasNoCiviles),
  length(PersonasNoCiviles, CantidadNoCiviles).
  
cantidadDeCiviles(CantidadCiviles):-
    findall(Persona, (siguenEnJuego(Persona, 1), rol(Persona, civil)), Civiles),
    length(Civiles, CantidadCiviles).

noEsCivil(Persona):-
    rol(Persona, Rol),
    Rol\=civil.


% PUNTO 5

% PARTE A 
jugadorProfesional(Persona) :- 
    rol(Persona,_),
    contrincantes(Persona,Contrincante),
    forall(accionAfectada(Contrincante,Accion),accionResponsable(Persona,Accion)).

accionResponsable(Persona,atacarPersona(_)) :-
     rol(Persona,mafia).
accionResponsable(Persona,salvarPersona(Persona,_)) :-
    rol(Persona,medico),
    ronda(_,salvarPersona(Persona,_)).
accionResponsable(Persona,investigarPersona(Persona,_)) :-
    rol(Persona,detective),
    ronda(_,investigarPersona(Persona,_)). 
accionResponsable(Persona,eliminarPersona(PersonaEliminada)) :-
    ronda(_,eliminarPersona(PersonaEliminada)),
    contrincantes(PersonaEliminada,Persona).

accionAfectada(Persona,atacarPersona(Persona)) :-
    ronda(_,atacarPersona(Persona)).
accionAfectada(Persona,salvarPersona(_,Persona)) :-
    ronda(_,salvarPersona(_,Persona)).
accionAfectada(Persona,investigarPersona(_,Persona)) :-
    ronda(_,investigarPersona(_,Persona)).
accionAfectada(Persona,eliminarPersona(Persona)) :-
    ronda(_,eliminaroPersona(Persona)).

% Caso de prueba.
:- begin_tests(jugador_profesional).
test(jugadores_profesionales,set(Jugadores==[bart,tony,maggie,lisa,rafa])) :- 
    jugadorProfesional(Jugadores).
:- end_tests(jugador_profesional).


% PARTE B  
estrategiaDesenvuelta(Estrategia) :-         % Estrategia = ListaDeAcciones 
    estrategiaEstaEncadenada(1,Estrategia).

% La persona afectada por la acción anterior es la responsable de la siguiente.
estrategiaEstaEncadenada(Ronda,[AccionRonda1,AccionRonda2|AccionesRondasSiguientes]) :-  
    accionAfectada(Persona,AccionRonda1),
    accionResponsable(Persona,AccionRonda2),
    RondaSiguiente is Ronda +1,
    estrategiaEstaEncadenada(RondaSiguiente,[AccionRonda2|AccionesRondasSiguientes]).

estrategiaEstaEncadenada(UltimaRonda,[AccionUltimaRonda]) :-
    ronda(UltimaRonda,AccionUltimaRonda),
    accionAfectada(_,AccionUltimaRonda).     

% Caso de prueba.
:- begin_tests(estrategia_desenvuelta).
test(estrategia_desenvuelta,nondet) :- 
    estrategiaDesenvuelta([atacarPersona(lisa),investigarPersona(lisa,bart),atacarPersona(lisa),investigarPersona(lisa,homero),eliminarPersona(bart),atacarPersona(burns)]).
:- end_tests(estrategia_desenvuelta).

% 1)La mafia ataca a Lisa.
% 2)Lisa investiga a Bart.
% 3)La mafia vuelve a atacar a Lisa.
% 4)Lisa investiga a Homero.
% 5)Bart es eliminado. 
% 6)La mafia ataca a Burns. 
