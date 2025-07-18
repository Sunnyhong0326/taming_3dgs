## Local Test Docker
```bash
xhost +local:docker

export HOME="/home/sunnyhong"
export CODE="$HOME/code/taming-3dgs"
export DATA="$HOME/data/colmap/GS_data"
export OUTPUT="$HOME/data/output/Taming3DGS"
docker run --rm -it --gpus all \
-e QT_XCB_GL_INTEGRATION=xcb_egl \
-e DISPLAY=:1 \
--shm-size 32gb \
-v $CODE:/app \
-v $DATA:/app/data \
-v $OUTPUT:/app/output \
taming_3dgs \
bash
```