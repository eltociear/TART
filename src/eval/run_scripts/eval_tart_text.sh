#!/bin/bash

base_model_name="EleutherAI/gpt-neo-125m"
model_name_split=$(echo "$base_model_name" | awk -F/ '{print $NF}')

k_range=(18 32 48 64 128 256)
k_range_str=$(printf "[%s]" "$(printf ", %s" "${k_range[@]}" | cut -c3-)")

seeds=(42 69 128) 
seeds_str=$(printf "[%s]" "$(printf ", %s" "${seeds[@]}" | cut -c3-)")

 
path_to_reasoning_module="/u/scr/nlp/data/ic-fluffy-head-k-2/3e9724ed-5a49-4070-9b7d-4209a30e2392"
chkpt=(model_24000.pt)

run_id=$(echo "$path_to_reasoning_module" | awk -F/ '{print $NF}')

prefix=""

save_dir="./outputs" 
datasets=("rotten_tomatoes" "sst" "sms_spam" "ag_news_0" "dbpedia_14_0" "Wrench_youtube")
key="text"
n_dims=16
n_positions=258
num_pca_components=16
text_threshold=100
embed_type=("stream" "loo") # options: "stream" "loo" "vanilla"


data_path="/u/nlp/data/ic-nk/nlp_data_final/" # customize as needed

# customize as needed. this path is relative to where you will be calling the script from
path_to_script=./eval/eval_text.py

for dataset in "${datasets[@]}"
do
  for c_type in "${embed_type[@]}"
  do
    for c in "${chkpt[@]}"
    do
      python $path_to_script \
        --base_model_name=$base_model_name \
        --n_dims=$n_dims \
        --n_positions=$n_positions \
        --num_pca_components=$num_pca_components \
        --k_range="$k_range_str" \
        --seeds="$seeds_str" \
        --path_to_tart_inference_head="$path_to_reasoning_module/$c" \
        --dataset=$dataset \
        --key=$key \
        --save_dir=$save_dir \
        --text_threshold=$text_threshold \
        --embed_type=$c_type \
        --data_path=$data_path
    done
  done
done
