############################################################################
################      Script per progetto BDSI 2023/2024     #################
############################################################################
#
# Matricola: 7078620       Cognome:     Cappini            Nome:     Niccolò
# Matricola: 7115898       Cognome:     Bollecchino        Nome:     Matteo
#
############################################################################

DROP DATABASE IF EXISTS DBOspedale;
CREATE DATABASE DBOspedale;
USE DBOspedale;

############################################################################
################   Creazione schema e vincoli database     #################
############################################################################

DROP TABLE IF EXISTS  Visita;
DROP TABLE IF EXISTS Medico;
DROP TABLE IF EXISTS RicoveroPassato;
DROP TABLE IF EXISTS Ricovero;
DROP TABLE IF EXISTS Paziente;
DROP TABLE IF EXISTS Reparto;
DROP TABLE IF EXISTS Struttura;

CREATE TABLE IF NOT EXISTS Struttura(
	Nome VARCHAR(40) PRIMARY KEY,
    Citta VARCHAR(20),
    Cap INT,
    Via VARCHAR(30),
    Numero SMALLINT
)ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Reparto(
	Nome VARCHAR(30),
    Struttura VARCHAR(40),
    PRIMARY KEY (Nome,Struttura),
    NumMed INT,
    NumPaz INT,
    Capienza INT,
    Primario INT,
    FOREIGN KEY (Struttura) REFERENCES Struttura(Nome) 
		ON DELETE CASCADE ON UPDATE CASCADE
)ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Paziente(
	Cf CHAR(16) PRIMARY KEY,
	Nome VARCHAR(20),
    Cognome VARCHAR(20),
    Sesso ENUM ('M','F')
)ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Ricovero(
	Paziente CHAR(16) PRIMARY KEY,
	NomeReparto VARCHAR(30),
    StrutturaReparto VARCHAR(40),
    DataInizio DATE,
    Motivo VARCHAR(30),
	FOREIGN KEY (Paziente) REFERENCES Paziente(Cf) 
		ON DELETE CASCADE,
    FOREIGN KEY (NomeReparto, StrutturaReparto) REFERENCES Reparto(Nome,Struttura) 
		ON UPDATE CASCADE
)ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS RicoveroPassato(
	Paziente CHAR(16),
	NomeReparto VARCHAR(30),
    StrutturaReparto VARCHAR(40),
    DataInizio DATE,
    DataFine DATE,
    PRIMARY KEY (Paziente, NomeReparto, StrutturaReparto, DataInizio, DataFine),
    Motivo VARCHAR(30),
    FOREIGN KEY (Paziente) REFERENCES Paziente(Cf) 
		ON DELETE CASCADE,
    FOREIGN KEY (NomeReparto, StrutturaReparto) REFERENCES Reparto(Nome,Struttura) 
		ON UPDATE CASCADE
)ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Medico(
	IdM INT PRIMARY KEY AUTO_INCREMENT,
	Nome VARCHAR(20),
    Cognome VARCHAR(20),
    AnniCarriera INT, 
    Specializzazione VARCHAR(20),
	NomeReparto VARCHAR(30),
    StrutturaReparto VARCHAR(40),
    FOREIGN KEY (NomeReparto, StrutturaReparto) REFERENCES Reparto(Nome,Struttura) 
		ON UPDATE CASCADE
)ENGINE = InnoDB;

ALTER TABLE Reparto ADD FOREIGN KEY (Primario) REFERENCES Medico(IdM) 
	ON DELETE SET NULL;

CREATE TABLE IF NOT EXISTS Visita(
	Medico INT, 
    Paziente CHAR(16), 
    Data DATE, 
    PRIMARY KEY (Medico, Paziente, Data),
    Esito ENUM('Positivo','Negativo'),
    FOREIGN KEY (Medico) REFERENCES Medico(IdM) 
		ON DELETE CASCADE,
    FOREIGN KEY (Paziente) REFERENCES Paziente(Cf) 
		ON DELETE CASCADE
)ENGINE = InnoDB;

