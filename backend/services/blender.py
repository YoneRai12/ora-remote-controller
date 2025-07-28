import os
from pathlib import Path
from ..utils import proc_store

RENDER_KEY = "blender"

BLENDER_EXE = os.getenv("BLENDER_EXE", r"C:\\Program Files\\Blender Foundation\\Blender 4.3\\blender.exe")
BLENDER_OUTPUT_DIR = os.getenv("BLENDER_OUTPUT_DIR", r"C:\\Users\\YoneRai12\\Renders\\Output")
FRAME_START = int(os.getenv("FRAME_START", "1"))
FRAME_END = int(os.getenv("FRAME_END", "250"))


def start_render(blend_file: str, frame_start: int = FRAME_START, frame_end: int = FRAME_END) -> None:
    exe = Path(BLENDER_EXE)
    if not exe.exists():
        raise FileNotFoundError(f"Blender not found: {exe}")
    output_dir = Path(BLENDER_OUTPUT_DIR)
    output_dir.mkdir(parents=True, exist_ok=True)
    args = [str(exe), "-b", blend_file, "-o", str(output_dir / "frame_#####"), "-s", str(frame_start), "-e", str(frame_end), "-a"]
    proc_store.store.start(RENDER_KEY, args)


def stop_render() -> None:
    proc_store.store.stop(RENDER_KEY)


def is_running() -> bool:
    return proc_store.store.is_running(RENDER_KEY)
