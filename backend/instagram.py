from instagrapi import Client
import anthropic
import json
import os

SAMPLE_VIBE_PATH = os.path.join(os.path.dirname(__file__), "..", "Resources", "sample_vibe.md")

def _load_sample_vibe() -> str:
    if os.path.exists(SAMPLE_VIBE_PATH):
        return open(SAMPLE_VIBE_PATH).read()
    return ""

def pull_and_generate_vibe(username: str, password: str, session_path: str, two_factor_code: str | None = None) -> str:
    cl = Client()

    if os.path.exists(session_path):
        cl.load_settings(session_path)
        cl.login(username, password)
    elif two_factor_code:
        cl.login(username, password, verification_code=two_factor_code)
        cl.dump_settings(session_path)
    else:
        raise ValueError("No saved session found. Provide a 2FA code to log in.")

    posts = cl.user_medias(cl.user_id, amount=50)

    post_data = [
        {
            "caption": post.caption_text or "",
            "likes": post.like_count,
            "media_type": str(post.media_type),
            "timestamp": str(post.taken_at),
        }
        for post in posts
    ]

    sample_vibe = _load_sample_vibe()

    prompt = f"""You are analyzing a user's Instagram posts to build their personal taste profile.

Here are their recent Instagram posts (captions, likes, media type):
{json.dumps(post_data, indent=2)}

Generate a vibe.md file for this user in EXACTLY the same format and structure as the sample below.
Fill in all YAML fields based on patterns you observe in their captions, hashtags, and engagement.
Make confident inferences — don't leave fields empty or vague.
Use a unique vibe_id like usr_XXXX.

Sample format to follow:
{sample_vibe}

Output only the vibe.md content, nothing else."""

    ai = anthropic.Anthropic()
    with ai.messages.stream(
        model="claude-opus-4-8",
        max_tokens=4096,
        messages=[{"role": "user", "content": prompt}],
    ) as stream:
        return stream.get_final_message().content[0].text
