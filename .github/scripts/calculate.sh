#!/bin/bash

#PSEUDO CODE IN HERE

fetch_bench_data() {
    aws api code that downloads bench metrics from redis
}

data=fetch_bench_data
Delays=[]
for each data.Transactions:
    submitTime = data.Tx.timestamp
    confirmationTIme = data.Tx.Block.timestamp
    TxDelay=confirmationTIme-submitTime
    Delays.append(TxDelay)

NETWORK_LATENCY=Delays.sum / Delays.length

BLOCKS=[(size,time)]


for each block in data.Blocks:
    size=data.block.size
    time=data.block.timestamp-data.previous_block.timestamp
    BLOCKS.append((size,time))

AVERAGE_BLOCK_SIZE=BLOCKS.SIZES.sum / BLOCKS.length
AVERAGE_BLOCK_TIME=BLOCKS.TIMES.sum / BLOCKS.length

TPS=AVERAGE_BLOCK_SIZE / AVERAGE_BLOCK_TIME

dump_data() {
    write data to json file
}


