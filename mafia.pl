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
% salvarPersona(medico,persona salvada).
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

% Explicar qué conceptos permiten resolver este requerimiento sin la necesidad de armar listas.

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
    rol(Persona,Rol),
    bandoContrario(Contrincante,Rol).
    
%bandoContrario(Contrincante,RolPersona)
bandoContrario(Contrincante,mafia) :-
    rol(Contrincante,Rol),
    Rol\=mafia.

bandoContrario(Contrincante,Rol) :-
    Rol\= mafia,
    rol(Contrincante,mafia).

% PARTE B
   gano(Persona) :-
    not(perdieronLaRonda(Persona,_)),
    forall(contrincantes(Persona,Contrincante),perdieronLaRonda(Contrincante,_)).

% Explicar cómo se relaciona el concepto de inversibilidad con la solución.      (NO es iversible asi)

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




% PUNTO 4

% PARTE A
siguenEnJuego(Persona,RondaNueva) :- 
    not(perdieronLaRonda(Persona,RondaAnterior)), 
    RondaAnterior < RondaNueva.     
         
% Caso de prueba
:- begin_tests(jugadores_siguen_en_juego).
test(jugador_sigue_jugando_aunque_pierda_despues,nondet) :- 
    siguenEnJuego(rafa,2).
test(jugador_que_perdio_antes_no_sigue_jugando,fail) :- 
    siguenEnJuego(nick,4).
test(jugadores_que_llegan_a_la_ultima_ronda,set(Jugadores==[maggie,burns])) :- 
    siguenEnJuego(Jugadores,6).
%Todas las personas en juego juegan la primera ronda.     poner todos asi??
test(todos_los_jugadores_juegan_la_primer_ronda,set(Jugadores==[maggie,burns,homero,bart,tony,nick,hibbert,lisa,rafa])) :- 
    siguenEnJuego(Jugadores,1).
:- end_tests(jugadores_siguen_en_juego).

% PARTE B
% Una ronda es interesante si en dicha ronda siguen más de 7 personas en juego.
rondaInteresante(Ronda) :-
    findall(Persona,siguenEnJuego(Persona,Ronda), PersonasQueSiguen),
    length(PersonasQueSiguen, Cantidad),
    Cantidad > 7.
    
% También es interesante cuando quedan en juego menos o igual cantidad de personas que la cantidad inicial de la mafia.

% Caso de prueba
:- begin_tests(rondas_interesantes).
test(ronda_con_mucha_gente_es_interesante,nondet) :- 
    rondaInteresante(1).
% La última ronda es interesante porque quedan pocas personas.
test(ronda_con_7_personas_en_juego_no_es_interesante,fail) :-
    rondaInteresante(3).
test(rodas_interesantes,set(Rondas==[1,2,6])) :-
    rondaInteresante(Rondas).
:- end_tests(rondas_interesantes).

% PUNTO 5

% PARTE A 

jugadorProfesional(Persona) :- 
contrincantes(Persona,Contrincante),
forall(accionResponsable(Persona,Accion), accionAfectada(Contrincante,Accion)).

accionResponsable(Persona,atacarPersona) :-
     rol(Persona,mafia).
accionResponsable(Persona,salvarPersona) :-
    rol(Persona,medico),
    ronda(_,salvarPersona(_,Persona)).
accionResponsable(Persona,investigarPersona) :-
    rol(Persona,detective),
    ronda(_,investigarPersona(Persona,_)).
accionResponsable(Persona,eliminarPersona) :-
    ronda(_,eliminarPersona(PersonaEliminada)),
    contrincantes(PersonaEliminada,Persona).

accionAfectada(Persona,atacarPersona) :-
    ronda(_,atacarPersona(Persona)).
accionAfectada(Persona,salvarPersona) :-
    ronda(_,salvarPersona(_,Persona)).
accionAfectada(Persona,investigarPersona) :-
    ronda(_,investigarPersona(_,Persona)).
accionAfectada(Persona,eliminarPersona) :-
    ronda(_,eliminaroPersona(Persona)).






