import displayio
import time
import random
import terminalio
from adafruit_display_text import label

class ZombieShooterGame:
    def __init__(self, display, owned_pets=None):
        self.display = display
        self.owned_pets = owned_pets if owned_pets else []

        self.player_x = 120
        self.player_y = 120
        self.player_health = 100
        self.max_health = 100
        self.score = 0
        self.money = 0
        self.ammo = 30
        self.max_ammo = 50
        self.day = 1
        self.wave = 0
        self.wave_active = False
        self.is_night = False
        self.time_of_day = 0
        self.hunger = 100
        self.wood = 0
        self.metal = 0
        self.food = 5
        self.last_hunger = time.monotonic()
        self.last_spawn = time.monotonic()
        self.last_shot = 0

        self.recalculate_stats()

        self.game_over = False
        self.show_menu = False
        self.zombies = []
        self.bullets = []

        self.upgrade_costs = {"damage": 50, "fire_rate": 60}
        self.recipes = {"medkit": {"food": 3}, "ammo": {"metal": 2}, "barricade": {"wood": 5}}

        self.root_group = displayio.Group()
        self.bg_group = displayio.Group()
        self.player_group = displayio.Group()
        self.zombie_group = displayio.Group()
        self.bullet_group = displayio.Group()
        self.ui_group = displayio.Group()
        self.menu_group = displayio.Group()

        self.root_group.append(self.bg_group)
        self.root_group.append(self.zombie_group)
        self.root_group.append(self.player_group)
        self.root_group.append(self.bullet_group)
        self.root_group.append(self.ui_group)

        self.zombie_sprites = []
        self.bullet_sprites = []

        # Cache for label text
        self._last_hp_text = ""
        self._last_ammo_text = ""
        self._last_wave_text = ""

        # Pre-allocate menu background
        self.menu_bg_bmp = displayio.Bitmap(240, 240, 1)
        self.menu_bg_pal = displayio.Palette(1)
        self.menu_bg_pal[0] = 0x0a0a1a
        self.menu_bg_sprite = displayio.TileGrid(self.menu_bg_bmp, pixel_shader=self.menu_bg_pal)

        self._init_graphics()

    def recalculate_stats(self):
        self.pet_bonuses = self._calculate_pet_bonuses()
        self.damage = 1 + self.pet_bonuses.get("dmg", 0)
        self.fire_rate = 0.5 * self.pet_bonuses.get("rate_mult", 1.0)
        self.bullet_speed = 5
        self.move_speed = 3 + self.pet_bonuses.get("speed", 0)

    def _calculate_pet_bonuses(self):
        bonuses = {"dmg": 0, "rate_mult": 1.0, "speed": 0, "regen": 0}
        for pet in self.owned_pets:
            r = pet.get("rarity", "common")
            if r == "common": bonuses["speed"] += 0.1
            elif r == "uncommon": bonuses["dmg"] += 0.5
            elif r == "rare": bonuses["rate_mult"] *= 0.95
            elif r == "epic": bonuses["regen"] += 0.05
            elif r == "legendary": bonuses["dmg"] += 2
        return bonuses

    def _create_sprite(self, width, height, color, group):
        b = displayio.Bitmap(width, height, 1)
        p = displayio.Palette(1)
        p[0] = color
        s = displayio.TileGrid(b, pixel_shader=p)
        group.append(s)
        return s

    def _init_graphics(self):
        self.player_body = self._create_sprite(12, 8, 0x0066CC, self.player_group)
        self.player_head = self._create_sprite(8, 8, 0xFFAA88, self.player_group)
        self.player_gun = self._create_sprite(6, 3, 0x333333, self.player_group)

        for _ in range(15):
            s = self._create_sprite(12, 10, 0x00AA00, self.zombie_group)
            s.hidden = True
            self.zombie_sprites.append(s)

        for _ in range(15):
            s = self._create_sprite(3, 8, 0xFFFF00, self.bullet_group)
            s.hidden = True
            self.bullet_sprites.append(s)

        self.hp_label = label.Label(terminalio.FONT, text="HP: 100", color=0xFFFFFF, x=5, y=10)
        self.ui_group.append(self.hp_label)

        self.ammo_label = label.Label(terminalio.FONT, text="Ammo: 30", color=0xFFFF00, x=5, y=30)
        self.ui_group.append(self.ammo_label)

        self.wave_label = label.Label(terminalio.FONT, text="D:1", color=0xFF0000, x=150, y=10)
        self.ui_group.append(self.wave_label)

    def start_wave(self):
        self.wave += 1
        self.wave_active = True
        self.zombies_to_spawn = 5 + (self.wave * 3)

    def end_wave(self):
        self.wave_active = False
        self.day += 1
        self.wood += 5
        self.metal += 2
        self.food += 2
        self.last_spawn = time.monotonic()

    def spawn_zombie(self):
        if self.zombies_to_spawn <= 0: return
        pos = random.choice([(random.randint(10, 230), 10), (random.randint(10, 230), 230), (10, random.randint(10, 230)), (230, random.randint(10, 230))])
        self.zombies.append({"x": pos[0], "y": pos[1], "speed": 0.4 + (self.wave * 0.05), "health": 2 + (self.wave // 2), "worth": 5})
        self.zombies_to_spawn -= 1

    def render(self):
        if self.show_menu or self.game_over: return
        self.player_body.x, self.player_body.y = int(self.player_x - 6), int(self.player_y - 8)
        self.player_head.x, self.player_head.y = int(self.player_x - 4), int(self.player_y - 14)
        self.player_gun.x, self.player_gun.y = int(self.player_x + 4), int(self.player_y - 6)
        for i, s in enumerate(self.zombie_sprites):
            if i < len(self.zombies):
                z = self.zombies[i]
                s.hidden = False
                s.x, s.y = int(z["x"] - 6), int(z["y"] - 10)
            else: s.hidden = True
        for i, s in enumerate(self.bullet_sprites):
            if i < len(self.bullets):
                b = self.bullets[i]
                s.hidden = False
                s.x, s.y = int(b["x"] - 1), int(b["y"] - 4)
            else: s.hidden = True
        hp_text = f"HP: {int(self.player_health)}"
        if hp_text != self._last_hp_text: self.hp_label.text = hp_text; self._last_hp_text = hp_text
        ammo_text = f"Ammo: {self.ammo}"
        if ammo_text != self._last_ammo_text: self.ammo_label.text = ammo_text; self._last_ammo_text = ammo_text
        wave_text = f"W:{self.wave}" if self.wave_active else f"D:{self.day}"
        if wave_text != self._last_wave_text: self.wave_label.text = wave_text; self._last_wave_text = wave_text

    def update(self):
        if self.game_over or self.show_menu: return
        t = time.monotonic()
        if self.pet_bonuses["regen"] > 0: self.player_health = min(self.max_health, self.player_health + self.pet_bonuses["regen"]/60)
        if t - self.last_hunger > 10:
            self.hunger = max(0, self.hunger - 1)
            self.last_hunger = t
            if self.hunger == 0: self.player_health -= 0.5
        if self.player_health <= 0: self.game_over = True; self.show_game_over(); return
        for b in self.bullets[:]:
            b["x"] += b["dx"] * self.bullet_speed; b["y"] += b["dy"] * self.bullet_speed
            if not (0 < b["x"] < 240 and 0 < b["y"] < 240): self.bullets.remove(b)
        if not self.wave_active:
            if t - self.last_spawn > 5: self.start_wave(); self.last_spawn = t
            return
        if self.zombies_to_spawn > 0 and t - self.last_spawn > 1.0: self.spawn_zombie(); self.last_spawn = t
        for z in self.zombies[:]:
            dx, dy = self.player_x - z["x"], self.player_y - z["y"]
            dist = (dx**2 + dy**2)**0.5
            if dist > 5: z["x"] += (dx/dist) * z["speed"]; z["y"] += (dy/dist) * z["speed"]
            else: self.player_health -= 0.1
            for b in self.bullets[:]:
                if abs(b["x"] - z["x"]) < 10 and abs(b["y"] - z["y"]) < 10:
                    z["health"] -= self.damage
                    if b in self.bullets: self.bullets.remove(b)
                    if z["health"] <= 0:
                        self.money += z["worth"]; self.score += z["worth"]
                        if z in self.zombies: self.zombies.remove(z)
                    break
        if self.zombies_to_spawn == 0 and not self.zombies: self.end_wave()

    def shoot(self):
        if self.ammo <= 0 or self.show_menu or self.game_over: return
        t = time.monotonic()
        if t - self.last_shot > self.fire_rate:
            self.ammo -= 1; dx, dy = 0, -1
            if self.zombies:
                z = self.zombies[0]; ndx, ndy = z["x"] - self.player_x, z["y"] - self.player_y
                dist = (ndx**2 + ndy**2)**0.5
                if dist > 0: dx, dy = ndx/dist, ndy/dist
            self.bullets.append({"x": self.player_x, "y": self.player_y, "dx": dx, "dy": dy}); self.last_shot = t

    def show_game_over(self):
        while len(self.ui_group) > 0: self.ui_group.pop()
        self.ui_group.append(label.Label(terminalio.FONT, text="GAME OVER", color=0xFF0000, x=70, y=100, scale=2))
        self.ui_group.append(label.Label(terminalio.FONT, text=f"Score: {self.score}", color=0xFFFFFF, x=80, y=140))
        self.ui_group.append(label.Label(terminalio.FONT, text="Press A to Restart", color=0x00FF00, x=60, y=180))

    def toggle_menu(self):
        if self.game_over: return
        self.show_menu = not self.show_menu
        if self.show_menu: self.render_menu(); self.display.root_group = self.menu_group
        else: self.display.root_group = self.root_group

    def render_menu(self):
        while len(self.menu_group) > 0: self.menu_group.pop()
        self.menu_group.append(self.menu_bg_sprite)
        self.menu_group.append(label.Label(terminalio.FONT, text=f"SHOP M:{self.money}", color=0xFFFFFF, x=20, y=30))
        self.menu_group.append(label.Label(terminalio.FONT, text=f"[A] DMG (${self.upgrade_costs['damage']})", color=0x00FF00, x=10, y=60))
        self.menu_group.append(label.Label(terminalio.FONT, text=f"[Y] Rate (${self.upgrade_costs['fire_rate']})", color=0x00FF00, x=10, y=90))
        self.menu_group.append(label.Label(terminalio.FONT, text="[UP] Medkit (3 Food)", color=0x00FF00, x=10, y=120))
        self.menu_group.append(label.Label(terminalio.FONT, text="[DOWN] Ammo (2 Metal)", color=0x00FF00, x=10, y=150))
        self.menu_group.append(label.Label(terminalio.FONT, text="[X] Barricade (5 Wood)", color=0x00FF00, x=10, y=180))
        self.menu_group.append(label.Label(terminalio.FONT, text="Press B to Close", color=0x888888, x=10, y=210))

    def craft(self, k):
        r = self.recipes.get(k)
        if not r: return
        if all(getattr(self, res) >= amt for res, amt in r.items()):
            for res, amt in r.items(): setattr(self, res, getattr(self, res) - amt)
            if k == "medkit": self.player_health = min(self.max_health, self.player_health + 30)
            elif k == "ammo": self.ammo += 20
            self.render_menu()

    def buy_upgrade(self, k):
        c = self.upgrade_costs.get(k)
        if self.money >= c:
            self.money -= c
            if k == "damage": self.damage += 1
            elif k == "fire_rate": self.fire_rate = max(0.1, self.fire_rate * 0.9)
            self.upgrade_costs[k] = int(c * 1.5); self.render_menu()

    def move_up(self): self.player_y = max(15, self.player_y - self.move_speed)
    def move_down(self): self.player_y = min(225, self.player_y + self.move_speed)
    def move_left(self): self.player_x = max(15, self.player_x - self.move_speed)
    def move_right(self): self.player_x = min(225, self.player_x + self.move_speed)
    def restart(self): self.__init__(self.display, self.owned_pets)
