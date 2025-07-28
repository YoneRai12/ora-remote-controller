import os
from pathlib import Path
from ..utils import proc_store

MC_KEY = "minecraft"

MC_JAR_PATH = os.getenv("MC_JAR_PATH", r"C:\\Users\\YoneRai12\\Downloads\\server.jar")


def start_server() -> None:
    jar = Path(MC_JAR_PATH)
    if not jar.exists():
        raise FileNotFoundError(f"Minecraft jar not found: {jar}")
    proc_store.store.start(MC_KEY, ["java", "-jar", str(jar), "nogui"], cwd=jar.parent)


def stop_server() -> None:
    proc_store.store.stop(MC_KEY)


def is_running() -> bool:
    return proc_store.store.is_running(MC_KEY)
