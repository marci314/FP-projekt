#ALGORITEM UPORABLJEN V PRVI FAZI

from sage.graphs.graph_generators import graphs
    
    def najdi_graf_z_premerom(n, d):
        # Najvecje stevilo povezav in graf z najvec povezavami.
        max_povezave = 0
        graf_z_max_povezav = None
        
        # Zanka po vseh povezanih grafih z n vozlisci, ki jih generiramo z uporabo nauty_geng().
        for G in graphs.nauty_geng(str(n) + " -c"):
            
            # Premer grafa.
            premer = G.premer()
            
            # Ce srecamo graf katerega premer je enak nasemu premeru d
            if premer == d:
                # zabelezimo stevilo povezav
                stevilo_povezav = G.size()
                
                # Ce je stevilo povezav vecje od trenutnega maksimuma, posodobi maksimum.
                if stevilo_povezav > max_povezave:
                    max_povezave = stevilo_povezav
                    graf_z_max_povezav = G.copy()  
        
        return graf_z_max_povezav, max_povezave
    
    # Primer za neko stevilo vozlisc n in premer d.
    n = 8
    d = 3
    
    # Poiscemo povezan graf z dolocenim stevilom vozlisc in premerom, ki bo imel maksimalno stevilo povezav.
    graf_z_max_povezav, max_povezave = najdi_graf_z_premerom(n, d)
    
    
    # Ce je graf najden ga prikazemo
    if graf_z_max_povezav:
        print(f"Povezan graf z {n} vozlsci in premerom {d} s {max_povezave} povezavami:")
        print(graf_z_max_povezav)
        
        graf_z_max_povezav.show()
    else:
        print(f"Graf z {n} vozlisci in premerom {d} ni bil najden .")
    
    
    import pandas as pd
    import matplotlib.pyplot as plt
    
    rezultati = []
    
    # Zanka za preiskovanje razlicnih kombinacij n in d, grafe z maksimalnim stevilom povezav shranjujemo v slovar
    for n in range(1, 10):
        for d in range(1, n):
            graf_z_max_povezav, max_povezave = najdi_graf_z_premerom(n, d)
            rezultat_slovar = {
                'n': n,
                'd': d,
                'max_povezave': max_povezave
            }
            rezultati.append(rezultat_slovar)
    
    # Prikazemo rezultate s tabelo
    df = pd.DataFrame(rezultati)

    print(df)
    
    # Prikazemo tudi graf, ki predstavlja maksimalno stevilo povezav v odvisnosti od d za razlicne n
    plt.figure(figsize=(10, 6))
    for n in range(1, 9):
        podskupina = df[df['n'] == n]
        plt.plot(podskupina['d'], podskupina['max_povezave'], label=f'n={n}')
    plt.xlabel('premer (d)')
    plt.ylabel('maksimalno stevilo povezav')
    plt.legend()
    plt.title('max_povezave(d) za razlicne n')
    plt.show()