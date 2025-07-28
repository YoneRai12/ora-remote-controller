import subprocess
from typing import Optional


class ProcStore:
    def __init__(self):
        self._procs: dict[str, subprocess.Popen] = {}

    def start(self, key: str, args: list[str], cwd: Optional[str] = None) -> None:
        if key in self._procs:
            raise RuntimeError(f"Process {key} already running")
        self._procs[key] = subprocess.Popen(args, cwd=cwd)

    def stop(self, key: str) -> None:
        proc = self._procs.get(key)
        if proc and proc.poll() is None:
            proc.terminate()
            try:
                proc.wait(timeout=10)
            except subprocess.TimeoutExpired:
                proc.kill()
        self._procs.pop(key, None)

    def is_running(self, key: str) -> bool:
        proc = self._procs.get(key)
        return proc is not None and proc.poll() is None


store = ProcStore()
