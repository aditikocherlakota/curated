from instagrapi import Client
import anthropic
import httpx
import base64
import json
import os

SAMPLE_VIBE_PATH = os.path.join(os.path.dirname(__file__), "..", "Resources", "sample_vibe.md")
MAX_IMAGES = 20  # Claude API limit per request

def _load_sample_vibe() -> str:
    if os.path.exists(SAMPLE_VIBE_PATH):
        return open(SAMPLE_VIBE_PATH).read()
    return ""

def _fetch_image_b64(url: str) -> str | None:
    try:
        resp = httpx.get(url, timeout=10, follow_redirects=True)
        if resp.status_code == 200:
            return base64.b64encode(resp.content).decode()
    except Exception:
        pass
    return None

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
    print(f"Pulled {len(posts)} posts")

    # Build post metadata + download thumbnails for the first MAX_IMAGES posts
    post_data = []
    image_blocks = []  # interleaved image + caption content blocks

    for i, post in enumerate(posts):
        meta = {
            "caption": post.caption_text or "",
            "likes": post.like_count,
            "media_type": str(post.media_type),
            "timestamp": str(post.taken_at),
        }
        post_data.append(meta)

        if i < MAX_IMAGES:
            url = str(post.thumbnail_url) if post.thumbnail_url else None
            b64 = _fetch_image_b64(url) if url else None
            if b64:
                image_blocks.append({"type": "image", "source": {"type": "base64", "media_type": "image/jpeg", "data": b64}})
                image_blocks.append({"type": "text", "text": f"Post {i+1} — {meta['likes']} likes | {meta['caption']}"})

    sample_vibe = _load_sample_vibe()

    instructions = f"""You are analyzing a user's Instagram posts — both the images and captions — to build their personal taste profile.

The first {len(image_blocks) // 2} posts include the actual photos so you can analyze visual aesthetic, color palette, style, and subjects directly.
The full metadata for all {len(posts)} posts is below.

Post metadata (all posts):
{json.dumps(post_data, indent=2)}

Generate a vibe.md file in EXACTLY the same format and structure as the sample below.
Fill in all YAML fields based on what you observe visually in the photos AND in the captions/hashtags.
Pay special attention to: color palette (pull real hex values from the photos), aesthetic keywords, fashion silhouette, and the narrative sections.
Make confident inferences — don't leave fields empty or vague.
Use a unique vibe_id like usr_XXXX.

Sample format to follow:
{sample_vibe}

Output only the vibe.md content, nothing else."""

    # Build multimodal message: images first, then instructions
    content = image_blocks + [{"type": "text", "text": instructions}]

    ai = anthropic.Anthropic()
    with ai.messages.stream(
        model="claude-opus-4-8",
        max_tokens=4096,
        messages=[{"role": "user", "content": content}],
    ) as stream:
        return stream.get_final_message().content[0].text
