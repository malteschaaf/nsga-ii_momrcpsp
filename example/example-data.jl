### Hier sind alle Daten gespeichert ###

AE=22    # Arbeitselemente
MI=4     # Mitarbeiter (3 Arbeiter + Kolonnenführer)
O=2      # Ausstattungsmodi

Periodenlänge=5


# Kostensätze
Stundensatz_Ar=30
Stundensatz_Ko=60
Stundensatz_Ex=2.3


# Kosten pro Periode
Kosten_MA=Stundensatz_Ar/60*Periodenlänge           
Kosten_MAEx=(Stundensatz_Ar+Stundensatz_Ex)/60*Periodenlänge  
Kosten_KO=Stundensatz_Ko/60*Periodenlänge            
Kosten_KOEx=(Stundensatz_Ko+Stundensatz_Ex)/60*Periodenlänge 


# Vorgänger
V1	=	[0]
V2	=	[1]
V3	=	[1]
V4	=	[3]
V5	=	[2,4]
V6	=	[3]
V7	=	[4,6]
V8	=	[6,5,7]
V9	=	[11]
V10	=	[3]
V11	=	[4,2,10]
V12	=	[8,11]
V13	=	[11]
V14	=	[3]
V15	=	[14,4]
V16	=	[9,12,15]
V17	=	[16]
V18	=	[17,13]
V19	=	[17]
V20	=	[9,13,12]
V21	=	[16]
V22	=	[18,19,20,21]

V=[V1,V2,V3,V4,V5,V6,V7,V8,V9,V10,V11,V12,V13,V14,V15,V16,V17,V18,V19,V20,V21,V22]


# Vom anteiligen Bearbeitungsfortschritt abhängige Vorrangbeziehung 
Lag=[
1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1
1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1
1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1
1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1
1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1
1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1
1	1	1	1	1	1	1	0.2	1	1	1	1	1	1	1	1	1	1	1	1	1	1
1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1
1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1
1	1	1	1	1	1	1	1	1	1	0.2	1	1	1	1	1	1	1	1	1	1	1
1	1	1	1	1	1	1	1	1	1	1	0.2	1	1	1	1	1	1	1	1	1	1
1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1
1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1
1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1
1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0.2	1	1	1	1	1	1
1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1
1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1
1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1
1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1
1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1
1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1
1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1
]


# Mögliche Bearbeitungszeiten (Spaltenindex ist Anzahl Personen und Zahl jeweils benötigte Perioden)
M=50     # BIG M: Mitarbeiteranzahl zu niedrig
N=55     # BIG N: Mitarbeiteranzahl zu hoch / kein Mehrwert

# Spaltenanzahl muss MI entsprechen
D1	=[	0	N	N	N	]
D2	=[	7	N	N	N	]
D3	=[	M	7	5	N	]
D4	=[	M	6	5	N	]
D5	=[	4	N	N	N	]
D6	=[	3	2	N	N	]
D7	=[	3	2	N	N	]
D8	=[	16	12	10	N	]
D9	=[	6	4	N	N	]
D10	=[	12	10	N	N	]
D11	=[	M	8	6	N	]
D12	=[	M	12	10	N	]
D13	=[	8	6	N	N	]
D14	=[	4	3	2	N	]
D15	=[	M	10	8	N	]
D16	=[	M	12	10	N	]
D17	=[	4	3	N	N	]
D18	=[	M	6	5	N	]
D19	=[	2	1	N	N	]
D20	=[	2	N	N	N	]
D21	=[	2	N	N	N	]
D22	=[	0	N	N	N	]

D = [D1,D2,D3,D4,D5,D6,D7,D8,D9,D10,D11,D12,D13,D14,D15,D16,D17,D18,D19,D20,D21,D22]


# Kolonnenführer zwingend erforderlich
K1	=	0
K2	=	1
K3	=	0
K4	=	0
K5	=	1
K6	=	0
K7	=	0
K8	=	1
K9	=	0
K10	=	0
K11	=	0
K12	=	1
K13	=	0
K14	=	0
K15	=	0
K16	=	1
K17	=	0
K18	=	0
K19	=	0
K20	=	1
K21	=	1
K22	=	0

K = [K1,K2,K3,K4,K5,K6,K7,K8,K9,K10,K11,K12,K13,K14,K15,K16,K17,K18,K19,K20,K21,K22]


# Belastung in KJ/min. je Arbeitsgang
B1	=	0.00
B2	=	10.00
B3	=	18.50
B4	=	17.50
B5	=	11.00
B6	=	13.00
B7	=	17.00
B8	=	14.00
B9	=	13.00
B10	=	12.00
B11	=	18.00
B12	=	15.00
B13	=	13.00
B14	=	17.00
B15	=	19.00
B16	=	16.00
B17	=	13.00
B18	=	18.00
B19	=	14.00
B20	=	10.00
B21	=	10.00
B22	=	0.00

Belastung=[B1,B2,B3,B4,B5,B6,B7,B8,B9,B10,B11,B12,B13,B14,B15,B16,B17,B18,B19,B20,B21,B22]


# Reduzierung Belastung durch Exo
R1	=	0
R2	=	0
R3	=	-0.2
R4	=	-0.2
R5	=	0
R6	=	0
R7	=	-0.2
R8	=	0
R9	=	0
R10	=	0
R11	=	-0.2
R12	=	-0.2
R13	=	0
R14	=	-0.2
R15	=	-0.3
R16	=	-0.2
R17	=	0
R18	=	-0.2
R19	=	-0.1
R20	=	0
R21	=	0
R22	=	0

Exorel=[R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,R13,R14,R15,R16,R17,R18,R19,R20,R21,R22].+1
BelastungEx= Belastung.*Exorel

# Heißt im Formalmodell Theta:
BEL=[Belastung,BelastungEx]