/* ==================================================================
 * Semestrální práce: FITYard (Varianta B)
 * Jazyk: Prolog (SWI)
 *
 * Popis řešení:
 * Implementace agenta ve světě Wumpus World. Agent prozkoumává
 * mřížku 4x4, sbírá předměty, vyhýbá se pastem a skládá bedny,
 * aby dosáhl na klíč.
 * ================================================================== */

% --------------------------------------------------
% 1) Dynamická fakta a stav světa (aktualizovatelné)
% --------------------------------------------------
:- dynamic current_agent_pos/1.     % aktuální souřadnice agenta (X,Y)
:- dynamic carried_item/1.          % co agent nosí (none nebo obj(Nazev, Atributy))
:- dynamic location_of_object/3.    % objekty na mapě: location_of_object(Nazev,(X,Y),A)
:- dynamic is_stacking_completed/1. % příznak: zda byl proveden stack beden v místnosti
:- dynamic has_key_acquired/0.      % příznak: klíč byl sebrán
:- dynamic agent_history/1.         % historie navštívených buněk (seznam)
:- dynamic death_status/0.          % pokud definováno => agent zemřel
:- dynamic observed_area/3.         % paměť nalezených objektů (Nazev, Lokace, Atributy)

% --------------------------------------------------
% 2) Základní nastavení světa a statické překážky
% --------------------------------------------------
map_coord(X,Y) :- between(1,4,X), between(1,4,Y). % pole 4x4

% sousedství (jednokrokový pohyb)
is_adjacent((X1,Y1),(X2,Y2)) :-
    map_coord(X1,Y1), map_coord(X2,Y2),
    ( (X1 = X2, Diff is abs(Y1-Y2), Diff =:= 1)
    ; (Y1 = Y2, Diff is abs(X1-X2), Diff =:= 1) ).

% statické nebezpečí
danger_wumpus((3,3)).
danger_pit((1,4)).
danger_pit((4,1)).

% výchozí rozmístění objektů (id, pozice, seznam atributů)
initial_object_state(big_crate,   (2,2), [size(large),  color(dark), material(wood), weight(heavy)]).
initial_object_state(mid_crate,   (2,3), [size(medium), color(green), material(wood), weight(moderate)]).
initial_object_state(small_crate, (3,2), [size(small),  color(red),   material(wood), weight(light)]).
initial_object_state(power_cell,  (1,2), [size(small),  color(blue),  material(metal), shape(cylinder)]).
initial_object_state(yard_key,    (4,4), [color(gold), size(small), material(metal), shape(unusual)]).
initial_object_state(old_tire,    (2,1), [size(medium), color(grey),  material(rubber), shape(ring)]).

% --------------------------------------------------
% 3) Senzorika — jednoduché detekce prostředí
% --------------------------------------------------
% vánek = sousední jáma
detect_breeze(Room) :- danger_pit(P), is_adjacent(Room,P).
% zápach = sousední Wumpus
detect_stench(Room) :- danger_wumpus(W), is_adjacent(Room,W).

% seznam objektů v aktuální lokaci
items_in_current_room(Items) :- current_agent_pos(Pos), findall(O, location_of_object(O, Pos, _), Items).

% vrátí atributy objektu přítomného v aktuální lokaci
get_object_attributes(Item, Attrs) :- current_agent_pos(Pos), location_of_object(Item, Pos, Attrs).

% rozpoznání typu podle atributů (jednoduché pravidla)
identify_item(Attrs, small_crate) :- member(material(wood),Attrs), member(size(small),Attrs), !.
identify_item(Attrs, mid_crate)   :- member(material(wood),Attrs), member(size(medium),Attrs), !.
identify_item(Attrs, big_crate)   :- member(material(wood),Attrs), member(size(large),Attrs), !.
identify_item(Attrs, power_cell)  :- member(color(blue),Attrs), member(shape(cylinder),Attrs), !.
identify_item(Attrs, yard_key)    :- member(color(gold),Attrs), member(material(metal),Attrs), !.
identify_item(Attrs, old_tire)    :- member(color(grey),Attrs), member(shape(ring),Attrs), !.
identify_item(_, unknown).

% --------------------------------------------------
% 4) Pohyb a manipulace — akce agenta
% --------------------------------------------------
% jednoduchá kontrola, zda je agent naživu
is_agent_alive :- \+ death_status, !.
is_agent_alive :- writeln('CHYBA: Agent je mrtvý.'), fail.