############################################################################
################  Creazione istanza: popolamento database  #################
############################################################################

-- Popolamento della tabella 'Struttura'
INSERT INTO Struttura (Nome, Citta, Cap, Via, Numero) VALUES
('Dipartimento Oncologico e di chirurgia', 'Firenze', 20121, 'Via Roma', 10),
('Dipartimento Neuromuscoloscheletrico', 'Firenze', 10121, 'Corso Torino', 25),
('Dipartimento Materno-infantile', 'Prato', 40126, 'Via Universitaria', 5);

-- Inserire il proprio filepath
LOAD DATA LOCAL INFILE 'C:\\Users\\nicco\\Uni\\Anno2\\Secondo Semestre\\Basi di Dati\\Progetto\\PopolamentoPaziente.txt' INTO TABLE Paziente 
FIELDS TERMINATED BY ", "
LINES TERMINATED BY "\r\n"
IGNORE 4 ROWS;

-- Popolamento della tabella 'Reparto' senza i Primari perché la tabella Medico non è stata ancora popolata
INSERT INTO Reparto (Nome, Struttura, NumMed, NumPaz, Capienza, Primario) VALUES
('Chirurgia Generale', 'Dipartimento Oncologico e di chirurgia', 2, 1, 60, NULL),
('Oncologia', 'Dipartimento Oncologico e di chirurgia', 1, 1, 40, NULL),
('Pediatria', 'Dipartimento Materno-infantile', 2, 1, 80, NULL),
('Neurologia', 'Dipartimento Neuromuscoloscheletrico', 1, 1, 50, NULL),
('Ostetricia', 'Dipartimento Materno-infantile', 1, 1, 70, NULL);

-- Popolamento della tabella 'Medico'
INSERT INTO Medico (Nome, Cognome, AnniCarriera, Specializzazione, NomeReparto, StrutturaReparto) VALUES
('Giovanni', 'Bianchi', 15, 'Chirurgia Generale', 'Chirurgia Generale', 'Dipartimento Oncologico e di chirurgia'),
('Lucia', 'Rossi', 10, NULL, 'Chirurgia Generale', 'Dipartimento Oncologico e di chirurgia'),
('Paolo', 'Gialli', 20, 'Oncologia', 'Oncologia', 'Dipartimento Oncologico e di chirurgia'),
('Marco', 'Verdi', 8, 'Pediatria', 'Pediatria', 'Dipartimento Materno-infantile'),
('Franco', 'Rossini', 8, NULL, 'Pediatria', 'Dipartimento Materno-infantile'),
('Anna', 'Neri', 12, 'Neurologia', 'Neurologia', 'Dipartimento Neuromuscoloscheletrico'),
('Paola', 'Verdi', 20, 'Ostetricia', 'Ostetricia', 'Dipartimento Materno-infantile');

-- Aggiornamento della tabella 'Reparto' con i Primari
UPDATE Reparto SET Primario = 1 WHERE Nome = 'Chirurgia Generale' AND Struttura = 'Dipartimento Oncologico e di chirurgia';
UPDATE Reparto SET Primario = 3 WHERE Nome = 'Oncologia' AND Struttura = 'Dipartimento Oncologico e di chirurgia';
UPDATE Reparto SET Primario = 4 WHERE Nome = 'Pediatria' AND Struttura = 'Dipartimento Materno-infantile';
UPDATE Reparto SET Primario = 6 WHERE Nome = 'Neurologia' AND Struttura = 'Dipartimento Neuromuscoloscheletrico';
UPDATE Reparto SET Primario = 7 WHERE Nome = 'Ostetricia' AND Struttura = 'Dipartimento Materno-infantile';

