% sangre(Mago, Sangre).
sangre(harry, mestiza).
sangre(draco, pura).
sangre(hermione, impura).

% caracteristicas(Mago, Caracteristicas).
caracteristicas(harry, [coraje, amistad, orgullo, inteligencia]).
caracteristicas(draco, [orgullo, inteligencia]).
caracteristicas(hermione, [responsabilidad, orgullo, inteligencia]).

% odia(Mago, Casa).
odia(harry, slytherin).
odia(draco, hufflepuff).

% apropiado(Casa, Caracteristica).
apropiado(gryffindor, coraje).
apropiado(slytherin, orgullo).
apropiado(slytherin, inteligencia).
apropiado(ravenclaw, inteligencia).
apropiado(ravenclaw, responsabilidad).
apropiado(hufflepuff, amistad).

/*
1. Saber si una casa permite entrar a un mago, lo cual se cumple 
para cualquier mago y cualquier casa excepto en el caso 
de Slytherin, que no permite entrar a magos de sangre impura.
*/

% permiteEntrar(Casa, Mago).

mago(Mago):-
    sangre(Mago, _).

permiteEntrar(Casa, Mago):-
    mago(Mago),
    apropiado(Casa, _),
    Casa \= slytherin.

permiteEntrar(slytherin, Mago):-
    mago(Mago),
    not(sangre(Mago, impura)).

/*
2. Saber si un mago tiene el carácter apropiado para una casa, lo cual se cumple para cualquier mago 
si sus características incluyen todo lo que se busca para los integrantes de esa 
casa, independientemente de si la casa le permite la entrada.
*/

% caracterApropiado(Mago, Casa).
casa(Casa):-
    apropiado(Casa, _).

caracterApropiado(Mago, Casa):-
    casa(Casa),
    caracteristicas(Mago, CaracteristicasMago),
    forall(apropiado(Casa, CaracteristicaCasa), member(CaracteristicaCasa, CaracteristicasMago)).

/*
3. Determinar en qué casa podría quedar seleccionado un mago sabiendo que 
tiene que tener el carácter adecuado para la casa, 
la casa permite su entrada y además el mago no odiaría que lo manden a esa casa. 
Además Hermione puede quedar seleccionada en Gryffindor, 
porque al parecer encontró una forma de hackear al sombrero.
*/

puedeSerSeleccionado(Mago, Casa):-
    caracterApropiado(Mago, Casa),
    permiteEntrar(Casa, Mago),
    not(odia(Mago, Casa)).

puedeSerSeleccionado(hermione, gryffindor).

/*
4. Definir un predicado cadenaDeAmistades/1 que se cumple para una lista de magos si todos ellos 
se caracterizan por ser amistosos y cada uno podría estar en la misma casa que el siguiente. 
No hace falta que sea inversible, se consultará de forma individual.
*/

cadenaDeAmistades(ListaMagos):-
    todosAmistosos(ListaMagos),
    puedeEstarEnCasaDelSiguiente(ListaMagos).

todosAmistosos(ListaMagos):-
    forall((member(Mago, ListaMagos), caracteristicas(Mago, CaracteristicasMago)) , (member(amistad, CaracteristicasMago))).

puedeEstarEnCasaDelSiguiente(ListaMagos):-
    forall(sonConsecutivos(Mago, SiguienteMago, ListaMagos), (puedeSerSeleccionado(Mago, Casa), puedeSerSeleccionado(SiguienteMago, Casa))).

sonConsecutivos(Mago, SiguienteMago, Magos):-
    nth1(Indice, Magos, Mago),
    nth1(IndiceSiguiente, Magos, SiguienteMago),
    IndiceSiguiente is Indice + 1.
    

% nth1 lo uso para obtener el indice de cada mago particular en la lista. Si se cumple que uno es el siguiente del otro son consecutivos.

/*
A lo largo del año los alumnos pueden ganar o perder puntos para su casa en base a las buenas y malas acciones 
realizadas, y cuando termina el año se anuncia el ganador de la copa. 
Sobre las acciones que impactan al puntaje actualmente tenemos la siguiente información:
- Malas acciones: son andar de noche fuera de la cama (que resta 50 puntos) o ir a lugares prohibidos. 
La cantidad de puntos que se resta por ir a un lugar prohibido se indicará para cada lugar. 
Ir a un lugar que no está prohibido no afecta al puntaje.
- Buenas acciones: son reconocidas por los profesores y prefectos individualmente y el puntaje se indicará para cada acción premiada.
*/

esDe(hermione, gryffindor).
esDe(ron, gryffindor).
esDe(harry, gryffindor).
esDe(draco, slytherin).
esDe(luna, ravenclaw).

