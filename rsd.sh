#!/bin/sh

## PRE-REQ: a `.envrc` with AWS credentials in homedir

git clone https://github.com/anjakefala/readysetdata.git 
apt install -y python3-pip zip

cd readysetdata
pip3 install -r requirements.txt
PYTHONPATH=. scripts/movielens.py -o output

OUTDIR=output/wp-infoboxes scripts/wikipages.sh

cd output/wp-infoboxes
zip ../wikipedia-infoboxes.zip *.jsonl

cd ~/readysetdata
# Install aws
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

cd ~
source env.list
cd readysetdata/output/

zip movielens.zip movielens*.jsonl
zip -n .arrow movielens.arrowz movielens*.arrow
zip -n .arrow movielens.arrowsz movielens*.arrows
zip movielens.parquetz movielens*.parquet


for fn in *.zip *z *.sqlite *.duckdb ; do
    aws s3 cp "$fn" "s3://data.saul.pw/$fn" --acl public-read
done
