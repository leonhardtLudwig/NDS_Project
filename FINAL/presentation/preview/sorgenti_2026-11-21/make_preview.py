"""Preview of the changes: modified slides (before / after) and the outline with the
changes highlighted against the previous version (blue = new text, red struck = removed).

usage: python3 make_preview.py <new canovaccio.tex> <old canovaccio.tex> <slides.json> <out.tex>
The out.tex is compiled in the folder of the new canovaccio: ../main.{pdf,aux} is the new
presentation, OLDPRES (in slides.json) the old one.
"""
import re, sys, json, difflib

new_path, old_path, slides_path, out_path = sys.argv[1:5]
cfg = json.load(open(slides_path))


def read_arg(s, i):
    """s[i] == '{': return (content, index after the closing brace)."""
    assert s[i] == '{', s[i:i + 30]
    depth, j = 0, i
    while True:
        c = s[j]
        if c == '\\':
            j += 2
            continue
        if c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
            if depth == 0:
                return s[i + 1:j], j + 1
        j += 1


def parse(path):
    s = open(path).read()
    pre = s[:s.index('\\begin{document}')]
    s = pre + '\n'.join(re.sub(r'(?<!\\)%.*$', '', l) for l in s[len(pre):].split('\n'))
    body = s[s.index('\\begin{document}'):s.index('\\end{document}')]
    seq = []
    pat = re.compile(r'\\parte\{|\\begin\{(slide|slidedue|slidetre|slidepag)\}')
    pos = 0
    while True:
        m = pat.search(body, pos)
        if not m:
            break
        if m.group(0).startswith('\\parte'):
            a, k = read_arg(body, m.end() - 1)
            b, k = read_arg(body, k)
            seq.append({'kind': 'parte', 'title': a, 'time': b})
            pos = k
            continue
        env = m.group(1)
        k = m.end()
        a1, k = read_arg(body, k)
        a2, k = read_arg(body, k)
        a3, k = read_arg(body, k)
        endtag = '\\end{%s}' % env
        e = body.index(endtag, k)
        inner = body[k:e]
        items = []
        if '\\begin{discorso}' in inner:
            d = inner[inner.index('\\begin{discorso}') + len('\\begin{discorso}'):inner.index('\\end{discorso}')]
            for chunk in re.split(r'\\item\b', d)[1:]:
                items.append(' '.join(chunk.split()))
        key = a1 if env != 'slidepag' else 'pag:' + a2
        seq.append({'kind': 'block', 'env': env, 'a1': a1, 'title': a2, 'time': a3,
                    'items': items, 'key': key})
        pos = e + len(endtag)
    return pre, seq


new_pre, new_seq = parse(new_path)
old_pre, old_seq = parse(old_path)
old_blocks = {b['key']: b for b in old_seq if b['kind'] == 'block'}
old_order = [b['key'] for b in old_seq if b['kind'] == 'block']
old_parts = [b for b in old_seq if b['kind'] == 'parte']

# moved blocks: not in the longest increasing subsequence of old positions
new_keys = [b['key'] for b in new_seq if b['kind'] == 'block' and b['key'] in old_blocks]
idx = [old_order.index(k) for k in new_keys]
n = len(idx)
best, prev = [1] * n, [-1] * n
for i in range(n):
    for j in range(i):
        if idx[j] < idx[i] and best[j] + 1 > best[i]:
            best[i], prev[i] = best[j] + 1, j
i = max(range(n), key=lambda q: best[q]) if n else -1
lis = set()
while i != -1:
    lis.add(new_keys[i])
    i = prev[i]
moved = set(new_keys) - lis

def tokenize(text):
    toks, cur, depth, math, i = [], '', 0, False, 0
    while i < len(text):
        c = text[i]
        if c == '\\' and i + 1 < len(text):
            cur += text[i:i + 2]
            i += 2
            continue
        if c == '$':
            math = not math
        elif c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
        if c.isspace() and depth == 0 and not math:
            if cur:
                toks.append(cur)
            cur = ''
        else:
            cur += c
        i += 1
    if cur:
        toks.append(cur)
    return toks


