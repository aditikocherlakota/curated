from instagrapi import Client
import anthropic
import json
import os

USERNAME = os.environ["IG_USERNAME"]
PASSWORD = os.environ["IG_PASSWORD"]

cl = Client()

if os.path.exists("session.json"):
    cl.load_settings("session.json")
    cl.login(USERNAME, PASSWORD)
else:
    verification_code = input("Enter Instagram 2FA code: ")
    cl.login(USERNAME, PASSWORD, verification_code=verification_code)
    cl.dump_settings("session.json")

posts = cl.user_medias(cl.user_id, amount=50)
print(f"Pulled {len(posts)} posts")

post_data = []
for post in posts:
    post_data.append({
        "caption": post.caption_text or "",
        "likes": post.like_count,
        "media_type": str(post.media_type),
        "timestamp": str(post.taken_at),
    })

posts_summary = json.dumps(post_data, indent=2)

SAMPLE_VIBE = open("Resources/sample_vibe.md").read() if os.path.exists("Resources/sample_vibe.md") else ""

prompt = f"""You are analyzing a user's Instagram posts to build their personal taste profile.

Here are their recent Instagram posts (captions, likes, media type):
{posts_summary}

Generate a vibe.md file for this user in EXACTLY the same format and structure as the sample below.
Fill in all YAML fields based on patterns you observe in their captions, hashtags, and engagement.
Make confident inferences — don't leave fields empty or vague.
Use a unique vibe_id like usr_XXXX.

Sample format to follow:
{SAMPLE_VIBE}

Output only the vibe.md content, nothing else."""

print("Generating vibe profile...")
ai = anthropic.Anthropic()

with ai.messages.stream(
    model="claude-opus-4-8",
    max_tokens=4096,
    messages=[{"role": "user", "content": prompt}],
) as stream:
    vibe_content = stream.get_final_message().content[0].text

with open("vibe.md", "w") as f:
    f.write(vibe_content)

print("Saved vibe.md")