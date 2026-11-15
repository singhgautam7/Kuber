#!/usr/bin/env python3
"""Merges one l10n fragment into every ARB, then runs gen-l10n, under the
repo-wide agent lock (safe to run from several agents at once).

Fragment: {"en": {key: text}, "hi": {...}, "mr": {...}, ...}. Keys already in
the ARB are overwritten, new keys are appended. {x} placeholders become String
placeholders unless "@key" metadata is given in "en" (copied as is).
Usage: python3 tool/l10n_add.py specs/advanced-history-v1/l10n/<group>.json"""
import collections, fcntl, json, os, re, subprocess, sys
L = 'lib/l10n'
LANGS = 'hi mr bn pa ta te ml kn'.split()
def load(p): return json.load(open(p), object_pairs_hook=collections.OrderedDict)
def dump(p, o):
    with open(p, 'w') as f:
        json.dump(o, f, ensure_ascii=False, indent=2); f.write('\n')
frag = load(sys.argv[1])
os.makedirs('.dart_tool', exist_ok=True)
with open('.dart_tool/agent.lock', 'w') as lock:
    fcntl.flock(lock, fcntl.LOCK_EX)
    en = frag['en']
    arb = load(f'{L}/app_en.arb')
    for k, v in en.items():
        if k.startswith('@'):
            arb[k] = v; continue
        arb[k] = v
        ph = re.findall(r'\{(\w+)\}', v)
        if ph and '@' + k not in en:
            arb['@' + k] = {'placeholders': {p: {'type': 'String'} for p in dict.fromkeys(ph)}}
    dump(f'{L}/app_en.arb', arb)
    for lang in LANGS:
        tr = frag.get(lang, {})
        a = load(f'{L}/app_{lang}.arb')
        for k in en:
            if k.startswith('@'): continue
            a[k] = tr.get(k, en[k])
        dump(f'{L}/app_{lang}.arb', a)
    sys.exit(subprocess.call(['flutter', 'gen-l10n']))
