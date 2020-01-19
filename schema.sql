CREATE DATABASE point DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
use point;

CREATE TABLE point_trasaction (
    id binary(16) NOT NULL,
    userId binary(16) NOT NULL,
    eventType varchar(15) NOT NULL,
    eventId binary(16) NOT NULL,
    action varchar(10) NOT NULL,
    detailType varchar(20) NOT NULL,
    point int UNSIGNED NOT NULL,
    pointDiff tinyint UNSIGNED NOT NULL,
    createdAt datetime NOT NULL DEFAULT NOW(),
    PRIMARY KEY(id),
    INDEX idx_userId (userId),
    INDEX idx_event (eventType, eventId),
    INDEX idx_createdAt (createdAt),

) ENGINE=InnoDB DEFAULT CHARSET=utf8