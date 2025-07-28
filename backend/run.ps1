$env:$(Get-Content .env | ForEach-Object {$_})
uvicorn backend.main:app --host 0.0.0.0 --port 8000

