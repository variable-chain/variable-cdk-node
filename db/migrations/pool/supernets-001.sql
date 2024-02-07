-- +migrate Down
DROP TABLE IF EXISTS pool.acl CASCADE;
DROP TABLE IF EXISTS pool.policy CASCADE;

-- +migrate Up
CREATE TABLE IF NOT EXISTS pool.policy
(
    name VARCHAR PRIMARY KEY,
    allow BOOLEAN NOT NULL DEFAULT false
);

INSERT INTO pool.policy (name, allow) VALUES ('send_tx', false) ON CONFLICT (name) DO NOTHING;
INSERT INTO pool.policy (name, allow) VALUES ('deploy', false) ON CONFLICT (name) DO NOTHING;

CREATE TABLE IF NOT EXISTS pool.acl
(
    address VARCHAR,
    policy  VARCHAR,
    PRIMARY KEY (address, policy)
);