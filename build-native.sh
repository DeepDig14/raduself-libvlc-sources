#!/usr/bin/env bash
set -euo pipefail
bundle=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
inputs="$bundle/sources"
audit="$bundle/audit"
rebuild="${RADUSELF_REBUILD_DIR:-$HOME/raduself-libvlc-source-rebuild}"
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
if test -e "$rebuild"; then printf '%s\n' "Refuz: directorul exista deja: $rebuild" >&2; exit 1; fi
for tool in python3 patch x86_64-w64-mingw32-gcc x86_64-w64-mingw32-g++ taskset; do command -v "$tool" >/dev/null || { printf 'Lipseste: %s\n' "$tool" >&2; exit 1; }; done
compiler_info=$(x86_64-w64-mingw32-gcc -v 2>&1)
case "$compiler_info" in *'Thread model: win32'*) ;; *) printf '%s\n' 'Compilatorul selectat nu foloseste modelul win32. Oprire.' >&2; exit 1 ;; esac
case "$compiler_info" in *'gcc version 13'*) ;; *) printf '%s\n' 'Compilatorul selectat nu este GCC 13. Oprire.' >&2; exit 1 ;; esac
python3 - "$inputs" "$rebuild" <<'PY'
import sys,pathlib,hashlib,tarfile
inputs=pathlib.Path(sys.argv[1]);dest=pathlib.Path(sys.argv[2])
expected={'vlc-source-6de05adcba.tar.gz': 'b31069c1619fd5482fb67fbad62fe684454f26ffa328b74f80dc95bcfe0b4add', 'contrib-sources-and-rules.tar.gz': '1767e17f5caa5a1362746748ff603dde78ab66598ad9ee2ca14dedd351f3a6b8'}
for name,wanted in expected.items():
    h=hashlib.sha256()
    with (inputs/name).open('rb') as f:
        for block in iter(lambda:f.read(1048576),b''):h.update(block)
    if h.hexdigest()!=wanted:raise SystemExit('SHA256 diferit: '+name)
if not hasattr(tarfile,'data_filter'):raise SystemExit('Este necesar Python cu filtrul sigur tarfile.data_filter.')
dest.mkdir();(dest/'vlc').mkdir()
for name in expected:
    with tarfile.open(inputs/name) as t:t.extractall(dest/'vlc',filter='data')
(dest/'vlc/src/revision.txt').write_text('6de05adcbaf2e8b85fe86aad4169393098628119\n',encoding='ascii')
print('Sursele au fost verificate si extrase in',dest)
PY
cd "$rebuild/vlc"
patch --dry-run -p1 < "$inputs/vlc-local-changes.patch"
patch -p1 < "$inputs/vlc-local-changes.patch"
printf '%s\n' 'Incepe recompilarea intr-un arbore nou. Playerul instalat nu este modificat.'
env CONTRIBFLAGS="--disable-gpl --disable-gnuv3 --enable-ad-clauses" CONFIGFLAGS="--disable-live555" taskset -c 0-3 sh extras/package/win32/build.sh -a x86_64 -r -z -o "$rebuild/output" 2>&1 | tee "$rebuild/build.log"
runtime_dll=$(x86_64-w64-mingw32-gcc -print-file-name=libgcc_s_seh-1.dll)
python3 "$audit/select_candidate.py" "$rebuild/output" "$runtime_dll" "$rebuild/candidate-305"
printf '%s\n' "Recompilare terminata. Candidat separat: $rebuild/candidate-305" 'Playerul existent nu a fost inlocuit. Testele functionale urmeaza separat.'
