import httpx
import os

ELEVENLABS_API_KEY = os.environ["ELEVENLABS_API_KEY"]
ELEVENLABS_AGENT_ID = os.environ["ELEVENLABS_AGENT_ID"]

BASE_MIRROR_PROMPT = """You are a talking mirror — a calm, direct, tasteful voice that reflects the user's aesthetic back to them.
You know their style, interests, and sensibility intimately because their taste profile is below.
Speak like a confident, warm friend with excellent taste. Never be sycophantic. Be brief and specific.

{vibe_md}"""

async def create_session(vibe_md: str) -> dict:
    system_prompt = BASE_MIRROR_PROMPT.format(vibe_md=vibe_md)

    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"https://api.elevenlabs.io/v1/convai/conversations",
            headers={"xi-api-key": ELEVENLABS_API_KEY},
            json={
                "agent_id": ELEVENLABS_AGENT_ID,
                "conversation_config_override": {
                    "agent": {
                        "prompt": {
                            "prompt": system_prompt,
                        }
                    }
                },
            },
        )
        response.raise_for_status()
        return response.json()
