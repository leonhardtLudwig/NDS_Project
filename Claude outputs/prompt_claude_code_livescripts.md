# Prompt per Claude Code: due live script con la teoria e le simulazioni del report NDS

Lavora nella cartella del progetto `NDS_Project` (la radice è la cartella che contiene `setup_paths.m`). MATLAB è R2025b. Lavora in autonomia e alla fine scrivi il resoconto richiesto in fondo. Non fare commit.

## Obiettivo

Crea due nuovi live script, e nient'altro:

- `livescripts/ch01_fdg_report.mlx`: modello French–Harary–DeGroot (FDG)
- `livescripts/ch04_fj_report.mlx`: modello Friedkin–Johnsen (FJ)

Ognuno ha due parti:

1. **Parte 1 – Teoria:** la teoria già scritta da me nei miei live script, copiata così com'è, con le sole correzioni elencate più sotto.
2. **Parte 2 – Simulazioni del report:** i blocchi che generano le figure del report, presi dagli script `FINAL/report/figures/make_fdg_figures.m` e `FINAL/report/figures/make_fj_figures.m`. Vanno nell'ordine del report, divisi in sezioni e commentati.

I live script sono in inglese, come il report.

## Regole

1. **Non modificare nessun file esistente:** né i `.mlx` in `livescripts/`, né `FINAL/report/**`, né `lib/**`, né `tests/**`, né `make_*_figures.m`. Se i due file di destinazione esistono già, fermati e chiedimi. Tieni i file di lavoro (script Python, `.m` intermedi, `.eps` di prova) in una cartella temporanea fuori dal progetto.
2. **Teoria:** testo, equazioni, elenchi e celle di codice devono restare identici all'originale. Le uniche eccezioni sono le correzioni della tabella più sotto. Non riscrivere, non riassumere e non aggiungere nulla. Se trovi altri punti che ti sembrano sbagliati, non toccarli e riportali nel resoconto.
3. **Codice delle figure:** copia il codice da `make_*_figures.m` senza cambiare dati, parametri, colori, stili, etichette o titoli. Sono ammesse solo queste modifiche:
   - **Funzioni locali:** rinominale con il prefisso `rep_` e aggiorna le chiamate, per esempio `social_power` → `rep_social_power`, `export` → `rep_export`, `new_figure` → `rep_new_figure`. Serve a evitare conflitti con `lib/`, che ha già `social_power`, e con la funzione MATLAB `export`. Mettile in fondo al live script.
   - **`rep_new_figure`:** deve creare figure visibili, quindi togli `'Visible','off'`. Altrimenti nel live script le figure non compaiono.
   - **Salvataggio `.eps`:** solo se `saveEps` è `true`, nella cartella `outDir`, mai in `FINAL/report/figures`; la variabile `here` degli script originali diventa `outDir`. Dopo il salvataggio non chiudere la figura (niente `close(fig)`).
   - **Parti comuni:** i parametri comuni (`n`, `x0`, matrici delle reti, colori degli agenti) vanno in una cella iniziale della Parte 2. Questa cella si apre con `clearvars -except saveEps outDir projectDir`, così le variabili degli esempi della teoria non interferiscono.
   - **Controlli numerici:** i controlli di ciascuna figura vanno subito dopo la figura a cui si riferiscono; se un controllo riguarda più figure, va dopo l'ultima. In fondo serve una cella di riepilogo che stampi `ALL CHECKS PASSED` oppure `SOME CHECKS FAILED`.
   - **Blocchi esclusi:** se una figura tenuta, o un suo controllo, usa variabili calcolate in un blocco escluso, porta solo il calcolo necessario, senza la figura, e segnalalo nel resoconto.
   - **Commenti di storia:** non copiare i commenti `REVISED` / `ADDED` / `Was:` né il codice vecchio commentato. La storia resta in `make_*_figures.m`.
4. **Commenti al codice:** in inglese. Per ogni passo dicono cosa calcola e quale modello o matrice usa, con il numero di equazione del report, e cosa mostra ogni pannello. Per i numeri usa `FINAL/report/main.aux`, che è aggiornato.
5. **Testo nuovo:** solo quello indicato in questo prompt, cioè titoli, intestazioni, didascalie prese dal report, la frase sulla convenzione degli archi e le corrispondenze di numerazione. Nient'altro.

