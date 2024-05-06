% Definizione dei dati

% Definizione delle classi e del numero di studenti
enum Classe = {Classe1A, Classe1B};

% Definizione dei professori
enum Professore = {Rossi, Ravera, Rota, Merelli, Carrara, Ferrari, Russo};

% Definizione dei giorni e delle ore
enum Giorno = {Lun, Mar, Mer, Gio, Ven, Sab};
enum Ora = {h8_9, h9_10, h10_11, h11_12, h12_13};

% Definizione delle materie e delle ore
enum Materia = {Italiano, StoriaArte, Storia, Geografia, Inglese, Francese, Matematica, Scienze, Tecnologia, Ginnastica, Musica};
array[Professore] of set of Materia: materieInsegnate = 
    [ {Italiano, StoriaArte},            % Rossi insegna Italiano, StoriaArte
      {Storia, Geografia},               % Ravera insegna Storia e Geografia
      {Inglese, Francese},               % Rota insegna Inglese e Francese
      {Matematica, Scienze},             % Merelli insegna Matematica e Scienze
      {Tecnologia},                      % Carrara insegna Tecnologia
      {Ginnastica},                      % Ferrari insegna Ginnastica
      {Musica}                           % Russo insegna Musica
    ];    
array[Materia] of Professore: professoreCheInsegna =
[Rossi, Rossi, Ravera, Ravera, Rota, Rota, Merelli, Merelli, Carrara, Ferrari, Russo];
array[Materia] of int: oreMaterie = [5, 2, 3, 2, 3, 3, 3, 3, 2, 2, 2];


% Definizione dei vincoli di tempo per i professori
array[Professore, Giorno, Ora] of var bool: disponibilitaProfessore;

% Inizializzazione dei vincoli di tempo per i professori
constraint forall(p in Professore, g in Giorno, o in Ora)(
    if p == Rossi then
        if g == Lun then
            disponibilitaProfessore[p, g, o] = false
        else
            disponibilitaProfessore[p, g, o] = true
        endif
    elseif p == Ravera then
        if o = h8_9 \/ o = h9_10 then
            disponibilitaProfessore[p, g, o] = false
        else
            disponibilitaProfessore[p, g, o] = true
        endif
    elseif p == Rota then
        if o = h10_11 \/ o = h11_12 \/ o = h12_13 then
            disponibilitaProfessore[p, g, o] = false
        else
            disponibilitaProfessore[p, g, o] = true
        endif
    elseif p == Merelli then
        if g = Mar \/ g = Gio \/ g = Sab then
            disponibilitaProfessore[p, g, o] = false
        else
            disponibilitaProfessore[p, g, o] = true
        endif
    elseif p == Carrara then
        if g == Gio then
            disponibilitaProfessore[p, g, o] = true
        else
            disponibilitaProfessore[p, g, o] = false
        endif
    elseif p == Ferrari then
        if g == Mar then
            disponibilitaProfessore[p, g, o] = true
        else
            disponibilitaProfessore[p, g, o] = false
        endif
    elseif p == Russo then
        if g == Lun then
            disponibilitaProfessore[p, g, o] = true
        else
            disponibilitaProfessore[p, g, o] = false
        endif
    else
        disponibilitaProfessore[p, g, o] = false
    endif
);

% Assegnamento delle lezioni
array[Classe, Ora, Giorno] of var Materia: orarioLezioni;

constraint forall(c in Classe, p in Professore, g in Giorno, o in Ora) (
  if disponibilitaProfessore[p, g, o] == false then
    forall(m in materieInsegnate[p]) (
      orarioLezioni[c, o, g] != m
      )
endif
);

%Definizione dei vincoli sulle ore totali per materia
constraint forall(c in Classe, m in Materia)(
    sum(o in Ora, g in Giorno)(orarioLezioni[c, o, g] == m) == oreMaterie[m]
    );
    
% Vincoli di consistenza
constraint forall(o in Ora, g in Giorno)(
    professoreCheInsegna[orarioLezioni[Classe1A, o, g]] != professoreCheInsegna[orarioLezioni[Classe1B, o, g]]
);

%PARTE SULLE AULE
array[Classe] of int: numeroStudenti;

