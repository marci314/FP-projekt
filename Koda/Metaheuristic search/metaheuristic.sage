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

def ciljna_funkcija(graf):
    return len(graf.edges)

def najdi_pot(graf, zacetek, konec):
    try:
        pot = nx.shortest_path(graf, source=zacetek, target=konec)
        return pot
    except nx.NetworkXNoPath:
        return None

def odstrani_nakljucno_povezavo_iz_poti_v_grafu(graf, pot):
    nakljucni_indeks_povezave = random.randint(1, len(pot) - 1)
    povezava_za_odstranitev = (pot[nakljucni_indeks_povezave - 1], pot[nakljucni_indeks_povezave])
    graf.remove_edge(*povezava_za_odstranitev)
    return graf

def simulirano_hlajenje_2_povezavi_razmaka(n, max_iteracij, zacetna_temperatura, stopnja_hlajenja, premer):
    trenutna_resitev = spodnja_meja(n, premer)
    najboljsa_resitev = trenutna_resitev.copy()
    temperatura = zacetna_temperatura

    for iteracija in range(max_iteracij):
        if premer == nx.diameter(trenutna_resitev) or premer < nx.diameter(trenutna_resitev) or nx.diameter(trenutna_resitev) < 1:
            vozlisce1 = random.choice(list(trenutna_resitev.nodes))
            vozlisca_2_razmaka = [vozlisce for vozlisce in trenutna_resitev.nodes - set([vozlisce1]) if nx.shortest_path_length(trenutna_resitev, source=vozlisce1, target=vozlisce) == 2]
            vozlisce2 = random.choice(vozlisca_2_razmaka)
            while trenutna_resitev.has_edge(vozlisce1, vozlisce2):
                vozlisce1 = random.choice(list(trenutna_resitev.nodes))
                vozlisca_2_razmaka = [vozlisce for vozlisce in trenutna_resitev.nodes - set([vozlisce1]) if nx.shortest_path_length(trenutna_resitev, source=vozlisce1, target=vozlisce) == 2]
                vozlisce2 = random.choice(vozlisca_2_razmaka)
            nova_resitev = trenutna_resitev.copy()
            nova_resitev.add_edge(vozlisce1, vozlisce2) 
            delta = ciljna_funkcija(nova_resitev) - ciljna_funkcija(trenutna_resitev)
            if delta > 0 or random.random() < math.exp(delta / temperatura):
                trenutna_resitev = nova_resitev.copy()
                if ciljna_funkcija(nova_resitev) > ciljna_funkcija(najboljsa_resitev) and premer == nx.diameter(nova_resitev):
                    najboljsa_resitev = nova_resitev.copy()
        else:
            ekscentričnosti = nx.eccentricity(trenutna_resitev)  
            max_ekscentričnost = max(ekscentričnosti.values())
            vozlisca_z_max_ekscentričnostjo = [vozlisce for vozlisce, ekscentričnost in ekscentričnosti.items() if ekscentričnost == max_ekscentričnost]
            kombinacije_parov = list(combinations(vozlisca_z_max_ekscentričnostjo, 2))
            rezultat = []
            for i, j in kombinacije_parov:
                potencialen_rezultat = najdi_pot(trenutna_resitev, i, j) 
                if potencialen_rezultat and len(potencialen_rezultat) > len(rezultat):
                    rezultat = potencialen_rezultat
            nova_resitev = trenutna_resitev.copy()
            nova_resitev = odstrani_nakljucno_povezavo_iz_poti_v_grafu(trenutna_resitev.copy(), rezultat)
            delta = ciljna_funkcija(nova_resitev) - ciljna_funkcija(trenutna_resitev)
            if (delta > 0 or random.random() < math.exp(delta / temperatura)) and nx.is_connected(nova_resitev):
                trenutna_resitev = nova_resitev.copy()
                if ciljna_funkcija(nova_resitev) > ciljna_funkcija(najboljsa_resitev) and premer == nx.diameter(nova_resitev):
                    najboljsa_resitev = nova_resitev.copy()

        temperatura *= stopnja_hlajenja

    return najboljsa_resitev


st_vozlisc = 50
max_iteracij = 1000
zacetna_temperatura = 1.0
stopnja_hlajenja = 0.95
zeljen_premer = 10

najboljsi_graf = simulirano_hlajenje_2_povezavi_razmaka(st_vozlisc, max_iteracij, zacetna_temperatura, stopnja_hlajenja, zeljen_premer)
print(f"Število povezav v najboljšem generiranem grafu: {ciljna_funkcija(najboljsi_graf)}")


plt.figure(figsize=(8, 8))
nx.draw(najboljsi_graf, with_labels=True, font_weight='bold', node_color='skyblue', node_size=800, font_size=10)
plt.show()