## Struttura di ciascun live script

1. **Titolo:**
   - FDG: `The French–Harary–DeGroot model: theory and simulations of the report`
   - FJ: `The Friedkin–Johnsen model: theory and simulations of the report`
2. **Bootstrap:** la cella identica a quella dei miei live script, che risale fino a `setup_paths.m` e lo esegue.
3. **Impostazioni:** una cella con
   ```matlab
   if ~exist('saveEps','var'), saveEps = false; end
   if ~exist('outDir','var'),  outDir = fullfile(projectDir,'livescripts','report_figures'); end
   ```
   La cartella `outDir` va creata solo se `saveEps` è `true`.
4. **Parte 1 – Theory.**
   - Intestazione FDG: `Part 1 – Theory (from ch01_fdg_v6.mlx, Sections 1.1–1.4)`
   - Intestazione FJ: `Part 1 – Theory (from ch04_fj_v3.mlx, Sections 4.1–4.3)`
   - Prima della teoria va una sezione `Direction convention` con i paragrafi di testo della sezione «A: Direction convention» di `livescripts/ch00_preliminaries.mlx`. Escludi la sua cella di codice, che chiama `make_example_french3`, una funzione che non esiste in `lib/`. Togli anche la frase che inizia con `plot_network exposes this as an option`, perché `plot_network` non esiste. Subito dopo aggiungi questa frase:
     `In this live script, Part 1 follows Proskurnikov & Tempo, so a stubborn agent is a source node; the report and Part 2 follow the course convention (an edge i → j means that agent i is influenced by agent j), so the same agent is a sink.`
   - Poi viene la teoria:
     - FDG: le sezioni 1.1, 1.2, 1.3 e 1.4 di `livescripts/ch01_fdg_v6.mlx`, dall'intestazione «1.1 The French-DeGroot model of opinion formation» fino a prima di «1.5 Examples», celle di codice degli esempi comprese.
     - FJ: le sezioni 4.1, 4.2 e 4.3 di `livescripts/ch04_fj_v3.mlx`. Escludi l'intestazione vuota 4.4 e tutto ciò che viene dopo.
5. **Parte 2 – Simulations of the report.**
   - Intestazione FDG: `Part 2 – Simulations of the report (Section 2.2)`
   - Intestazione FJ: `Part 2 – Simulations of the report (Section 3.2)`
   - Solo nel live script FJ, all'inizio della Parte 2, aggiungi le corrispondenze di numerazione, come righe di testo:
     - `Theorem 4.1 (Part 1) = Theorem 3.2 (report) = Theorem 21 in [5]`
     - `Corollary 4.1 (Part 1) = Corollary 3.3 (report) = Corollary 22 in [5]`
     - `Corollary 4.2 (Part 1) = Corollary 3.4 (report) = Corollary 23 in [5]`
     - `Lemma 4.1 (Part 1) = Lemma 3.5 (report) = Lemma 24 in [5]`
   - Poi una sezione per figura, con questo schema:
     - **Intestazione:** `Figure N – <titolo della sottosezione del report>`
     - **Testo di riferimento:** `Report: Section X.Y.Z, paragraph «…», Figure N (FINAL/report/figures/<file>.eps).` Ometti `paragraph «…»` se la tabella non lo indica.
     - **Didascalia:** `Caption in the report:` seguito dalla didascalia, presa da `FINAL/report/main.aux` (terzo campo di `\newlabel{fig:…}`). Converti così:
       - `\ref` e `\eqref` diventano i numeri del report;
       - `\cite{proskurnikov2017tutorial}` diventa `[5]`;
       - `~` diventa uno spazio e `--` diventa `–`;
       - la matematica diventa equazioni del Live Editor.
     - **Codice commentato.**
     - **Controlli numerici** della figura.
6. **Riepilogo dei controlli.**
7. **Funzioni locali** (`rep_…`).

## Figure da inserire, nell'ordine del report

Live script FDG (`make_fdg_figures.m`):

