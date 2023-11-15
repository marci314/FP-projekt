import networkx as nx
import matplotlib.pyplot as plt
import random
from itertools import combinations
import math


def spodnja_meja(n, d):
    if d >= n:
        return 'Izbrani premer je prevelik'
    elif d < 1:
        return 'Izbrani premer je premajhen'
    elif d == 1:
        G = nx.complete_graph(n)
        return G
    else:
        G = nx.complete_graph(n - d + 1)
        new_node = n - d + 1
        for i in range(n - d):
            existing_node = i
            G.add_edge(new_node, existing_node)
        if d > 2:
            for i in range(n - d + 2, n):
                new_nodes = i
                G.add_edge(new_nodes, new_nodes - 1)
        return G


# Prešteje število povezav v grafu.
def ciljna_funkcija(graf):
    return len(graf.edges)


# Najde najkrajšo možno pot v grafu med začetnim in končnim vozliščem.
def najdi_pot(graf, zacetek, konec):
    try:
        pot = nx.shortest_path(graf, source=zacetek, target=konec)
        return pot
    except nx.NetworkXNoPath:
        return None


# Kot argument sprejme graf ter pot iz katere želimo odstranit povezavo, nato iz nje naključno odstrani povezavo.
def odstrani_nakljucno_povezavo_iz_poti_v_grafu(graf, pot):
    nakljucni_indeks_povezave = random.randint(1, len(pot) - 1)
    povezava_za_odstranitev = (pot[nakljucni_indeks_povezave - 1], pot[nakljucni_indeks_povezave])
    graf.remove_edge(*povezava_za_odstranitev)
    return graf


# METAHEVRISTIČNI ALGORITEM 
def simulirano_hlajenje_2_povezavi_razmaka_spodnja_meja(n, max_iteracij, zacetna_temperatura, stopnja_hlajenja, premer):
    trenutna_resitev = spodnja_meja(n, premer)
    najboljsa_resitev = trenutna_resitev.copy()
    temperatura = zacetna_temperatura

    for iteracija in range(max_iteracij):
        # Preverimo kakšen je premer, bodisi je večji ali enak premeru trenutne rešitve, bodisi pa je manjši od 1. V zadnjem primeru je torej nepovezan graf. Dodamo povezavo.
        if premer <= nx.diameter(trenutna_resitev) or nx.diameter(trenutna_resitev) < 1:
            # Izbere 2 naključni vozlišči, ki nista povezani.
            vozlisce1 = random.choice(list(trenutna_resitev.nodes))
            vozlisca_2_razmaka = [vozlisce for vozlisce in trenutna_resitev.nodes - set([vozlisce1]) if nx.shortest_path_length(trenutna_resitev, source=vozlisce1, target=vozlisce) == 2]
            vozlisce2 = random.choice(vozlisca_2_razmaka)
            # Dodamo povezavo med izbranima vozliščema.
            nova_resitev = trenutna_resitev.copy()
            nova_resitev.add_edge(vozlisce1, vozlisce2) 
            # Preverimo ali je nov graf tak, da ima več povezav. V primeru da je to res, posodobimo najboljšo rešitev, sicer pa z verjetnostjo izberemo ali bomo posodobili trenutno rešitev ali ne.
            # Opomba: Lahko pride do izbire "slabšega" grafa, upamo, da nas bo ta "slabši" vseeno pripeljal do boljše rešitve v nadaljevanju.
            delta = ciljna_funkcija(nova_resitev) - ciljna_funkcija(trenutna_resitev)
            if (delta > 0 and premer <= nx.diameter(nova_resitev)) or random.random() < math.exp(-delta / temperatura):
                trenutna_resitev = nova_resitev.copy()
                if ciljna_funkcija(nova_resitev) > ciljna_funkcija(najboljsa_resitev) and premer == nx.diameter(nova_resitev):
                    najboljsa_resitev = nova_resitev.copy()
        else:
            # Poiščemo kombinacije vozlišč z največjo ekscentričnostjo.
            ekscentričnosti = nx.eccentricity(trenutna_resitev)  
            max_ekscentričnost = max(ekscentričnosti.values())
            vozlisca_z_max_ekscentričnostjo = [vozlisce for vozlisce, ekscentričnost in ekscentričnosti.items() if ekscentričnost == max_ekscentričnost]
            kombinacije_parov = list(combinations(vozlisca_z_max_ekscentričnostjo, 2))
            rezultat = []
            # Izberemo najbolj oddaljeni vozlišči.
            for i, j in kombinacije_parov:
                potencialen_rezultat = najdi_pot(trenutna_resitev, i, j) 
                if potencialen_rezultat and len(potencialen_rezultat) > len(rezultat):
                    rezultat = potencialen_rezultat
            nova_resitev = trenutna_resitev.copy()
            nova_resitev = odstrani_nakljucno_povezavo_iz_poti_v_grafu(trenutna_resitev.copy(), rezultat)
            # Preverimo ali je nov graf tak, da ima več povezav. V primeru da je to res, posodobimo najboljšo rešitev, sicer pa z verjetnostjo izberemo ali bomo posodobili trenutno rešitev ali ne.
            # Opomba: Lahko pride do izbire "slabšega" grafa, upamo, da nas bo ta "slabši" vseeno pripeljal do boljše rešitve v nadaljevanju.
            delta = ciljna_funkcija(nova_resitev) - ciljna_funkcija(trenutna_resitev)
            # IF pogoj je vedno izpolnjen, pustimo ga zgolj za voljo testiranja.
            if ((delta > 0 and premer <= nx.diameter(nova_resitev)) or random.random() < math.exp(-delta / temperatura)) and nx.is_connected(nova_resitev):
                trenutna_resitev = nova_resitev.copy()
                if ciljna_funkcija(nova_resitev) > ciljna_funkcija(najboljsa_resitev) and premer == nx.diameter(nova_resitev):
                    najboljsa_resitev = nova_resitev.copy()
        # Znižamo(ohladimo) temperaturo po stopnji hlajenja.
        temperatura *= stopnja_hlajenja

    return najboljsa_resitev


st_vozlisc = 30
max_iteracij = 1000
zacetna_temperatura = 1.0
stopnja_hlajenja = 0.95
zeljen_premer = 7

najboljsi_graf_s_m = simulirano_hlajenje_2_povezavi_razmaka_spodnja_meja(st_vozlisc, max_iteracij, zacetna_temperatura, stopnja_hlajenja, zeljen_premer)
print(f"Število povezav v najboljšem generiranem grafu: {ciljna_funkcija(najboljsi_graf_s_m)}")


plt.figure(figsize=(8, 8))
nx.draw(najboljsi_graf_s_m, with_labels=True, font_weight='bold', node_color='skyblue', node_size=800, font_size=10)
plt.show()