# Domande del prof a cui il report non risponde (versione rivista, 19/11)

Criterio: restano solo i punti in cui il report consegnato (24 pagine) è impreciso, afferma qualcosa senza spiegarlo, oppure tace su una cosa che le figure mettono sotto gli occhi. Ho tolto tutte le domande a cui il report già risponde: erano più della metà della versione di ieri, per esempio consensus e disagreement nel FJ, «attachment», V = 𝟙e₁ᵀ, Λ = I.

Ogni punto riporta tre cose:
- **Nel report:** la frase com'è scritta;
- **Cosa non torna:** perché il prof può fermarsi lì;
- **Risposta:** cosa dire.

Priorità: ★★★ alta, ★★ media, ★ bassa. I numeri li ho ricontrollati con un calcolo a parte.

---

## A. Frasi scritte in modo impreciso

**1. ★★★ Il vettore (1/6)𝟙 a t = 0** (§2.2, inizio; §2.2.3; Conclusioni)
- **Nel report:** «Both matrices are doubly-stochastic, so w = (1/6)𝟙₆ is the left eigenvector associated with the eigenvalue 1». Più avanti: «w₁ … grows from 1/6 to 1».
- **Cosa non torna:** a t = 0 le reti sono periodiche e non c'è consensus, quindi non esiste una social power. Eppure il vettore è chiamato w, come la social power, e il valore 1/6 è presentato come punto di partenza della crescita.
- **Risposta:** a t = 0 (1/6)𝟙 è solo l'autovettore sinistro di A(0) per l'autovalore 1. È unico a meno di scala perché A(0) è irriducibile, e dice che la struttura non favorisce nessuno. La social power esiste per t ∈ (0, 1]; 1/6 è il limite di w₁(t) per t → 0⁺, non un valore raggiunto.

**2. ★★★ «agents 2, …, 6 receive the same total weight from the others»** (§2.2.3)
- **Cosa non torna:** alla lettera è falso in A(t). Sul ciclo la colonna 2 somma a 1 − t; sull'anello le colonne 2 e 6 sommano a 1 − t/2; la colonna 1 somma a 1 + t. In più il report non dice perché la soluzione trovata con la sostituzione è proprio la social power.
- **Risposta:** la frase va letta in A(0), dove ogni colonna somma a 1 (A(0) è doubly-stochastic). Per t > 0 cambia solo la riga dell'agente 1. Gli agenti che l'agente 1 ascolta ricevono da lui (1 − t)a₁ⱼw₁, che è uguale ad a₁ⱼb perché (1 − t)w₁ = b: la stessa quota di prima da un agente di peso b. La soluzione è unica perché per t > 0 l'autovalore 1 è semplice (condizione (A1) del Teorema 2.2). È il ragionamento della slide 13.

**3. ★★★ «Λ < Iₙ»** (Corollary 3.3; Figura 10: «every agent is prejudiced (Λ < I₆)»)
- **Cosa non torna:** nella §1.1.2 il report dichiara che le disuguaglianze fra matrici valgono entrata per entrata. Con questa convenzione Λ < Iₙ non è mai vera: fuori dalla diagonale darebbe 0 < 0.
- **Risposta:** la notazione è quella del tutorial e, per matrici diagonali, vuol dire λᵢ < 1 per ogni i. L'enunciato della Corollary 3.3 non si può cambiare perché è la frase della fonte; nel testo della Figura 10 sarebbe stato più corretto scrivere «λᵢ < 1 for every i».

**4. ★★ «the social power is uniformly distributed between all agents»** (§3.1.4, caso α = 0)
- **Cosa non torna:** lì si parla di c₀ = n⁻¹𝟙, cioè della influence centrality, non della social power.
- **Risposta:** è la formulazione del tutorial, che usa «social power» in senso lato per la misura di Friedkin. Nel lessico del report è la influence centrality.

**5. ★★ «when every agent is influenced by a prejudiced agent»** (Abstract; Conclusioni)
- **Cosa non torna:** non coincide con la Definition 3.1. Un agente prejudiced non è «influenzato da un prejudiced», eppure è P-dependent; e non è chiaro se l'influenza debba essere diretta.
- **Risposta:** si intende «tutti gli agenti sono P-dependent». Ogni agente è prejudiced, oppure è collegato da un cammino, diretto o indiretto, ad almeno un agente prejudiced, non necessariamente lo stesso per tutti.

**6. ★★ La seconda riscrittura: «λᵢ = 1 − aᵢ₁, wᵢⱼ = aᵢⱼ/λᵢ»** (§3.2.1)
- **Cosa non torna:** se aᵢ₁ = 1, cioè l'agente ascolta solo lo stubborn, allora λᵢ = 0 e wᵢⱼ non è definito. Succede per l'agente 6 del ciclo a t = 1.
- **Risposta:** con λᵢ = 0 la riga di W è moltiplicata per zero, quindi va bene qualunque riga stocastica. Nel report la riscrittura è applicata all'anello, dove a₂₁ = a₆₁ = 1/2, e il problema non si presenta.

