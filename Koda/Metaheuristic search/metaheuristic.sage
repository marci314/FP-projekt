#ALGORITEM UPORABLJEN V DRUGI FAZI

import networkx as nx
    import matplotlib.pyplot as plt
    import random
    from itertools import combinations
    import math
    
    
    # Ustvari zaceten graf(drevo) z n vozlisci in premerom d
    def zacetni_graf(n, d):
        if d == 1:
            G = nx.complete_graph(n)
            return G
        else:
            G = nx.Graph()
            G.add_nodes_from(range(n))
            vozlisca = list(G.nodes())
            for i in range(d): # Poveze d + 1 vozlisc v pot dolzine d
                G.add_edge(vozlisca[i], vozlisca[i + 1])
            for i in range(d + 1, n): # Nakljucno doda ostale povezave na notranjih d - 1 vozlisc
                izbran = random.randint(1, d - 1)
                G.add_edge(vozlisca[i], vozlisca[izbran])
            return G


    # Presteje stevilo povezav v grafu.
    def ciljna_funkcija(graf):
        return len(graf.edges)


    # Najde najkrajso mozno pot v grafu med zacetnim in koncnim vozliscem.
    def najdi_pot(graf, zacetek, konec):
        try:
            pot = nx.shortest_path(graf, source=zacetek, target=konec)
            return pot
        except nx.NetworkXNoPath:
            return None


    # Kot argument sprejme graf ter pot iz katere zelimo odstranit povezavo, nato iz nje nakljucno odstrani povezavo.
    def odstrani_nakljucno_povezavo_iz_poti_v_grafu(graf, pot):
        nakljucni_indeks_povezave = random.randint(1, len(pot) - 1)
        povezava_za_odstranitev = (pot[nakljucni_indeks_povezave - 1], pot[nakljucni_indeks_povezave])
        graf.remove_edge(*povezava_za_odstranitev)
        return graf


    # METAHEVRISTIcNI ALGORITEM 
    def simulirano_hlajenje_2_povezavi_razmaka(n, max_iteracij, zacetna_temperatura, stopnja_hlajenja, premer):
        trenutna_resitev = zacetni_graf(n, premer)
        najboljsa_resitev = trenutna_resitev.copy()
        temperatura = zacetna_temperatura

        for iteracija in range(max_iteracij):
            # Preverimo kaksen je premer, bodisi je vecji ali enak premeru trenutne resitve, bodisi pa je manjsi od 1. V zadnjem primeru je torej nepovezan graf. Dodamo povezavo.
            if premer <= nx.diameter(trenutna_resitev) or nx.diameter(trenutna_resitev) < 1:
                # Izbere 2 nakljucni vozlisci, ki nista povezani.
                vozlisce1 = random.choice(list(trenutna_resitev.nodes))
                vozlisca_2_razmaka = [vozlisce for vozlisce in trenutna_resitev.nodes - set([vozlisce1]) if nx.shortest_path_length(trenutna_resitev, source=vozlisce1, target=vozlisce) == 2]
                vozlisce2 = random.choice(vozlisca_2_razmaka)
                # Dodamo povezavo med izbranima vozliscema.
                nova_resitev = trenutna_resitev.copy()
                nova_resitev.add_edge(vozlisce1, vozlisce2) 
                # Preverimo ali je nov graf tak, da ima vec povezav. V primeru da je to res, posodobimo najboljso resitev, sicer pa z verjetnostjo izberemo ali bomo posodobili trenutno resitev ali ne.
                # Opomba: Lahko pride do izbire "slabsega" grafa, upamo, da nas bo ta "slabsi" vseeno pripeljal do boljse resitve v nadaljevanju.
                delta = ciljna_funkcija(nova_resitev) - ciljna_funkcija(trenutna_resitev)
                if (delta > 0 and premer <= nx.diameter(nova_resitev)) or random.random() < math.exp(-delta / temperatura):
                    trenutna_resitev = nova_resitev.copy()
                    if ciljna_funkcija(nova_resitev) > ciljna_funkcija(najboljsa_resitev) and premer == nx.diameter(nova_resitev):
                        najboljsa_resitev = nova_resitev.copy()
            else:
                # Poiscemo kombinacije vozlisc z najvecjo ekscentricnostjo.
                ekscentricnosti = nx.eccentricity(trenutna_resitev)  
                max_ekscentricnost = max(ekscentricnosti.values())
                vozlisca_z_max_ekscentricnostjo = [vozlisce for vozlisce, ekscentricnost in ekscentricnosti.items() if ekscentricnost == max_ekscentricnost]
                kombinacije_parov = list(combinations(vozlisca_z_max_ekscentricnostjo, 2))
                rezultat = []
                # Izberemo najbolj oddaljeni vozlisci.
                for i, j in kombinacije_parov:
                    potencialen_rezultat = najdi_pot(trenutna_resitev, i, j) 
                    if potencialen_rezultat and len(potencialen_rezultat) > len(rezultat):
                        rezultat = potencialen_rezultat
                nova_resitev = trenutna_resitev.copy()
                nova_resitev = odstrani_nakljucno_povezavo_iz_poti_v_grafu(trenutna_resitev.copy(), rezultat)
                # Preverimo ali je nov graf tak, da ima vec povezav. V primeru da je to res, posodobimo najboljso resitev, sicer pa z verjetnostjo izberemo ali bomo posodobili trenutno resitev ali ne.
                # Opomba: Lahko pride do izbire "slabsega" grafa, upamo, da nas bo ta "slabsi" vseeno pripeljal do boljse resitve v nadaljevanju.
                delta = ciljna_funkcija(nova_resitev) - ciljna_funkcija(trenutna_resitev)
                # IF pogoj je vedno izpolnjen, ko je novi graf povezan, prvi del pogoja pustimo zgolj za voljo testiranja.
                if ((delta > 0 and premer <= nx.diameter(nova_resitev)) or random.random() < math.exp(-delta / temperatura)) and nx.is_connected(nova_resitev):
                    trenutna_resitev = nova_resitev.copy()
                    if ciljna_funkcija(nova_resitev) > ciljna_funkcija(najboljsa_resitev) and premer == nx.diameter(nova_resitev):
                        najboljsa_resitev = nova_resitev.copy()
            # Znizamo(ohladimo) temperaturo po stopnji hlajenja.
            temperatura *= stopnja_hlajenja

        return najboljsa_resitev

    # Prikaz delovanja algoritma na primeru.
    st_vozlisc = 30
    max_iteracij = 1000
    zacetna_temperatura = 1.0
    stopnja_hlajenja = 0.95
    zeljen_premer = 7

    najboljsi_graf = simulirano_hlajenje_2_povezavi_razmaka(st_vozlisc, max_iteracij, zacetna_temperatura, stopnja_hlajenja, zeljen_premer)
    print(f"Stevilo povezav v najboljsem generiranem grafu: {ciljna_funkcija(najboljsi_graf)}")

    # Graf se prikazemo.
    plt.figure(figsize=(8, 8))
    nx.draw(najboljsi_graf, with_labels=True, font_weight='bold', node_color='skyblue', node_size=800, font_size=10)
    plt.show()