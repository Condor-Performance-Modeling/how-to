#! /bin/bash

set -e

if [[ -z "${TOP}" ]]; then
  { echo "TOP is undefined, execute 'source how-to/env/setuprc.sh'"; exit 1; }
fi

if [[ -z "${WHISPER_DIR}" ]]; then
{
  echo "-E: WHISPER_DIR is undefined, execute 'source how-to/env/setuprc.sh'";
  exit 1;
}
fi

source "$TOP/how-to/scripts/git_clone_retry.sh"

cd $TOP
mkdir -p exttools; cd exttools
# Boost - needed for Tenstorrent Whisper
clone_repository_with_retries "https://github.com/boostorg/boost.git" "boost" "--recursive"

# Whisper
cd $TOP

if ! [ -d "$WHISPER_DIR" ]; then
{
  echo "-W: whisper does not exist, cloning repo."
  clone_repository_with_retries "https://github.com/Condor-Performance-Modeling/tenstorrent-whisper.git" $WHISPER_DIR "--recursive"
}
fi

cd $WHISPER_DIR
make -j$(nproc)
cp build-Linux/whisper $TOOLS/bin
cd $TOP

