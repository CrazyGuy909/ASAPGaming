CREATE TABLE s5618_asap_players.users (
    name VARCHAR(255),
    slug varchar(50),
    old_credits INT,
    donator_visual INT,
    donator_tier_inv VARCHAR(50),
    donator_tier INT,
    credits INT,
    steam_account_id VARCHAR(50) PRIMARY KEY,
    total_credits INT
);