| Figura del report | label | file | Posizione nel report | Blocco in `make_fdg_figures.m` |
|---|---|---|---|---|
| 2 | `fig:fdg-conv` | `fdg_convergence.eps` | Section 2.2.2 *Self-weights, stubbornness and convergence* | `% Figure 1 - trajectories` |
| 3 | `fig:fdg-power` | `fdg_social_power.eps` | Section 2.2.3 *Self-weights, stubbornness and social power* | `% Figure 2 - social power of agent 1, and the resulting consensus value` |

I controlli 1–7 della sezione `% Numerical checks` vanno distribuiti dopo la figura a cui si riferiscono.

Live script FJ (`make_fj_figures.m`):

| Figura del report | label | file | Posizione nel report | Blocco in `make_fj_figures.m` |
|---|---|---|---|---|
| 6 | `fig:fj-stub-equivalence` | `fj_stubborn_equivalence.eps` | Section 3.2.1 *Modelling stubbornness: prejudices and stubborn agents*, paragraph «The stubborn agent as an input» | `% Figure 1 - stubborn agent: FDG with A(1) equals FJ with lambda_1 = 0` |
| 7 | `fig:fj-stub-perturbation` | `fj_stubborn_perturbation.eps` | Section 3.2.1, paragraph «State or input» | `% Figure 2 - the same two models started from x_1(0) = 0.5` |
| 9 | `fig:fj-one-prejudiced` | `fj_one_prejudiced.eps` | Section 3.2.2 *Prejudices, stubbornness and convergence*, paragraph «A single prejudice» | `% Figure 4 - one prejudiced agent, attachment 1 - lambda_1 = 1/2` |
| 10 | `fig:fj-all-prejudiced` | `fj_all_prejudiced.eps` | Section 3.2.2, paragraph «Every agent prejudiced» | `% Figure 5 - every agent gives weight 0.2 to its own opinion: FDG against FJ` |
| 12 | `fig:fj-auxiliary` | `fj_auxiliary.eps` | Section 3.2.2, paragraph «Where the prejudice does not arrive» | `% Figure 6 - auxiliary network, P-dependent and P-independent agents` |
| 13 | `fig:fj-lemma24` | `fj_lemma24.eps` | Section 3.2.3 *Prejudices, stubbornness and influence centrality*, paragraph «Where the two measures meet» | `% Figure 8 - Lemma 24: c_alpha tends to the social power` |

Blocchi da escludere, perché le loro figure non sono nel report: `Figure 0` (`fj_stub_reduction`), `Figure 3` (`fj_error`), `Figure 3b` (`fj_delta_vs_error`), `Figure 7` (`fj_influence_centrality`).

## Correzioni ammesse nella teoria (solo queste)

Applica ogni correzione nel paragrafo indicato, lasciando intatto il resto del paragrafo. «(eq.)» vuol dire che il testo da cambiare sta dentro un'equazione (LaTeX). Nelle stringhe, `$…$` indica un'equazione del Live Editor.

**`ch01_fdg_v6.mlx`**