accion(harry, [andarFueraDeCama]).
accion(hermione, [irAlTercerPiso, irASeccionProhibidaBiblioteca]).
accion(harry, [irAlBosque, irASeccionProhibidaBiblioteca]).
accion(draco, [irAMazmorras]).
accion(ron, [ganarAjedrezMagico]).
accion(hermione, [salvarAmigos]).
accion(harry, [ganarAVoldemort]).

puntajeLugar(irAlBosque, -50).
puntajeLugar(irASeccionProhibidaBiblioteca, -10).
puntajeLugar(irAlTercerPiso, -75).
puntajeLugar(ganarAjedrezMagico, 50).
puntajeLugar(salvarAmigos, 50).
puntajeLugar(ganarAVoldemort, 60).

/*
1. Saber si un mago es buen alumno, que se cumple si hizo alguna acción y ninguna de 
las cosas que hizo se considera una mala acción (que son aquellas que provocan un puntaje negativo).
*/

malaAccion(Accion):-
    puntajeLugar(Accion, Puntaje),
    Puntaje < 0.

esBuenAlumno(Mago):-
    esDe(Mago, _),
    forall((accion(Mago, Acciones), member(Accion, Acciones)), not(malaAccion(Accion))).
    
/*
2. Saber si una acción es recurrente, que se cumple si más de un mago hizo esa misma acción.
*/

accionRecurrente(Accion):-
    accion(Mago, ListaAcciones),
    accion(OtroMago, OtraListaAcciones),
    member(Accion, ListaAcciones),
    member(Accion, OtraListaAcciones),
    Mago \= OtroMago.

/*
3. Saber cuál es el puntaje total de una casa, que es la suma de los puntos obtenidos por sus miembros.
*/

obtenerPuntajeCasa(Casa, Puntaje):-
    findall(PuntajeMago, (esDe(Mago, Casa), obtenerPuntaje(Mago, PuntajeMago)), PuntajesCasa),
    sumlist(PuntajesCasa, Puntaje).


obtenerPuntaje(Mago, Puntaje):-
    findall(ListaAcciones, accion(Mago, ListaAcciones), GranLista),
    flatten(GranLista, Acciones),
    puntajesPersonajeAcciones(Acciones, ListaPuntajes),
    sumlist(ListaPuntajes, PuntajeAcciones),
    obtenerPuntajePreguntasMago(Mago, PuntajePreguntas),
    Puntaje is PuntajeAcciones + PuntajePreguntas.

puntajesPersonajeAcciones(Acciones, Puntajes):-
    findall(Puntaje, (member(Accion, Acciones), puntajeLugar(Accion, Puntaje)), Puntajes).

/*
4. Saber cuál es la casa ganadora de la copa, que se verifica para aquella casa que haya obtenido una cantidad 
mayor de puntos que todas las otras.
*/

casaGanadora(Casa):-
    esDe(_, Casa),
    obtenerPuntajeCasa(Casa, Puntaje),
    forall((esDe(_, OtraCasa), Casa \= OtraCasa), (obtenerPuntajeCasa(OtraCasa, OtroPuntaje), Puntaje > OtroPuntaje)).

/*
5. Queremos agregar la posibilidad de ganar puntos por responder preguntas en clase. 
    La información que nos interesa de las respuestas en clase son: cuál fue la pregunta, cuál es la dificultad de la pregunta 
    y qué profesor la hizo.
*/

/*
Por ejemplo, sabemos que Hermione respondió a la pregunta de dónde se 
encuentra un Bezoar, de dificultad 20, realizada por el profesor Snape, 
y cómo hacer levitar una pluma, de dificultad 25, 
realizada por el profesor Flitwick. 
Modificar lo que sea necesario para que este agregado funcione con lo desarrollado 
hasta ahora, teniendo en cuenta que los puntos que se otorgan equivalen a 
la dificultad de la pregunta, a menos que la haya hecho Snape, que da 
la mitad de puntos en relación a la dificultad de la pregunta.
*/

pregunta(hermione, dondeSeEncuentraUnBezoar, 20, snape).
pregunta(hermione, comoHacerLevitarUnaPluma, 25, flitwick).

obtenerPuntajePregunta(Mago, Pregunta, Puntaje):-
    pregunta(Mago, Pregunta, Dificultad, snape),
    Puntaje is Dificultad / 2.

obtenerPuntajePregunta(Mago, Pregunta, Puntaje):-
    pregunta(Mago, Pregunta, Dificultad, Profesor),
    Profesor \= snape,
    Puntaje is Dificultad.

obtenerPuntajePreguntasMago(Mago, PuntajeFinal):-
    findall(Pregunta, pregunta(Mago, Pregunta, _, _), Preguntas),
    findall(Puntaje, (member(Pregunta, Preguntas), obtenerPuntajePregunta(Mago, Pregunta, Puntaje)), Puntajes),
    sumlist(Puntajes, PuntajeFinal).