class _T:
    findall = staticmethod(tokenize)


TOK = _T


def del_run(tokens):
    out, plain = [], []
    def flush():
        if plain:
            out.append('{\\color{red}%s}' % ' '.join('\\barrato{%s}' % w for w in plain))
            plain.clear()
    for t in tokens:
        if '$' in t or '\\' in t or '{' in t or '}' in t:
            flush()
            out.append('{\\color{red}%s}' % t)
        else:
            plain.append(t)
    flush()
    return ' '.join(out)


def add_run(tokens):
    return '{\\color{blue}%s}' % ' '.join(tokens)


def word_diff(a, b):
    ta, tb = TOK.findall(a), TOK.findall(b)
    sm = difflib.SequenceMatcher(None, ta, tb, autojunk=False)
    out = []
    for op, i1, i2, j1, j2 in sm.get_opcodes():
        if op == 'equal':
            out.append(' '.join(tb[j1:j2]))
        else:
            if i2 > i1:
                out.append(del_run(ta[i1:i2]))
            if j2 > j1:
                out.append(add_run(tb[j1:j2]))
    return ' '.join(out)


def items_diff(old_items, new_items):
    rows = []
    sm = difflib.SequenceMatcher(None, old_items, new_items, autojunk=False)
    for op, i1, i2, j1, j2 in sm.get_opcodes():
        if op == 'equal':
            rows += new_items[j1:j2]
            continue
        olds, news = old_items[i1:i2], new_items[j1:j2]
        # pair similar items in order
        oi = 0
        for nw in news:
            best_k, best_r = None, 0.45
            for k in range(oi, len(olds)):
                r = difflib.SequenceMatcher(None, olds[k], nw, autojunk=False).ratio()
                if r > best_r:
                    best_k, best_r = k, r
            if best_k is None:
                rows.append(add_run(TOK.findall(nw)))
            else:
                for k in range(oi, best_k):
                    rows.append(del_run(TOK.findall(olds[k])))
                rows.append(word_diff(olds[best_k], nw))
                oi = best_k + 1
        for k in range(oi, len(olds)):
            rows.append(del_run(TOK.findall(olds[k])))
    return rows


# ------------------------------------------------------------------ preamble
pre = new_pre
pre = pre.replace('\\externaldocument[P-]{../main}  % legge ../main.aux',
                  '\\externaldocument[P-]{../main}  %% la presentazione nuova\n'
                  '\\externaldocument[O-]{%s}  %% la presentazione precedente' % cfg['oldpres'])
pre += r'''
%% testo tolto: barrato parola per parola (senza pacchetti esterni)
\newsavebox{\barratobox}
\newcommand{\barrato}[1]{\leavevmode\sbox{\barratobox}{#1}%%
  \rlap{\rule[0.55ex]{\wd\barratobox}{0.5pt}}\usebox{\barratobox}}
\newcommand{\vecchia}{%s.pdf}
\newcommand{\pgO}[1]{\getpagerefnumber{O-#1}}
\newcommand{\frO}[1]{\getrefnumber{O-#1}}
\newcommand{\miniO}[1]{{\setlength{\fboxsep}{0pt}%%
  \fbox{\includegraphics[page=#1,width=\dimexpr\linewidth-2\fboxrule\relax]{\vecchia}}}}
\newcommand{\etichetta}[2]{\,{\setlength{\fboxsep}{1.5pt}\colorbox{#1}{\scriptsize\bfseries\color{white}#2}}}
\newcommand{\nuova}{\etichetta{blue}{NUOVA}}
\newcommand{\spostata}{\etichetta{orange}{SPOSTATA}}
\newcommand{\divisa}{\etichetta{teal}{DIVISA}}
\newcommand{\toltatesto}[1]{{\color{red}\barrato{#1}}}
''' % cfg['oldpres']

