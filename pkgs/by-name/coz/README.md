[Source](https://github.com/ggerganov/llama.cpp)

Currently only the smallest net is installed. To install a new one you first 
need to download it with the following script:

```bash
#!/usr/bin/env bash
# UPDATE from Shawn (Mar 5 @ 2:43 AM)

PRESIGNED_URL="https://agi.gpt4.org/llama/LLaMA/*"

#MODEL_SIZE=${1:-7B,13B,30B,65B}  # edit this list with the model sizes you wish to download
MODEL_SIZE=${1:-7B}  # edit this list with the model sizes you wish to download
TARGET_FOLDER=${2:-./}           # where all files should end up

if [ $TARGET_FOLDER != "./" ]; then
    mkdir -p $TARGET_FOLDER
fi

declare -A N_SHARD_DICT

N_SHARD_DICT["7B"]="0"
N_SHARD_DICT["13B"]="1"
N_SHARD_DICT["30B"]="3"
N_SHARD_DICT["65B"]="7"

echo "Downloading tokenizer"
wget ${PRESIGNED_URL/'*'/"tokenizer.model"} -O ${TARGET_FOLDER}"/tokenizer.model"
wget ${PRESIGNED_URL/'*'/"tokenizer_checklist.chk"} -O ${TARGET_FOLDER}"/tokenizer_checklist.chk"

(cd ${TARGET_FOLDER} && md5sum -c tokenizer_checklist.chk)

for i in ${MODEL_SIZE//,/ }
do
    echo "Downloading ${i}"
    mkdir -p ${TARGET_FOLDER}"/${i}"
    for s in $(seq -f "0%g" 0 ${N_SHARD_DICT[$i]})
    do
        wget ${PRESIGNED_URL/'*'/"${i}/consolidated.${s}.pth"} -O ${TARGET_FOLDER}"/${i}/consolidated.${s}.pth"
    done
    wget ${PRESIGNED_URL/'*'/"${i}/params.json"} -O ${TARGET_FOLDER}"/${i}/params.json"
    wget ${PRESIGNED_URL/'*'/"${i}/checklist.chk"} -O ${TARGET_FOLDER}"/${i}/checklist.chk"
    echo "Checking checksums"
    (cd ${TARGET_FOLDER}"/${i}" && md5sum -c checklist.chk)
done
```

Next you need to convert the network into the ggml FP16 format with:
```bash
convert-pth-to-ggml models/7B/ 1
```

And finally it need to be quantiszed with
```bash
quantize 7B
```
