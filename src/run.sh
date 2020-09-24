#!/usr/bin/env bash
set -Ceu
#---------------------------------------------------------------------------
# 日本人の名字と名前のテーブルを作る。
# CreatedAt: 2020-09-24
#---------------------------------------------------------------------------
Run() {
	THIS="$(realpath "${BASH_SOURCE:-0}")"; HERE="$(dirname "$THIS")"; PARENT="$(dirname "$HERE")"; THIS_NAME="$(basename "$THIS")"; APP_ROOT="$PARENT";
	cd "$HERE"
	DB_PATH='Names.db'
	CreateTable() {
		for path in `ls -1 | grep .sql | sort`; do
			sqlite3 -batch -interactive "$DB_PATH" < "$path"
		done
#		sqlite3 -batch -interactive "$DB_PATH" 'select * from sqlite_master'
	}
	Import() {
		LastNames() {
			TSV="$(cat ./tsv/last/one_to_one_yk.tsv)"
			MAX_ID=$(($(echo -e "$TSV" | wc -l) - 1))
			paste <(eval echo {0..$MAX_ID} | tr ' ' '\n') <(echo -e "$TSV") > add_surnames.tsv
			paste <(eval echo {0..$MAX_ID} | tr ' ' '\n') <(echo -e "$TSV") | sqlite3 "$DB_PATH" '.mode tabs' '.import /dev/stdin LastNames'
		}
		FirstNames() {
			ID=0; BEGIN_ID=0; END_ID=-1;
			for SEX in m f c mc fc cm cf; do
				echo "$SEX"
				TSV="$(cat './tsv/first/'$SEX'.tsv')"
				BEGIN_ID=$((END_ID + 1))
				END_ID=$((BEGIN_ID + $(echo -e "$TSV" | wc -l) - 1))
				NUM=$((END_ID - BEGIN_ID))
				paste <(eval echo {$BEGIN_ID..$END_ID} | tr ' ' '\n') <(echo -e "$TSV") <(eval "printf ${SEX}\"%.s\n\" {0..$NUM}")  > "add_$SEX.tsv"
				paste <(eval echo {$BEGIN_ID..$END_ID} | tr ' ' '\n') <(echo -e "$TSV") <(eval "printf ${SEX}\"%.s\n\" {0..$NUM}") | \
				sqlite3 "$DB_PATH" '.mode tabs' '.import /dev/stdin FirstNames'
			done
		}
		LastNames
		FirstNames
		Vacuum() { sqlite3 -batch -interactive "$DB_PATH" 'vacuum'; }
		Vacuum
	}
	Examples() {
		sqlite3 -batch -interactive "$DB_PATH" \
			'.trace stdout' \
			'select count(*) from LastNames' \
			'select count(*) from FirstNames' \
			'select count(*) from FirstNames where sex="m"' \
			'select * from LastNames where Id in (select Id from LastNames order by random() limit 5)' \
			'select * from FirstNames where Id in (select Id from FirstNames where sex in ("m","mc","cm","c") order by random() limit 5);'
	}
	CreateTable
	Import
	Examples
}
Run "$@"
