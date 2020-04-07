#!/bin/sh
echo "Reads,  ReadMerges, Writes, WriteMerges"
lastKnownReads=$(echo $statLine | cut -d ' ' -f 1)
lastKnownReadMerges=$(echo $statLine | cut -d ' ' -f 4)
lastKnownWrites=$(echo $statLine | cut -d ' ' -f 7)
lastKnownWriteMerges=$(echo $statLine | cut -d ' ' -f 9)
while [ 1 ]
do
	sleep 10
	statLine=$(vmstat -D | grep 'merged\|reads\|writes' | tr '\n' ' ' | sed -e 's/[[:space:]]\+/ /g')
	newReads=$(echo $statLine | cut -d ' ' -f 1)
	newReadMerges=$(echo $statLine | cut -d ' ' -f 4)
	newWrites=$(echo $statLine | cut -d ' ' -f 7)
	newWriteMerges=$(echo $statLine | cut -d ' ' -f 9)
	reads=$((newReads-lastKnownReads))
	readMerges=$((newReadMerges-lastKnownReadMerges))
	writes=$((newWrites - lastKnownWrites))
	writeMerges=$((newWriteMerges - lastKnownWriteMerges))
	lastKnownReads=$newReads
	lastKnownWrites=$newWrites	
	lastKnownReadMerges=$newReadMerges
	lastKnownWriteMerges=$newWriteMerges
	pad_reads=$((reads/10))
	pad_reads=$(echo "       ${pad_reads}" | grep -o '........$')
	pad_writes=$((writes/10))
	pad_writes=$( echo "        ${pad_writes}"  | grep -o '........$')
	pad_readMerges=$((readMerges/10))
	pad_readMerges=$( echo "         ${pad_readMerges}"  | grep -o '........$')
	pad_writeMerges=$((writeMerges/10))
	pad_writeMerges=$( echo "          ${pad_writeMerges}" | grep -o '........$')
	echo "$pad_reads, $pad_readMerges, $pad_writes, $pad_writeMerges"
done