% Definizione delle aule e delle capacità
enum Aula = {AulaA, AulaB, LabInformatica1, LabInformatica2, Palestra, AulaMusica};
array[Aula] of int: capacitaAula = [40, 40, 20, 20, 50, 40];

% Definizione delle capacità delle aule utilizzate durante le ore di Tecnologia
array[Classe, Ora, Giorno] of var int: occupazioneLabInformatica1;
array[Classe, Ora, Giorno] of var int: occupazioneLabInformatica2;
% Definizione delle capacità della palestra utilizzata durante le ore di Ginnastica
array[Classe, Ora, Giorno] of var int: occupazionePalestra;
% Definizione delle capacità dell'aula di Musica utilizzata durante le ore di Musica
array[Classe, Ora, Giorno] of var int: occupazioneAulaMusica;
% Definizione delle capacità delle aula ordinarie
array[Classe, Ora, Giorno] of var int: occupazioneAulaA;
array[Classe, Ora, Giorno] of var int: occupazioneAulaB;

% Vincoli
constraint forall(c in Classe, o in Ora, g in Giorno where orarioLezioni[c, o, g] != Musica /\ orarioLezioni[c, o, g] != Tecnologia /\ orarioLezioni[c, o, g] != Ginnastica)(
    occupazioneLabInformatica1[c, o, g] = 0
    /\ occupazioneLabInformatica2[c, o, g] = 0
    /\ occupazioneAulaMusica[c, o, g] = 0
    /\ occupazionePalestra[c, o, g] = 0
    /\ if c == Classe1A then occupazioneAulaA[c, o, g] = numeroStudenti[c]
    else occupazioneAulaB[c, o, g] = numeroStudenti[c]
    endif
);

% Vincoli di capacità delle aule
constraint forall(c in Classe, o in Ora, g in Giorno where orarioLezioni[c, o, g] == Tecnologia)(
    occupazioneAulaMusica[c, o, g] = 0
    /\ occupazionePalestra[c, o, g] = 0
    /\
    if numeroStudenti[c] <= capacitaAula[LabInformatica1] then
        occupazioneLabInformatica1[c, o, g] = numeroStudenti[c]
        /\ occupazioneLabInformatica2[c, o, g] = 0
    else
        occupazioneLabInformatica1[c, o, g] = capacitaAula[LabInformatica1]
        /\ occupazioneLabInformatica2[c, o, g] = numeroStudenti[c] - 20
    endif
    /\
    if c == Classe1A then occupazioneAulaA[c, o, g] = 0
    else occupazioneAulaB[c, o, g] = 0
    endif
);

constraint forall(c in Classe, o in Ora, g in Giorno where orarioLezioni[c, o, g] == Ginnastica)(
    occupazioneLabInformatica1[c, o, g] = 0
    /\ occupazioneLabInformatica2[c, o, g] = 0
    /\ occupazioneAulaMusica[c, o, g] = 0
    /\
    if numeroStudenti[c] <= capacitaAula[Palestra] then
        occupazionePalestra[c, o, g] = numeroStudenti[c]
    else
        occupazionePalestra[c, o, g] = capacitaAula[Palestra]
    endif
    /\
    if c == Classe1A then occupazioneAulaA[c, o, g] = 0
    else occupazioneAulaB[c, o, g] = 0
    endif
);

constraint forall(c in Classe, o in Ora, g in Giorno where orarioLezioni[c, o, g] == Musica)(
    occupazioneLabInformatica1[c, o, g] = 0
    /\ occupazioneLabInformatica2[c, o, g] = 0
    /\ occupazionePalestra[c, o, g] = 0
    /\
    if numeroStudenti[c] <= capacitaAula[AulaMusica] then
        occupazioneAulaMusica[c, o, g] = numeroStudenti[c]
    else
        occupazioneAulaMusica[c, o, g] = capacitaAula[AulaMusica]
    endif
    /\
    if c == Classe1A then occupazioneAulaA[c, o, g] = 0
    else occupazioneAulaB[c, o, g] = 0
    endif
);

solve satisfy;


