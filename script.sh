#!/usr/bin/env bash

#Su nuovo branch
# Copia tutti i file da una cartella A a una cartella B
# Uso: script.sh [-n|--dry-run] [-v|--verbose] SRC_DIR DEST_DIR
# Opzioni:
#   -n, --dry-run    : mostra cosa verrebbe copiato senza eseguire
#   -v, --verbose    : mostra i file mentre vengono copiati
#   -h, --help       : mostra questo aiuto

set -euo pipefail

DRY_RUN=0
VERBOSE=0

usage() {
	sed -n '1,200p' <<'USAGE'
Usage: script.sh [options] SRC_DIR DEST_DIR

Options:
	-n, --dry-run     Show actions without performing copy
	-v, --verbose     Print each copied file
	-h, --help        Show this help

Examples:
	./script.sh /path/to/src /path/to/dest
	./script.sh --dry-run -v ./a ./b
USAGE
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		-n|--dry-run)
			DRY_RUN=1; shift ;;
		-v|--verbose)
			VERBOSE=1; shift ;;
		-h|--help)
			usage; exit 0 ;;
		--) shift; break ;;
		-*)
			echo "Unknown option: $1" >&2; usage; exit 2 ;;
		*)
			break ;;
	esac
done

if [[ $# -ne 2 ]]; then
	echo "Error: serve SRC_DIR e DEST_DIR" >&2
	usage
	exit 2
fi

SRC_DIR=$1
DEST_DIR=$2

# Controlli di base
if [[ ! -d "$SRC_DIR" ]]; then
	echo "Error: SRC_DIR '$SRC_DIR' non esiste o non è una directory" >&2
	exit 3
fi

# Creiamo DEST_DIR se non esiste
if [[ ! -e "$DEST_DIR" ]]; then
	if [[ $DRY_RUN -eq 1 ]]; then
		echo "[DRY-RUN] Creazione directory di destinazione: $DEST_DIR"
	else
		mkdir -p "$DEST_DIR"
	fi
fi

# Usare rsync per copia robusta; mantiene permessi e gestisce ricorsività
RSYNC_OPTS=(--archive --delete --links)
if [[ $VERBOSE -eq 1 ]]; then
	RSYNC_OPTS+=(--verbose)
fi
if [[ $DRY_RUN -eq 1 ]]; then
	RSYNC_OPTS+=(--dry-run)
fi

# Assicuriamoci che i path finiscano con slash per copiare il contenuto di SRC_DIR
src_path="${SRC_DIR%/}/"
dest_path="${DEST_DIR%/}/"

echo "Copying from '$src_path' to '$dest_path'" >&2

rsync "${RSYNC_OPTS[@]}" "$src_path" "$dest_path"

exit 0