% přesun — pouze mezi sousedy; kontrola pastí/Wumpuse
agent_move(Dest) :-
    is_agent_alive,
    current_agent_pos(Start),
    is_adjacent(Start, Dest),
    map_coord(DX,DY), Dest = (DX,DY),
    ( danger_pit(Dest) -> writeln('Agent spadl do jámy! 💀'), assertz(death_status), fail
    ; danger_wumpus(Dest) -> writeln('Agent narazil na Wumpuse! ☠️'), assertz(death_status), fail
    ; retract(current_agent_pos(Start)), asserta(current_agent_pos(Dest)), update_history(Dest),
      format('Agent se přesunul z ~w do ~w~n',[Start,Dest]), print_status ).

% zaznamenání navštíveného místa (množinový přístup přes seznam)
update_history(Room) :-
    retract(agent_history(H)),
    ( member(Room,H) -> asserta(agent_history(H)) ; asserta(agent_history([Room|H])) ).

% zvednout objekt (pokud ruce prázdné a věc je ve stejné buňce)
agent_pick_up(Item) :-
    is_agent_alive,
    carried_item(none),
    current_agent_pos(Pos),
    location_of_object(Item, Pos, Attrs),
    !,
    retract(carried_item(none)),
    asserta(carried_item(obj(Item,Attrs))),
    retract(location_of_object(Item, Pos, Attrs)),
    retractall(observed_area(Item, Pos, _)),
    format('Agent zvedl: ~w~n',[Item]).

agent_pick_up(_) :- carried_item(obj(N,_)), format('Agent již nese ~w.~n',[N]), fail.
agent_pick_up(Item) :- format('Předmět ~w tu není.~n',[Item]), fail.

% položit to, co nese (na aktuální pozici)
agent_put_down :-
    is_agent_alive,
    carried_item(obj(O,A)),
    current_agent_pos(Pos),
    !,
    retract(carried_item(obj(O,A))), asserta(carried_item(none)),
    asserta(location_of_object(O, Pos, A)),
    retractall(observed_area(O,_,_)), asserta(observed_area(O, Pos, A)),
    format('Agent položil ~w v ~w~n',[O,Pos]).

agent_put_down :- writeln('Nic neneseš.'), fail.

% dobíjení z baterie — nejdřív z ruky, pak ze země
agent_recharge :-
    is_agent_alive,
    ( carried_item(obj(power_cell,_)) -> retract(carried_item(obj(power_cell,_))), asserta(carried_item(none)),
        writeln('Dobití z nesené baterie (spotřebována).')
    ; current_agent_pos(Pos), location_of_object(power_cell, Pos, Attr) -> retract(location_of_object(power_cell, Pos, Attr)), retractall(observed_area(power_cell, Pos, _)), writeln('Dobito z baterie na zemi.')
    ; writeln('Žádná baterie v dosahu.'), fail ).

% pomocná operace: položení na jiný objekt (debug)
agent_place_on(Target) :-
    is_agent_alive,
    carried_item(obj(Item,_)),
    current_agent_pos(Pos),
    location_of_object(Target, Pos, _),
    format('DEBUG: Položeno ~w na ~w.~n',[Item,Target]).

% --------------------------------------------------
% 5) Skládání beden a získání klíče (řešení úkolu)
% --------------------------------------------------
attempt_crate_stack :-
    is_agent_alive,
    current_agent_pos(Room),
    location_of_object(B1, Room, A1), identify_item(A1, big_crate),
    location_of_object(B2, Room, A2), identify_item(A2, mid_crate),
    location_of_object(B3, Room, A3), identify_item(A3, small_crate),
    B1 \= B2, B1 \= B3, B2 \= B3,
    !,
    retract(location_of_object(B1, Room, A1)), retractall(observed_area(B1,Room,_)),
    retract(location_of_object(B2, Room, A2)), retractall(observed_area(B2,Room,_)),
    retract(location_of_object(B3, Room, A3)), retractall(observed_area(B3,Room,_)),
    assertz(is_stacking_completed(Room)),
    writeln('Stack: bedny úspěšně složeny (velká->střední->malá).'),
    agent_grab_key(Room).

attempt_crate_stack :- writeln('Nelze postavit schody — chybí bedny.' ).

% zkusit sebrat klíč (pokud jsme ve stejné buňce a ruce volné)
agent_grab_key(Room) :-
    is_agent_alive,
    current_agent_pos(Room),
    location_of_object(K, Room, AK), identify_item(AK, yard_key),
    carried_item(none),
    !,
    retract(location_of_object(K, Room, AK)), retract(carried_item(none)), asserta(carried_item(obj(K,AK))),
    assertz(has_key_acquired), writeln('Klíč získán — úspěch!').