**7. ★ «oscillating between two configurations»** (§2.2.2, anello a t = 0)
- **Cosa non torna:** non è vero fin dall'inizio.
- **Risposta:** è vero asintoticamente. Le componenti sugli autovalori ±1/2 si smorzano, resta quella sull'autovalore −1, di periodo 2.

**8. ★ «Aperiodicity: always needed»** (Tabella 3, colonna FDG)
- **Cosa non torna:** non dice aperiodicità di cosa.
- **Risposta:** di ogni sink di C(G), cioè della rete intera se è fortemente connessa. Senza, si è nei casi (ii) o (v).

**9. ★ «an agent with a positive self-weight changes its opinion more slowly»** (§2.2.1)
- **Cosa non torna:** «più lentamente» rispetto a cosa?
- **Risposta:** rispetto al caso senza self-weight. A ogni passo copre solo la frazione 1 − aᵢᵢ della distanza verso la media pesata delle opinioni che ascolta: xᵢ(k+1) − xᵢ(k) = Σ_{j≠i} aᵢⱼ(xⱼ − xᵢ), con Σ_{j≠i} aᵢⱼ = 1 − aᵢᵢ.

**10. ★ La conclusione del Teorema 2.4, «lim x(k) = v ≠ α𝟙ₙ»**
- **Cosa non torna:** per x(0) = 𝟙 il limite è 𝟙.
- **Risposta:** è l'enunciato delle slide, e va letto come «il modello non va in consensus»: esiste almeno un x(0) per cui il limite non ha la forma α𝟙 (Definition 2.1).

**11. ★ Notazione: w (social power) e wᵢⱼ (entrate di W)**
- **Cosa non torna:** la stessa lettera per due oggetti diversi.
- **Risposta:** w è il vettore del teorema del consensus delle slide; il tutorial chiama la social power p∞. I pedici li distinguono: wᵢ è il vettore, wᵢⱼ la matrice.

---

## B. Affermazioni senza spiegazione (il prof può chiedere «perché?»)

**12. ★★★ Perché V è stocastica?** Il report lo prende dal Theorem 3.2 senza spiegarlo.
- Siccome W𝟙 = 𝟙, si ha (I − ΛW)𝟙 = (I − Λ)𝟙, quindi V𝟙 = (I − ΛW)⁻¹(I − Λ)𝟙 = 𝟙.
- V ≥ 0 perché (I − ΛW)⁻¹ = Σₖ(ΛW)ᵏ ≥ 0 (serie di Neumann, valida perché ρ(ΛW) < 1).

**13. ★★★ Perché Λ¹¹W¹¹ è Schur stabile anche quando ci sono agenti P-independent?** Il report lo spiega col Lemma 1.14 solo per r = n.
- Λ¹¹W¹¹ è row-substochastic.
- Ogni agente P-dependent con riga che somma a 1 raggiunge, passando solo per agenti P-dependent, un agente con riga che somma meno di 1: un prejudiced, oppure un agente che ascolta dei P-independent, perché togliere le colonne di W¹² abbassa la somma della riga.
- Il Lemma 1.14 dà quindi ρ(Λ¹¹W¹¹) < 1.

**14. ★★ Lemma 1.14 applicato a ΛW: gli agenti con λᵢ = 0 perdono i loro archi.** Il report legge la condizione del lemma sul grafo G di W, ma il grafo di ΛW è diverso.
- **Risposta:** la condizione non cambia. Lungo un cammino verso i prejudiced basta arrivare al primo prejudiced incontrato, e prima di lui tutti hanno λ = 1, quindi i loro archi esistono anche in ΛW.

**15. ★★★ Perché il FJ converge se ΛW è regolare, mentre x(k+1) = x(k) + u diverge (A = B = I)?** Il report cita il controesempio del tutorial ma non dice cosa salva il FJ.
- **Risposta:** l'ingresso (I − Λ)u entra solo negli agenti prejudiced, che stanno nel blocco P-dependent, Schur stabile. L'autovalore 1 sta in W²², cioè negli agenti P-independent, che non ricevono ingresso: le righe corrispondenti di I − Λ sono nulle.

**16. ★★★ Perché (1 − α)(I − αW)⁻¹ → 𝟙wᵀ per α → 1?** Nella discussione del Lemma 3.5 il report lo cita da [5] senza spiegarlo.
- **Risposta:** (1 − α)(I − αW)⁻¹ = Σₖ(1 − α)αᵏWᵏ è una media pesata delle potenze di W, con pesi che sommano a 1. Per α → 1 i pesi si spostano sulle potenze alte, dove Wᵏ → 𝟙wᵀ perché W è fully regular.

