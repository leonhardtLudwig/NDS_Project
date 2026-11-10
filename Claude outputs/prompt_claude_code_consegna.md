Obiettivo: creare `FINAL/code/` con una copia di tutto il codice da consegnare insieme al report.

Regole:
- Lavora solo su copie dentro `FINAL/code/`. Non modificare né cancellare niente fuori da lì, e in particolare non toccare `livescripts/`, `lib/` e `FINAL/report/`.
- **Nei live script non deve esserci nessuna funzione locale.** Ogni funzione va definita in libreria, un file per funzione. I live script servono solo ad applicare le funzioni, vedere i risultati e fare i grafici.
- Nella Part 1 dei live script il testo teorico è mio. Puoi solo togliere parti intere e correggere riferimenti; non riscrivere, non riassumere, non aggiungere teoria.
- Le figure e i numeri prodotti devono restare identici a quelli di oggi.
- Prima di qualsiasi modifica, mostrami il piano completo (cosa togli, quali funzioni sposti e dove, che nomi dai) e aspetta il mio ok.

## 1. Pulizia del testo dei live script

Copia `livescripts/ch01_fdg_report.mlx` e `livescripts/ch04_fj_report.mlx` in `FINAL/code/`. Devono contenere solo la teoria e le figure usate nel report.

Per decidere cosa togliere, confronta ogni elemento della Part 1 con il report (`FINAL/report`). I candidati che ho già individuato sono qui sotto; verificali uno per uno e aggiungi quelli che trovi tu.

**`ch01_fdg_report.mlx`:**
- titolo della Part 1: togli "(from ch01_fdg_v6.mlx, Sections 1.1–1.4)";
- §1.3: togli i paragrafi sulla catena di Markov duale e sull'ergodicità. Tieni la definizione di social power e l'Example 1.3 (n = 3, w = (2/7, 3/7, 2/7)), che sono nel report;
- §1.3: togli la chiamata `plot_eigenvalues`, perché il report non ha grafici dello spettro;
- §1.4: togli il blocco di codice dell'Example 1.4, che non è nel report. Tieni il testo sugli agenti stubborn;
- Settings: togli il riferimento a `FINAL/report/figures`.

**`ch04_fj_report.mlx`:**
- titolo della Part 1: togli "(from ch04_fj_v3.mlx, Sections 4.1–4.3)";
- §4.1: togli le due frasi su Taylor ("discrete-time modification of Taylor's model", "same role as the coefficients γ_i in Taylor's model");
- §4.1: verifica se la "coupling condition" 1 − λ_i = w_ii compare nel report; se non c'è, toglila;
- §4.3: togli "and PageRank" dal titolo e ogni frase su PageRank;
- Settings: togli il riferimento a `FINAL/report/figures`.

**Tabella di corrispondenza:**
- All'inizio della Part 2 del live script FDG aggiungi una tabella come quella che c'è già nel FJ: "Lemma x (Part 1) = Theorem y (report) = Theorem z in [5]".
- Prendi i numeri del report da `main.aux` dopo aver compilato il report in una cartella temporanea, non nella cartella originale. Attenzione: nella Sezione 2 è stata aggiunta la Definizione 2.1, quindi i teoremi della Sezione 2 sono scalati di uno.
- Ricontrolla anche la tabella del FJ.

## 2. Funzioni locali → libreria

Oggi i due live script definiscono in fondo, nella sezione "Local functions", queste funzioni con prefisso `rep_`:

- **FDG:** `rep_cycle_matrix`, `rep_ring_matrix`, `rep_self_weight`, `rep_simulate`, `rep_social_power`, `rep_sort_eig`, `rep_fmt_eig`, `rep_tex_frac`, `rep_new_figure`, `rep_save_eps`.
- **FJ:** `rep_cycle_matrix`, `rep_ring_matrix`, `rep_self_weight`, `rep_sim_fdg`, `rep_sim_fj`, `rep_Vmat`, `rep_fj_limit`, `rep_centrality`, `rep_social_power`, `rep_draw_traj`, `rep_finish_axes`, `rep_shared_legend`, `rep_agent_proxies`, `rep_strip_tex`, `rep_new_figure`, `rep_check`, `rep_save_eps`.