-- Popolamento della tabella 'Ricovero'
INSERT INTO Ricovero (Paziente, NomeReparto, StrutturaReparto, DataInizio, Motivo) VALUES
('RSSMRA85M01H501Z', 'Chirurgia Generale', 'Dipartimento Oncologico e di chirurgia', '2024-01-10', 'Controllo'),
('BNCLGI90F45H501Q', 'Oncologia', 'Dipartimento Oncologico e di chirurgia', '2024-02-15', 'Trattamento'),
('VRDGLL92F50H501P', 'Pediatria', 'Dipartimento Materno-infantile', '2024-03-20', 'Visita'),
('NRNANN95M60H501R', 'Neurologia', 'Dipartimento Neuromuscoloscheletrico', '2024-04-25', 'Terapia'),
('RSSFNC75M01H501T', 'Ostetricia', 'Dipartimento Materno-infantile', '2024-05-30', 'Intervento');

-- Inserire il proprio filepath
LOAD DATA LOCAL INFILE 'C:\\Users\\nicco\\Uni\\Anno2\\Secondo Semestre\\Basi di Dati\\Progetto\\PopolamentoRicoveroPassato.txt' INTO TABLE RicoveroPassato  
FIELDS TERMINATED BY ", " ENCLOSED BY "'"
LINES TERMINATED BY "\r\n"
IGNORE 4 ROWS;

-- Popolamento della tabella 'Visita'
INSERT INTO Visita (Medico, Paziente, Data, Esito) VALUES
(1, 'RSSMRA85M01H501Z', '2024-01-15', 'Positivo'),
(2, 'BNCLGI90F45H501Q', '2024-02-20', 'Negativo'),
(3, 'VRDGLL92F50H501P', '2024-03-25', 'Positivo'),
(4, 'NRNANN95M60H501R', '2024-04-30', 'Negativo'),
(5, 'GLLMRC87M23H501S', '2024-05-05', 'Positivo'),
(1, 'PSDFRN85M01H501T', '2024-01-20', 'Positivo'),
(2, 'LCAVNC90F45H501U', '2024-02-25', 'Negativo'),
(3, 'DMTRLU92F50H501V', '2024-03-30', 'Positivo'),
(4, 'SRNCHN95M60H501W', '2024-04-05', 'Negativo'),
(5, 'GNGNCM87M23H501X', '2024-05-10', 'Positivo'),
(1, 'VNTMRA80A01H501Y', '2024-05-15', 'Positivo'),
(3, 'RSSFBA75L01H501Z', '2024-05-16', 'Negativo'),
(4, 'BNCLMR60M01D612W', '2024-05-17', 'Positivo'),
(7, 'VRDFLB90C01F205V', '2024-05-18', 'Negativo'),
(7, 'RSSCST85M01H501X', '2024-05-19', 'Positivo'),
(6, 'BNCFRC70L01D612Y', '2024-05-20', 'Negativo'),
(4, 'VRDGNN60C01F205W', '2024-05-21', 'Positivo'),
(3, 'RSSFNC75M01H501T', '2024-05-22', 'Negativo'),
(1, 'BNCLRA80M01D612U', '2024-05-23', 'Positivo'),
(2, 'VRDCPP85C01F205R', '2024-05-24', 'Negativo'),
(4, 'RSSLGI80M01H501P', '2024-05-25', 'Positivo'),
(3, 'VRDCPP85C01F205R', '2024-05-26', 'Negativo'),
(2, 'VRDMRL90C01F205Q', '2024-05-27', 'Positivo'),
(1, 'RSSFBR85M01H501N', '2024-05-28', 'Negativo'),
(4, 'BNCCRL70L01D612O', '2024-05-29', 'Positivo'),
(5, 'VRDGLP60C01F205M', '2024-05-30', 'Negativo'),
(6, 'RSSCMN75M01H501L', '2024-05-31', 'Positivo'),
(6, 'BNCMRT80M01D612K', '2024-06-01', 'Negativo'),
(2, 'VRDPLL85C01F205J', '2024-06-02', 'Positivo'),
(1, 'RSSLMR90M01H501H', '2024-06-03', 'Negativo');

#############################################################################
################  Ulteriori vincoli tramite viste e/o trigger ###############
#############################################################################