agent_grab_key(_) :- carried_item(obj(N,_)), format('Nelze vzít klíč, nesu ~w.~n',[N]), fail.
agent_grab_key(_) :- writeln('Klíč tady není.'), fail.

% --------------------------------------------------
% 6) Paměť, plánování a procházení známých míst
% --------------------------------------------------
process_sensor_data :-
    current_agent_pos(Pos),
    findall((O,Attr), location_of_object(O, Pos, Attr), Pairs),
    forall(member((O,Attr),Pairs), ( observed_area(O, Pos, Attr) -> true ; asserta(observed_area(O, Pos, Attr)) ) ).

% nalezení cesty v grafu navštívených buněk (DFS přes známé body)
find_known_path(S,E,Path) :- travel_known(S,E,[S],Q), reverse(Q,Path).

travel_known(A,B,P,[B|P]) :- is_adjacent(A,B), agent_history(H), member(B,H).
travel_known(A,B,Visited,Path) :-
    is_adjacent(A,C), agent_history(H), member(C,H), C \= B, \+ member(C,Visited), travel_known(C,B,[C|Visited],Path).

execute_move_sequence([]).
execute_move_sequence([_]).
execute_move_sequence([From,To|Rest]) :- agent_move(To), From \= To, execute_move_sequence([To|Rest]).

go_to_known_location(Target) :- current_agent_pos(Target), !, writeln('Agent již v cíli.').
go_to_known_location(Target) :- current_agent_pos(Start), ( find_known_path(Start, Target, Path) -> format('Trasa: ~w~n',[Path]), execute_move_sequence(Path) ; format('Neznámá cesta z ~w do ~w.~n',[Start,Target]), fail ).

% --------------------------------------------------
% 7) Diagnostika, reset a hlavní skript
% --------------------------------------------------
print_status :-
    current_agent_pos(Pos), carried_item(Car), agent_history(H),
    ( Car = none -> Item = none ; Car = obj(N,_) -> Item = N ; Item = Car ),
    format('--- STAV ---~nPozice: ~w | Nese: ~w~nNavštíveno: ~w~n',[Pos,Item,H]),
    ( detect_breeze(Pos) -> writeln('Senzor: Vánek') ; true ),
    ( detect_stench(Pos) -> writeln('Senzor: Zápach') ; true ),
    items_in_current_room(Obs), length(Obs,N), format('Předmětů: ~w~n',[N]),
    ( Obs = [] -> writeln('Žádné předměty zde.') ; format('Obsah: ~w~n',[Obs]),
      findall((O,Id),( member(O,Obs), get_object_attributes(O,Attrs), identify_item(Attrs,Id) ), P), format('Rozpoznáno: ~w~n',[P]) ),
    writeln('--------------'), process_sensor_data.

reinitialize_world :-
    retractall(has_key_acquired), retractall(death_status), retractall(location_of_object(_,_,_)), retractall(current_agent_pos(_)), retractall(carried_item(_)), retractall(is_stacking_completed(_)), retractall(agent_history(_)), retractall(observed_area(_,_,_)),
    asserta(current_agent_pos((1,1))), asserta(carried_item(none)), asserta(agent_history([(1,1)])),
    forall(initial_object_state(N,P,A), asserta(location_of_object(N,P,A))), writeln('Svět resetován.').

% jednoduchý demonstrační plán (sekvence tahů)
agent_plan :-
    reinitialize_world,
    writeln('--- START PLÁNU ---'), print_status,
    agent_move((1,2)), agent_pick_up(power_cell), agent_recharge,
    agent_move((2,2)), agent_pick_up(big_crate),
    agent_move((3,2)), agent_move((4,2)), agent_move((4,3)), agent_move((4,4)), agent_put_down,
    agent_move((3,4)), agent_move((2,4)), agent_move((2,3)), agent_pick_up(mid_crate),
    go_to_known_location((4,4)), agent_put_down,
    go_to_known_location((3,2)), agent_pick_up(small_crate),
    go_to_known_location((4,4)), agent_put_down,
    attempt_crate_stack,
    ( has_key_acquired -> writeln('Mise splněna: klíč v držení.') ; writeln('Mise neúspěšná.') ),
    writeln('--- KONEC PLÁNU ---').
