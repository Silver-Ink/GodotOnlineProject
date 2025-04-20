from fastapi import FastAPI, Request
import subprocess
import json

app = FastAPI()

@app.post("/submit_score")
async def submit_score(request: Request):
    print("requete recue")
    body_bytes = await request.body()
    data = json.loads(body_bytes)
    
    if data["auth_ticket"] != "FAKE_TICKET":
        return {"status": "invalid_ticket"}

    with open("replay.json", "w") as f:
        json.dump(data, f)

    # result = subprocess.run(["godot", "--headless", "--path", ".", "--scene", "res://Server/server_replayer.tscn"], capture_output=True)
    result = subprocess.run(["../ServerExport/ServerValidator.exe", "--headless", "../server/replay.json"], capture_output=True)


    if result.returncode == 0:
        print("Simulation ok")
        return {"status": "valid"}
    else:
        return {"status": "invalid_simulation"}