-- 1) Si controlla nella tabella Ricovero, nel caso di inserimenti per il reparto di Ostetricia,
-- che il paziente abbia sesso femminile

DROP TRIGGER IF EXISTS RicoveroOstetricia;

DELIMITER $$

CREATE TRIGGER RicoveroOstetricia
BEFORE INSERT ON Ricovero
FOR EACH ROW
BEGIN
	IF NEW.NomeReparto = 'Ostetricia' AND (SELECT Sesso as SessoPaziente from Paziente WHERE CF = NEW.Paziente) = 'M'
	THEN SIGNAL SQLSTATE VALUE '45000'
    SET MESSAGE_TEXT = 'TriggerError: Si sta provando ad inserire un uomo nel reparto di Ostetricia';
    END IF;
END $$

DELIMITER ;

-- 2) Si controlla nella tabella RicoveroPassato, nel caso di inserimenti per il reparto di Ostetricia,
-- che il paziente abbia sesso femminile

DROP TRIGGER IF EXISTS RicoveroPassatoOstetricia;

DELIMITER $$

CREATE TRIGGER RicoveroPassatoOstetricia
BEFORE INSERT ON RicoveroPassato
FOR EACH ROW
BEGIN
	IF NEW.NomeReparto = 'Ostetricia' AND (SELECT Sesso as SessoPaziente from Paziente WHERE CF = NEW.Paziente) = 'M'
	THEN SIGNAL SQLSTATE VALUE '45000'
    SET MESSAGE_TEXT = 'TriggerError: Si sta provando ad inserire un uomo nel reparto di Ostetricia';
    END IF;
END $$

DELIMITER ;

-- 3) Si controlla prima di inserire in RicoveroPassato se DataInizio < DataFine

DROP TRIGGER IF EXISTS RicoveroPassatoControlloDate;

DELIMITER $$

CREATE TRIGGER RicoveroPassatoControlloDate
BEFORE INSERT ON RicoveroPassato
FOR EACH ROW
BEGIN
	IF datediff(NEW.DataFine, NEW.DataInizio) < 0
    THEN SIGNAL SQLSTATE VALUE '45000'
    SET MESSAGE_TEXT = 'TriggerError: DataFine è precedente a DataInizio';
    END IF;
END $$

DELIMITER ;

-- 4) Per cambiamenti successivi nella tabella Reparto si controlla che il nuovo primario sia un medico con specializzazione,
-- che non sia già primario di un altro reparto e che afferisca a quel reparto.

DROP TRIGGER IF EXISTS ControlloNuovoPrimarioReparto;

DELIMITER $$

CREATE TRIGGER ControlloNuovoPrimarioReparto
BEFORE UPDATE ON Reparto
FOR EACH ROW
BEGIN
	IF NEW.Primario <> OLD.Primario AND ( 
		isnull((SELECT Specializzazione FROM Medico WHERE IdM = New.Primario)) OR
		(SELECT count(*) FROM Reparto WHERE NEW.Primario = Primario) <> 0 OR
		(SELECT NomeReparto, StrutturaReparto FROM Medico WHERE IdM = NEW.Primario) <> (NEW.Nome, NEW.Struttura)	)
    THEN SIGNAL SQLSTATE VALUE '45000'
    SET MESSAGE_TEXT = 'TriggerError: Impossibile aggiornare il primario del reparto';
    END IF;
END $$

DELIMITER ;

-- 5) Si controlla, prima di effettuare un inserimento in Reparto, che NumPaz <= Capienza

DROP TRIGGER IF EXISTS RepartoControlloNumPaz;

DELIMITER $$

CREATE TRIGGER RepartoControlloNumPaz
BEFORE INSERT ON Reparto
FOR EACH ROW
BEGIN
	IF NEW.NumPaz>NEW.Capienza
    THEN SIGNAL SQLSTATE VALUE '45000'
    SET MESSAGE_TEXT = 'TriggerError: Nel reparto il numero di pazienti è maggiore della capienza massima';
    END IF;