| Sezione | Testo attuale | Testo corretto |
|---|---|---|
| 1.1 | (eq.) `X = (x_{ii})\in \mathbb R ^ {n \times m}` | `X = (x_{ij})\in \mathbb R ^ {n \times m}` |
| 1.1 | `evolves in accordance to M1. Hence M2 with` | `evolves in accordance to M1.1. Hence M1.2 with` |
| 1.2 (intestazione) | `Conensus` | `Consensus` |
| 1.2 | `Lyapunov stable but it such stability` | `Lyapunov stable but such stability` |
| 1.2 | `the limits exists` | `the limit exists` |
| 1.2 | `reaches consensu if` / `initial coniditon` | `reaches consensus if` / `initial condition` |
| 1.2 | `$W$regular` (manca lo spazio dopo l'equazione) | `$W$ regular` |
| 1.2, Lemma 1.1 | `unit cricle` / `reaches consensu (ie` / `$\iff$this eigenvalue` | `unit circle` / `reaches consensus (ie` / `$\iff$ this eigenvalue` |
| 1.2, Lemma 1.2 | `irreducibile stochastic matric` / `isp rimitive` | `irreducible stochastic matrix` / `is primitive` |
| 1.2, Lemma 1.3 | `the grap` / `is stroing` / `reaches a consensu` | `the graph` / `is strong` / `reaches a consensus` |
| 1.3 | `convrrges` | `converges` |
| 1.3 | `its history and convergence to the unique stationary distribution` | `its history and converges to the unique stationary distribution` |
| 1.3, (E1.1) | (eq.) `x(k+1) = W^kx(0)` | `x(k) = W^kx(0)` |
| 1.3 | `eigenvecotr` / `functions pf the graph` | `eigenvector` / `functions of the graph` |
| 1.3 | paragrafo che inizia con `lot_graph(W, [], 'Title','Example 1.3', 'Subtitle','matrix W') One can expect` (codice finito nel testo) | togli il pezzo di codice: il paragrafo inizia con `One can expect` |
| 1.3 | `sgent` / `Thisiis` | `agent` / `This is` |
| 1.4 | `opnly` / `obiously` | `only` / `obviously` |
| 1.4, Corollary 1.2 | `all other nodes of $\mathcal G[W]$. Then` (parentesi non chiusa) | `all other nodes of $\mathcal G[W]$). Then` |
| 1.4, cella di codice dell'Example 1.4 | `'Title','Example 1.3'` (in `plot_opinions` e in `plot_eigenvalues`) | `'Title','Example 1.4'` |

**`ch04_fj_v3.mlx`**

| Sezione | Testo attuale | Testo corretto |
|---|---|---|
| 4.1 | `a discrete-time modification of the dynamics M3.2` | `a discrete-time modification of Taylor's model` |
| 4.1 | `the coefficients $\gamma_i$ in model M3.2` | `the coefficients $\gamma_i$ in Taylor's model` |
| 4.1 | `social infleunces` / `constant vecotr` | `social influences` / `constant vector` |
| 4.1, primo punto dell'elenco | (eq.) `\Lambda = 0` e `M4.1turns` | `\Lambda = I` e `M4.1 turns` (con Λ = I il modello FJ diventa il FDG) |
| 4.1 | `factors its intro any opinion iteration` / `the first tep` | `factors it into any opinion iteration` / `the first step` |
| 4.1 | `Friedking-Johnsen` / (eq.) `u 0 x(0)` / `independet` | `Friedkin-Johnsen` / `u = x(0)` / `independent` |
| 4.2 | `the prjudice` / `opinion vecotr` | `the prejudice` / `opinion vector` |
| 4.2 | `Since PD agents are, by definition, not prejudiced` | `Since PI agents are, by definition, not prejudiced` |
| 4.2, (M4.1.1) | (eq.) `x_1(k+1) = \Lambda^{11}[W^{11}-x_1(k)+W^{12}x_2(k)]-(I-\Lambda^{11})u_1` | `x_1(k+1) = \Lambda^{11}[W^{11}x_1(k)+W^{12}x_2(k)]+(I-\Lambda^{11})u_1` |
| 4.2 | `$V$is stochastic` / `irreducibile` | `$V$ is stochastic` / `irreducible` |
| 4.2 | cella di codice che contiene solo `% esempio 3 del paper` | togli la cella |
| 4.3 | `the angets converge to the same consensu opinion` | `the agents converge to the same consensus opinion` |
| 4.3 | `infleunce wieghts` / `adapted to  given graph` | `influence weights` / `adapted to a given graph` |
| 4.3 | parte sul PageRank: dal paragrafo che inizia con `The class of Friedkin's centrality measures` fino alla fine della 4.3 (equazione M4.2 compresa) | togli tutto: la 4.3 si chiude con il paragrafo che inizia con `Indeed $V_\alpha = (1-\alpha)(I-\alpha W)^{-1}` |

Punti dubbi da **non** correggere, ma da riportare nel resoconto, insieme ad altri che trovi:

- 1.1: `w_{ij}>0` (forse dovrebbe essere `\ge 0`);
- 1.1: `x^i = (x_{1i}, \dots,x_{mi})` (indici forse invertiti);
- 1.3: (M1.3) usa `t = 0,1,\dots` mentre l'equazione usa `k`;
- 4.2: «a walk from j to i exists in the graph $\mathcal G [A]$», dove `A` non è ancora definita.

## Come costruire i `.mlx` (consiglio)

Il `.mlx` è uno ZIP (OPC) con `[Content_Types].xml`, `_rels/.rels`, `matlab/document.xml`, `matlab/output.xml` e `metadata/*.xml`. Nei miei file, `matlab/document.xml` usa queste strutture:

- **Paragrafo:**
  ```xml
  <w:p><w:pPr><w:pStyle w:val="STYLE"/><w:jc w:val="left"/></w:pPr><w:r><w:t>…</w:t></w:r></w:p>
  ```
  Gli stili sono `title`, `heading`, `text` e `ListParagraph`.
- **Equazione nel testo:**
  ```xml
  <w:customXml w:element="equation"><w:customXmlPr><w:attr w:name="displayStyle" w:val="false"/></w:customXmlPr><w:r><w:t>LATEX</w:t></w:r></w:customXml>
  ```
- **Cella di codice:** un solo paragrafo per cella, con le righe in un CDATA.
  ```xml
  <w:p><w:pPr><w:pStyle w:val="code"/></w:pPr><w:r><w:t><![CDATA[…righe…]]></w:t></w:r></w:p>
  ```
- **Separatore di sezione:**
  ```xml
  <w:p><w:pPr><w:sectPr/></w:pPr></w:p>
  ```

Approccio consigliato:

- **Teoria:** copia i paragrafi `<w:p>` direttamente dal `document.xml` originale, applicando solo le correzioni. Così testo ed equazioni restano identici.
- **Parti nuove:** genera i paragrafi con le stesse strutture viste sopra.
- **Pacchetto:** riusa `[Content_Types].xml`, `_rels` e `metadata` del `.mlx` sorgente.
- **Output:** gli output vecchi non devono comparire. Puoi togliere `output.xml` e i suoi riferimenti, oppure usare un `output.xml` vuoto e valido. Verifica con MATLAB che il file si apra e giri.

Puoi usare un altro metodo affidabile, purché tutte le verifiche qui sotto passino.

## Verifiche obbligatorie

1. **MATLAB da terminale:** controlla se è disponibile, per esempio con `which matlab` o con `/Applications/MATLAB_R2025b.app/bin/matlab`.
2. **Esecuzione:** dalla radice del progetto lancia
   ```
   matlab -batch "run('livescripts/ch01_fdg_report.mlx')"
   ```
   e lo stesso per `ch04_fj_report.mlx`. Devono girare senza errori, anche negli esempi della teoria, e stampare `ALL CHECKS PASSED`.
3. **Figure identiche al report:** esegui i due live script con
   ```
   matlab -batch "saveEps=true; outDir=tempname; mkdir(outDir); run('livescripts/…')"
   ```
   e confronta gli `.eps` ottenuti con quelli in `FINAL/report/figures/`, ignorando le righe di intestazione che iniziano con `%%`. Se restano differenze e Ghostscript è disponibile, rasterizza entrambe le versioni e confronta i pixel. Riporta l'esito figura per figura.
4. **Teoria:** estrai il testo, con il LaTeX delle equazioni, della Parte 1 del nuovo file e delle sezioni sorgenti. Fai un diff: le uniche differenze ammesse sono le correzioni della tabella.
5. **Codice:** fai un diff di ogni blocco della Parte 2 contro le righe corrispondenti di `make_*_figures.m`. Le uniche differenze ammesse sono le modifiche elencate nella regola 3.
6. **Senza MATLAB da terminale:** consegna comunque i file, esegui le verifiche 4 e 5, e scrivimi i comandi da lanciare io.

## Resoconto finale

Scrivimi in italiano:

- i file creati;
- le correzioni applicate alla teoria (prima → dopo);
- i punti dubbi non toccati;
- le modifiche al codice rispetto a `make_*_figures.m`, compresi i calcoli portati dai blocchi esclusi;
- l'esito di ogni verifica;
- eventuali problemi rimasti aperti.
