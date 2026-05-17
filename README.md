# CPG — Campus do Programador Guerreiro

A 2D educational game built with **Godot 4** where a student navigates a school, talks to teachers, and battles through minigames themed around programming and computer science concepts.

---

## Gameplay Overview

The player explores two main areas:

- **Study Room** — interact with teachers to unlock minigames
- **Fight Room** — tower-defense arena where enemies attack the brain (base)

Talk to each teacher **twice** to trigger their minigame challenge. Completing minigames returns the player to the Study Room.

---

## Controls

| Action | Key |
|---|---|
| Move | Arrow Keys / WASD |
| Shoot (JudgmentHall) | Left Click |
| Pause | ESC |

---

## Teachers & Minigames

| Teacher | Minigame | Win Condition |
|---|---|---|
| **Soned** | Flap Bird | Survive as long as possible |
| **Jonas** | Dodge | 300 points |
| **Ynoguti** | Typing | 100 points |
| **Mosca** | Regex | 100 points |
| **Renzo** | Judgment Hall | Defeat Renzo (5 hits) |
| **Chris** | Brownie Quiz | Answer the math question correctly |

---

## Minigames

### Flap Bird
Keep the bird in the air by pressing any key to flap. Avoid obstacles. Hitting anything ends the game.

### Dodge (Jonas)
Items fall from the top of the screen. A prompt at the top tells you which **database type** to collect:

| Prompt | Collect |
|---|---|
| Banco Relacional | SQL (MySQL) |
| Banco Orientado a Grafos | Neo4j |
| Banco Orientado a Documentos | MongoDB |

- **Correct DB** → +30 points, prompt changes
- **Wrong DB** → -1 life
- **Bomb** → -1 life
- **300 points** → Victory, return to Study Room

Power-ups that also fall:
- Helmet — temporary shield against 1 hit
- Potion — +1 life (max 5)
- Speed boost — faster movement for 4s
- Glasses — slows all falling items for 5s

### Typing (Ynoguti)
Programming keywords fall from the top. Type the word before it reaches the bottom to score points. Missing words costs lives. Reach 100 points to win.

### Regex (Mosca)
Words scroll across the screen. Write a regex pattern and submit — every word it matches scores points. Words that escape without being matched cost lives. Reach 100 points to win.

### Judgment Hall (Renzo)
Boss fight. The player shoots lasers at Renzo. Each hit makes him teleport to a new platform. 5 hits defeat him. Falling items spawn as hazards. Score 300+ points to earn the victory screen.

### Brownie Quiz (Chris)
A question appears on screen. Type the correct numeric answer in the input bar and press Confirm (or Enter). The correct answer is **2**. A correct answer returns to the Study Room.

---

## Fight Room

A tower-defense arena the player can explore. Enemies (Integrais) spawn from 4 corners of the map every 3 seconds and march in a straight line toward the **Brain** (your base).

### Towers

| Tower | Fires toward | Triggers |
|---|---|---|
| Math Tower (Calc) | Bottom-left diagonal | Player nearby |
| PC Tower | Bottom-right diagonal | Player nearby |
| BoxOne | Top-left diagonal | Player nearby |
| BoxTwo | Top-right diagonal | Player nearby |

### Brain (Life)
- 100 HP, 10 damage per integral hit
- Plays a damage animation on each hit

---

## Project Structure

```
cpg/
├── Map/
│   ├── StudyRoom/      — main hub, teacher NPCs
│   └── FightRoom/      — tower defense arena
├── minigames/
│   ├── FlapBird/
│   ├── dodge/
│   ├── typing/
│   ├── regex/
│   ├── JudgmentHall/
│   └── brownie/
├── player/             — player character + laser shot
├── teacher/            — NPC teacher scripts and scenes
├── enemies/integral/   — enemy that attacks the brain
├── tower/              — tower shooters (calc, pc, box)
├── life/               — brain/base scene
├── screens/pause/      — ESC pause screen
└── dialog/             — dialogue box system
```

---

## Built With

- [Godot 4](https://godotengine.org/) — game engine
- GDScript — scripting language