END$$

DELIMITER ;

############################################################################
################                  Interrogazioni              ##############
############################################################################

-- 1) Informazioni relative a tutti i primari

SELECT Medico.Nome, Cognome, AnniCarriera, Specializzazione FROM Reparto, Medico
WHERE Reparto.Primario = Medico.IdM;

-- 2) Trovare i pazienti che hanno effettuato più ricoveri in passato

DROP VIEW IF EXISTS Paziente_RicoveroPassato;

CREATE VIEW Paziente_RicoveroPassato AS 
	SELECT Paziente, COUNT(Paziente) AS Numero_Ricoveri FROM RicoveroPassato 
	GROUP BY Paziente;
    
SELECT * FROM Paziente_RicoveroPassato 
WHERE Numero_Ricoveri = (SELECT MAX(Numero_Ricoveri) FROM Paziente_RicoveroPassato);

-- 3) Trovare i medici che hanno fatto più visite

DROP VIEW IF EXISTS Medico_Visita;

CREATE VIEW Medico_Visita AS 
	SELECT IdM, Nome, Cognome, count(IdM) AS Numero_Visite FROM Medico JOIN Visita ON Medico.IdM = Visita.Medico
	GROUP BY Medico.IdM;

SELECT * FROM Medico_Visita 
WHERE Numero_Visite = (SELECT MAX(Numero_Visite) FROM Medico_Visita)
ORDER BY IdM;

-- 4) Trovare il paziente che ha effettuato più visite

DROP VIEW IF EXISTS Paziente_Visita;

CREATE VIEW Paziente_Visita AS 
	SELECT Paziente, COUNT(Paziente) AS Numero_Visite FROM Visita 
	GROUP BY Paziente;

SELECT * FROM Paziente_Visita 
WHERE Numero_Visite = (SELECT MAX(Numero_Visite) FROM Paziente_Visita);

-- 5) Trovare i pazienti che hanno una visita fissata ma non sono ricoverati in alcun reparto

DROP VIEW IF EXISTS Paziente_Ricovero;

CREATE VIEW Paziente_Ricovero AS
	SELECT Paziente FROM Ricovero, Paziente
	WHERE Paziente.Cf = Ricovero.Paziente;

SELECT Nome, Cognome FROM Visita, Paziente
WHERE Paziente.Cf = Visita.Paziente AND Paziente.Cf NOT IN (SELECT * FROM Paziente_Ricovero)
GROUP BY Nome, Cognome;

############################################################################
################          Procedure e funzioni             #################
############################################################################

-- 1) Dato un CF, la procedura stampa tutte e sole le informazioni relative a quel paziente 
DROP PROCEDURE IF EXISTS informazioni_paziente;

DELIMITER $$

CREATE PROCEDURE informazioni_paziente(CF CHAR(16))
BEGIN
	SELECT * FROM Paziente
		WHERE Paziente.CF = CF;
	SELECT Medico as IdMedico, Data as DataVisita, Esito FROM Paziente, Visita
		WHERE Paziente.CF = CF AND Visita.Paziente = CF;
    SELECT NomeReparto as RepartoRicovero, StrutturaReparto as StrutturaRicovero, DataInizio as InizioRicovero, Motivo as MotivoRicovero FROM Paziente, Ricovero
		WHERE Paziente.CF = CF AND Ricovero.Paziente = CF;
    SELECT NomeReparto as RepartoRicoveroPassato, StrutturaReparto as StrutturaRicoveroPassato, DataInizio as InizioRicoveroPassato, DataFine as FineRicoveroPassato, Motivo as MotivoRicovero FROM Paziente, RicoveroPassato
		WHERE Paziente.CF = CF AND RicoveroPassato.Paziente = CF;
END $$

DELIMITER ;

CALL informazioni_paziente('BNCLGI90F45H501Q');

-- 2) La funzione, dato l'ID di un medico in input, calcola e restituisce per quanti pazienti ha fatto delle visite