Per ognuna:
1. **Se in `lib/` esiste già una funzione che fa la stessa cosa, usa quella.** Candidati:
   - `rep_social_power` → `social_power`;
   - `rep_simulate` / `rep_sim_fdg` → `sim_degroot`;
   - `rep_sim_fj` → `sim_friedkin_johnsen`;
   - `rep_Vmat` → `total_influence`;
   - `rep_fj_limit` → `fj_equilibrium`;
   - `rep_centrality` → `influence_centrality`.

   Verifica numericamente che dia lo stesso risultato sulle matrici del report. Attenzione alla direzione degli archi: per esempio `ring_graph` di `lib/` fa ascoltare l'agente i−1, mentre nel report l'agente i ascolta i+1. **Se non è identica, non usarla**: non cambiare la rete né la numerazione degli agenti.
2. **Altrimenti crea una nuova funzione in libreria:**
   - senza prefisso `rep_`, con un nome coerente con quelli di `lib/`;
   - nella sottocartella giusta: `matrices` per le matrici, `models` per le simulazioni, `analysis` per le formule, `viz` per i grafici, `internal` per formattazione e check;
   - con l'intestazione di help nello stesso stile delle altre funzioni di `lib/`.
3. Le funzioni comuni ai due live script (`cycle`, `ring`, `self_weight`, `social_power`, `new_figure`, `save_eps`) vanno definite una volta sola.
4. Prima di creare un nome nuovo, controlla con `which -all` che non vada in conflitto con funzioni di `lib/` o di MATLAB.
5. Togli dai live script la sezione "Local functions", insieme alla frase sui "helpers of make_fdg_figures.m / make_fj_figures.m", e sostituisci le chiamate.

## 3. Libreria da consegnare

- Calcola le dipendenze dei due live script finali: le funzioni che chiamano, più quelle chiamate da loro, ricorsivamente.
- Metti in `FINAL/code/lib/` solo quelle (le esistenti copiate da `lib/`, più le nuove), nelle stesse sottocartelle. Non copiare le altre e non segnarle come deprecated.
- Copia `setup_paths.m` in `FINAL/code/` e, nella copia, lascia solo le cartelle che esistono.
- Scrivi `FINAL/code/README.md`, breve e in inglese:
  - cosa contiene la cartella;
  - come si eseguono i live script;
  - la convenzione sulla direzione degli archi;
  - la tabella delle funzioni incluse.
  - Niente su Abelson, Taylor, dataset, test o `docs/`.
- Non copiare `docs/`, `tests/`, `data/`, `Prove/`, `claude_livescripts/`, le versioni vecchie dei live script, né il `README.md` originale.

## 4. Come modificare i `.mlx`

Sono zip. Modifica `matlab/document.xml` togliendo interi paragrafi `<w:p>` e cambiando solo le righe di codice necessarie, poi ricomprimi mantenendo la struttura del pacchetto. Non convertirli in `.m`, perché si perdono le equazioni e la formattazione. Dopo le modifiche mostrami il diff del testo e del codice estratti, prima e dopo.

## 5. Verifica

1. **Prima di toccare qualsiasi cosa**, esegui i live script originali con `saveEps = true` e `outDir` = cartella temporanea A, e salva l'output stampato.
2. Alla fine esegui i live script di `FINAL/code/` con il path di MATLAB pulito (`restoredefaultpath`), `saveEps = true` e `outDir` = cartella temporanea B.
3. Entrambi devono stampare `ALL CHECKS PASSED`, con gli stessi numeri della prima esecuzione. Controlla con `which` che ogni funzione usata venga presa da `FINAL/code/lib/`.
4. Confronta le `.eps` di A e di B, e anche quelle di `FINAL/report/figures/` (`fdg_convergence`, `fdg_social_power`, `fj_stubborn_equivalence`, `fj_stubborn_perturbation`, `fj_one_prejudiced`, `fj_all_prejudiced`, `fj_auxiliary`, `fj_lemma24`). Convertile in PNG e confrontale: devono avere lo stesso contenuto.
5. Se ci riesci, salva i live script con gli output incorporati (per esempio con `matlab.internal.liveeditor.executeAndSave`), così le figure si vedono senza eseguire. Se non funziona, dimmelo e lo faccio io a mano.
6. Se un check fallisce o una figura è diversa, fermati e dimmelo: non correggere di testa tua.

## 6. Alla fine

Dammi:
- l'albero di `FINAL/code/`;
- le modifiche fatte al testo dei live script;
- la tabella "funzione locale → funzione di libreria", indicando se era esistente o nuova;
- l'output dei check;
- l'esito del confronto delle figure.