**17. ★★ «the social power … can be regarded as a centrality measure»** (§2.1.2) — quale centralità? Il report non lo dice.
- **Risposta:** la riga j di wᵀA = wᵀ è w_j = Σᵢ wᵢaᵢⱼ. Un agente conta in base a quanto è ascoltato e da chi: essere ascoltati da agenti che contano di più vale di più.

**18. ★★ «All the entries of V are positive, since W is irreducible»** (Figura 10) — il passaggio manca.
- **Risposta:** V = 0.2 Σₖ(0.8W)ᵏ. W è irriducibile, quindi per ogni coppia (i, j) esiste un k con (Wᵏ)ᵢⱼ > 0, e quindi Vᵢⱼ > 0.

**19. ★★ La coupling condition 1 − λᵢ = wᵢᵢ** (§3.1.1) — il report dice solo che non la impone, «As in [5]». Il prof può chiedere il motivo concreto.
- **Risposta:** nelle nostre reti W non ha self-loop (wᵢᵢ = 0). La coupling darebbe λᵢ = 1 per tutti, quindi nessun prejudice, e il FJ coinciderebbe col FDG.

**20. ★ Il Remark 2.7 è vostro?** Il report non lo dice.
- **Risposta:** combina la Corollary 2.6 (convergenza quando gli stubborn influenzano tutti, dal tutorial) con il Theorem 2.4 (dalle slide). Per la forma del limite rimanda a [5].

**21. ★★ «we do not compare them directly, but in parallel»** (§3.2.3) — l'espressione è vaga.
- **Risposta:** w pesa lo stato iniziale di un modello che ricorda x(0), il FDG; c pesa l'ingresso u = x(0) di un modello che dimentica x(0), il FJ. Non sono la stessa grandezza: si confronta come si comportano nei due modelli, non i valori. Coincidono solo nel limite del Lemma 3.5.

---

## C. Cose che il report non dice ma che le figure fanno chiedere

**22. ★★ «the attachment only changes how fast it is reached»** (Figura 9) — quanto velocemente?
- **Risposta (conto nostro):** sul ciclo ΛW ha polinomio caratteristico μ⁶ − λ₁, quindi ρ(ΛW) = λ₁^{1/6} ≈ 0.891 per λ₁ = 1/2. Sull'anello vale 0.924 (calcolato). Più l'attachment è debole (λ₁ vicino a 1), più la convergenza è lenta.

**23. ★★★ Perché c₂ scende sotto w₂ sul ciclo?** (Figura 13: minimo ≈ 0.137 a α ≈ 0.65)
- **Risposta onesta:** il Lemma 3.5 dà solo il limite, non dice che c_α sia monotona. È un'osservazione numerica (minimo 0.1369 a α ≈ 0.653) per cui non abbiamo una spiegazione teorica.

**24. ★★★ E con la rete originale W = A(0), cosa farebbe c_α?** Il report spiega solo che il lemma chiede W fully regular.
- **Risposta:** A(0) è periodica, quindi non fully regular, e il lemma non si applica. In più è doubly-stochastic, quindi lo è anche V_α, e c_α = 𝟙/6 per ogni α: la curva sarebbe piatta (verificato). Per questo serve A(1/2).

**25. ★★ Numeri che le figure mostrano ma il testo non scrive**
- **Figura 10, limiti del FJ:**
  - ciclo ≈ (0.374, 0.467, 0.534, 0.567, 0.559, 0.499);
  - anello ≈ (0.394, 0.378, 0.451, 0.549, 0.622, 0.606).
- **Figura 10, influence centrality:** c = 𝟙/6 su entrambe le reti, perché W è doubly-stochastic. Come nel FDG con A = 0.2I + 0.8W.
- **Rete ausiliaria, social power (0.4, 0.4, 0.2) del gruppo chiuso:** si ricava da wᵀW = wᵀ sul blocco [[0,1,0],[½,0,½],[1,0,0]]. Si ottiene w₁ = w₂ e w₃ = w₂/2, con somma 1.

**26. ★ Perché la Figura 3 è «computed numerically», se c'è la formula chiusa?** Il report non lo dice.
- **Risposta:** il calcolo numerico (autovettore sinistro di A(t), normalizzato) è la verifica della formula sulle due reti: le curve coincidono con w(t) e con 3(1 − t)/(6 − 5t).

**27. ★ Scelte non motivate nel report**
- **x(0) = (0, 0.2, …, 1):** valori equidistanti, con l'agente 1 a 0, così il suo peso si vede subito nel valore di consensus, che va da 0.5 a 0.
- **Il peso 0.2 della Figura 10:** è lo stesso peso nei due modelli, abbastanza piccolo da lasciare agire la rete.
