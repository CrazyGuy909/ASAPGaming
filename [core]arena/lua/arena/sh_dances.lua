-- Fortnite Dances
local dances = {
    --bestmates = {"Best Mates", "wos_fn_bestmates", 20, "asap_dances/bestmates.mp3"},
    --boneless = {"Boneless", "wos_fn_boneless", 18, "asap_dances/boneless.mp3"},
    --breakdown = {"Breakdown", "wos_fn_breakdown", 25, "asap_dances/breakdown.mp3"},
    --dancemoves = {"Dance Moves", "wos_fn_dancemoves", 50, "asap_dances/defaultdance.mp3"},
    --discofever = {"Disco Fever", "wos_fn_discofever", 30, "asap_dances/discofever.mp3"},
    --eagle = {"Eagle", "wos_fn_eagle", 35, "asap_dances/eagle.mp3"},
    --electroshuffle = {"Electro Shuffle", "wos_fn_electroshuffle", 37, "asap_dances/electricshuffle.mp3"},
    --flippinincredible = {"Flippin Incredible", "wos_fn_flippin_incredible", 29, "asap_dances/flippinincredible.mp3"},
    --flippinsexy = {"Flippin Sexy", "wos_fn_flipping_sexy", 40, "asap_dances/flippinsexy.mp3"},
    --floss = {"Floss", "wos_fn_floss", 45, "asap_dances/floss.mp3"},
    --fresh = {"Fresh", "wos_fn_fresh", 55, "asap_dances/fresh.mp3"},
    --gentlemandab = {"Gentleman Dab", "wos_fn_gentlemandab", 17, "asap_dances/gentlemansdab.mp3"},
    --groovejam = {"Groove Jam", "wos_fn_groovejam", 60, "asap_dances/groovejam.mp3"},
    --handsignals = {"Hand Signals", "wos_fn_handsignals", 12, "asap_dances/handsignals.mp3"},
    --hype = {"Hype", "wos_fn_hype", 60, "asap_dances/hype.mp3"},
    --infinidab = {"Infini Dab", "wos_fn_infinidab", 42, "asap_dances/infinidab.mp3"},
    --intensity = {"Intensity", "wos_fn_intensity", 70, "asap_dances/intensity.mp3"},
    --jubilation = {"Jubilation", "wos_fn_jubilation", 65, "asap_dances/jubilation.mp3"},
    --laughitup = {"Laugh It Up", "wos_fn_laughitup", 28, "asap_dances/laughitup.mp3"},
    --livinglarge = {"Living Large", "wos_fn_livinglarge", 75, "asap_dances/livinglarge.mp3"},
    --orangejustice = {"Orange Justice", "wos_fn_orangejustice", 100, "asap_dances/orangejustice.mp3"},
    --poplock = {"Pop Lock", "wos_fn_poplock", 80, "asap_dances/poplock.mp3"},
    --rambunctious = {"Rambunctious", "wos_fn_rambunctious", 90, "asap_dances/rambunctious.mp3"},
    --reanimated = {"Re-Animated", "wos_fn_reanimated", 68, "asap_dances/reanimated.mp3"},
    --starpower = {"Star Power", "wos_fn_starpower", 72, "asap_dances/starpower.mp3"},
    --swipeit = {"Swipe It", "wos_fn_swipeit", 82, "asap_dances/swipeit.mp3"},
    --takethel = {"Take The L", "wos_fn_takethel", 86, "asap_dances/takethel.mp3"},
    --trueheart = {"True Heart", "wos_fn_trueheart", 72, "asap_dances/trueheart.mp3"},
    --twist = {"Twist", "wos_fn_twist", 76, "asap_dances/twist.mp3"},
    --wiggle = {"Wiggle", "wos_fn_wiggle", 62, "asap_dances/wiggle.mp3"},
    --youreawesome = {"You're Awesome", "wos_fn_youreawesome", 85, "asap_dances/youreawesome.mp3"},
    --zany = {"Zany", "wos_fn_zany", 78, "asap_dances/zany.mp3"},
    -- Gmod Dances
    gmoddance = {"Gmod Dance", "taunt_dance_base", 25},
    robot = {"Robot", "taunt_robot_base", 30},
    noice = {"Noice", "pose_standing_04", 40},
    punch = {"Punch", "seq_throw", 60},
    force = {"Force", "idle_magic", 45},
    cheer = {"Yayyy!!", "taunt_cheer_base", 50},
    freak = {"Freak", "zombie_climb_loop", 75},
    flashed = {"Flashed", "seq_preskewer", 78},
    deathpp = {"Fake Death #1", "death_02", 80},
    fakedeath = {"Fake Death #2", "death_01", 90},
    rocket = {"Rocket", "drive_pd", 95},
    bigppdeath = {"Fake Death #3", "death_04", 100},
    viber = {"Just Vibing", "ragdoll", 125},
    laugh = {"Laugh", "taunt_laugh_base", 1},
    bow = {"Bow", "gesture_bow_original", 20},
    zombie = {"Zombie", "menu_zombie_01", 42},
    nonono = {"No No No", "gesture_disagree_original", 15},
    lionpose = {"Lion Pose", "taunt_persistence_base", 1},
    salute = {"Salute", "gesture_salute_original", 2},
    wave = {"Wave", "gesture_wave_original", 4},
    thumbsup = {"Thumbs Up", "gesture_agree_original", 5},
    sexydance = {"Sexy Dance", "taunt_muscle_base", 8}
}

asapArena.Taunts = {}

for k,v in pairs(dances) do
    if (!v[4]) then v[4] = "" end
    asapArena.Taunts[k] = {
        Name = v[1],
        Anim = v[2],
        Level = v[3] or 1,
        Sound = v[4]
    }
end