% Stampare l'orario professori per la Classe1A
output ["Orario professori per Classe1A:\n"] ++
["\t" ++ show(g) ++ "\t" | g in Giorno] ++
[ "\n" ++ show(o) ++ "\t" ++ 
%concat([show(orarioLezioni[Classe1A, o, g]) ++ if string_length(show(orarioLezioni[Classe1A, o, g])) < 8 then "\t\t" else "\t" endif | g in Giorno]) ++ "\n" | o in Ora]
concat([show(orarioLezioni[Classe1A, o, g]) ++ "\t\t" | g in Giorno]) ++ "\n" | o in Ora]


++ ["\n\n"] % Riga vuota tra gli orari delle due classi

% Stampare l'orario professori per la Classe1B
++ ["Orario professori per Classe1B:\n"] ++
["\t" ++ show(g) ++ "\t" | g in Giorno] ++
[ "\n" ++ show(o) ++ "\t" ++ 
% concat([show(orarioLezioni[Classe1B, o, g]) ++ if string_length(show(orarioLezioni[Classe1B, o, g])) < 8 then "\t\t" else "\t" endif | g in Giorno]) ++ "\n" | o in Ora]
 concat([show(orarioLezioni[Classe1B, o, g]) ++ "\t\t" | g in Giorno]) ++ "\n" | o in Ora]
 
++ ["\n\n"] ++ ["Numero studenti "  ++ show(c) ++ ": " ++ show(numeroStudenti[c]) ++ "\n" | c in Classe]

% Stampare occupazione AulaA
++ ["\n\n"] ++  ["Occupazione AulaA:\n"] ++
["\t" ++ show(g) ++ "\t" | g in Giorno] ++
[ "\n" ++ show(o) ++ "\t" ++
 concat([show(occupazioneAulaA[Classe1A, o, g]) ++ "\t\t" | g in Giorno]) ++ "\n" | o in Ora]
 
% Stampare occupazione AulaB
++ ["\n\n"] ++  ["Occupazione AulaB:\n"] ++
["\t" ++ show(g) ++ "\t" | g in Giorno] ++
[ "\n" ++ show(o) ++ "\t" ++
 concat([show(occupazioneAulaB[Classe1B, o, g]) ++ "\t\t" | g in Giorno]) ++ "\n" | o in Ora]
 
% Stampare occupazione Laboratorio Informatica 1
++ ["\n\n"] ++  ["Occupazione Laboratorio Informatica 1:\n"] ++
["\t" ++ show(g) ++ "\t" | g in Giorno] ++
[ "\n" ++ show(o) ++ "\t" ++
 concat([show(occupazioneLabInformatica1[Classe1A, o, g] + occupazioneLabInformatica1[Classe1B, o, g]) ++ "\t\t" | g in Giorno]) ++ "\n" | o in Ora]
 
% Stampare occupazione Laboratorio Informatica 2
++ ["\n\n"] ++  ["Occupazione Laboratorio Informatica 2:\n"] ++
["\t" ++ show(g) ++ "\t" | g in Giorno] ++
[ "\n" ++ show(o) ++ "\t" ++
 concat([show(occupazioneLabInformatica2[Classe1A, o, g] + occupazioneLabInformatica2[Classe1B, o, g]) ++ "\t\t" | g in Giorno]) ++ "\n" | o in Ora]
 
 % Stampare occupazione Palestra
++ ["\n\n"] ++  ["Occupazione Palestra:\n"] ++
["\t" ++ show(g) ++ "\t" | g in Giorno] ++
[ "\n" ++ show(o) ++ "\t" ++
 concat([show(occupazionePalestra[Classe1A, o, g] + occupazionePalestra[Classe1B, o, g]) ++ "\t\t" | g in Giorno]) ++ "\n" | o in Ora]
 
 % Stampare occupazione Aula Musica
++ ["\n\n"] ++  ["Occupazione Aula Musica:\n"] ++
["\t" ++ show(g) ++ "\t" | g in Giorno] ++
[ "\n" ++ show(o) ++ "\t" ++
 concat([show(occupazioneAulaMusica[Classe1A, o, g] + occupazioneAulaMusica[Classe1B, o, g]) ++ "\t\t" | g in Giorno]) ++ "\n" | o in Ora]
