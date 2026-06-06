# vibe.md

> The portable taste profile. Generated once from the user's Instagram Data Download (likes, saves, posts, follows, searches), refreshed on re-import. Everything the assistant says or recommends is filtered through this file. This is also the integration contract between the data half (which writes it) and the experience half (which reads it). Treat the `profile` block as the stable machine-readable interface; the narrative below is context for the LLM.

---

## profile (machine-readable, parse this)

```yaml
vibe_id: usr_8842
version: 1
generated_from: instagram_dyi_export
updated: 2026-06-06
one_liner: "Quiet-luxury minimalist with a vintage-workwear streak. Craft over logos, texture over flash, calm over loud."

aesthetic:
  keywords: [elevated minimalism, vintage workwear, warm neutrals, film grain, mid-century, wabi-sabi]
  color_palette: ["#1C1B1A", "#6B5E4E", "#A89B86", "#D9D2C5", "#3B4A3F"]
  avoid: [neon, fast-fashion logos, glossy maximalism, busy patterns]

fashion:
  silhouette: relaxed-but-structured
  fits: [straight-leg, slightly cropped, boxy outerwear, tucked-in tee]
  loved_brands: [Our Legacy, Lemaire, Carhartt WIP, Vintage Levi's, New Balance 990, Margaret Howell]
  avoided_brands: [logo-forward streetwear, ultra-fast-fashion]
  materials: [raw denim, waxed canvas, fine merino, leather that ages, brushed cotton]
  footwear_bias: [worn-in leather boots, low-key sneakers, no flashy soles]
  accessories: minimal, one good watch, no statement jewelry

interests: [film photography, specialty coffee, mid-century furniture, ambient and jazz, slow travel, ceramics, cooking]
food:
  loves: [omakase, natural wine, third-wave coffee, regional Southeast Asian, handmade pasta]
  avoids: [chain dining, sweet cocktails, over-styled brunch spots]
  ordering_style: adventurous but not for the photo

travel:
  style: slow, neighborhood-deep, few destinations per trip
  pace: unhurried, mornings for walking and coffee, no packed checklists
  lodging: design-led small hotels or well-chosen apartments, not resorts
  loved_destinations: [Kyoto, Lisbon, Mexico City, Hanoi, Copenhagen]
  seeks: [independent shops, film labs, quiet viewpoints, local craft, good coffee within walking distance]
  avoids: [tour groups, landmark-only itineraries, party districts]

music: [ambient, modal jazz, lo-fi house, 70s folk]

values: [craft, authenticity, longevity over novelty, understatement, supporting independents]

personality:
  tone: dry, warm under the surface, allergic to hype
  humor: deadpan
  decisiveness: high on aesthetics, slower on logistics
  social_energy: small groups over crowds

communication_prefs:
  assistant_voice: calm, direct, a little wry; speaks like a tasteful friend, not a salesperson
  address_as: first name, casual
  avoid: [exclamation-heavy hype, generic influencer-speak, over-explaining, flattery]
  brevity: prefers short, confident answers with a reason

engagement_signals:
  most_liked_categories: [menswear fits, interior design, travel film photography, coffee, food]
  most_saved: [outfit grids, neighborhood travel guides, recipes, furniture]
  follows_archetypes: [independent designers, film photographers, chefs, small-hotel accounts, vintage sellers]
  recurring_hashtags: ["#filmphotography", "#menswear", "#specialtycoffee", "#midcenturymodern", "#slowtravel"]
  rarely_engages: [celebrity gossip, fitness challenges, crypto, dance trends]

anti_vibe: [trend-chasing, logomania, anything that tries too hard, mass tourism, hustle aesthetics]

confidence_by_domain:
  fashion: high
  food: high
  travel: medium
  interiors: medium
```

---

## Narrative (context for the model)

### Aesthetic and visual taste
The user gravitates to restraint. Warm neutrals, natural light, texture you want to touch, a little wear and patina. They like things that look better after five years than on day one. When they save an image, it is usually for the composition or the materials, not the brand. Film grain over HDR. Beige and olive and charcoal over anything bright.

### Fashion and how they dress
Relaxed shapes with enough structure to look intentional. Straight or slightly cropped trousers, a boxy jacket, a plain tee tucked in, worn leather boots. Quality fabrics that age well. They will pay for one good piece and skip ten cheap ones. Logos are a turn-off. When judging an outfit or an item, weigh fit, material, and whether it ages, not whether it is trendy this season.

### What they are drawn to, and what they reject
Drawn to: craft, independents, things with a story, understatement. Rejected: hype drops, fast fashion, anything loud for the sake of being seen. If a recommendation feels like it is chasing a trend, it is wrong for this person.

### Travel
Slow and deep. They would rather know three neighborhoods well than see twelve landmarks. Mornings are for walking and coffee. They want film labs, independent shops, quiet viewpoints, and a great espresso within walking distance of where they sleep. Resorts and tour groups are a hard no. Kyoto and Lisbon are reference points for the feeling they chase.

### Food and drink
Specialty coffee daily, natural wine over cocktails, regional and honest over styled and viral. Happy to eat somewhere with no English menu. Unhappy at a chain or an Instagram-bait brunch spot.

### How to talk to them
Calm, direct, a little dry. Like a friend with good taste who respects their time. Short answers with one clear reason beat long hype. Never flatter, never sell, never use three exclamation points. If they sound rushed or unsure (the emotion layer will tell you), get more concise and decisive, not chattier.

### Engagement fingerprint (their "algorithm")
What they like and save clusters tightly: menswear fits, mid-century interiors, travel shot on film, coffee, food. They follow makers and small accounts, not celebrities. They almost never engage with gossip, fitness challenges, crypto, or dance trends. Use this to weight recommendations: when in doubt, choose the option a thoughtful independent maker would choose.
