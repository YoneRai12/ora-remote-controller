from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from dotenv import load_dotenv
import os
from .services import mc, blender

load_dotenv()

API_KEY = os.getenv("API_KEY", "changeme")
security = HTTPBearer()
app = FastAPI()


def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    if credentials.credentials != API_KEY:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")


@app.get("/status", dependencies=[Depends(verify_token)])
def status_endpoint():
    return {
        "mc_running": mc.is_running(),
        "render_running": blender.is_running(),
    }


@app.post("/mc/start", dependencies=[Depends(verify_token)])
def mc_start():
    if mc.is_running():
        raise HTTPException(status_code=400, detail="MC already running")
    mc.start_server()
    return {"status": "starting"}


@app.post("/mc/stop", dependencies=[Depends(verify_token)])
def mc_stop():
    if not mc.is_running():
        raise HTTPException(status_code=400, detail="MC not running")
    mc.stop_server()
    return {"status": "stopping"}


@app.get("/mc/status", dependencies=[Depends(verify_token)])
def mc_status():
    return {"running": mc.is_running()}


@app.post("/render/start", dependencies=[Depends(verify_token)])
def render_start(blend_file: str, frame_start: int = blender.FRAME_START, frame_end: int = blender.FRAME_END):
    if blender.is_running():
        raise HTTPException(status_code=400, detail="Render already running")
    blender.start_render(blend_file, frame_start, frame_end)
    return {"status": "starting"}


@app.post("/render/stop", dependencies=[Depends(verify_token)])
def render_stop():
    if not blender.is_running():
        raise HTTPException(status_code=400, detail="Render not running")
    blender.stop_render()
    return {"status": "stopping"}


@app.get("/render/status", dependencies=[Depends(verify_token)])
def render_status():
    return {"running": blender.is_running()}


