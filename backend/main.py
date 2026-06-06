from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import os
from dotenv import load_dotenv
load_dotenv(os.path.join(os.path.dirname(__file__), ".env"), override=True)

from instagram import pull_and_generate_vibe
from elevenlabs import create_session

app = FastAPI()

# In-memory store for now — swap for a DB later
vibe_store: dict[str, str] = {}

SESSIONS_DIR = os.path.join(os.path.dirname(__file__), "sessions")
os.makedirs(SESSIONS_DIR, exist_ok=True)


class GenerateVibeRequest(BaseModel):
    username: str
    password: str
    two_factor_code: str | None = None


class AgentSessionRequest(BaseModel):
    username: str


@app.post("/vibe/generate")
async def generate_vibe(req: GenerateVibeRequest):
    session_path = os.path.join(SESSIONS_DIR, f"{req.username}.json")
    try:
        vibe_md = pull_and_generate_vibe(
            username=req.username,
            password=req.password,
            session_path=session_path,
            two_factor_code=req.two_factor_code,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    vibe_store[req.username] = vibe_md
    return {"vibe_md": vibe_md}


@app.get("/vibe/{username}")
async def get_vibe(username: str):
    vibe_md = vibe_store.get(username)
    if not vibe_md:
        raise HTTPException(status_code=404, detail="No vibe profile found for this user")
    return {"vibe_md": vibe_md}


@app.post("/agent/session")
async def start_agent_session(req: AgentSessionRequest):
    vibe_md = vibe_store.get(req.username)
    if not vibe_md:
        raise HTTPException(status_code=404, detail="Generate a vibe profile first")
    try:
        session = await create_session(vibe_md)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    return session


@app.get("/agent/token")
async def get_agent_token():
    from elevenlabs import get_conversation_token
    try:
        token = await get_conversation_token()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    return {"token": token}