DROP FUNCTION IF EXISTS pazienti_visitati;

DELIMITER $$

CREATE FUNCTION pazienti_visitati(IdM INT)
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE num_pazienti_visitati INT;
	SELECT COUNT(*) INTO num_pazienti_visitati FROM Visita
    WHERE Visita.Medico = IdM;
    RETURN num_pazienti_visitati;
END $$

DELIMITER ;

SELECT pazienti_visitati(1) as pazientiVisitati;


-- 3) La funzione, dato il CF di un paziente in input, ne calcola e restituisce il numero di ricoveri, presente e passati

DROP FUNCTION IF EXISTS ricoveri_paziente;

DELIMITER $$

CREATE FUNCTION ricoveri_paziente(CF CHAR(16))
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE numRicoveri INT;
	SELECT COUNT(*) INTO numRicoveri FROM RicoveroPassato
		WHERE RicoveroPassato.Paziente = CF;
    IF CF IN (SELECT Paziente from Ricovero) THEN
		SET numRicoveri = numRicoveri + 1;
	END IF;
    RETURN numRicoveri;
END $$

DELIMITER ;

SELECT ricoveri_paziente('RSSMRA85M01H501Z') AS numRicoveri;

-- 4) Trovare tutti i pazienti ricoverati ad oggi in una data struttura 

DROP PROCEDURE IF EXISTS pazienti_ricoverati_struttura;

DELIMITER $$

CREATE PROCEDURE pazienti_ricoverati_struttura(IN Struttura VARCHAR(40))
BEGIN
	SELECT Nome, Cognome, Sesso FROM Ricovero, Paziente
		WHERE Paziente = Cf AND StrutturaReparto = Struttura;
END $$

DELIMITER ;

CALL pazienti_ricoverati_struttura('Dipartimento Oncologico e di chirurgia');

-- 5) Calcolare, dati in input il CF del paziente, il numero totale di giorni che il paziente è stato ricoverato

DROP FUNCTION IF EXISTS durata_totale_ricoveri_passati;

DELIMITER $$

CREATE FUNCTION durata_totale_ricoveri_passati(CfPaziente CHAR(16))
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE somma INT;
    DECLARE stop INT;
    DECLARE DataF DATE;
    DECLARE DataI DATE;
    DECLARE cursore CURSOR FOR
		SELECT DataFine, DataInizio FROM Ricoveropassato, Paziente 
		WHERE Paziente = Cf AND Cf = CfPaziente;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET stop = 1;
	OPEN cursore;
    SET somma = 0;
    SET stop = 0;
	WHILE (stop <> 1) DO
		FETCH cursore INTO DataF, DataI;
        SET somma = somma + DATEDIFF(DataF, DataI);
	END WHILE;
	CLOSE cursore;
    SET somma = somma - DATEDIFF(DataF, DataI);
    RETURN somma;
END $$

DELIMITER ;

SELECT durata_totale_ricoveri_passati('RSSMRA85M01H501Z');

-- 6) Calcolare, dato il CF di un paziente, la durata media dei suoi ricoveri passati

DROP PROCEDURE IF EXISTS durata_media_ricoveri;

DELIMITER $$

CREATE PROCEDURE durata_media_ricoveri(CF CHAR(16))
BEGIN
	SELECT FORMAT(AVG(DATEDIFF(DataFine, DataInizio)), 1) AS durataMediaRicoveri FROM RicoveroPassato
		WHERE Paziente = CF;
END $$

DELIMITER ;

CALL durata_media_ricoveri('RSSMRA85M01H501Z');


-- 7) Per un paziente, dato il suo CF, elencare le sue visite con esito negativo

DROP PROCEDURE IF EXISTS visite_negative;

DELIMITER $$

CREATE PROCEDURE visite_negative(CF CHAR(16))
BEGIN
	SELECT * FROM Visita
		WHERE Paziente = CF AND Esito = 'Negativo';
END $$

DELIMITER ;

CALL visite_negative('VRDCPP85C01F205R');