out = [pre, '\\begin{document}\n']
out.append(r'''\begin{center}
  {\LARGE\bfseries Preview delle modifiche}\\[3pt]
  {\large Presentazione e canovaccio, discussione NDS del 26/11}\\[2pt]
  {\small\color{gray} Versione del \today. Confronto con la versione precedente: %s}
\end{center}

\textbf{Legenda.} {\color{blue}Blu}: testo nuovo. {\color{red}\barrato{Rosso barrato}}: testo
tolto (le formule tolte sono solo in rosso). \nuova: slide o blocco nuovo.
\spostata: slide spostata. \divisa: slide divisa in due.
''' % cfg['oldnote'])

# ------------------------------------------------------------------ part A: slides
out.append('\\section*{Slide modificate: prima e dopo}\n')
out.append(cfg['intro'] + '\n')
for e in cfg['slides']:
    # each entry in a minipage, so that title, note and thumbnails stay on the same page
    out.append('\\par\\addvspace{14pt}\\noindent\\begin{minipage}{\\textwidth}\n')
    out.append('{\\color{unipd}\\bfseries %s}%s\\par\\smallskip\n'
               % (e['title'], {'new': '\\nuova', 'moved': '\\spostata', 'split': '\\divisa'}.get(e.get('tag', ''), '')))
    out.append('{\\small %s}\\par\\smallskip\n' % e['note'])
    out.append('\\noindent\\begin{minipage}[t]{0.36\\textwidth}\\vspace{0pt}{\\scriptsize\\color{gray} Prima}\\par\n')
    if e['old']:
        for lab in e['old']:
            out.append('\\miniO{\\pgO{%s}}\\par\\smallskip\n' % lab)
    else:
        out.append('{\\small ---}\n')
    out.append('\\end{minipage}\\hfill\\begin{minipage}[t]{0.61\\textwidth}\\vspace{0pt}{\\scriptsize\\color{gray} Dopo}\\par\n')
    for lab in e['new']:
        out.append('\\mini{\\pg{%s}}\\par\\smallskip\n' % lab)
    out.append('\\end{minipage}\\par\n\\end{minipage}\\par\n')
for line in cfg.get('extra', []):
    out.append('\\par\\smallskip\\noindent ' + line + '\\par\n')

# ------------------------------------------------------------------ part B: outline
out.append('\\clearpage\n\\section*{Canovaccio: modifiche rispetto alla versione precedente}\n')
out.append(cfg['intro_canovaccio'] + '\n')
old_part_by_title = {p['title']: p for p in old_parts}
for b in new_seq:
    if b['kind'] == 'parte':
        op = old_part_by_title.get(b['title'])
        t = b['time']
        if op is None:
            title = add_run([b['title']])
        else:
            title = b['title']
            if op['time'] != t:
                t = '%s {\\color{red}\\barrato{%s}}' % (t, op['time'])
        out.append('\\parte{%s}{%s}\n' % (title, t))
        continue
    key = b['key']
    ob = old_blocks.get(key)
    title = b['title']
    tags = ''
    if ob is None:
        tags = '\\nuova'
    elif key in moved:
        tags = '\\spostata'
    time = b['time']
    if ob is not None and ob['time'] != b['time']:
        time = '%s {\\color{red}\\barrato{%s}}' % (b['time'], ob['time'] or '---')
    out.append('\\begin{%s}{%s}{%s%s}{%s}\n  \\begin{discorso}\n' % (b['env'], b['a1'], title, tags, time))
    rows = items_diff(ob['items'], b['items']) if ob else [add_run(TOK.findall(x)) for x in b['items']]
    for r in rows:
        out.append('    \\item ' + r + '\n')
    out.append('  \\end{discorso}\n\\end{%s}\n\n' % b['env'])
for k in old_order:
    if k not in {b['key'] for b in new_seq if b['kind'] == 'block'}:
        ob = old_blocks[k]
        out.append('\\par\\addvspace{10pt}\\noindent{\\color{red}\\bfseries Blocco tolto: %s}\\par\n' % ob['title'])
out.append('\\end{document}\n')
open(out_path, 'w').write(''.join(out))
print('blocks', len([b for b in new_seq if b['kind'] == 'block']), 'moved', sorted(moved),
      'new', [b['key'] for b in new_seq if b['kind'] == 'block' and b['key'] not in old_blocks])
